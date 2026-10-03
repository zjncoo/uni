//
//  ThemeManager.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import Combine

// MARK: - Theme Mode (Chiaro / Scuro / Sistema)
public enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - App Font Design
public enum AppFontDesign: String, CaseIterable, Identifiable {
    case modern = "modern"          // Sans-serif geometrico sottile
    case serif = "serif"            // Serif editoriale raffinato
    case monospaced = "monospaced"  // Monospace tecnico
    case rounded = "rounded"        // Arrotondato minimal
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .modern: return "Geometrico Sottile"
        case .serif: return "Serif Editoriale"
        case .monospaced: return "Monospazio Tecnico"
        case .rounded: return "Arrotondato"
        }
    }
    
    public var swiftUIDesign: Font.Design {
        switch self {
        case .modern: return .default
        case .serif: return .serif
        case .monospaced: return .monospaced
        case .rounded: return .rounded
        }
    }
}

// MARK: - Theme Manager
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    private static let storageKey = "uni_accent_color_hex"
    private static let themeModeStorageKey = "uni_theme_mode"
    private static let fontDesignStorageKey = "uni_font_design"
    private static let customFontStorageKey = "uni_custom_font_family"
    
    @Published public var accentColorHex: String {
        didSet {
            UserDefaults.standard.set(accentColorHex, forKey: Self.storageKey)
        }
    }
    
    @Published public var themeMode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: Self.themeModeStorageKey)
            applyAppearance()
        }
    }
    
    @Published public var fontDesign: AppFontDesign {
        didSet {
            UserDefaults.standard.set(fontDesign.rawValue, forKey: Self.fontDesignStorageKey)
        }
    }
    
    @Published public var customFontFamily: String {
        didSet {
            UserDefaults.standard.set(customFontFamily, forKey: Self.customFontStorageKey)
        }
    }
    
    public init() {
        self.accentColorHex = UserDefaults.standard.string(forKey: Self.storageKey) ?? "#0D5BFF"
        let savedMode = UserDefaults.standard.string(forKey: Self.themeModeStorageKey) ?? AppThemeMode.system.rawValue
        self.themeMode = AppThemeMode(rawValue: savedMode) ?? .system
        
        let savedFontDesign = UserDefaults.standard.string(forKey: Self.fontDesignStorageKey) ?? AppFontDesign.modern.rawValue
        self.fontDesign = AppFontDesign(rawValue: savedFontDesign) ?? .modern
        self.customFontFamily = UserDefaults.standard.string(forKey: Self.customFontStorageKey) ?? ""
        
        applyAppearance()
    }
    
    public func applyAppearance() {
        #if canImport(AppKit)
        DispatchQueue.main.async {
            switch self.themeMode {
            case .system:
                NSApp.appearance = nil
            case .light:
                NSApp.appearance = NSAppearance(named: .aqua)
            case .dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }
        }
        #endif
    }
    
    // Preset di colori d'accento personalizzabili dall'utente
    public static let presets: [(name: String, hex: String)] = [
        ("Arancio", "#FF5500"),
        ("Blu Cobalto", "#0D5BFF"),
        ("Smeraldo", "#10B981"),
        ("Viola Elettrico", "#8B5CF6"),
        ("Arancio Caldo", "#F59E0B"),
        ("Rosso", "#EF4444"),
        ("Grafite", "#4B5563"),
        ("Ciano", "#06B6D4"),
        ("Rosa", "#EC4899")
    ]
    
    public var accentColor: Color {
        Color(hex: accentColorHex) ?? Color.blue
    }
    
    /// Testo ad alto contrasto (bianco o nero) a seconda della luminosità del colore d'accento
    public var accentTextColor: Color {
        accentColor.contrastTextColor
    }
    
    /// Calcola il colore di testo (bianco o nero) con contrasto accessibile per qualsiasi colore di sfondo
    public func contrastTextColor(for color: Color) -> Color {
        color.contrastTextColor
    }
    
    // Supporto per Slider HSB aperti integrati nella view
    #if canImport(AppKit)
    public var hue: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.hueComponent)
    }
    public var saturation: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.saturationComponent)
    }
    public var brightness: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.brightnessComponent)
    }
    
    public var red: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.redComponent)
    }
    public var green: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.greenComponent)
    }
    public var blue: Double {
        let ns = NSColor(Color(hex: accentColorHex) ?? .blue).usingColorSpace(.sRGB) ?? NSColor.blue
        return Double(ns.blueComponent)
    }
    
    public func updateRGB(red: Double, green: Double, blue: Double) {
        let r = max(0, min(255, Int(round(red * 255))))
        let g = max(0, min(255, Int(round(green * 255))))
        let b = max(0, min(255, Int(round(blue * 255))))
        self.accentColorHex = String(format: "#%02X%02X%02X", r, g, b)
    }
    
    public func updateHSB(hue: Double, saturation: Double, brightness: Double) {
        let ns = NSColor(calibratedHue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1.0)
        if let srgb = ns.usingColorSpace(.sRGB) {
            let r = Int(round(srgb.redComponent * 255))
            let g = Int(round(srgb.greenComponent * 255))
            let b = Int(round(srgb.blueComponent * 255))
            self.accentColorHex = String(format: "#%02X%02X%02X", r, g, b)
        }
    }
    #endif
}

