# HoloBubble macOS helper

A lightweight SwiftUI app that captures your screen every 20 seconds, posts the PNG to your backend, and floats the returned text in a holographic bubble that is configured to stay out of normal screen recordings.

## Highlights
- **Automated captures** using `CGDisplayCreateImage` and multipart uploads via `URLSession`.
- **Beautiful holographic bubble** with a configurable color (default: unicorn pink).
- **Screen-recording avoidance** by rendering the bubble in a borderless `NSPanel` with `sharingType = .none` and a screensaver-level window.

## Running
1. Ensure you are on macOS 13+ with Xcode command-line tools installed.
2. Update the default backend URL in the UI or set it in `BackendClient.backendURL`.
3. Run the app:
   ```bash
   swift run
   ```
4. Grant screen recording permissions when macOS prompts, then watch the floating bubble react to backend responses.
