# स्मृति / smriti

**A personal notepad that lives in a single HTML file.**

No server. No cloud. No account. No subscription. No tracking. No internet required.  
Just a file on your machine that remembers things — and looks good doing it.

---

> *"smriti"* (स्मृति) — Sanskrit for **memory**.

---

## Screenshots

<!-- Screenshot 1: Grid view — both panels side by side, dot grid, ubuntu mono -->
![smriti grid view](screenshots/grid-view.png)

<!-- Screenshot 2: Tab view — single panel, ruled, warm cream background -->
![smriti tab view](screenshots/tab-view.png)

---

## Why smriti?

Every notes app eventually wants something from you.

Notion wants a login. Apple Notes wants iCloud. Obsidian wants a plugin ecosystem. Bear wants $2.99/month.

smriti wants nothing. It's a file. Open it. Write things. Close it. That's the whole product.

It also looks like a notebook.

---

## Features

**2–4 tabs**, each with its own name, color palette, and page style. Switch between **Grid view** (all tabs side by side) or **Tab view** (one at a time). Tab names are editable — click and type.

---

### Colors

Nine warm palettes — Cream, Rose, Sage, Lavender, Sky, Terra, Slate, Honey, Paper. Pick one per tab. Background, line color, and accent all shift together.

### Page styles

| Style | |
|---|---|
| **Ruled** | Classic horizontal lines |
| **Graph (fine)** | Dense 10px grid |
| **Graph (large)** | Spacious 25px grid |
| **Dot grid** | The Leuchtturm1917 of digital notebooks |
| **Blank** | Pure color. Occasionally peaceful. |

### Per-task options

- **Priority** — flag a task as high priority
- **Countdown timer** — set a duration. Turns yellow when close, red when gone, pulses at zero
- **Deadline** — pick a date and time. Same urgency coloring.
- **Photo** — drag or paste an image directly onto a task
- **Voice note** — tap 🎙, say the thing, done. Plays back inline.

### Completed tasks

Tick a task to complete it. It slides to a **Completed** section at the bottom. Restore it anytime. Delete permanently when you're ready.

### Fonts

Eight options. The default is Ubuntu Mono.

### Private by design

No server. No account. No tracking. Your notes live in your browser's `localStorage` — on your machine, invisible to everyone else. Works offline, always. Nothing leaves without you knowing.

---

## Privacy

smriti is structurally private. There is no server to send your data to.

- **100% offline** — works without an internet connection, always
- **No cloud, no sync, no accounts** — nothing leaves your machine
- **No tracking, no analytics, no cookies, no telemetry** — zero
- **Your notes live only in your browser's localStorage** — invisible to everyone else
- **The entire app is one HTML file** — open source, nothing hidden

Your data is yours. Not "yours, stored on our servers." Yours.

---

## Getting started

### Option 1 — Just open it

Download `smriti.html`. Open it in Chrome or Safari. Done.

No install. No setup. No terminal. No npm. Nothing.

### Option 2 — Menu bar app (macOS)

For the full experience: a permanent ☀ smriti button in your macOS menu bar.

```bash
git clone https://github.com/rithviksj/smriti
cd smriti
bash build-smriti-bar.sh
```

This compiles a tiny Swift menu bar helper and installs a LaunchAgent so it starts at login.  
Click ☀ स्मृति/smriti in the menu bar to open/focus the panel. Right-click to quit.

### Option 3 — Localhost mode

For mic permissions to persist across sessions (Chrome requires a non-`file://` origin for mic access):

```bash
bash open-smriti.sh
```

Spins up a local HTTP server on port 7842 and opens smriti in Chrome app mode — no address bar, no tabs, just the app. Feels native.

---

## Data

Everything saves automatically to `localStorage` under the key `smriti_v2`.

To **back up**: open DevTools → Application → Local Storage → export the value. Or just copy the HTML file; the data lives in the browser, not the file.

To **move to another machine**: export localStorage, import it on the other machine. A one-time manual step. This is a feature, not a bug — your notes never leave without you knowing.

To **reset**: `localStorage.clear()` in the DevTools console, then reload.

---

## Tech stack

| Layer | What |
|---|---|
| HTML/CSS/JS | All inline in one file. Zero dependencies. |
| Storage | `localStorage` — browser-native, no library |
| Fonts | Google Fonts (Ubuntu Mono, Ubuntu) — loaded once, cached |
| Icons | None — everything is Unicode or hand-drawn SVG |
| Build step | None |
| Server | None |
| Framework | None |
| Complexity | Minimal, intentional |

---

## License

MIT License — Copyright © 2026 Rithvik Javgal

You are free to use, copy, modify, and distribute this software.  
You must keep the copyright notice and this license in all copies or substantial portions.

Full text: [LICENSE](LICENSE)

---

## Author

**Rithvik Javgal**  
[rithviksj@gmail.com](mailto:rithviksj@gmail.com)  
[bihag.vercel.app](https://bihag.vercel.app) — the other thing I made

---

*Built because every other notes app eventually wanted something from me.*
