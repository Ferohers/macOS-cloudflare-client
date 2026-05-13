//
//  Components.swift
//  Flare
//
//  Reusable UI components for the Flare app
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
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - DNS Type Badge

struct DNSTypeBadge: View {
    let type: String

    var body: some View {
        Text(type)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(minWidth: 48)
            .background(
                RoundedRectangle(cornerRadius: FlareRadius.sm)
                    .fill(FlareColors.colorForDNSType(type))
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
            .help(isProxied ? "Proxied through Cloudflare" : "DNS Only")
    }
}

// MARK: - Loading Skeleton

struct LoadingCard: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: FlareRadius.lg)
            .fill(FlareColors.bgSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: FlareRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                FlareColors.bgSecondary,
                                FlareColors.bgTertiary.opacity(0.5),
                                FlareColors.bgSecondary
                            ],
                            startPoint: isAnimating ? .trailing : .leading,
                            endPoint: isAnimating ? .leading : .trailing
                        )
                    )
            )
            .frame(height: 72)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
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
            RoundedRectangle(cornerRadius: FlareRadius.md)
                .fill(FlareColors.statusError.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: FlareRadius.md)
                        .strokeBorder(FlareColors.statusError.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Toast Banner (bottom notification with auto-dismiss)

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
                        RoundedRectangle(cornerRadius: FlareRadius.sm)
                            .fill(isHoveringClose ? FlareColors.bgHover : FlareColors.bgElevated)
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
            RoundedRectangle(cornerRadius: FlareRadius.lg)
                .fill(FlareColors.bgSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: FlareRadius.lg)
                        .strokeBorder(isError ? FlareColors.statusError.opacity(0.3) : FlareColors.statusActive.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = FlareColors.cloudflareOrange

    var body: some View {
        VStack(alignment: .leading, spacing: FlareSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(FlareColors.textPrimary)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(FlareColors.textSecondary)
        }
        .padding(FlareSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FlareRadius.lg)
                .fill(FlareColors.bgSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: FlareRadius.lg)
                        .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                )
        )
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
                .foregroundStyle(FlareColors.textTertiary)

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
