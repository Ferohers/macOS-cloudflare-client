# Flare: Native macOS Cloudflare Dashboard

Flare is a high-fidelity, native macOS application built with SwiftUI for managing your Cloudflare resources. It provides a sleek, responsive, and secure interface to monitor and configure your domains, DNS records, and Cloudflare Workers — all from your Mac.

🔗 **Repository**: [github.com/Ferohers/macOS-cloudflare-client]

<img width="1812" height="1308" alt="Screenshot 2026-05-13 at 17 36 43" src="https://github.com/user-attachments/assets/bc2b7701-04cc-4cd0-b2be-e90995a4b51c" />
<img width="1832" height="1340" alt="Screenshot 2026-05-13 at 17 36 35" src="https://github.com/user-attachments/assets/812c63ae-c6f9-4dce-83d7-069ffce1b0c1" />
<img width="1828" height="1344" alt="Screenshot 2026-05-13 at 17 36 28" src="https://github.com/user-attachments/assets/8c945dca-f053-40de-a258-627ca3a28510" />
<img width="1088" height="1016" alt="Screenshot 2026-05-13 at 17 36 16" src="https://github.com/user-attachments/assets/36d1af0b-2049-4133-82d3-0ceb4c90a1d5" />



## Features

- **Zone Management**: View all your Cloudflare zones (domains) at a glance.
- **DNS Record Editor**: Add, edit, and delete DNS records (A, AAAA, CNAME, TXT, etc.) with proxy toggling.
- **Data Export**: Export account metadata (User ID, Domain Name, Zone ID, Record Name, Record Type, Record ID) to CSV for auditing or integration.
- **Workers Integration**: View and edit your Cloudflare Workers scripts directly within the app.
- **API Permission Inspector**: Live-checks all required Cloudflare API scopes and shows which are granted or denied with a green/yellow status indicator.
- **Native Experience**: Built entirely with SwiftUI, featuring a three-column navigation layout, sidebar, and full dark mode support.
- **Secure**: Sensitive API tokens are stored securely in the macOS Keychain and never leave your device.
- **Responsive State**: Real-time state management for loading indicators, success messages, and error handling.

## Privacy

> **Flare does not collect, transmit, or store any of your data.**

Your Cloudflare API token is stored exclusively in the macOS Keychain on your device. Flare communicates directly and only with the official Cloudflare API (`api.cloudflare.com`). No analytics, no telemetry, no third-party servers — ever.

## Getting Started

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- A Cloudflare API Token with the following permissions:
  - **User: Read** — to verify token and fetch user details
  - **Zone: Zone Settings — Read** — to list domains
  - **Zone: DNS — Edit** — to read, create, update, and delete DNS records
  - **Account: Workers Scripts — Read** — to list and view Workers scripts

### Installation

**Downloading the Pre-compiled Release:**
1. Go to the [Releases](https://github.com/Ferohers/macOS-cloudflare-client/releases) page and download `Flare-macOS-arm64.zip`.
2. Extract the ZIP archive and move `Flare.app` to your `Applications` folder.
3. **Important (Unsigned App):** Because this application is currently not signed with an Apple Developer certificate, macOS Gatekeeper will block it from running. You can allow it to run using either of these methods:
   - **Method 1 (Terminal):** Open your terminal and run the following command to remove the quarantine attribute:
     ```bash
     xattr -cr /Applications/Flare.app
     ```
   - **Method 2 (Finder):** Right-click (or Control-click) on `Flare.app` in Finder, select **Open** from the context menu, and then click **Open** again in the warning dialog.

**Building from Source:**
1. Clone the repository:
   ```bash
   git clone https://github.com/Ferohers/macOS-cloudflare-client.git
   ```
2. Open `Flare.xcodeproj` in Xcode.
3. Build and run the application (`Cmd + R`).

### Configuration

On first launch you will be prompted to enter your Cloudflare API Token. Flare will verify the token, securely store it in your Keychain, and load your account data automatically.

You can check which permissions are granted at any time in **Settings → API Token → Issues** (the yellow indicator appears when a permission is missing).

## Technical Details

- **Language**: Swift 6.0 (Concurrency)
- **Framework**: SwiftUI
- **Architecture**: Observable State Pattern (`@Observable`)
- **Networking**: URLSession with a typed Cloudflare API v4 layer
- **Security**: Keychain Services for token persistence

## Project Structure

```
Flare/
├── AppState.swift              # Root state container & business logic
├── CloudflareAPI.swift         # Networking layer (Cloudflare API v4)
├── Models.swift                # Codable data models
├── PermissionCheck.swift       # Live API permission probing
├── Theme.swift                 # Design system (colors, spacing, typography)
└── Views/
    ├── SettingsView.swift      # Settings, About, and token status
    ├── PermissionsInspectorView.swift  # Permission details sheet
    ├── ZoneDetailView.swift    # DNS record management
    ├── WorkerDetailView.swift  # Worker script editor
    └── ...
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Credits

Developed by [Ferohers](https://github.com/Ferohers).
