# CLAUDE.md — स्मृति/smriti Sticky Notes App

## What this is
A self-contained sticky notes web app with a warm ruled-notebook aesthetic.
Single `index.html` — no server, no build step, no npm. Opens via Chrome `--app=` mode.
Menu bar app (`smriti-bar`) launches/focuses the panel from the macOS menu bar.

---

## File Structure

```
smriti/
├── index.html          ← Entire app: HTML + CSS + JS (all-in-one, intentional)
├── smriti-bar.swift    ← macOS menu bar app (Swift, NSStatusItem)
├── smriti-bar          ← Compiled binary (do NOT commit changes to this directly)
├── smriti-bar.plist    ← LaunchAgent plist for auto-start at login
├── build-smriti-bar.sh ← Compiles swift → binary, installs LaunchAgent
├── open-smriti.sh      ← Opens index.html in Chrome app mode (682×530)
├── app.js              ← (stub, logic lives in index.html)
├── storage.js          ← (stub, logic lives in index.html)
├── style.css           ← (stub, styles live in index.html)
└── timer.js            ← (stub, logic lives in index.html)
```

**All live code is in `index.html`.** The `.js` and `.css` files are stubs/unused — do not move code into them.

---

## Architecture (inside index.html)

### CSS (lines ~14–1500)
- `:root` — global CSS vars: `--ink`, `--ink-mid`, `--ink-faint`, `--ink-ghost`, `--bg`, `--accent`, `--line-color`, `--task-font`
- `.dark-tab` — ink overrides for dark-background palettes (currently only Paper/white triggers `dark:false`)
- Page styles: `.ps-ruled`, `.ps-graph-fine`, `.ps-graph-large`, `.ps-dot`, `.ps-wide`, `.ps-blank`
- Font: Ubuntu Mono (`--task-font`), Ubuntu (`--sans`)

### JS Constants (lines ~1648–1660)
```js
const PALETTES = [
  { name, bg, lineColor, accent, swatchBg?, dark? },
  ...
]
```
- 9 palettes: Cream, Rose, Sage, Lavender, Sky, Terra, Slate, Honey, Paper
- `swatchBg` — bubble display color (used when different from accent, e.g. Paper white)
- `dark` — if true, applies `.dark-tab` CSS class for ink color overrides
- **Night (black) palette was removed** — too many UI visibility issues across all modes

### Data Model (localStorage key: `stickies_v2`)
```js
{
  activeTab: "tab-uuid",
  order: ["tab-uuid", ...],
  tabs: {
    "tab-uuid": {
      label, bg, lineColor, accent, pageStyle,
      lineAlphaScale,   // 0.5–1.5 line density slider value
      dark,             // boolean, set when palette selected
      tasks: [{ id, text, done, createdAt, timerMode, timerDurationMs, timerStartedAt, dueAt, priority, photo, audio }]
    }
  }
}
```

### Key Functions
- `render()` — rebuilds tab view. Applies `--bg`, `--accent`, `--line-color` CSS vars. Toggles `.dark-tab`.
- `buildGridView()` — builds grid mode. Same CSS var application per panel. Calls `buildPalette()` per panel.
- `buildPalette()` — renders palette swatches in tab view toolbar. Uses `p.swatchBg ?? p.accent` for bubble color.
- `scaleRgbaAlpha(rgba, scale)` — scales alpha of rgba string for line density
- `lineColorRGB(tab)` — extracts `"r,g,b"` from `tab.lineColor` for gradient bars
- `saveData()` / `loadData()` — localStorage read/write
- `makeTask(text)` — creates new task object with UUID and `createdAt`

### Line Density
- Slider range: 0.5 (faint) → 1.5 (bold)
- Default tab view: `tab.lineAlphaScale ?? 1.0` (mid)
- Default grid view: `tab.lineAlphaScale ?? 1.5` (max)
- Not persisted until user drags slider

---

## UI Details

### Tab View
- Left margin red line (`#notebook::before`) — decorative, `--margin-ln` var
- Ruled/grid/dot background pattern driven by `.ps-*` class on `#notebook`
- Add-task input: `#new-task-input` — brick red blinking caret (`caret-color: #c1440e`)
- Completed section: dark green `#1a5c2a`, 0.702rem, `> ◌/◉ Completed (N)` toggle

### Grid View
- Each tab = `.grid-panel` with same CSS vars as tab view
- `.grid-add-row` at bottom of each panel — "+ add task" input
- Palette swatches per panel: `.grid-swatch`
- Task delete: `.grid-task-del` — red ✕, always visible at `opacity: 0.45`

### Task Delete (✕)
- **Always visible** at `opacity: 0.45`, full `opacity: 1` on hover
- Applies in BOTH tab view (`.task-del`) and grid view (`.grid-task-del`)

### Branding
- Header: `स्मृति/smriti` in Ubuntu Mono
- Byline: `by Rithvik Javgal` in dark green `#1a5c2a`

---

## Menu Bar App (smriti-bar.swift)

- Detects macOS light/dark mode via `NSApp.effectiveAppearance`
- Rebuilds icon on `AppleInterfaceThemeChangedNotification`
- Light mode: near-black text (`white: 0.12`). Dark mode: near-white (`white: 1.0`).
- Left click → focus/launch app. Right click → Quit menu.
- Launches via `open-smriti.sh` which opens Chrome in `--app=` mode

### Build & Install
```bash
cd /Users/rjavgal/stickies
bash build-smriti-bar.sh
```

### Launch app manually
```bash
bash open-smriti.sh
```
Window size: 782×612. Position: 367,45 (matched to Rithvik's actual running window, 2026-07-26).

---

## Rules for Claude

1. **All code changes go in `index.html`** — do not create separate JS/CSS files
2. **After every change: hard-refresh Chrome** via AppleScript reload + Cmd+Shift+R
3. **Test in both tab view and grid view** — palette/color changes affect both
4. **Palette changes**: update PALETTES array + both `buildPalette()` and `buildGridView()` swatch renderers
5. **Dark palette support**: set `dark: true` on palette entry → `.dark-tab` class applied → ink vars override
6. **Night (black) palette is removed** — do not re-add without solving all dark-mode UI visibility issues first
7. **Red ✕ always visible** (`opacity: 0.45`) — never set to `opacity: 0` (hidden until hover)
8. **Menu bar changes** require recompile: `bash build-smriti-bar.sh`
9. **No npm, no build, no server** — this is a local file://  app, keep it that way

---

## Known Limitations / Future Work
- Phase 2: Voice input (`SpeechRecognition` API) — mic button scaffolded, logic pending
- Phase 3: Native app sync (Google Tasks API / CloudKit JS) — schema ready, not implemented
- Dark theme: `.dark-tab` CSS exists but Night bubble removed due to widespread UI issues. Needs full audit before re-enabling.