// MARK: - Color Hex & Accessible Contrast Extensions
extension Color {
    public init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        guard cleanHex.count == 6 || cleanHex.count == 8 else { return nil }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgbValue) else { return nil }
        
        let r, g, b, a: Double
        if cleanHex.count == 6 {
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        } else {
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
    
    public func toHex() -> String {
        #if canImport(AppKit)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return "#0D5BFF" }
        let r = Int(round(rgbColor.redComponent * 255))
        let g = Int(round(rgbColor.greenComponent * 255))
        let b = Int(round(rgbColor.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return "#0D5BFF"
        #endif
    }
    
    /// Luminosità percepita (da 0.0 per il nero a 1.0 per il bianco)
    public var perceivedLuminance: Double {
        #if canImport(AppKit)
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.blue
        let r = Double(ns.redComponent)
        let g = Double(ns.greenComponent)
        let b = Double(ns.blueComponent)
        return 0.299 * r + 0.587 * g + 0.114 * b
        #else
        return 0.5
        #endif
    }
    
    /// Luminanza relativa WCAG 2.1
    public var relativeLuminance: Double {
        #if canImport(AppKit)
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.blue
        func channelLuminance(_ val: CGFloat) -> Double {
            let v = Double(val)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        let r = channelLuminance(ns.redComponent)
        let g = channelLuminance(ns.greenComponent)
        let b = channelLuminance(ns.blueComponent)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
        #else
        return 0.5
        #endif
    }
    
    /// Rapporto di contrasto WCAG (da 1.0 a 21.0) con un altro colore
    public func contrastRatio(with other: Color) -> Double {
        let l1 = self.relativeLuminance
        let l2 = other.relativeLuminance
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Restituisce testo nero o bianco per garantire la massima leggibilità e accessibilità (WCAG).
    /// Se il colore di sfondo rende il testo bianco poco visibile (luminanza elevata o contrasto scarso),
    /// restituisce automaticamente il colore nero.
    public var contrastTextColor: Color {
        #if canImport(AppKit)
        let whiteContrast = self.contrastRatio(with: .white)
        let blackContrast = self.contrastRatio(with: .black)
        let lum = self.perceivedLuminance
        
        // Se il contrasto con il bianco è sotto 3.5, o la luminosità percepita è > 0.48,
        // o il nero offre un contrasto nettamente superiore a quello del bianco:
        if lum > 0.48 || whiteContrast < 3.5 || blackContrast > (whiteContrast * 1.1) {
            return Color.black
        }
        return Color.white
        #else
        return Color.white
        #endif
    }
}

extension View {
    /// Applica colore di testo (bianco o nero) garantendo sempre un contrasto ottimale sullo sfondo specificato
    public func contrastForeground(on backgroundColor: Color) -> some View {
        self.foregroundStyle(backgroundColor.contrastTextColor)
    }
}

// MARK: - Scandinavian / Geometric Modern Typography (Sottile & Personalizzabile)
public struct UniFont {
    private static var activeDesign: Font.Design {
        ThemeManager.shared.fontDesign.swiftUIDesign
    }
    
    private static var customFamily: String {
        ThemeManager.shared.customFontFamily.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func font(size: CGFloat, weight: Font.Weight, design: Font.Design? = nil) -> Font {
        let custom = customFamily
        if !custom.isEmpty {
            return .custom(custom, size: size)
        }
        return .system(size: size, weight: weight, design: design ?? activeDesign)
    }
    
    /// Numero o lettera display gigante per statistiche d'impatto - leggero e raffinato
    public static func displayGigantic() -> Font {
        font(size: 40, weight: .light)
    }
    
    /// Valore numerico metrico per statistiche primarie (es. CFU, Media, Percentuali)
    public static func displayMetric() -> Font {
        font(size: 26, weight: .light)
    }
    
    /// Font display parametrico per dimensioni personalizzate
    public static func display(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        font(size: size, weight: weight)
    }
    
    /// Micro-etichetta con tracking largo architettonico
    public static func sectionLabel() -> Font {
        font(size: 10, weight: .medium)
    }
    
    public static func largeTitle() -> Font {
        font(size: 22, weight: .regular)
    }
    
    public static func title() -> Font {
        font(size: 16.5, weight: .regular)
    }
    
    public static func headline() -> Font {
        font(size: 13.5, weight: .medium)
    }
    
    public static func body() -> Font {
        font(size: 13, weight: .light)
    }
    
    public static func subheadline() -> Font {
        font(size: 12, weight: .light)
    }
    
    public static func caption() -> Font {
        font(size: 11, weight: .light)
    }
    
    public static func mono() -> Font {
        let custom = customFamily
        if !custom.isEmpty {
            return .custom(custom, size: 12)
        }
        return .system(size: 12, weight: .light, design: .monospaced)
    }
}

// MARK: - Card Style
public enum UniCardStyle {
    case surface       // Superficie piana antracite scura / bianco puro con bordo micro-fine
    case liquidGlass   // Vetro liquido translucido ultraThinMaterial con riflesso satinato
    case accentHero    // Sfondo solido nel colore d'accento ad alto contrasto
    case secondary     // Grigio secondario pulito
    case outline       // Solo contorno geometrico
}

// MARK: - Polished Bento Card (Supporta sia Spigoli Netti a 90° che angoli arrotondati e finitura Liquid Glass)
public struct UniCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 0 // Default 0 per mantenere i quadrati spigolosi nella overview
    var style: UniCardStyle = .surface
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    
    public init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 0,
        style: UniCardStyle = .surface,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.style = style
        self.content = content()
    }
    
    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: max(0, cornerRadius), style: .continuous)
        content
            .padding(padding)
            .background(
                Group {
                    if style == .liquidGlass {
                        shape
                            .fill(.ultraThinMaterial)
                    } else {
                        shape
                            .fill(backgroundFill)
                    }
                }
            )
            .overlay(
                shape
                    .strokeBorder(strokeBorderColor, lineWidth: 1)
            )
            .clipShape(shape)
            .shadow(
                color: style == .liquidGlass ? Color.black.opacity(colorScheme == .dark ? 0.22 : 0.05) : Color.clear,
                radius: 12,
                x: 0,
                y: 4
            )
    }
    
    private var backgroundFill: Color {
        switch style {
        case .liquidGlass:
            return colorScheme == .dark ? (Color(hex: "#151618") ?? Color.black).opacity(0.85) : Color.white.opacity(0.85)
        case .accentHero:
            return themeManager.accentColor
        case .surface:
            return colorScheme == .dark ? (Color(hex: "#151618") ?? Color.black) : Color.white
        case .secondary:
            return colorScheme == .dark ? (Color(hex: "#1C1D21") ?? Color.gray) : (Color(hex: "#F2F3F5") ?? Color.white)
        case .outline:
            return Color.clear
        }
    }
    
    private var strokeBorderColor: Color {
        switch style {
        case .liquidGlass:
            return colorScheme == .dark ? Color.white.opacity(0.14) : Color.white.opacity(0.75)
        case .accentHero:
            return Color.clear
        case .surface:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
        case .secondary:
            return colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.04)
        case .outline:
            return colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.10)
        }
    }
}

