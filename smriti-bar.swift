import Cocoa
import WebKit

class SmritiBar: NSObject, NSApplicationDelegate, NSWindowDelegate, WKUIDelegate {
    var statusItem: NSStatusItem!
    var panel: NSPanel!
    var webView: WKWebView!

    // ── Lifecycle ─────────────────────────────────────────────────

    func applicationDidFinishLaunching(_ n: Notification) {
        setupMenuBar()
        setupPanel()
        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(themeChanged),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil)
    }

    // ── Menu Bar ──────────────────────────────────────────────────

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusItem.button {
            btn.image = makeGlowImage()
            btn.toolTip = "स्मृति"
            btn.target = self
            btn.action = #selector(handleClick(_:))
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func themeChanged() { statusItem.button?.image = makeGlowImage() }

    func isDarkMode() -> Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
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
            .foregroundColor: dark
                ? NSColor(white: 1.0, alpha: 0.92)
                : NSColor(white: 0.12, alpha: 0.88),
            .font: NSFont.systemFont(ofSize: 12, weight: .medium)
        ]
        let full = NSMutableAttributedString()
        full.append(NSAttributedString(string: "☀ ", attributes: sunAttrs))
        full.append(NSAttributedString(string: "स्मृति/smriti", attributes: labelAttrs))
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
            togglePanel()
        }
    }

    // ── Floating Panel ────────────────────────────────────────────

    func setupPanel() {
        let w: CGFloat = 782, h: CGFloat = 612
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let sf = screen.visibleFrame
        let origin = NSPoint(x: 367, y: sf.maxY - 45 - h)

        panel = NSPanel(
            contentRect: NSRect(origin: origin, size: NSSize(width: w, height: h)),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false)
        panel.level = .floating          // always on top of normal windows
        panel.hidesOnDeactivate = false  // stays visible when another app is focused
        panel.isReleasedWhenClosed = false
        panel.title = "स्मृति / smriti"
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.delegate = self

        let cfg = WKWebViewConfiguration()
        cfg.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: .zero, configuration: cfg)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        let cv = panel.contentView!
        cv.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
            webView.topAnchor.constraint(equalTo: cv.topAnchor),
            webView.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
        ])

        loadContent()
        panel.makeKeyAndOrderFront(nil)
    }

    func loadContent() {
        let dir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
        let html = dir.appendingPathComponent("smriti.html")
        webView.loadFileURL(html, allowingReadAccessTo: dir)
    }

    @objc func togglePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.makeKeyAndOrderFront(nil)
        }
    }

    // Red close button hides the panel instead of destroying it
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    // ── Mic permission ────────────────────────────────────────────

    @available(macOS 12.0, *)
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    @objc func quitApp() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let bar = SmritiBar()
app.delegate = bar
app.run()
