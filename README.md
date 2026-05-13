# Flare: Native macOS Cloudflare Dashboard

Flare is a high-fidelity, native macOS application built with SwiftUI for managing your Cloudflare resources. It provides a sleek, responsive, and secure interface to monitor and configure your domains, DNS records, and Cloudflare Workers.

![Flare App Preview](https://via.placeholder.com/800x450.png?text=Flare+Dashboard+Preview)

## Features

- **Zone Management**: View all your Cloudflare zones (domains) at a glance.
- **DNS Record Editor**: Add, edit, and delete DNS records (A, AAAA, CNAME, TXT, etc.) with support for proxy toggling.
- **Data Export**: Export account metadata (User ID, Zone ID, Record ID) to CSV for auditing or integration purposes.
- **Workers Integration**: View and edit your Cloudflare Workers scripts directly within the app.
- **Native Experience**: Built entirely with SwiftUI, featuring a three-column navigation layout, sidebar, and full dark mode support.
- **Secure**: Sensitive API tokens are stored securely in the macOS Keychain.
- **Responsive State**: Real-time state management for loading indicators, success messages, and error handling.

## Getting Started

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- A Cloudflare API Token with the following permissions:
  - Account: Workers Scripts (Read)
  - Zone: DNS (Edit)
  - Zone: Zone (Read)
  - User: Details (Read)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Ferohers/macOS-cloudflare-client.git
   ```
2. Open `Flare.xcodeproj` in Xcode.
3. Build and run the application (`Cmd + R`).

### Configuration

On the first launch, you will be prompted to enter your Cloudflare API Token. Flare will verify the token and securely store it in your Keychain for subsequent launches.

## Technical Details

- **Language**: Swift 6.0 (Concurrency)
- **Framework**: SwiftUI
- **Architecture**: Observable State Pattern
- **Networking**: URLSession with custom Cloudflare API layer
- **Security**: Keychain Services for token persistence

## Development

The project is structured as follows:
- `Flare/AppState.swift`: Root state container and business logic.
- `Flare/CloudflareAPI.swift`: Networking layer for Cloudflare communication.
- `Flare/Models.swift`: Codable structures for API responses.
- `Flare/Views/`: Modular SwiftUI components for the dashboard, DNS editor, and Worker views.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Developed by [Ferohers](https://github.com/Ferohers).
