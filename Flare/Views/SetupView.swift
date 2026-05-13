//
//  SetupView.swift
//  Flare
//
//  Premium onboarding screen for API token entry
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
            // Background gradient
            LinearGradient(
                colors: [
                    FlareColors.bgPrimary,
                    Color(hex: "0A0F14"),
                    FlareColors.bgPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle radial glow behind logo
            RadialGradient(
                colors: [
                    FlareColors.cloudflareOrange.opacity(0.06),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 200
            )
            .offset(y: -40)
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
                        .glowEffect(radius: 25)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    VStack(spacing: FlareSpacing.xs) {
                        Text("Welcome to Flare")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(FlareColors.textPrimary)

                        Text("Connect your Cloudflare account to get started")
                            .font(.system(size: 12))
                            .foregroundStyle(FlareColors.textSecondary)
                    }
                    .opacity(logoOpacity)
                }

                // Token Input Card
                VStack(spacing: FlareSpacing.md) {
                    VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                        HStack(spacing: FlareSpacing.xs) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(FlareColors.cloudflareOrange)
                            Text("API Token")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(FlareColors.textSecondary)
                        }

                        HStack(spacing: FlareSpacing.sm) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(FlareColors.textTertiary)

                            SecureField("Paste your Cloudflare API token", text: $tokenInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(FlareColors.textPrimary)
                        }
                        .padding(FlareSpacing.sm)
                        .padding(.horizontal, FlareSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md)
                                .fill(FlareColors.bgPrimary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.md)
                                        .strokeBorder(
                                            tokenInput.isEmpty
                                                ? FlareColors.borderPrimary
                                                : FlareColors.cloudflareOrange.opacity(0.5),
                                            lineWidth: 1
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
                            RoundedRectangle(cornerRadius: FlareRadius.sm)
                                .fill(FlareColors.statusError.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlareRadius.sm)
                                        .strokeBorder(FlareColors.statusError.opacity(0.2), lineWidth: 1)
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
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md)
                                .fill(
                                    tokenInput.isEmpty
                                        ? FlareColors.bgElevated
                                        : (isHoveringConnect
                                            ? FlareColors.cloudflareOrangeDark
                                            : FlareColors.cloudflareOrange)
                                )
                        )
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
                .background(
                    RoundedRectangle(cornerRadius: FlareRadius.xl)
                        .fill(FlareColors.bgSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: FlareRadius.xl)
                                .strokeBorder(FlareColors.borderPrimary, lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 30, y: 15)

                // Version footer
                Text("Flare v1.0")
                    .font(.system(size: 9))
                    .foregroundStyle(FlareColors.textTertiary)
            }
            .padding(FlareSpacing.xxl)
            .frame(width: 420)
        }
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
