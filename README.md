# Trace Overlay

A minimal **macOS menu bar app** that shows a full-screen transparent overlay so you can trace an image in your favorite drawing app. Move, resize, and rotate the reference image, then **lock** it for click-through and draw underneath.

No window chrome — everything is controlled from the **menu bar icon** (▼).

![macOS 10.13+](https://img.shields.io/badge/macOS-10.13+-blue) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Download

Get the latest release from the [Releases](../../releases) page. Download `TraceOverlay-macOS.zip`, unzip, and drag **Trace Overlay.app** to Applications (or run from anywhere).

Releases built **with** [Apple signing](#publishing-a-release) (v1.0.1+) open immediately. If you see **"damaged"** (unsigned build), run once: `xattr -cr /path/to/Trace\ Overlay.app` then open the app.

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

1. Update version in `Info.plist` and `CHANGELOG.md`.
2. Commit, then create and push a tag (e.g. `v1.0.1`):
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
3. GitHub Actions builds the app and creates a release with `TraceOverlay-macOS.zip` attached.

### Signed & notarized builds (opens immediately when downloaded)

To have releases **signed and notarized** so they open with no "damaged" warning, you need an [Apple Developer account](https://developer.apple.com) and these **GitHub repository secrets**:

| Secret | Description |
|--------|-------------|
| `APPLE_DEVELOPER_CERTIFICATE_P12_BASE64` | Export your **Developer ID Application** certificate from Keychain (File → Export; save as .p12). Then: `base64 -i YourCert.p12 | pbcopy` and paste as the secret value. |
| `APPLE_DEVELOPER_CERTIFICATE_PASSWORD` | Password you set when exporting the .p12. |
| `APPLE_SIGNING_IDENTITY` | Exact name of the cert, e.g. `Developer ID Application: Your Name (TEAM_ID)`. Find in Keychain or run `security find-identity -v -p codesigning`. |
| `APPLE_ID` | Your Apple ID email. |
| `APPLE_APP_SPECIFIC_PASSWORD` | [Create an app-specific password](https://appleid.apple.com/account/manage) for notarization (sign in to Apple ID → Sign-In and Security → App-Specific Passwords). |
| `APPLE_TEAM_ID` | Your Team ID from [Apple Developer Membership](https://developer.apple.com/account). |

Add these under **Settings → Secrets and variables → Actions**. The next release you tag will be signed and notarized; the zip will open immediately for users. If any secret is missing, the workflow still runs and produces an ad-hoc signed zip (users may need the `xattr -cr` workaround).

---

## License

[MIT](LICENSE) — use it, change it, ship it.
