//
//  Theme.swift
//  Flare
//
//  macOS Tahoe "Liquid Glass" design system
//

import SwiftUI
import AppKit

// MARK: - Color Palette

enum FlareColors {
    // Brand
    static let cloudflareOrange = Color(hex: "F6821F")
    static let cloudflareOrangeLight = Color(hex: "FBAD41")
    static let cloudflareOrangeDark = Color(hex: "E05D00")

    // Backgrounds — darker base for glass contrast
    static let bgPrimary = Color(hex: "0D1117")
    static let bgSecondary = Color(hex: "161B22")
    static let bgTertiary = Color(hex: "1C2128")
    static let bgElevated = Color(hex: "21262D")
    static let bgHover = Color(hex: "292E36")

    // Glass surfaces
    static let glassBackground = Color.white.opacity(0.06)
    static let glassBorder = Color.white.opacity(0.15)
    static let glassHighlight = Color.white.opacity(0.25)
    static let glassHover = Color.white.opacity(0.10)
    static let glassSurface = Color.white.opacity(0.04)
    static let glassOverlay = Color.white.opacity(0.08)

    // Text
    static let textPrimary = Color(hex: "E6EDF3")
    static let textSecondary = Color(hex: "8B949E")
    static let textTertiary = Color(hex: "6E7681")
    static let textLink = Color(hex: "58A6FF")

    // Borders
    static let borderPrimary = Color(hex: "30363D")
    static let borderSecondary = Color(hex: "21262D")

    // Status
    static let statusActive = Color(hex: "3FB950")
    static let statusWarning = Color(hex: "D29922")
    static let statusError = Color(hex: "F85149")
    static let statusPending = Color(hex: "A371F7")
    static let statusInfo = Color(hex: "58A6FF")

    // DNS Record Type Colors
    static let dnsA = Color(hex: "58A6FF")
    static let dnsAAAA = Color(hex: "79C0FF")
    static let dnsCNAME = Color(hex: "8A3FFC")
    static let dnsMX = Color(hex: "3FB950")
    static let dnsTXT = Color(hex: "D29922")
    static let dnsNS = Color(hex: "F778BA")
    static let dnsSRV = Color(hex: "FFA657")
    static let dnsCAA = Color(hex: "FF7B72")
    static let dnsDefault = Color(hex: "8B949E")

    static func colorForDNSType(_ type: String) -> Color {
        switch type.uppercased() {
        case "A": return dnsA
        case "AAAA": return dnsAAAA
        case "CNAME": return dnsCNAME
        case "MX": return dnsMX
        case "TXT": return dnsTXT
        case "NS": return dnsNS
        case "SRV": return dnsSRV
        case "CAA": return dnsCAA
        default: return dnsDefault
        }
    }
}

// MARK: - Spacing & Layout

enum FlareSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// MARK: - Tahoe Squircle Radii

enum FlareRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14       // Nested panels, cards, buttons
    static let xl: CGFloat = 20
    static let window: CGFloat = 24   // Main windows, top-level containers
    static let pill: CGFloat = 999
}

// MARK: - Liquid Glass View Modifiers

/// Primary Liquid Glass — for main panels and containers
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = FlareRadius.window

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass material
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // Glass tint layer
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(FlareColors.glassBackground)

                    // Top-left light refraction highlight
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.04),
                                    Color.clear,
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Edge border with refraction
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.10),
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
            )
    }
}

/// Nested Glass — for cards and panels inside glass containers
struct NestedGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = FlareRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Subtle glass surface
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(FlareColors.glassOverlay)

                    // Light refraction edge
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.02),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Micro-thin edge reflection
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.06),
                                    Color.white.opacity(0.03),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
    }
}

/// Stacked Glass for Stat Cards — with tinted accent glow
struct StatCardGlassModifier: ViewModifier {
    var accentColor: Color = FlareColors.statusInfo
    var cornerRadius: CGFloat = FlareRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass - using glassSurface (less opaque) to reduce grey look
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(FlareColors.glassSurface)

                    // Tinted accent glow — increased for visual pop
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(0.15),
                                    accentColor.opacity(0.04),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Top-left light refraction
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.04),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Micro-thin edge reflection
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    accentColor.opacity(0.18),
                                    Color.white.opacity(0.06),
                                    Color.white.opacity(0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
            )
            .shadow(color: accentColor.opacity(0.14), radius: 14, x: 0, y: 4)
    }
}

/// Hover Glow — cursor-tracking radial highlight
struct HoverGlowModifier: ViewModifier {
    var color: Color = Color.white
    var radius: CGFloat = 120
    @State private var hoverLocation: CGPoint = .zero
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isHovering {
                        RadialGradient(
                            colors: [
                                color.opacity(0.07),
                                color.opacity(0.03),
                                Color.clear
                            ],
                            center: UnitPoint(
                                x: hoverLocation.x / max(geo.size.width, 1),
                                y: hoverLocation.y / max(geo.size.height, 1)
                            ),
                            startRadius: 0,
                            endRadius: radius
                        )
                        .allowsHitTesting(false)
                    }
                }
                .allowsHitTesting(false)
            )
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoverLocation = location
                    withAnimation(.easeOut(duration: 0.15)) {
                        isHovering = true
                    }
                case .ended:
                    withAnimation(.easeOut(duration: 0.3)) {
                        isHovering = false
                    }
                }
            }
    }
}

