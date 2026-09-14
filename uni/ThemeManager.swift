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
        #if canImport(AppKit)
        let ns = NSColor(accentColor).usingColorSpace(.sRGB) ?? NSColor.blue
        let luminance = 0.299 * Double(ns.redComponent) + 0.587 * Double(ns.greenComponent) + 0.114 * Double(ns.blueComponent)
        return luminance > 0.62 ? Color.black : Color.white
        #else
        return Color.white
        #endif
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

// MARK: - Color Hex Extensions
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
    case accentHero    // Sfondo solido nel colore d'accento ad alto contrasto
    case secondary     // Grigio secondario pulito
    case outline       // Solo contorno geometrico
}

// MARK: - Polished Minimalist Bento Card (Riquadri con Spigoli Vivi)
public struct UniCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 0 // Spigoli geometrici netti a 90°
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
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: max(0, cornerRadius), style: .continuous)
                    .fill(backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: max(0, cornerRadius), style: .continuous)
                    .strokeBorder(strokeBorderColor, lineWidth: 1)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: max(0, cornerRadius), style: .continuous)
            )
    }
    
    private var backgroundFill: Color {
        switch style {
        case .accentHero:
            return themeManager.accentColor
        case .surface:
            return colorScheme == .dark ? Color(hex: "#141414")! : Color.white
        case .secondary:
            return colorScheme == .dark ? Color(hex: "#1C1C1E")! : Color(hex: "#F2F3F5")!
        case .outline:
            return Color.clear
        }
    }
    
    private var strokeBorderColor: Color {
        switch style {
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
                    .fill(colorScheme == .dark ? Color(hex: "#2C2C2E")! : Color(hex: "#E5E5EA")!)
                
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
                    .foregroundStyle(.white)
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
