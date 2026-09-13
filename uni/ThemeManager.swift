//
//  ThemeManager.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
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

// MARK: - Theme Manager
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    private static let storageKey = "uni_accent_color_hex"
    private static let themeModeStorageKey = "uni_theme_mode"
    
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
    
    public init() {
        self.accentColorHex = UserDefaults.standard.string(forKey: Self.storageKey) ?? "#0D5BFF"
        let savedMode = UserDefaults.standard.string(forKey: Self.themeModeStorageKey) ?? AppThemeMode.system.rawValue
        self.themeMode = AppThemeMode(rawValue: savedMode) ?? .system
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
    
    // Preset di colori d'accento in stile Apple / Modern
    public static let presets: [(name: String, hex: String)] = [
        ("Blu Apple", "#0D5BFF"),
        ("Smeraldo", "#10B981"),
        ("Viola Elettrico", "#8B5CF6"),
        ("Arancio", "#F59E0B"),
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

// MARK: - Apple Style Typography (SF Pro)
public struct UniFont {
    public static func largeTitle() -> Font {
        .system(size: 26, weight: .semibold, design: .default)
    }
    
    public static func title() -> Font {
        .system(size: 19, weight: .regular, design: .default)
    }
    
    public static func headline() -> Font {
        .system(size: 14, weight: .medium, design: .default)
    }
    
    public static func body() -> Font {
        .system(size: 13, weight: .light, design: .default)
    }
    
    public static func subheadline() -> Font {
        .system(size: 12, weight: .light, design: .default)
    }
    
    public static func caption() -> Font {
        .system(size: 11, weight: .regular, design: .default)
    }
    
    public static func mono() -> Font {
        .system(size: 12, weight: .light, design: .monospaced)
    }
}

// MARK: - Polished Apple-Style UI Components
public struct UniCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    @Environment(\.colorScheme) private var colorScheme
    
    public init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.24) : Color.black.opacity(0.035), radius: 3, x: 0, y: 1.5)
    }
    
    private var cardBackground: Color {
        #if canImport(AppKit)
        if colorScheme == .dark {
            return Color(nsColor: .controlBackgroundColor).opacity(0.85)
        } else {
            return Color.white
        }
        #else
        return colorScheme == .dark ? Color(white: 0.15) : Color.white
        #endif
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.11) : Color.black.opacity(0.065)
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
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(UniFont.caption())
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(colorScheme == .dark ? 0.18 : 0.10))
        .foregroundStyle(textColor)
        .clipShape(Capsule())
    }
    
    private var textColor: Color {
        // Se il badge ha colore secondario o chiaro in light mode, garantiamo contrasto
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
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
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
            VStack(alignment: .leading, spacing: 2) {
                if let subtitle = subtitle {
                    Text(subtitle.uppercased())
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                }
                Text(title)
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(actionTitle)
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
    }
}

// Backward compatibility alias
public typealias SuisseFont = UniFont