/// Adaptive Backing — ensures AAA readability against glass
struct AdaptiveBackingModifier: ViewModifier {
    var opacity: Double = 0.85
    var cornerRadius: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(FlareColors.bgPrimary.opacity(opacity))
            )
    }
}

/// Light Refraction Edge — specular highlight overlay
struct LightRefractionEdge: ViewModifier {
    var cornerRadius: CGFloat = FlareRadius.lg

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
                    .allowsHitTesting(false)
            )
    }
}

/// Sidebar Selection — refractive light highlight carved into glass
struct GlassSelectionModifier: ViewModifier {
    var isSelected: Bool
    var accentColor: Color = FlareColors.cloudflareOrange

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.16),
                                        Color.white.opacity(0.08),
                                        accentColor.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: FlareRadius.md, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.30),
                                                accentColor.opacity(0.25),
                                                Color.white.opacity(0.12)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.75
                                    )
                            )
                            .shadow(color: accentColor.opacity(0.20), radius: 10, x: 0, y: 2)
                    }
                }
            )
    }
}

/// Glass Footer — slightly more opaque glass element
struct GlassFooterModifier: ViewModifier {
    var cornerRadius: CGFloat = FlareRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.thinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    FlareColors.cloudflareOrange.opacity(0.25),
                                    FlareColors.cloudflareOrange.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.06),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
    }
}

/// Liquid Glass Button
struct LiquidGlassButtonModifier: ViewModifier {
    var color: Color? = nil
    var isPrimary: Bool
    var cornerRadius: CGFloat = FlareRadius.lg
    
    func body(content: Content) -> some View {
        let baseColor = color ?? (isPrimary ? FlareColors.cloudflareOrange : FlareColors.glassOverlay)
        let isColorCustom = color != nil
        
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(baseColor)
                    
                    if isPrimary || isColorCustom {
                        // Glossy overlay for primary or colored buttons
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.20), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        // Glass refraction for secondary button
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // Refractive Edge
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(
                color: (color ?? (isPrimary ? FlareColors.cloudflareOrange : Color.black)).opacity(0.4),
                radius: (isPrimary || isColorCustom) ? 8 : 4,
                x: 0,
                y: (isPrimary || isColorCustom) ? 3 : 2
            )
    }
}

// MARK: - Old Modifier Compatibility (CardStyle, GlassStyle, GlowEffect)

struct CardStyle: ViewModifier {
    var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                        .fill(isHovered ? FlareColors.glassHover : FlareColors.glassOverlay)

                    RoundedRectangle(cornerRadius: FlareRadius.lg, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isHovered ? 0.10 : 0.06),
                                    Color.white.opacity(0.02),
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
                                    Color.white.opacity(0.06),
                                    Color.white.opacity(0.03),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

struct GlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassModifier(cornerRadius: FlareRadius.lg))
    }
}

struct GlowEffect: ViewModifier {
    var color: Color = FlareColors.cloudflareOrange
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlass(cornerRadius: CGFloat = FlareRadius.window) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }

    func nestedGlass(cornerRadius: CGFloat = FlareRadius.lg) -> some View {
        modifier(NestedGlassModifier(cornerRadius: cornerRadius))
    }

    func statCardGlass(accentColor: Color = FlareColors.statusInfo) -> some View {
        modifier(StatCardGlassModifier(accentColor: accentColor))
    }

    func hoverGlow(color: Color = .white, radius: CGFloat = 120) -> some View {
        modifier(HoverGlowModifier(color: color, radius: radius))
    }

    func adaptiveBacking(opacity: Double = 0.85, cornerRadius: CGFloat = 0) -> some View {
        modifier(AdaptiveBackingModifier(opacity: opacity, cornerRadius: cornerRadius))
    }

    func lightRefractionEdge(cornerRadius: CGFloat = FlareRadius.lg) -> some View {
        modifier(LightRefractionEdge(cornerRadius: cornerRadius))
    }

    func glassSelection(isSelected: Bool, accentColor: Color = FlareColors.cloudflareOrange) -> some View {
        modifier(GlassSelectionModifier(isSelected: isSelected, accentColor: accentColor))
    }

    func glassFooter(cornerRadius: CGFloat = FlareRadius.lg) -> some View {
        modifier(GlassFooterModifier(cornerRadius: cornerRadius))
    }

    func liquidGlassButton(color: Color? = nil, isPrimary: Bool = false, cornerRadius: CGFloat = FlareRadius.lg) -> some View {
        modifier(LiquidGlassButtonModifier(color: color, isPrimary: isPrimary, cornerRadius: cornerRadius))
    }

    func cardStyle(isHovered: Bool = false) -> some View {
        modifier(CardStyle(isHovered: isHovered))
    }

    func glassStyle() -> some View {
        modifier(GlassStyle())
    }

    func glowEffect(color: Color = FlareColors.cloudflareOrange, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
