//
//  PermissionsInspectorView.swift
//  Flare
//
//  Sheet that shows all required Cloudflare API permissions with live green/red status
//

import SwiftUI

struct PermissionsInspectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("API Permissions")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(FlareColors.textPrimary)

                    Text("Required Cloudflare API scopes for Flare")
                        .font(.system(size: 12))
                        .foregroundStyle(FlareColors.textSecondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(FlareColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.vertical, FlareSpacing.lg)

            Divider().background(FlareColors.borderPrimary)

            // Summary banner
            summaryBanner

            Divider().background(FlareColors.borderPrimary)

            // Permission rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(appState.permissionStatuses.enumerated()), id: \.element.id) { index, perm in
                        permissionRow(perm)
                        if index < appState.permissionStatuses.count - 1 {
                            Divider()
                                .background(FlareColors.borderPrimary)
                                .padding(.horizontal, FlareSpacing.xl)
                        }
                    }
                }
                .padding(.vertical, FlareSpacing.sm)
            }

            Divider().background(FlareColors.borderPrimary)

            // Footer
            HStack(spacing: FlareSpacing.md) {
                if appState.hasPermissionIssues {
                    Link(destination: URL(string: "https://dash.cloudflare.com/profile/api-tokens")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 11))
                            Text("Edit API Token Permissions")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(FlareColors.textLink)
                    }
                }

                Spacer()

                Button(action: {
                    Task {
                        await appState.checkPermissions()
                    }
                }) {
                    HStack(spacing: 6) {
                        if appState.isCheckingPermissions {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11))
                        }
                        Text("Re-check")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(FlareColors.textSecondary)
                    .padding(.horizontal, FlareSpacing.md)
                    .padding(.vertical, FlareSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: FlareRadius.md)
                            .fill(FlareColors.bgTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: FlareRadius.md)
                                    .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(appState.isCheckingPermissions)
            }
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.vertical, FlareSpacing.md)
        }
        .background(FlareColors.bgPrimary)
        .frame(minWidth: 480, minHeight: 420)
    }

    // MARK: - Summary Banner

    @ViewBuilder
    private var summaryBanner: some View {
        let denied = appState.permissionStatuses.filter { $0.status == .denied }.count
        let granted = appState.permissionStatuses.filter { $0.status == .granted }.count
        let total = appState.permissionStatuses.count

        HStack(spacing: FlareSpacing.lg) {
            statusStat(label: "Granted", value: "\(granted)", color: FlareColors.statusActive)
            statusStat(label: "Denied", value: "\(denied)", color: FlareColors.statusError)
            statusStat(label: "Total Required", value: "\(total)", color: FlareColors.textSecondary)
            Spacer()

            if denied > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FlareColors.statusWarning)
                    Text("\(denied) permission\(denied == 1 ? "" : "s") missing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.statusWarning)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(FlareColors.statusWarning.opacity(0.1))
                        .overlay(Capsule().strokeBorder(FlareColors.statusWarning.opacity(0.3), lineWidth: 1))
                )
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FlareColors.statusActive)
                    Text("All permissions granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.statusActive)
                }
            }
        }
        .padding(.horizontal, FlareSpacing.xl)
        .padding(.vertical, FlareSpacing.md)
        .background(FlareColors.bgSecondary)
    }

    private func statusStat(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(FlareColors.textTertiary)
        }
    }

    // MARK: - Permission Row

    private func permissionRow(_ perm: PermissionCheck) -> some View {
        HStack(spacing: FlareSpacing.md) {
            // Status indicator
            Group {
                switch perm.status {
                case .granted:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(FlareColors.statusActive)
                case .denied:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(FlareColors.statusError)
                case .unknown:
                    Image(systemName: "circle.dashed")
                        .foregroundStyle(FlareColors.textTertiary)
                }
            }
            .font(.system(size: 16))
            .frame(width: 24)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(perm.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(FlareColors.textPrimary)

                    Text(perm.scope)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(FlareColors.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(FlareColors.bgTertiary)
                        )
                }
                Text(perm.description)
                    .font(.system(size: 11))
                    .foregroundStyle(FlareColors.textSecondary)
            }

            Spacer()

            // Status label
            Text(perm.status == .granted ? "Granted"
                 : perm.status == .denied ? "Denied"
                 : "Unknown")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(perm.status == .granted ? FlareColors.statusActive
                                 : perm.status == .denied ? FlareColors.statusError
                                 : FlareColors.textTertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(
                        (perm.status == .granted ? FlareColors.statusActive
                         : perm.status == .denied ? FlareColors.statusError
                         : FlareColors.textTertiary).opacity(0.12)
                    )
                )
        }
        .padding(.horizontal, FlareSpacing.xl)
        .padding(.vertical, FlareSpacing.md)
    }
}