// MARK: - Fluid Background Gradient (Liquid Glass Backdrop ispirato a Mastro)
public struct UniBackgroundGradientView: View {
    let isDarkMode: Bool
    
    public init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }
    
    public var body: some View {
        let colors = isDarkMode
            ? [Color(red: 0.08, green: 0.09, blue: 0.12), Color(red: 0.04, green: 0.05, blue: 0.07)]
            : [Color(red: 0.95, green: 0.96, blue: 0.98), Color(red: 0.89, green: 0.91, blue: 0.94)]
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

// MARK: - Liquid Sidebar Navigation Button (Ispirato a Mastro con micro-interazioni polished)
public struct SidebarButtonLiquidUni: View {
    let title: String
    let icon: String
    var count: Int = 0
    var badgeText: String? = nil
    var shortcutHint: String? = nil
    var isCollapsed: Bool = false
    let isSelected: Bool
    let isDark: Bool
    let action: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isHovered: Bool = false
    
    public init(
        title: String,
        icon: String,
        count: Int = 0,
        badgeText: String? = nil,
        shortcutHint: String? = nil,
        isCollapsed: Bool = false,
        isSelected: Bool,
        isDark: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.count = count
        self.badgeText = badgeText
        self.shortcutHint = shortcutHint
        self.isCollapsed = isCollapsed
        self.isSelected = isSelected
        self.isDark = isDark
        self.action = action
    }
    
    private var iconColor: Color {
        if isSelected { return themeManager.accentColor }
        return isDark ? Color.white.opacity(0.9) : Color.black.opacity(0.85)
    }
    
    private var textColor: Color {
        if isSelected {
            return themeManager.accentColor
        }
        return isDark ? Color.white.opacity(0.9) : Color.black.opacity(0.85)
    }
    
    private var badgeBgColor: Color {
        if isSelected { return themeManager.accentColor.opacity(0.22) }
        return Color.primary.opacity(0.08)
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                action()
            }
        }) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Fixed 64pt leading container: center X is ALWAYS 32, NEVER shifts!
                    ZStack {
                        Image(systemName: icon)
                            .font(.system(size: 13.5, weight: isSelected ? .bold : .medium))
                            .foregroundColor(iconColor)
                        
                        if isCollapsed && (count > 0 || (badgeText != nil && !badgeText!.isEmpty)) {
                            Circle()
                                .fill(themeManager.accentColor)
                                .frame(width: 6, height: 6)
                                .offset(x: 9, y: -9)
                        }
                    }
                    .frame(width: 64, height: 40, alignment: .center)
                    
                    // Labels smoothly appear to the right from X = 64
                    HStack(spacing: 6) {
                        Text(title)
                            .font(UniFont.body())
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                        
                        Spacer(minLength: 0)
                        
                        if let hint = shortcutHint, !isSelected && !isHovered && count == 0 {
                            Text(hint)
                                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary.opacity(0.6))
                        }
                        
                        if let b = badgeText, !b.isEmpty {
                            Text(b)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(badgeBgColor)
                                .foregroundColor(isSelected ? themeManager.accentColor : .secondary)
                                .clipShape(Capsule())
                        } else if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 10.5, weight: .bold))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(badgeBgColor)
                                .foregroundColor(isSelected ? themeManager.accentColor : .secondary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.trailing, 14)
                    .frame(width: 181, alignment: .leading)
                    .opacity(isCollapsed ? 0 : 1)
                    .clipped()
                }
                .frame(width: 245, height: 40, alignment: .leading)
                .contentShape(Rectangle())
                .opacity(isHovered ? 0.50 : 1.0)
                
                // Architectural 1.5pt Divider line (visible ONLY when expanded, never when compressed)
                Rectangle()
                    .fill(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.10))
                    .frame(height: 1.5)
                    .opacity(isCollapsed ? 0 : 1.0)
                    .padding(.horizontal, 10)
            }
        }
        .buttonStyle(.plain)
        .help(title)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hover
            }
        }
    }
}

