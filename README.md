# Graphics Flipper

**Fix black screens on Netflix, Disney+, Prime Video, and other streaming services — with one click.**

When hardware acceleration is enabled in Chrome or Edge, some streaming platforms fail to render video correctly, showing a black screen instead of the content. Graphics Flipper lets you toggle GPU acceleration on or off and restart your browser instantly, without touching any settings menus.

---

## The Problem

Streaming services like Netflix, Disney+, and Amazon Prime Video use hardware-accelerated video decoding and DRM (Widevine). On certain GPU drivers or display configurations, this causes:

- **Black screen** on video playback
- Content area that stays blank while audio plays normally
- Flickering or rendering artifacts during playback

The fix is always the same: disable hardware acceleration in your browser settings and restart. Graphics Flipper automates that in one click.

---

## How It Works

Click the toolbar icon → click **Disable & Restart** → your browser reopens with all your tabs restored, hardware acceleration off. Stream without issues. When you're done, click again to re-enable it.

No settings menus. No lost tabs.

---

## Installation

Graphics Flipper requires a small **companion app** that handles the system-level toggle. This is a one-time setup.

### Step 1 — Install the companion app

1. Download the latest release from the [Releases page](../../releases)
2. Run `install.bat` (Edge) or `install-chrome.bat` (Chrome)
3. That's it — no restart required

### Step 2 — Install the extension

**Edge:**
1. Open `edge://extensions`
2. Enable **Developer mode**
3. Click **Load unpacked** → select the `extension/` folder
4. The Graphics Flipper icon will appear in your toolbar

**Chrome:**
1. Open `chrome://extensions`
2. Enable **Developer mode**
3. Click **Load unpacked** → select the `extension/` folder

> Once published to the Edge Add-ons and Chrome Web Store, you'll be able to install directly from the store without Developer mode.

---

## Building from Source

```bash
npm install
npm run build
```

This compiles the TypeScript source in `src/` into `extension/popup.js` and `extension/background.js`.

To compile the native host:

```bat
cd companion
build.bat
```

Requires .NET Framework 4.x (pre-installed on Windows).

---

## Project Structure

```
src/                  TypeScript source
  popup.ts            Extension popup UI logic
  background.ts       Service worker / native messaging bridge
extension/            Loadable browser extension
  manifest.json
  popup.html
  popup.js            Compiled from src/popup.ts
  background.js       Compiled from src/background.ts
  icons/
companion/            Native messaging host (Windows)
  NativeHost.cs       C# source
  build.bat           Compiles NativeHost.exe
  gpu_toggle.json     Native messaging host manifest
  install.bat         Registers host for Edge
  install-chrome.bat  Registers host for Chrome
  uninstall.bat       Removes registration
```

---

## Compatibility

| Browser | Supported |
|---------|-----------|
| Microsoft Edge | ✓ |
| Google Chrome | ✓ |

Windows only. The companion app modifies `Local State` in your browser's user data directory.

---

## License

MIT
