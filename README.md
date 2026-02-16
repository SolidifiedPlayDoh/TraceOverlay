# Trace Overlay

A minimal **macOS menu bar app** that shows a full-screen transparent overlay so you can trace an image in your favorite drawing app. Move, resize, and rotate the reference image, then **lock** it for click-through and draw underneath.

No window chrome — everything is controlled from the **menu bar icon** (▼).

![macOS 10.13+](https://img.shields.io/badge/macOS-10.13+-blue) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Download

**Recommended:** Get the latest release from the [Releases](../../releases) page. Download `TraceOverlay-macOS.zip`, unzip, and drag **Trace Overlay.app** to your Applications folder (or run it from anywhere).

---

## Features

- **Full-screen overlay** — One reference image, always on top
- **Move, zoom, rotate** — Drag to move, scroll to zoom, **Option + drag** to rotate
- **Lock for tracing** — Lock turns the overlay into click-through so you can use your drawing app underneath while the image stays visible
- **Opacity** — 30%, 50%, 70%, or 100%
- **Drag & drop** — Drop an image onto the screen to load it
- **Open from menu** — Menu bar → Open Image… (⌘O)
- **Supported formats** — PNG, JPEG, GIF, TIFF, BMP

---

## Usage

| Action | How |
|--------|-----|
| **Open image** | Menu bar (▼) → Open Image… or **⌘O**, or drag an image onto the screen |
| **Move** | Drag (when unlocked) |
| **Resize** | Scroll wheel |
| **Rotate** | **Option + drag** |
| **Lock** | Menu → Lock — overlay becomes click-through so you can draw in the app behind |
| **Unlock** | Menu → Unlock |
| **Opacity** | Menu → Opacity → 30% / 50% / 70% / 100% |
| **Quit** | Menu → Quit Trace Overlay or **⌘Q** |

---

## Build from source

Requires macOS and Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/Solidifiedplaydoh/TraceOverlay.git
cd TraceOverlay
./build.sh
open TraceOverlay.app
```

---

## Requirements

- **macOS 10.13** (High Sierra) or later
- No Xcode project — single Swift file, built with `swiftc` via `build.sh`

---

## Publishing a release

Releases are built automatically. To publish a new version:

1. Update version in `Info.plist` and `CHANGELOG.md`.
2. Commit, then create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions builds the app and creates a release with `TraceOverlay-macOS.zip` attached.

---

## License

[MIT](LICENSE) — use it, change it, ship it.