// MARK: - Polished Liquid Button Style (Pulsanti generali dell'app)
public struct LiquidButtonStyle: ButtonStyle {
    var isAccent: Bool = false
    var cornerRadius: CGFloat = 8
    
    public init(isAccent: Bool = false, cornerRadius: CGFloat = 8) {
        self.isAccent = isAccent
        self.cornerRadius = cornerRadius
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        LiquidButtonView(configuration: configuration, isAccent: isAccent, cornerRadius: cornerRadius)
    }
    
    private struct LiquidButtonView: View {
        let configuration: Configuration
        let isAccent: Bool
        let cornerRadius: CGFloat
        
        @Environment(\.colorScheme) private var colorScheme
        @EnvironmentObject private var themeManager: ThemeManager
        @State private var isHovered: Bool = false
        
        var body: some View {
            configuration.label
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(backgroundFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(strokeColor, lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : (isHovered ? 1.015 : 1.0))
                .animation(.spring(response: 0.25, dampingFraction: 0.78), value: isHovered)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
        
        private var backgroundFill: Color {
            if isAccent {
                return configuration.isPressed ? themeManager.accentColor.opacity(0.85) : (isHovered ? themeManager.accentColor.opacity(0.95) : themeManager.accentColor)
            }
            if colorScheme == .dark {
                return configuration.isPressed ? Color.white.opacity(0.14) : (isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            } else {
                return configuration.isPressed ? Color.black.opacity(0.08) : (isHovered ? Color.white.opacity(0.85) : Color.white.opacity(0.55))
            }
        }
        
        private var strokeColor: Color {
            if isAccent {
                return Color.white.opacity(0.25)
            }
            if colorScheme == .dark {
                return isHovered ? Color.white.opacity(0.22) : Color.white.opacity(0.08)
            } else {
                return isHovered ? Color.white : Color.black.opacity(0.08)
            }
        }
    }
}

// MARK: - Minimalist Block Progress Gauge (Indicatore Geometrico a Blocchi)
public struct UniBlockProgress: View {
    var value: Double       // 0.0 ... 1.0
    var height: CGFloat = 10
    var cornerRadius: CGFloat = 0 // Spigoli geometrici netti
    var activeColor: Color? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    
    public init(value: Double, height: CGFloat = 10, cornerRadius: CGFloat = 0, activeColor: Color? = nil) {
        self.value = max(0, min(1.0, value))
        self.height = height
        self.cornerRadius = cornerRadius
        self.activeColor = activeColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Sfondo barra neutro scuro
                Rectangle()
                    .fill(colorScheme == .dark ? (Color(hex: "#2C2C2E") ?? Color.gray) : (Color(hex: "#E5E5EA") ?? Color.gray))
                
                // Blocco riempito pieno
                Rectangle()
                    .fill(activeColor ?? themeManager.accentColor)
                    .frame(width: max(0, geo.size.width * CGFloat(value)))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Minimalist Bento Tile (Modular Grid Tile con Spigoli Netti)
public struct UniBentoTile<TopTrailing: View, BottomContent: View>: View {
    let title: String
    var subtitle: String? = nil
    var isHero: Bool = false
    var cornerRadius: CGFloat = 0
    var topTrailing: TopTrailing
    var bottomContent: BottomContent
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ThemeManager
    
    public init(
        title: String,
        subtitle: String? = nil,
        isHero: Bool = false,
        cornerRadius: CGFloat = 0,
        @ViewBuilder topTrailing: () -> TopTrailing,
        @ViewBuilder bottomContent: () -> BottomContent
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isHero = isHero
        self.cornerRadius = cornerRadius
        self.topTrailing = topTrailing()
        self.bottomContent = bottomContent()
    }
    
    public var body: some View {
        UniCard(padding: 16, cornerRadius: cornerRadius, style: isHero ? .accentHero : .surface) {
            VStack(alignment: .leading, spacing: 0) {
                // Riga superiore: Titolo e azione / menu
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(UniFont.headline())
                            .foregroundStyle(isHero ? themeManager.accentTextColor : .primary)
                            .lineLimit(2)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(UniFont.caption())
                                .foregroundStyle(isHero ? themeManager.accentTextColor.opacity(0.85) : .secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    topTrailing
                }
                
                Spacer(minLength: 20)
                
                // Sezione inferiore: icona al tratto o metrica
                bottomContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension UniBentoTile where TopTrailing == EmptyView {
    public init(
        title: String,
        subtitle: String? = nil,
        isHero: Bool = false,
        cornerRadius: CGFloat = 0,
        @ViewBuilder bottomContent: () -> BottomContent
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            isHero: isHero,
            cornerRadius: cornerRadius,
            topTrailing: { EmptyView() },
            bottomContent: bottomContent
        )
    }
}

public struct UniBadge: View {
    let text: String
    var color: Color
    var icon: String? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    public init(_ text: String, color: Color = .secondary, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
            Text(text.uppercased())
                .font(.system(size: 9.5, weight: .bold))
                .tracking(0.6)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .background(color.opacity(colorScheme == .dark ? 0.16 : 0.09))
        .foregroundStyle(textColor)
        .clipShape(Rectangle())
    }
    
    private var textColor: Color {
        if colorScheme == .dark {
            return color
        } else {
            return color == .secondary ? .secondary : color
        }
    }
}


public struct UniEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    @EnvironmentObject var themeManager: ThemeManager
    
    public init(
        icon: String,
        title: String,
        subtitle: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.04))
                    .frame(width: 54, height: 54)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 3) {
                Text(title)
                    .font(UniFont.headline())
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(buttonTitle)
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 6)
                    .background(themeManager.accentColor)
                    .foregroundStyle(themeManager.accentTextColor)
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 18)
        .background(
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.primary.opacity(0.08))
        )
    }
}

public struct UniHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    @EnvironmentObject var themeManager: ThemeManager
    
    public init(_ title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                if let subtitle = subtitle {
                    Text(subtitle.uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                }
                Text(title)
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(actionTitle)
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.06))
                    .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
    }
}

// Backward compatibility alias
public typealias SuisseFont = UniFont
