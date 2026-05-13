//
//  Components.swift
//  Flare
//
//  Reusable UI components — macOS Tahoe Liquid Glass design
//

import SwiftUI

// MARK: - Status Badge

struct StatusBadge: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }

    init(zoneStatus: String) {
        self.text = zoneStatus.capitalized
        switch zoneStatus.lowercased() {
        case "active":
            self.color = FlareColors.statusActive
        case "pending":
            self.color = FlareColors.statusPending
        case "moved":
            self.color = FlareColors.statusWarning
        default:
            self.color = FlareColors.textTertiary
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 0)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(color.opacity(0.10))
                .overlay(
                    Capsule()
                        .strokeBorder(color.opacity(0.15), lineWidth: 0.5)
                )
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - DNS Type Badge — Translucent Glass

struct DNSTypeBadge: View {
    let type: String

    var body: some View {
        let badgeColor = FlareColors.colorForDNSType(type)
        Text(type)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(minWidth: 48)
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                    .fill(badgeColor.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                            .strokeBorder(badgeColor.opacity(0.25), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - Proxy Status Icon

struct ProxyStatusIcon: View {
    let isProxied: Bool

    var body: some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: 14))
            .foregroundStyle(isProxied ? FlareColors.cloudflareOrange : FlareColors.textTertiary)
            .shadow(color: isProxied ? FlareColors.cloudflareOrange.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 0)
            .help(isProxied ? "Proxied through Cloudflare" : "DNS Only")
    }
}

// MARK: - Loading Skeleton — Glass Shimmer

struct LoadingCard: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
            .fill(FlareColors.glassOverlay)
            .overlay(
                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.02),
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: isAnimating ? .trailing : .leading,
                            endPoint: isAnimating ? .leading : .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .strokeBorder(FlareColors.glassBorder.opacity(0.5), lineWidth: 0.5)
            )
            .frame(height: 72)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Error Banner (for inline use, e.g. setup screen)

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: FlareSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(FlareColors.statusError)

            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(FlareColors.textPrimary)
                .lineLimit(2)

            Spacer()

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(FlareColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(FlareSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                .fill(FlareColors.statusError.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                        .strokeBorder(FlareColors.statusError.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Toast Banner — Glass notification

struct ToastBanner: View {
    let message: String
    var isError: Bool = true
    var onDismiss: (() -> Void)?
    @State private var isHoveringClose = false

    var body: some View {
        HStack(spacing: FlareSpacing.md) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(isError ? FlareColors.statusError : FlareColors.statusActive)
                .shadow(color: (isError ? FlareColors.statusError : FlareColors.statusActive).opacity(0.4), radius: 4, x: 0, y: 0)

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(FlareColors.textPrimary)
                .lineLimit(3)

            Spacer()

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    HStack(spacing: FlareSpacing.xs) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                        Text("Close")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(isHoveringClose ? FlareColors.textPrimary : FlareColors.textSecondary)
                    .padding(.horizontal, FlareSpacing.sm)
                    .padding(.vertical, FlareSpacing.xs + 1)
                    .background(
                        RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                            .fill(isHoveringClose ? FlareColors.glassHover : FlareColors.glassOverlay)
                            .overlay(
                                RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isHoveringClose = hovering
                }
            }
        }
        .padding(FlareSpacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .fill(FlareColors.glassOverlay)

                // Light refraction edge
                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                (isError ? FlareColors.statusError : FlareColors.statusActive).opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 24, y: -6)
    }
}

// MARK: - Stat Card — Stacked Glass with Accent Glow

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = FlareColors.cloudflareOrange

    var body: some View {
        HStack(spacing: FlareSpacing.md) {
            // Icon — small, tinted
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(iconColor)
                .shadow(color: iconColor.opacity(0.4), radius: 3, x: 0, y: 0)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                        .fill(iconColor.opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(FlareColors.textPrimary)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(FlareColors.textPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, FlareSpacing.md)
        .padding(.vertical, FlareSpacing.sm + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .statCardGlass(accentColor: iconColor)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var action: (() -> Void)?
    var actionLabel: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(FlareColors.textPrimary)
                    .tracking(0.3)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(FlareColors.textSecondary)
                }
            }

            Spacer()

            if let action = action, let label = actionLabel {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .semibold))
                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(FlareColors.cloudflareOrange)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: FlareSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(FlareColors.textTertiary.opacity(0.6))
                .shadow(color: FlareColors.textTertiary.opacity(0.1), radius: 8, x: 0, y: 0)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FlareColors.textSecondary)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(FlareColors.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
