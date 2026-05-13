//
//  SettingsView.swift
//  Flare
//
//  Account info, token management, and app preferences — Liquid Glass panels
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    @State private var isHoveringSignOut = false
    @State private var isHoveringExport = false
    @State private var isHoveringGitHub = false
    @State private var showPermissionsSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: FlareSpacing.xl) {
                // Header
                SectionHeader(title: "Settings", subtitle: "Account & preferences")
                    .padding(.horizontal, FlareSpacing.xl)
                    .padding(.top, FlareSpacing.lg)

                // Account section — nested glass
                settingsSection("Account") {
                    settingsRow(
                        icon: "globe",
                        iconColor: FlareColors.statusActive,
                        title: "Zones",
                        value: "\(appState.zones.count)"
                    )

                    Divider().background(FlareColors.glassBorder.opacity(0.5)).padding(.horizontal, FlareSpacing.md)

                    settingsRow(
                        icon: "chevron.left.forwardslash.chevron.right",
                        iconColor: FlareColors.statusPending,
                        title: "Workers",
                        value: "\(appState.workers.count)"
                    )
                }

                // Domain Filter section — nested glass
                settingsSection("Visible Domains") {
                    if appState.zones.isEmpty {
                        HStack(spacing: FlareSpacing.sm) {
                            Image(systemName: "globe")
                                .font(.system(size: 13))
                                .foregroundStyle(FlareColors.textTertiary)
                                .frame(width: 24)
                            Text("No domains loaded yet")
                                .font(.system(size: 12))
                                .foregroundStyle(FlareColors.textTertiary)
                            Spacer()
                        }
                        .padding(FlareSpacing.md)
                    } else {
                        ForEach(Array(appState.zones.enumerated()), id: \.element.id) { index, zone in
                            DomainToggleRow(zone: zone, appState: appState)

                            if index < appState.zones.count - 1 {
                                Divider().background(FlareColors.glassBorder.opacity(0.5)).padding(.horizontal, FlareSpacing.md)
                            }
                        }
                    }
                }

                // API Token section — nested glass
                settingsSection("API Token") {
                    Button(action: { showPermissionsSheet = true }) {
                        HStack(spacing: FlareSpacing.md) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(FlareColors.statusActive)
                                .shadow(color: FlareColors.statusActive.opacity(0.3), radius: 3, x: 0, y: 0)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Token Status")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(FlareColors.textPrimary)

                                Text(appState.hasPermissionIssues
                                     ? "Some permissions are missing — tap to inspect"
                                     : "Active and connected")
                                    .font(.system(size: 11))
                                    .foregroundStyle(appState.hasPermissionIssues
                                                     ? FlareColors.statusWarning
                                                     : FlareColors.statusActive)
                            }

                            Spacer()

                            // Indicator badge
                            if appState.isCheckingPermissions {
                                ProgressView()
                                    .controlSize(.small)
                            } else if appState.hasPermissionIssues {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(FlareColors.statusWarning)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: FlareColors.statusWarning.opacity(0.4), radius: 3)
                                    Text("Issues")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(FlareColors.statusWarning)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(FlareColors.statusWarning.opacity(0.10))
                                        .overlay(Capsule().strokeBorder(FlareColors.statusWarning.opacity(0.25), lineWidth: 0.5))
                                )
                            } else {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(FlareColors.statusActive)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: FlareColors.statusActive.opacity(0.4), radius: 3)
                                    Text("Connected")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(FlareColors.statusActive)
                                }
                            }

                            // Chevron
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(FlareColors.textTertiary)
                        }
                        .padding(FlareSpacing.md)
                    }
                    .buttonStyle(.plain)
                }

                // Missing Permissions section
                if !appState.missingPermissions.isEmpty {
                    settingsSection("Missing Permissions") {
                        VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                            HStack(spacing: FlareSpacing.sm) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(FlareColors.statusWarning)
                                    .shadow(color: FlareColors.statusWarning.opacity(0.3), radius: 3)

                                Text("Your API token may be missing these permissions:")
                                    .font(.system(size: 12))
                                    .foregroundStyle(FlareColors.textSecondary)
                            }

                            ForEach(appState.missingPermissions, id: \.self) { perm in
                                HStack(spacing: FlareSpacing.sm) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(FlareColors.statusError)
                                        .frame(width: 24)

                                    Text(perm)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(FlareColors.textPrimary)

                                    Spacer()
                                }
                            }

                            HStack(spacing: FlareSpacing.xs) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 10))
                                Text("Update token permissions at")
                                    .font(.system(size: 10))
                                Text("dash.cloudflare.com/profile/api-tokens")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(FlareColors.textLink)
                            }
                            .foregroundStyle(FlareColors.textTertiary)
                            .padding(.top, FlareSpacing.xs)
                        }
                        .padding(FlareSpacing.md)
                    }
                }

                // Danger zone — nested glass
                settingsSection("Danger Zone") {
                    HStack(spacing: FlareSpacing.md) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.statusError)
                            .shadow(color: FlareColors.statusError.opacity(0.3), radius: 3)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sign Out")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textPrimary)

                            Text("Remove stored API token and disconnect")
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.textTertiary)
                        }

                        Spacer()

                        Button(action: { showSignOutAlert = true }) {
                            Text("Sign Out")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, FlareSpacing.md)
                                .padding(.vertical, FlareSpacing.sm)
                                .liquidGlassButton(color: FlareColors.statusError.opacity(0.9), isPrimary: true)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isHoveringSignOut = hovering
                            }
                        }
                    }
                    .padding(FlareSpacing.md)
                }

                // Export section — nested glass
                settingsSection("Data Export") {
                    HStack(spacing: FlareSpacing.md) {
                        Image(systemName: "tablecells.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.textLink)
                            .shadow(color: FlareColors.textLink.opacity(0.3), radius: 3)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export Account Data")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textPrimary)

                            Text("Export User ID, Zone IDs, and Record IDs as CSV")
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.textTertiary)
                        }

                        Spacer()

                        Button(action: {
                            Task {
                                await appState.exportAccountDataCSV()
                            }
                        }) {
                            if appState.isExporting {
                                ProgressView()
                                    .controlSize(.small)
                                    .padding(.horizontal, FlareSpacing.md)
                            } else {
                                Text("Export CSV")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, FlareSpacing.md)
                                    .padding(.vertical, FlareSpacing.sm)
                                    .liquidGlassButton(color: FlareColors.textLink.opacity(0.9), isPrimary: true)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.isExporting)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isHoveringExport = hovering
                            }
                        }
                    }
                    .padding(FlareSpacing.md)
                }

                // About section — distinct glass element
                settingsSection("About") {
                    VStack(spacing: 0) {
                        // App identity
                        HStack(spacing: FlareSpacing.md) {
                            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Flare")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(FlareColors.textPrimary)
                                    .tracking(0.3)
                                Text("Native macOS Cloudflare Dashboard")
                                    .font(.system(size: 11))
                                    .foregroundStyle(FlareColors.textSecondary)
                                Text("v1.0  ·  Built with SwiftUI  ·  Cloudflare API v4")
                                    .font(.system(size: 10))
                                    .foregroundStyle(FlareColors.textTertiary)
                            }

                            Spacer()
                        }
                        .padding(FlareSpacing.md)

                        Divider().background(FlareColors.glassBorder.opacity(0.5)).padding(.horizontal, FlareSpacing.md)

                        // GitHub link — with subtle glow arrow
                        HStack(spacing: FlareSpacing.md) {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 13))
                                .foregroundStyle(FlareColors.textLink)
                                .shadow(color: FlareColors.textLink.opacity(0.3), radius: 3)
                                .frame(width: 24)

                            Text("Open Source")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textPrimary)

                            Spacer()

                            Link(destination: URL(string: "https://github.com/Ferohers/macOS-cloudflare-client")!) {
                                HStack(spacing: 4) {
                                    Text("GitHub")
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .semibold))
                                        .shadow(color: FlareColors.textLink.opacity(isHoveringGitHub ? 0.6 : 0.3), radius: isHoveringGitHub ? 6 : 3)
                                }
                                .foregroundStyle(FlareColors.textLink)
                            }
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isHoveringGitHub = hovering
                                }
                            }
                        }
                        .padding(FlareSpacing.md)

                        Divider().background(FlareColors.glassBorder.opacity(0.5)).padding(.horizontal, FlareSpacing.md)

                        // Privacy statement — verbatim text
                        HStack(alignment: .top, spacing: FlareSpacing.md) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(FlareColors.statusActive)
                                .shadow(color: FlareColors.statusActive.opacity(0.3), radius: 3)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Privacy")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(FlareColors.textPrimary)
                                Text("Flare does not collect, transmit, or store any of your data. Your API token is stored exclusively in the macOS Keychain on this device and is never sent to any third-party server.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(FlareColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()
                        }
                        .padding(FlareSpacing.md)
                    }
                }

                Spacer(minLength: FlareSpacing.xl)
            }
        }
        .background(FlareColors.bgPrimary)
        .sheet(isPresented: $showPermissionsSheet) {
            PermissionsInspectorView()
                .environment(appState)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("This will remove your stored API token. You'll need to re-enter it to use Flare.")
        }
    }

    // MARK: - Section Builder — Nested Glass Panels

    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: FlareSpacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(FlareColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, FlareSpacing.xl)

            VStack(spacing: 0) {
                content()
            }
            .nestedGlass(cornerRadius: FlareRadius.lg)
            .padding(.horizontal, FlareSpacing.xl)
        }
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: FlareSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(iconColor)
                .shadow(color: iconColor.opacity(0.3), radius: 3, x: 0, y: 0)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(FlareColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(FlareColors.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(FlareSpacing.md)
    }
}

// MARK: - Domain Toggle Row

struct DomainToggleRow: View {
    let zone: Zone
    @Bindable var appState: AppState

    var body: some View {
        HStack(spacing: FlareSpacing.md) {
            Image(systemName: "globe")
                .font(.system(size: 13))
                .foregroundStyle(isVisible ? FlareColors.statusActive : FlareColors.textTertiary)
                .shadow(color: isVisible ? FlareColors.statusActive.opacity(0.3) : Color.clear, radius: 3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(zone.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(FlareColors.textPrimary)

                if isVisible {
                    StatusBadge(zoneStatus: zone.status)
                } else {
                    Text("Deactivated")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.statusError)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(FlareColors.statusError.opacity(0.10))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(FlareColors.statusError.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isVisible },
                set: { newValue in
                    if newValue {
                        appState.hiddenZoneIds.remove(zone.id)
                    } else {
                        appState.hiddenZoneIds.insert(zone.id)
                    }
                }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            .tint(FlareColors.cloudflareOrange)
        }
        .padding(FlareSpacing.md)
    }

    private var isVisible: Bool {
        !appState.hiddenZoneIds.contains(zone.id)
    }
}
