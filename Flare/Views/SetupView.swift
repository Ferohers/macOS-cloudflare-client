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
            // Premium background filling the entire window
            FlareColors.bgPrimary
                .ignoresSafeArea()
            
            // Subtle ambient glow
            RadialGradient(
                colors: [FlareColors.cloudflareOrange.opacity(0.12), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: FlareSpacing.xl) {
                Spacer()

                // Logo & Title
                VStack(spacing: FlareSpacing.lg) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [FlareColors.cloudflareOrange, FlareColors.cloudflareOrangeLight],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .shadow(color: FlareColors.cloudflareOrange.opacity(0.4), radius: 20, x: 0, y: 0)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    VStack(spacing: FlareSpacing.xs) {
                        Text("Welcome to Flare")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(FlareColors.textPrimary)
                            .tracking(0.5)

                        Text("Connect your Cloudflare account to get started")
                            .font(.system(size: 13))
                            .foregroundStyle(FlareColors.textSecondary)
                    }
                    .opacity(logoOpacity)
                }

                // Token Input Card — Single Glass Panel
                VStack(spacing: FlareSpacing.lg) {
                    VStack(alignment: .leading, spacing: FlareSpacing.sm) {
                        HStack(spacing: FlareSpacing.xs) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(FlareColors.cloudflareOrange)
                            Text("API TOKEN")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(FlareColors.textSecondary)
                                .tracking(1.0)
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
                        .padding(.horizontal, FlareSpacing.md)
                        .padding(.vertical, FlareSpacing.sm + 2)
                        .background(
                            RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                .fill(Color.black.opacity(0.3))
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

                    if let error = appState.authError {
                        Text(error)
                            .font(.system(size: 11))
                            .foregroundStyle(FlareColors.statusError)
                            .padding(FlareSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(FlareColors.statusError.opacity(0.1))
                            .cornerRadius(FlareRadius.sm)
                    }

                    Button(action: {
                        Task { await appState.authenticate(token: tokenInput) }
                    }) {
                        HStack(spacing: FlareSpacing.sm) {
                            if appState.isAuthenticating {
                                ProgressView().controlSize(.small).tint(.white)
                            } else {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            Text(appState.isAuthenticating ? "Connecting..." : "Connect")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FlareSpacing.md)
                        .foregroundStyle(.white)
                        .liquidGlassButton(isPrimary: !tokenInput.isEmpty)
                    }
                    .buttonStyle(.plain)
                    .disabled(tokenInput.isEmpty || appState.isAuthenticating)

                    HStack(spacing: FlareSpacing.xs) {
                        Text("Create a token at")
                            .font(.system(size: 10))
                        Text("dash.cloudflare.com/profile/api-tokens")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(FlareColors.textLink)
                    }
                    .foregroundStyle(FlareColors.textTertiary)
                }
                .padding(FlareSpacing.xl)
                .frame(width: 400)
                .liquidGlass(cornerRadius: FlareRadius.xl)
                
                Spacer()

                Text("Flare v1.0")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(FlareColors.textTertiary)
                    .padding(.bottom, FlareSpacing.xl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}
