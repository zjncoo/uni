//
//  ColorPickerBoxView.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct ColorPickerBoxView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var hue: Double = 0.58
    @State private var saturation: Double = 0.85
    @State private var brightness: Double = 0.95
    @State private var hexInput: String = "0D5BFF"
    @State private var isCopied: Bool = false
    @FocusState private var isHexFocused: Bool
    
    private let boxWidth: CGFloat = 260
    private let boxHeight: CGFloat = 190
    private let barWidth: CGFloat = 24
    
    public init() {}
    
    public var body: some View {
        HStack(alignment: .top, spacing: 18) {
            // 1. Riquadro 2D Sfumato (Saturazione orizzontale / Luminosità verticale)
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    // Colore base della tonalità corrente
                    Color(hue: hue, saturation: 1.0, brightness: 1.0)
                    
                    // Gradiente orizzontale: da bianco a trasparente (Saturazione)
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .white.opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Gradiente verticale: da trasparente a nero (Luminosità)
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0), .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Cursore circolare di puntamento
                    let posX = CGFloat(saturation) * w
                    let posY = CGFloat(1.0 - brightness) * h
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .background(Circle().stroke(Color.black.opacity(0.4), lineWidth: 1))
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .frame(width: 14, height: 14)
                        .position(x: min(max(posX, 7), w - 7), y: min(max(posY, 7), h - 7))
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let sat = max(0.0, min(1.0, Double(value.location.x / w)))
                            let bri = max(0.0, min(1.0, Double(1.0 - (value.location.y / h))))
                            self.saturation = sat
                            self.brightness = bri
                            syncFromHSB()
                        }
                )
            }
            .frame(width: boxWidth, height: boxHeight)
            
            // 2. Barra Verticale Arcobaleno (Tonalità / Hue)
            GeometryReader { geo in
                let barH = geo.size.height
                
                ZStack(alignment: .top) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 1.0, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.8333, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.6667, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.5, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.3333, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.1667, saturation: 1.0, brightness: 1.0),
                            Color(hue: 0.0, saturation: 1.0, brightness: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: barWidth, height: barH)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                    
                    // Frecce indicatrici laterali
                    let arrowY = (1.0 - CGFloat(hue)) * (barH - 8)
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.primary)
                            .shadow(radius: 1)
                        
                        Spacer()
                        
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.primary)
                            .shadow(radius: 1)
                    }
                    .frame(width: barWidth + 12)
                    .offset(x: -6, y: arrowY)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newHue = max(0.0, min(1.0, Double(1.0 - (value.location.y / barH))))
                            self.hue = newHue
                            syncFromHSB()
                        }
                )
            }
            .frame(width: barWidth + 12, height: boxHeight)
            
            // 3. Anteprima & Codice HEX Copiabile e Modificabile a Mano
            VStack(alignment: .leading, spacing: 14) {
                // Riquadro Anteprima Colore
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.currentLanguage == .italian ? "Anteprima" : "Preview")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(themeManager.accentColor)
                        .frame(width: 80, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 6, y: 2)
                }
                
                Divider()
                    .frame(width: 160)
                
                // Campo HEX (#) Modificabile a Mano e Copiabile
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.currentLanguage == .italian ? "Codice HEX" : "HEX Code")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Text("#")
                            .font(UniFont.headline())
                            .foregroundStyle(.secondary)
                        
                        TextField("000000", text: $hexInput)
                            .textFieldStyle(.roundedBorder)
                            .font(UniFont.mono())
                            .frame(width: 90)
                            .focused($isHexFocused)
                            .onChange(of: hexInput) { _, newValue in
                                var clean = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                if clean.hasPrefix("#") { clean.removeFirst() }
                                if clean.count == 6 || clean.count == 3 {
                                    applyHex(clean, updateInputText: false)
                                }
                            }
                            .onChange(of: isHexFocused) { _, focused in
                                if !focused {
                                    applyHex(hexInput, updateInputText: true)
                                }
                            }
                            .onSubmit {
                                applyHex(hexInput, updateInputText: true)
                                isHexFocused = false
                            }
                        
                        // Pulsante Copia negli Appunti
                        Button {
                            copyHex()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundStyle(isCopied ? .green : .primary)
                            }
                            .frame(width: 28, height: 24)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.currentLanguage == .italian ? "Copia codice esadecimale (⌘C)" : "Copy HEX code")
                    }
                    
                    if isCopied {
                        Text(localizationManager.currentLanguage == .italian ? "Copiato negli appunti!" : "Copied to clipboard!")
                            .font(UniFont.caption())
                            .foregroundStyle(.green)
                            .transition(.opacity)
                    }
                }
            }
            .padding(.leading, 6)
        }
        .onAppear {
            loadFromTheme()
        }
        .onChange(of: themeManager.accentColorHex) { _, _ in
            if !isHexFocused {
                loadFromTheme()
            }
        }
    }
    
    // MARK: - Synchronizations
    private func loadFromTheme() {
        let hex = themeManager.accentColorHex
        if let (r, g, b) = parseHex(hex) {
            let (h, s, bri) = rgbToHsb(r: r, g: g, b: b)
            self.hue = h
            self.saturation = s
            self.brightness = bri
            
            var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            if clean.hasPrefix("#") { clean.removeFirst() }
            self.hexInput = clean.uppercased()
        }
    }
    
    private func syncFromHSB() {
        let (r, g, b) = hsbToRgb(h: hue, s: saturation, b: brightness)
        let hexStr = String(format: "%02X%02X%02X", r, g, b)
        if !isHexFocused {
            self.hexInput = hexStr
        }
        let fullHex = "#" + hexStr
        if themeManager.accentColorHex.uppercased() != fullHex {
            themeManager.accentColorHex = fullHex
        }
    }
    
    private func applyHex(_ str: String, updateInputText: Bool) {
        if let (r, g, b) = parseHex(str) {
            let (h, s, bri) = rgbToHsb(r: r, g: g, b: b)
            self.hue = h
            self.saturation = s
            self.brightness = bri
            
            let hexStr = String(format: "%02X%02X%02X", r, g, b)
            if updateInputText {
                self.hexInput = hexStr
            }
            let fullHex = "#" + hexStr
            if themeManager.accentColorHex.uppercased() != fullHex {
                themeManager.accentColorHex = fullHex
            }
        } else if updateInputText {
            // Ripristina l'hex attuale se non valido
            loadFromTheme()
        }
    }
    
    private func copyHex() {
        #if canImport(AppKit)
        let clean = hexInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let pasteString = clean.hasPrefix("#") ? clean : "#" + clean
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(pasteString, forType: .string)
        
        withAnimation {
            self.isCopied = true
        }
        
        NotificationManager.shared.notify(
            title: "Colore copiato",
            message: "\(pasteString) copiato negli appunti",
            type: .custom(themeManager.accentColor),
            icon: "doc.on.doc",
            postToSystem: false
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                self.isCopied = false
            }
        }
        #endif
    }
    
    // MARK: - Color Conversion Helpers
    private func parseHex(_ hex: String) -> (Int, Int, Int)? {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("#") { clean.removeFirst() }
        if clean.count == 3 {
            let chars = Array(clean)
            clean = "\(chars[0])\(chars[0])\(chars[1])\(chars[1])\(chars[2])\(chars[2])"
        }
        guard clean.count == 6 else { return nil }
        var rgbValue: UInt64 = 0
        guard Scanner(string: clean).scanHexInt64(&rgbValue) else { return nil }
        let r = Int((rgbValue & 0xFF0000) >> 16)
        let g = Int((rgbValue & 0x00FF00) >> 8)
        let b = Int(rgbValue & 0x0000FF)
        return (r, g, b)
    }
    
    private func hsbToRgb(h: Double, s: Double, b: Double) -> (Int, Int, Int) {
        if s <= 0.0001 {
            let v = Int(round(b * 255.0))
            return (v, v, v)
        }
        
        let hueSix = (h >= 1.0 ? 0.0 : h) * 6.0
        let i = Int(hueSix)
        let f = hueSix - Double(i)
        let p = b * (1.0 - s)
        let q = b * (1.0 - f * s)
        let t = b * (1.0 - (1.0 - f) * s)
        
        var rd = 0.0
        var gd = 0.0
        var bd = 0.0
        
        switch i % 6 {
        case 0: rd = b; gd = t; bd = p
        case 1: rd = q; gd = b; bd = p
        case 2: rd = p; gd = b; bd = t
        case 3: rd = p; gd = q; bd = b
        case 4: rd = t; gd = p; bd = b
        case 5: rd = b; gd = p; bd = q
        default: break
        }
        
        return (
            max(0, min(255, Int(round(rd * 255.0)))),
            max(0, min(255, Int(round(gd * 255.0)))),
            max(0, min(255, Int(round(bd * 255.0))))
        )
    }
    
    private func rgbToHsb(r: Int, g: Int, b: Int) -> (Double, Double, Double) {
        let rd = Double(r) / 255.0
        let gd = Double(g) / 255.0
        let bd = Double(b) / 255.0
        
        let maxC = max(rd, gd, bd)
        let minC = min(rd, gd, bd)
        let delta = maxC - minC
        
        let bri = maxC
        let sat = maxC == 0 ? 0 : delta / maxC
        
        var h = 0.0
        if delta > 0.00001 {
            if maxC == rd {
                h = ((gd - bd) / delta).truncatingRemainder(dividingBy: 6.0)
            } else if maxC == gd {
                h = ((bd - rd) / delta) + 2.0
            } else {
                h = ((rd - gd) / delta) + 4.0
            }
            h = h / 6.0
            if h < 0 { h += 1.0 }
        }
        
        return (h, sat, bri)
    }
}
