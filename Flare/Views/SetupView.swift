//
//  SetupView.swift
//  Flare
//
//  Premium onboarding screen — Liquid Glass token entry
//

import SwiftUI

struct SetupView: View {
    @Environment(AppState.self) private var appState
    @State private var tokenInput = ""
    @State private var isHoveringConnect = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            // Clear background to let the window modifier handle the material
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: FlareSpacing.xl) {
                // Logo & Title
                VStack(spacing: FlareSpacing.lg) {
                    // Cloudflare icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [FlareColors.cloudflareOrange, FlareColors.cloudflareOrangeLight],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .shadow(color: FlareColors.cloudflareOrange.opacity(0.4), radius: 16, x: 0, y: 0)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    VStack(spacing: FlareSpacing.xs) {
                        Text("Welcome to Flare")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(FlareColors.textPrimary)
                            .tracking(0.5)

                        Text("Connect your Cloudflare account to get started")
                            .font(.system(size: 12))
                            .foregroundStyle(FlareColors.textSecondary)
                    }
                    .opacity(logoOpacity)
                }

                // Token Input Card — Glass panel
                VStack(spacing: FlareSpacing.md) {
                    VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                        HStack(spacing: FlareSpacing.xs) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(FlareColors.cloudflareOrange)
                                .shadow(color: FlareColors.cloudflareOrange.opacity(0.3), radius: 2)
                            Text("API Token")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(FlareColors.textSecondary)
                                .tracking(0.5)
                        }

                        HStack(spacing: FlareSpacing.sm) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(FlareColors.textTertiary)

                            SecureField("Paste your Cloudflare API token", text: $tokenInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(FlareColors.textPrimary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(height: 36)
                        .padding(.horizontal, FlareSpacing.sm + FlareSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                .fill(FlareColors.bgPrimary.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                        .strokeBorder(
                                            tokenInput.isEmpty
                                                ? FlareColors.glassBorder
                                                : FlareColors.cloudflareOrange.opacity(0.4),
                                            lineWidth: 0.5
                                        )
                                )
                        )
                    }

                    // Error message
                    if let error = appState.authError {
                        HStack(spacing: FlareSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.statusError)

                            Text(error)
                                .font(.system(size: 11))
                                .foregroundStyle(FlareColors.statusError.opacity(0.9))
                                .lineLimit(2)
                        }
                        .padding(FlareSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                                .fill(FlareColors.statusError.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.sm, style: .continuous)
                                        .strokeBorder(FlareColors.statusError.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Connect button
                    Button(action: {
                        Task {
                            await appState.authenticate(token: tokenInput)
                        }
                    }) {
                        HStack(spacing: FlareSpacing.sm) {
                            if appState.isAuthenticating {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.white)
                            } else {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            Text(appState.isAuthenticating ? "Connecting..." : "Connect")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FlareSpacing.sm + 2)
                        .foregroundStyle(.white)
                        .liquidGlassButton(isPrimary: !tokenInput.isEmpty)
                    }
                    .buttonStyle(.plain)
                    .disabled(tokenInput.isEmpty || appState.isAuthenticating)
                    .onHover { hovering in
                        isHoveringConnect = hovering
                    }
                    .animation(.easeInOut(duration: 0.15), value: isHoveringConnect)

                    // Help link
                    HStack(spacing: FlareSpacing.xs) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 10))
                        Text("Create a token at")
                            .font(.system(size: 10))
                        Text("dash.cloudflare.com/profile/api-tokens")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(FlareColors.textLink)
                    }
                    .foregroundStyle(FlareColors.textTertiary)
                }
                .padding(FlareSpacing.lg)
                .nestedGlass(cornerRadius: FlareRadius.window)

                // Version footer
                Text("Flare v1.0")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(FlareColors.textTertiary)
                    .padding(.top, FlareSpacing.xl)
            }
        }
        .liquidGlass(cornerRadius: FlareRadius.window).frame(width: 420)
        .frame(idealWidth: 520, idealHeight: 460)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.authError != nil)
    }
}
