//
//  PermissionsInspectorView.swift
//  Flare
//
//  Sheet that shows all required Cloudflare API permissions — Liquid Glass
//

import SwiftUI

struct PermissionsInspectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header — glass
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("API Permissions")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(FlareColors.textPrimary)
                        .tracking(0.3)

                    Text("Required Cloudflare API scopes for Flare")
                        .font(.system(size: 12))
                        .foregroundStyle(FlareColors.textSecondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FlareColors.textTertiary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(FlareColors.glassOverlay)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, FlareSpacing.xl)
            .padding(.vertical, FlareSpacing.lg)

            Divider().background(FlareColors.glassBorder)

            // Summary banner — glass
            summaryBanner

            Divider().background(FlareColors.glassBorder)

            // Permission rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(appState.permissionStatuses.enumerated()), id: \.element.id) { index, perm in
                        permissionRow(perm)
                        if index < appState.permissionStatuses.count - 1 {
                            Divider()
                                .background(FlareColors.glassBorder.opacity(0.5))
                                .padding(.horizontal, FlareSpacing.xl)
                        }
                    }
                }
                .padding(.vertical, FlareSpacing.sm)
            }

            Divider().background(FlareColors.glassBorder)

            // Footer — glass
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
                        ZStack {
                            RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                                .fill(FlareColors.glassOverlay)
                            RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        }
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

    // MARK: - Summary Banner — Glass

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
                        .shadow(color: FlareColors.statusWarning.opacity(0.3), radius: 3)
                    Text("\(denied) permission\(denied == 1 ? "" : "s") missing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.statusWarning)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(FlareColors.statusWarning.opacity(0.08))
                        .overlay(Capsule().strokeBorder(FlareColors.statusWarning.opacity(0.2), lineWidth: 0.5))
                )
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FlareColors.statusActive)
                        .shadow(color: FlareColors.statusActive.opacity(0.3), radius: 3)
                    Text("All permissions granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlareColors.statusActive)
                }
            }
        }
        .padding(.horizontal, FlareSpacing.xl)
        .padding(.vertical, FlareSpacing.md)
        .background(FlareColors.glassOverlay)
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
                        .shadow(color: FlareColors.statusActive.opacity(0.3), radius: 3)
                case .denied:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(FlareColors.statusError)
                        .shadow(color: FlareColors.statusError.opacity(0.3), radius: 3)
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
                            Capsule()
                                .fill(FlareColors.glassOverlay)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                                )
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
                         : FlareColors.textTertiary).opacity(0.10)
                    )
                    .overlay(
                        Capsule().strokeBorder(
                            (perm.status == .granted ? FlareColors.statusActive
                             : perm.status == .denied ? FlareColors.statusError
                             : FlareColors.textTertiary).opacity(0.15),
                            lineWidth: 0.5
                        )
                    )
                )
        }
        .padding(.horizontal, FlareSpacing.xl)
        .padding(.vertical, FlareSpacing.md)
    }
}
