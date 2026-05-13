//
//  SettingsView.swift
//  Flare
//
//  Account info, token management, and app preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    @State private var isHoveringSignOut = false

    var body: some View {
        ScrollView {
            VStack(spacing: FlareSpacing.xl) {
                // Header
                SectionHeader(title: "Settings", subtitle: "Account & preferences")
                    .padding(.horizontal, FlareSpacing.xl)
                    .padding(.top, FlareSpacing.lg)

                // Account section
                settingsSection("Account") {
                    settingsRow(
                        icon: "globe",
                        iconColor: FlareColors.statusActive,
                        title: "Zones",
                        value: "\(appState.zones.count)"
                    )

                    Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)

                    settingsRow(
                        icon: "chevron.left.forwardslash.chevron.right",
                        iconColor: FlareColors.statusPending,
                        title: "Workers",
                        value: "\(appState.workers.count)"
                    )
                }

                // Domain Filter section
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
                                Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)
                            }
                        }
                    }
                }

                // API Token section
                settingsSection("API Token") {
                    HStack(spacing: FlareSpacing.md) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.statusActive)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Token Status")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FlareColors.textPrimary)

                            Text("Active and connected")
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.statusActive)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Circle()
                                .fill(FlareColors.statusActive)
                                .frame(width: 6, height: 6)
                            Text("Connected")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(FlareColors.statusActive)
                        }
                    }
                    .padding(FlareSpacing.md)
                }

                // Missing Permissions section
                if !appState.missingPermissions.isEmpty {
                    settingsSection("Missing Permissions") {
                        VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                            HStack(spacing: FlareSpacing.sm) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(FlareColors.statusWarning)

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

                // Danger zone
                settingsSection("Danger Zone") {
                    HStack(spacing: FlareSpacing.md) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.statusError)
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
                                .background(
                                    RoundedRectangle(cornerRadius: FlareRadius.md)
                                        .fill(
                                            isHoveringSignOut
                                                ? FlareColors.statusError
                                                : FlareColors.statusError.opacity(0.8)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            isHoveringSignOut = hovering
                        }
                    }
                    .padding(FlareSpacing.md)
                }

                // Export section
                settingsSection("Data Export") {
                    HStack(spacing: FlareSpacing.md) {
                        Image(systemName: "tablecells.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.textLink)
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
                                    .background(
                                        RoundedRectangle(cornerRadius: FlareRadius.md)
                                            .fill(FlareColors.textLink)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.isExporting)
                    }
                    .padding(FlareSpacing.md)
                }

                // About section
                settingsSection("About") {
                    settingsRow(
                        icon: "flame.fill",
                        iconColor: FlareColors.cloudflareOrange,
                        title: "Flare",
                        value: "v1.0"
                    )

                    Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)

                    settingsRow(
                        icon: "swift",
                        iconColor: FlareColors.cloudflareOrangeLight,
                        title: "Built with",
                        value: "SwiftUI"
                    )

                    Divider().background(FlareColors.borderPrimary).padding(.horizontal, FlareSpacing.md)

                    settingsRow(
                        icon: "link",
                        iconColor: FlareColors.textLink,
                        title: "API",
                        value: "Cloudflare v4"
                    )
                }

                Spacer(minLength: FlareSpacing.xl)
            }
        }
        .background(FlareColors.bgPrimary)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("This will remove your stored API token. You'll need to re-enter it to use Flare.")
        }
    }

    // MARK: - Section Builder

    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: FlareSpacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(FlareColors.textTertiary)
                .textCase(.uppercase)
                .padding(.horizontal, FlareSpacing.xl)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.lg)
                    .fill(FlareColors.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.lg)
                            .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                    )
            )
            .padding(.horizontal, FlareSpacing.xl)
        }
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: FlareSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(iconColor)
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
                            Capsule().fill(FlareColors.statusError.opacity(0.12))
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
