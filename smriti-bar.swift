import Cocoa

class SmritiBar: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func smritiPID() -> Int32? {
        let t = Process()
        t.executableURL = URL(fileURLWithPath: "/bin/bash")
        t.arguments = ["-c", "pgrep -f 'smriti/smriti.html' | head -1"]
        let pipe = Pipe()
        t.standardOutput = pipe
        try? t.run()
        t.waitUntilExit()
        let str = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return Int32(str)
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusItem.button {
            btn.title = ""
            btn.image = makeGlowImage()
            btn.toolTip = "स्मृति"
            btn.target = self
            btn.action = #selector(handleClick(_:))
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Observe system light/dark mode changes
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(themeChanged),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    @objc func themeChanged() {
        statusItem.button?.image = makeGlowImage()
    }

    func isDarkMode() -> Bool {
        return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    func makeGlowImage() -> NSImage {
        let dark = isDarkMode()

        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 1.0, green: 0.70, blue: 0.0, alpha: dark ? 0.85 : 0.5)
        shadow.shadowBlurRadius = dark ? 4.5 : 2.5
        shadow.shadowOffset = .zero

        let sunAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0),
            .font: NSFont.systemFont(ofSize: 16, weight: .medium),
            .shadow: shadow
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            // Light mode: near-black for contrast. Dark mode: near-white.
            .foregroundColor: dark
                ? NSColor(white: 1.0, alpha: 0.92)
                : NSColor(white: 0.12, alpha: 0.88),
            .font: NSFont.systemFont(ofSize: 12, weight: .medium)
        ]

        let sunStr = NSAttributedString(string: "☀ ", attributes: sunAttrs)
        let labelStr = NSAttributedString(string: "स्मृति/smriti", attributes: labelAttrs)
        let full = NSMutableAttributedString()
        full.append(sunStr)
        full.append(labelStr)

        let strSize = full.size()
        let canvas = NSSize(width: strSize.width + 10, height: 22)

        let img = NSImage(size: canvas, flipped: false) { _ in
            full.draw(at: NSPoint(x: 4, y: (canvas.height - strSize.height) / 2))
            return true
        }
        img.isTemplate = false
        return img
    }

    @objc func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            let m = NSMenu()
            let qi = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
            qi.target = self
            m.addItem(qi)
            statusItem.menu = m
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            openApp()
        }
    }

    func windowCount(pid: Int32) -> Int {
        let s = NSAppleScript(source: """
            tell application "System Events"
                try
                    tell (first process whose unix id is \(pid))
                        return count of windows
                    end tell
                on error
                    return 0
                end try
            end tell
        """)
        var err: NSDictionary?
        let result = s?.executeAndReturnError(&err)
        return Int(result?.int32Value ?? 0)
    }

    func killPID(_ pid: Int32) {
        let t = Process()
        t.executableURL = URL(fileURLWithPath: "/bin/kill")
        t.arguments = ["-9", String(pid)]
        try? t.run()
        t.waitUntilExit()
    }

    func launchFresh() {
        let script = scriptPath()
        let t = Process()
        t.executableURL = URL(fileURLWithPath: "/bin/bash")
        t.arguments = [script]
        try? t.run()
    }

    @objc func openApp() {
        if let pid = smritiPID(), pid > 0 {
            if windowCount(pid: pid) > 0 {
                if let app = NSWorkspace.shared.runningApplications.first(where: { $0.processIdentifier == pid }) {
                    app.activate(options: .activateIgnoringOtherApps)
                }
                appleScript("""
                    tell application "System Events"
                        tell (first process whose unix id is \(pid))
                            set frontmost to true
                            perform action "AXRaise" of window 1
                        end tell
                    end tell
                """)
            } else {
                killPID(pid)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.launchFresh()
                }
            }
        } else {
            launchFresh()
        }
    }

    @objc func quitApp() { NSApp.terminate(nil) }

    func scriptPath() -> String {
        let exe = CommandLine.arguments[0]
        let dir = (exe as NSString).deletingLastPathComponent
        return "\(dir)/open-smriti.sh"
    }

    func appleScript(_ src: String) {
        let s = NSAppleScript(source: src)
        var err: NSDictionary?
        s?.executeAndReturnError(&err)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let bar = SmritiBar()
app.delegate = bar
app.run()
