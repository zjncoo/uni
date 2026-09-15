//
//  SettingsView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var quoteManager: QuoteManager
    
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var updateManager = UpdateManager.shared
    @State private var isShowingOnboarding = false
    @State private var showingClearAlert = false
    @State private var newQuoteText: String = ""
    @State private var editStudentName: String = ""
    @State private var editUniversityName: String = ""
    @State private var editUniversityPortalURL: String = ""
    
    // Gestione Scorciatoie Home & Bottone Rapido Navbar
    @State private var isShowingAddShortcutSheet = false
    @State private var editingShortcut: QuickShortcutLink? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                UniHeader(
                    localizationManager.t(.settingsTitle),
                    subtitle: localizationManager.t(.settingsSubtitle)
                )
                
                // SEZIONE 0: PROFILO STUDENTE & ATENEO
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.currentLanguage == .italian ? "PROFILO & ATENEO" : "STUDENT PROFILE & UNIVERSITY")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(localizationManager.currentLanguage == .italian ? "Personalizza il tuo nome e il link rapido al portale o sito della tua università." : "Customize your name and quick shortcut link to your university portal or website.")
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                                GridRow {
                                    Text(localizationManager.currentLanguage == .italian ? "Tuo Nome:" : "Your Name:")
                                        .font(UniFont.subheadline())
                                        .foregroundStyle(.secondary)
                                        .gridColumnAlignment(.trailing)
                                    TextField(localizationManager.currentLanguage == .italian ? "Es. Francesco" : "e.g. Alex", text: $dataManager.studentName)
                                        .textFieldStyle(.roundedBorder)
                                        .font(UniFont.body())
                                        .onChange(of: dataManager.studentName) { dataManager.saveData() }
                                }
                                
                                GridRow {
                                    Text(localizationManager.currentLanguage == .italian ? "Università:" : "University:")
                                        .font(UniFont.subheadline())
                                        .foregroundStyle(.secondary)
                                    TextField(localizationManager.currentLanguage == .italian ? "Es. Politecnico di Milano, UniMi, UniPD..." : "e.g. Stanford, MIT, Oxford...", text: $dataManager.universityName)
                                        .textFieldStyle(.roundedBorder)
                                        .font(UniFont.body())
                                        .onChange(of: dataManager.universityName) { dataManager.saveData() }
                                }
                                
                                GridRow {
                                    Text(localizationManager.currentLanguage == .italian ? "Sito / Portale:" : "Website / Portal:")
                                        .font(UniFont.subheadline())
                                        .foregroundStyle(.secondary)
                                    HStack {
                                        TextField("https://...", text: $dataManager.universityPortalURL)
                                            .textFieldStyle(.roundedBorder)
                                            .font(UniFont.body())
                                            .onChange(of: dataManager.universityPortalURL) { dataManager.saveData() }
                                        
                                        if !dataManager.universityPortalURL.isEmpty {
                                            Button {
                                                AppSystemHelper.openWebURL(urlString: dataManager.universityPortalURL)
                                            } label: {
                                                Image(systemName: "arrow.up.right.square")
                                                    .font(.system(size: 14))
                                            }
                                            .buttonStyle(.plain)
                                            .help(localizationManager.currentLanguage == .italian ? "Testa e apri link nel browser" : "Test and open link in browser")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // SEZIONE 0.5: BARRA DI NAVIGAZIONE & SCORCIATOIE HOME
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.currentLanguage == .italian ? "BARRA DI NAVIGAZIONE & SCORCIATOIE" : "NAVBAR & HOME SHORTCUTS")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 20) {
                            // 1. Scelta del Bottone Rapido nella Navbar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(localizationManager.currentLanguage == .italian ? "Bottone Rapido Barra di Navigazione" : "Navbar Quick Action Button")
                                        .font(UniFont.headline())
                                    Spacer()
                                    UniBadge(dataManager.navbarQuickActionType.uppercased(), color: themeManager.accentColor)
                                }
                                
                                Text(localizationManager.currentLanguage == .italian ? "Scegli quale azione rapida collocare in basso nella barra di navigazione laterale, accanto al tasto Impostazioni." : "Choose which quick action to place at the bottom of the sidebar navbar, next to the Settings button.")
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(NavbarQuickActionOption.allCases) { opt in
                                        let isSel = dataManager.navbarQuickActionType == opt.rawValue
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                dataManager.setNavbarQuickAction(option: opt, customId: dataManager.navbarQuickActionCustomId)
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: opt.defaultIcon)
                                                    .font(.system(size: 13, weight: isSel ? .bold : .medium))
                                                    .foregroundStyle(isSel ? themeManager.accentColor : .secondary)
                                                    .frame(width: 18)
                                                
                                                Text(opt.displayName(isItalian: localizationManager.currentLanguage == .italian))
                                                    .font(UniFont.caption())
                                                    .fontWeight(isSel ? .semibold : .regular)
                                                    .foregroundStyle(isSel ? themeManager.accentColor : .primary)
                                                    .lineLimit(1)
                                                
                                                Spacer(minLength: 0)
                                                
                                                if isSel {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundStyle(themeManager.accentColor)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(isSel ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(isSel ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.06), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                if dataManager.navbarQuickActionType == NavbarQuickActionOption.customShortcut.rawValue {
                                    if dataManager.quickShortcuts.isEmpty {
                                        Text(localizationManager.currentLanguage == .italian ? "Nessuna scorciatoia personalizzata configurata sotto. Aggiungine una prima!" : "No custom shortcuts configured below. Add one first!")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.orange)
                                            .padding(.top, 4)
                                    } else {
                                        HStack(spacing: 10) {
                                            Text(localizationManager.currentLanguage == .italian ? "Seleziona Scorciatoia:" : "Select Shortcut:")
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                            
                                            Picker("", selection: Binding(
                                                get: { dataManager.navbarQuickActionCustomId ?? dataManager.quickShortcuts.first?.id ?? UUID() },
                                                set: { newId in dataManager.setNavbarQuickAction(option: .customShortcut, customId: newId) }
                                            )) {
                                                ForEach(dataManager.quickShortcuts) { shortcut in
                                                    Text(shortcut.title).tag(shortcut.id)
                                                }
                                            }
                                            .labelsHidden()
                                            .pickerStyle(.menu)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // 2. Gestione Scorciatoie Home
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.currentLanguage == .italian ? "Scorciatoie della Home" : "Home Shortcuts")
                                            .font(UniFont.headline())
                                        Text(localizationManager.currentLanguage == .italian ? "Gestisci e ordina i collegamenti mostrati nel riquadro della Panoramica (Overview)." : "Manage and arrange the shortcut links displayed in the Overview card.")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        isShowingAddShortcutSheet = true
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 11, weight: .bold))
                                            Text(localizationManager.currentLanguage == .italian ? "Aggiungi Scorciatoia" : "Add Shortcut")
                                                .font(UniFont.caption())
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(themeManager.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                if dataManager.quickShortcuts.isEmpty {
                                    Text(localizationManager.currentLanguage == .italian ? "Nessuna scorciatoia configurata. Premi Aggiungi per crearne una." : "No shortcuts configured. Click Add to create one.")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .padding(.vertical, 8)
                                } else {
                                    VStack(spacing: 8) {
                                        ForEach(dataManager.quickShortcuts) { shortcut in
                                            HStack(spacing: 12) {
                                                Image(systemName: shortcut.iconName.isEmpty ? "link" : shortcut.iconName)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(themeManager.accentColor)
                                                    .frame(width: 28, height: 28)
                                                    .background(themeManager.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(shortcut.title)
                                                        .font(UniFont.body())
                                                        .fontWeight(.semibold)
                                                    Text(shortcut.url)
                                                        .font(.system(size: 11, design: .monospaced))
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                                
                                                Spacer()
                                                
                                                // Test Link
                                                if !shortcut.url.isEmpty {
                                                    Button {
                                                        AppSystemHelper.openWebURL(urlString: shortcut.url)
                                                    } label: {
                                                        Image(systemName: "arrow.up.forward")
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(.secondary)
                                                            .frame(width: 26, height: 26)
                                                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                                                    }
                                                    .buttonStyle(.plain)
                                                    .help(localizationManager.currentLanguage == .italian ? "Apri link nel browser" : "Open link in browser")
                                                }
                                                
                                                // Modifica
                                                Button {
                                                    editingShortcut = shortcut
                                                } label: {
                                                    Image(systemName: "pencil")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(.secondary)
                                                        .frame(width: 26, height: 26)
                                                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6))
                                                }
                                                .buttonStyle(.plain)
                                                .help(localizationManager.currentLanguage == .italian ? "Modifica scorciatoia" : "Edit shortcut")
                                                
                                                // Elimina
                                                Button {
                                                    withAnimation {
                                                        dataManager.deleteQuickShortcut(id: shortcut.id)
                                                    }
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(.red.opacity(0.85))
                                                        .frame(width: 26, height: 26)
                                                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
                                                }
                                                .buttonStyle(.plain)
                                                .help(localizationManager.currentLanguage == .italian ? "Elimina scorciatoia" : "Delete shortcut")
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // SEZIONE 1: TEMA DELL'APPLICAZIONE (CHIARO / SCURO / SISTEMA)
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.themeModeSection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(localizationManager.t(.themeModeSubtitle))
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(AppThemeMode.allCases) { mode in
                                    let isSelected = themeManager.themeMode == mode
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            themeManager.themeMode = mode
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: mode.icon)
                                                .font(.system(size: 20))
                                                .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                            
                                            Text(modeTitle(for: mode))
                                                .font(UniFont.headline())
                                                .foregroundStyle(isSelected ? themeManager.accentColor : .primary)
                                            
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundStyle(themeManager.accentColor)
                                            } else {
                                                Spacer().frame(height: 11)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Rectangle()
                                                .fill(isSelected ? themeManager.accentColor.opacity(0.08) : Color.primary.opacity(0.03))
                                        )
                                        .overlay(
                                            Rectangle()
                                                .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.06), lineWidth: isSelected ? 1.5 : 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                
                // SEZIONE 2: LINGUA / LANGUAGE
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.languageSection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(localizationManager.t(.languageSubtitle))
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(AppLanguage.allCases) { lang in
                                    let isSelected = localizationManager.currentLanguage == lang
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            localizationManager.currentLanguage = lang
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text(lang.flag)
                                                .font(.system(size: 16))
                                            Text(lang.displayName)
                                                .font(UniFont.headline())
                                                .foregroundStyle(isSelected ? themeManager.accentColor : .primary)
                                            Spacer()
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundStyle(themeManager.accentColor)
                                            }
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            Rectangle()
                                                .fill(isSelected ? themeManager.accentColor.opacity(0.08) : Color.primary.opacity(0.03))
                                        )
                                        .overlay(
                                            Rectangle()
                                                .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.06), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                
                // SEZIONE 3: COLORE D'ACCENTO (RIQUADRO SFUMATO & HEX)
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.appearanceSection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localizationManager.t(.accentColorSubtitle))
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            // Preset Colori d'Accento
                            VStack(alignment: .leading, spacing: 10) {
                                Text(localizationManager.t(.presetsTitle).uppercased())
                                    .font(UniFont.sectionLabel())
                                    .foregroundStyle(.secondary)
                                    .tracking(1.4)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130, maximum: 170), spacing: 8)], spacing: 8) {
                                    ForEach(ThemeManager.presets, id: \.hex) { preset in
                                        let isSelected = themeManager.accentColorHex.uppercased() == preset.hex.uppercased()
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                themeManager.accentColorHex = preset.hex
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(Color(hex: preset.hex) ?? .blue)
                                                    .frame(width: 14, height: 14)
                                                    .overlay(
                                                        Circle()
                                                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                                                    )
                                                
                                                Text(preset.name)
                                                    .font(UniFont.subheadline())
                                                    .fontWeight(isSelected ? .semibold : .regular)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                
                                                Spacer()
                                                
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundStyle(themeManager.accentColor)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(isSelected ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                            .overlay(
                                                Rectangle()
                                                    .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1)
                                            )
                                            .clipShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            ColorPickerBoxView()
                        }
                    }
                }
                
                // SEZIONE TIPOGRAFIA (FONT PERSONALIZZABILE & STILI)
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.typographySection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localizationManager.t(.typographySubtitle))
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            // Selezione Stile Tipografico
                            VStack(alignment: .leading, spacing: 10) {
                                Text(localizationManager.text(it: "STILE TIPOGRAFICO DI SISTEMA", en: "SYSTEM TYPOGRAPHY STYLE"))
                                    .font(UniFont.sectionLabel())
                                    .foregroundStyle(.secondary)
                                    .tracking(1.4)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(AppFontDesign.allCases) { design in
                                        let isSelected = themeManager.fontDesign == design && themeManager.customFontFamily.isEmpty
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                themeManager.customFontFamily = ""
                                                themeManager.fontDesign = design
                                            }
                                        } label: {
                                            HStack {
                                                Text(design.displayName)
                                                    .font(.system(size: 12.5, weight: .light, design: design.swiftUIDesign))
                                                    .foregroundStyle(isSelected ? themeManager.accentColor : .primary)
                                                Spacer()
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundStyle(themeManager.accentColor)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                            .overlay(
                                                Rectangle()
                                                    .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Campo Font Custom
                            VStack(alignment: .leading, spacing: 10) {
                                Text(localizationManager.text(it: "FONT PERSONALIZZATO (QUALSIASI FONT INSTALLATO)", en: "CUSTOM FONT (ANY INSTALLED FONT)"))
                                    .font(UniFont.sectionLabel())
                                    .foregroundStyle(.secondary)
                                    .tracking(1.4)
                                
                                HStack(spacing: 8) {
                                    TextField(localizationManager.text(it: "Es. Inter, Helvetica Neue, Futura, Avenir, Menlo...", en: "E.g. Inter, Helvetica Neue, Futura, Avenir, Menlo..."), text: $themeManager.customFontFamily)
                                        .textFieldStyle(.roundedBorder)
                                        .font(.system(size: 12))
                                    
                                    if !themeManager.customFontFamily.isEmpty {
                                        Button(localizationManager.text(it: "Ripristina", en: "Reset")) {
                                            themeManager.customFontFamily = ""
                                        }
                                        .buttonStyle(.bordered)
                                        .font(.system(size: 11))
                                    }
                                }
                                
                                // Suggerimenti Rapidi
                                HStack(spacing: 6) {
                                    Text(localizationManager.text(it: "Suggeriti:", en: "Popular:"))
                                        .font(.system(size: 10.5, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(["Inter", "Helvetica Neue", "Futura", "Avenir", "Menlo"], id: \.self) { fontName in
                                        Button {
                                            themeManager.customFontFamily = fontName
                                        } label: {
                                            Text(fontName)
                                                .font(.system(size: 10.5, weight: .light))
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 3)
                                                .background(themeManager.customFontFamily == fontName ? themeManager.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                                                .foregroundStyle(themeManager.customFontFamily == fontName ? themeManager.accentColor : .secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                // Anteprima Live
                                HStack(spacing: 12) {
                                    Text(localizationManager.text(it: "Anteprima:", en: "Preview:"))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Aa 123 • 28.50 / 30 CFU")
                                        .font(UniFont.headline())
                                        .foregroundStyle(.primary)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                
                // SEZIONE 4: NOTIFICHE & PROMEMORIA (MAC & IN-APP)
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.currentLanguage == .italian ? "NOTIFICHE & AVVISI" : "NOTIFICATIONS & ALERTS")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localizationManager.currentLanguage == .italian ? "Configura le notifiche su macOS e le notifiche fluttuanti (Toast HUD) all'interno dell'app." : "Configure macOS Notification Center alerts and in-app floating Toast HUDs.")
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                // Toggle Notifiche macOS
                                Toggle(isOn: $notificationManager.systemNotificationsEnabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.currentLanguage == .italian ? "Centro Notifiche di macOS" : "macOS Notification Center")
                                            .font(UniFont.headline())
                                        Text(localizationManager.currentLanguage == .italian ? "Ricevi banner di sistema per scadenze, promemoria esami e timer" : "Receive system banners for deadlines, exam reminders, and timers")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .toggleStyle(.switch)
                                
                                Divider()
                                
                                // Toggle In-App Toast
                                Toggle(isOn: $notificationManager.inAppToastsEnabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.currentLanguage == .italian ? "Notifiche Fluttuanti In-App (Toast HUD)" : "In-App Floating Toasts (HUD)")
                                            .font(UniFont.headline())
                                        Text(localizationManager.currentLanguage == .italian ? "Mostra eleganti notifiche a pillola in alto durante l'utilizzo dell'app" : "Show polished top pill banners during in-app actions")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .toggleStyle(.switch)
                                
                                Divider()
                                
                                // Toggle Suoni Notifiche
                                Toggle(isOn: $notificationManager.soundEnabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.currentLanguage == .italian ? "Suoni Notifiche di Sistema" : "System Notification Sounds")
                                            .font(UniFont.headline())
                                        Text(localizationManager.currentLanguage == .italian ? "Riproduci suono per promemoria inviati a macOS" : "Play sound for alerts posted to macOS")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .toggleStyle(.switch)
                                
                                Divider()
                                
                                // Toggle Effetti Sonori Raffinati In-App
                                Toggle(isOn: $soundManager.soundEnabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.currentLanguage == .italian ? "Effetti Sonori Raffinati In-App" : "Refined In-App Sound Effects")
                                            .font(UniFont.headline())
                                        Text(localizationManager.currentLanguage == .italian ? "Suoni leggeri e feedback aptico per completamento scadenze, timer, file e azioni" : "Light, satisfying acoustic pop & chimes for task completion, timer, files and actions")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .toggleStyle(.switch)
                                
                                Divider()
                                
                                // Dettagli Promemoria Scadenze
                                HStack(spacing: 24) {
                                    Toggle(localizationManager.currentLanguage == .italian ? "Avviso 24 ore prima" : "Alert 24h before", isOn: $notificationManager.notify24hBefore)
                                        .font(UniFont.subheadline())
                                    
                                    Toggle(localizationManager.currentLanguage == .italian ? "Avviso 1 ora prima" : "Alert 1h before", isOn: $notificationManager.notify1hBefore)
                                        .font(UniFont.subheadline())
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 2)
                            }
                            
                            Divider()
                            
                            // Test Notification Button
                            Button {
                                NotificationManager.shared.notify(
                                    title: localizationManager.text(it: "Notifica di Prova • uni", en: "Test Notification • uni"),
                                    message: localizationManager.currentLanguage == .italian
                                        ? "Tutte le notifiche sono attive e funzionanti! 🎉"
                                        : "All notifications are active and working! 🎉",
                                    type: .success,
                                    icon: "bell.badge.fill",
                                    postToSystem: true
                                )
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.and.waves.left.and.right")
                                    Text(localizationManager.currentLanguage == .italian ? "Invia Notifica di Prova" : "Send Test Notification")
                                }
                                .font(UniFont.subheadline())
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                // SEZIONE 5: FRASI MOTIVAZIONALI HOME
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.customQuotesSection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localizationManager.t(.customQuotesSubtitle))
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 10) {
                                TextField(localizationManager.t(.addQuotePlaceholder), text: $newQuoteText)
                                    .textFieldStyle(.roundedBorder)
                                    .font(UniFont.body())
                                
                                Button {
                                    quoteManager.addQuote(newQuoteText)
                                    newQuoteText = ""
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                        Text(localizationManager.t(.addQuoteButton))
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(themeManager.accentColor)
                                .disabled(newQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.t(.activeQuotesTitle))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                
                                ForEach(Array(quoteManager.quotes.enumerated()), id: \.offset) { idx, quote in
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("“\(quote)”")
                                            .font(UniFont.subheadline())
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                quoteManager.deleteQuote(at: idx)
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 11))
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                        .help(localizationManager.text(it: "Elimina questa frase", en: "Delete this quote"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.primary.opacity(0.02))
                                    .overlay(Rectangle().stroke(Color.primary.opacity(0.06), lineWidth: 1))
                                    .clipShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                
                // SEZIONE 6: GUIDA, SETUP & TUTORIAL
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.currentLanguage == .italian ? "SETUP INIZIALE & GUIDA" : "INITIAL SETUP & TUTORIAL")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 20) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(themeManager.accentColor.opacity(0.12))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(themeManager.accentColor)
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(localizationManager.currentLanguage == .italian ? "Rivedi il Setup Iniziale e la Guida Funzionalità" : "Re-open Initial Setup & Features Tutorial")
                                    .font(UniFont.headline())
                                Text(localizationManager.currentLanguage == .italian ? "Avvia la procedura guidata a passaggi per reimpostare profilo, lingua, calendario iCal, colore e ripassare tutte le scorciatoie di uni." : "Launch the step-by-step wizard to reconfigure profile, language, iCal calendar, accent color, and review all uni shortcuts.")
                                    .font(UniFont.subheadline())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                isShowingOnboarding = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text(localizationManager.currentLanguage == .italian ? "Avvia Setup" : "Launch Setup")
                                }
                                .font(UniFont.headline())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.accentColor)
                        }
                    }
                }
                

                // SEZIONE 8: GESTIONE DATI & BACKUP
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.t(.dataManagementSection))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizationManager.t(.dataManagementTitle))
                                    .font(UniFont.headline())
                                Text(localizationManager.t(.dataManagementSubtitle))
                                    .font(UniFont.subheadline())
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Button {
                                    exportBackup()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text(localizationManager.t(.exportBackup))
                                    }
                                }
                                .buttonStyle(.bordered)
                                
                                Button {
                                    importBackup()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.and.arrow.down")
                                        Text(localizationManager.t(.restoreBackup))
                                    }
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    showingClearAlert = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash")
                                        Text(localizationManager.t(.clearAllData))
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                // SEZIONE 9: AGGIORNAMENTI SOFTWARE
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.text(it: "AGGIORNAMENTI SOFTWARE", en: "SOFTWARE UPDATES"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .center, spacing: 16) {
                                Circle()
                                    .fill(themeManager.accentColor.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(themeManager.accentColor)
                                            .rotationEffect(.degrees(updateManager.checkStatus == .checking ? 360 : 0))
                                            .animation(updateManager.checkStatus == .checking ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: updateManager.checkStatus == .checking)
                                    )
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 8) {
                                        Text(localizationManager.text(it: "Stato Aggiornamenti", en: "Update Status"))
                                            .font(UniFont.headline())
                                        
                                        Text("v\(updateManager.currentVersion) (\(updateManager.currentBuild))")
                                            .font(UniFont.mono())
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.primary.opacity(0.05))
                                            .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                    }
                                    
                                    if let last = updateManager.lastCheckDate {
                                        Text(localizationManager.text(
                                            it: "Ultimo controllo: \(formatCheckDate(last))",
                                            en: "Last checked: \(formatCheckDate(last))"
                                        ))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    } else {
                                        Text(localizationManager.text(it: "Nessun controllo effettuato di recente", en: "No recent update check performed"))
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    Task {
                                        await updateManager.checkForUpdates(force: true, isManual: true)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        if updateManager.checkStatus == .checking {
                                            ProgressView()
                                                .scaleEffect(0.65)
                                                .frame(width: 14, height: 14)
                                            Text(localizationManager.text(it: "Controllo in corso...", en: "Checking..."))
                                        } else {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 12, weight: .semibold))
                                            Text(localizationManager.text(it: "Controlla Aggiornamenti", en: "Check for Updates"))
                                        }
                                    }
                                    .font(UniFont.headline())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(themeManager.accentColor)
                                .disabled(updateManager.checkStatus == .checking)
                            }
                            
                            // Feedback Banner
                            switch updateManager.checkStatus {
                            case .upToDate(let ver):
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 14))
                                    Text(localizationManager.text(
                                        it: "uni v\(ver) è aggiornato alla versione più recente.",
                                        en: "uni v\(ver) is up to date with the latest release."
                                    ))
                                    .font(UniFont.subheadline())
                                    .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.08))
                                .overlay(Rectangle().stroke(Color.green.opacity(0.2), lineWidth: 1))
                                
                            case .updateAvailable(let rel):
                                HStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 16))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.text(
                                            it: "Nuova versione disponibile: uni v\(rel.version)!",
                                            en: "New version available: uni v\(rel.version)!"
                                        ))
                                        .font(UniFont.subheadline())
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        
                                        Text(localizationManager.text(
                                            it: "Visualizza le note di rilascio e avvia il download dell'aggiornamento.",
                                            en: "View release notes and download the update."
                                        ))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        updateManager.showUpdateModal = true
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text(localizationManager.text(it: "Vedi Aggiornamento", en: "View Update"))
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 10))
                                        }
                                        .font(UniFont.caption())
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.orange)
                                        .foregroundStyle(.white)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .background(Color.orange.opacity(0.08))
                                .overlay(Rectangle().stroke(Color.orange.opacity(0.25), lineWidth: 1))
                                
                            case .error(let err):
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 14))
                                    Text(err)
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Button {
                                        Task {
                                            await updateManager.checkForUpdates(force: true, isManual: true)
                                        }
                                    } label: {
                                        Text(localizationManager.text(it: "Riprova", en: "Retry"))
                                            .font(UniFont.caption())
                                            .foregroundStyle(themeManager.accentColor)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(10)
                                .background(Color.red.opacity(0.06))
                                .overlay(Rectangle().stroke(Color.red.opacity(0.15), lineWidth: 1))
                                
                            default:
                                EmptyView()
                            }
                            
                            Divider()
                            
                            Toggle(isOn: $updateManager.autoCheckUpdates) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(localizationManager.text(it: "Controlla aggiornamenti automaticamente all'avvio", en: "Automatically check for updates at launch"))
                                        .font(UniFont.subheadline())
                                    Text(localizationManager.text(it: "Verifica periodicamente e mostra un pop-up quando è pronta una nuova versione", en: "Periodically checks and presents a popup dialog when a new release is ready"))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .toggleStyle(.switch)
                        }
                    }
                }
                
                // SEZIONE 10: INFORMAZIONI, CREDITI & LICENZA
                VStack(alignment: .leading, spacing: 14) {
                    Text(localizationManager.text(it: "INFORMAZIONI & CREDITI", en: "ABOUT & CREDITS"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    UniCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("uni")
                                            .font(UniFont.largeTitle())
                                            .foregroundStyle(.primary)
                                        
                                        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                                        Text("v\(version) (\(build))")
                                            .font(UniFont.mono())
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.primary.opacity(0.05))
                                            .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                    }
                                    
                                    Text(localizationManager.text(it: "App nativa moderna per la gestione accademica su macOS.", en: "Modern native macOS academic workspace management."))
                                        .font(UniFont.subheadline())
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Link & Portfolio
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    // Portfolio zinco.cc
                                    Button {
                                        #if canImport(AppKit)
                                        if let url = URL(string: "https://zinco.cc") {
                                            NSWorkspace.shared.open(url)
                                        }
                                        #endif
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "globe")
                                                .font(.system(size: 11))
                                            Text("zinco.cc")
                                                .font(UniFont.headline())
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 9))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(themeManager.accentColor.opacity(0.1))
                                        .foregroundStyle(themeManager.accentColor)
                                        .overlay(
                                            Rectangle()
                                                .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .help(localizationManager.text(it: "Visita il portfolio zinco.cc", en: "Visit portfolio zinco.cc"))
                                    
                                    // GitHub
                                    Button {
                                        #if canImport(AppKit)
                                        if let url = URL(string: "https://github.com/zjncoo/uni") {
                                            NSWorkspace.shared.open(url)
                                        }
                                        #endif
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                                .font(.system(size: 11))
                                            Text("GitHub")
                                                .font(UniFont.headline())
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 9))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.primary.opacity(0.04))
                                        .foregroundStyle(.primary)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .help(localizationManager.text(it: "Codice sorgente su GitHub", en: "Source code on GitHub"))
                                }
                            }
                            
                            Divider()
                            
                            // Info Copyright e Licenza
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("© 2026 zinco.cc. All rights reserved.")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    Text(localizationManager.text(it: "Rilasciato con licenza open-source MIT.", en: "Released under open-source MIT License."))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(32)
        }
        .sheet(isPresented: $isShowingOnboarding) {
            OnboardingWizardView()
        }
        .sheet(isPresented: $isShowingAddShortcutSheet) {
            QuickShortcutEditorSheet(existingShortcut: nil)
        }
        .sheet(item: $editingShortcut) { shortcut in
            QuickShortcutEditorSheet(existingShortcut: shortcut)
        }
        .alert(localizationManager.t(.clearConfirmTitle), isPresented: $showingClearAlert) {
            Button(localizationManager.t(.cancel), role: .cancel) {}
            Button(localizationManager.t(.delete), role: .destructive) {
                dataManager.clearAllData()
                isShowingOnboarding = true
            }
        } message: {
            Text(localizationManager.t(.clearConfirmMessage))
        }
    }
    
    // MARK: - Esporta Backup
    private func exportBackup() {
        #if canImport(AppKit)
        let lm = LocalizationManager.shared
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "uni_backup_\(dateStamp()).json"
        savePanel.prompt = lm.t(.exportBackup)
        
        if savePanel.runModal() == .OK, let targetURL = savePanel.url {
            let payload = AppDataPayload(
                courses: dataManager.courses,
                deadlines: dataManager.deadlines,
                exams: dataManager.exams,
                assignments: dataManager.assignments,
                syncedEvents: dataManager.syncedEvents,
                calendarFeedURL: dataManager.calendarFeedURL,
                lastSyncDate: dataManager.lastSyncDate,
                studentName: dataManager.studentName,
                universityName: dataManager.universityName,
                universityPortalURL: dataManager.universityPortalURL,
                hasCompletedOnboarding: dataManager.hasCompletedOnboarding
            )
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(payload)
                try data.write(to: targetURL, options: .atomic)
            } catch {
                print("Errore esportazione backup: \(error)")
            }
        }
        #endif
    }
    
    // MARK: - Importa Backup
    private func importBackup() {
        #if canImport(AppKit)
        let lm = LocalizationManager.shared
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = lm.t(.restoreBackup)
        
        if openPanel.runModal() == .OK, let sourceURL = openPanel.url {
            do {
                let data = try Data(contentsOf: sourceURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let payload = try decoder.decode(AppDataPayload.self, from: data)
                
                dataManager.courses = payload.courses
                dataManager.deadlines = payload.deadlines
                dataManager.exams = payload.exams
                dataManager.assignments = payload.assignments
                dataManager.syncedEvents = payload.syncedEvents
                dataManager.calendarFeedURL = payload.calendarFeedURL
                dataManager.lastSyncDate = payload.lastSyncDate
                dataManager.studentName = payload.studentName ?? ""
                dataManager.universityName = payload.universityName ?? ""
                dataManager.universityPortalURL = payload.universityPortalURL ?? ""
                dataManager.hasCompletedOnboarding = payload.hasCompletedOnboarding ?? true
                dataManager.saveData()
            } catch {
                print("Errore importazione backup: \(error)")
            }
        }
        #endif
    }
    
    private func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    private func formatCheckDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
    
    private func modeTitle(for mode: AppThemeMode) -> String {
        switch mode {
        case .light: return localizationManager.t(.themeLight)
        case .dark: return localizationManager.t(.themeDark)
        case .system: return localizationManager.t(.themeSystem)
        }
    }
}

// MARK: - Quick Shortcut Editor Sheet
struct QuickShortcutEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var existingShortcut: QuickShortcutLink?
    
    @State private var title: String = ""
    @State private var url: String = ""
    @State private var iconName: String = "globe"
    
    private let availableIcons = [
        "globe", "graduationcap.fill", "video.fill", "book.closed.fill",
        "doc.text.fill", "link", "folder.fill", "tray.full.fill",
        "calendar", "message.fill", "network", "building.columns.fill",
        "cloud.fill", "safari", "sparkles", "briefcase.fill"
    ]
    
    var isEditing: Bool { existingShortcut != nil }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isEditing ? (localizationManager.currentLanguage == .italian ? "Modifica Scorciatoia" : "Edit Shortcut") : (localizationManager.currentLanguage == .italian ? "Nuova Scorciatoia" : "New Shortcut"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    Text(localizationManager.currentLanguage == .italian ? "Imposta il titolo, l'indirizzo web e l'icona del collegamento rapido." : "Set title, web address, and icon for the quick link.")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Color.primary.opacity(0.06), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Titolo
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localizationManager.currentLanguage == .italian ? "Titolo Scorciatoia" : "Shortcut Title")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.currentLanguage == .italian ? "Es. Moodle, Teams, Biblioteca, Mensa..." : "e.g. Moodle, Teams, Library...", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(UniFont.body())
                    }
                    
                    // URL
                    VStack(alignment: .leading, spacing: 6) {
                        Text("URL / Link Web")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                        HStack {
                            TextField("https://...", text: $url)
                                .textFieldStyle(.roundedBorder)
                                .font(UniFont.body())
                            
                            if !url.isEmpty {
                                Button {
                                    AppSystemHelper.openWebURL(urlString: url)
                                } label: {
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.currentLanguage == .italian ? "Testa link nel browser" : "Test link in browser")
                            }
                        }
                    }
                    
                    // Icon Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.currentLanguage == .italian ? "Icona Rappresentativa" : "Representative Icon")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                            ForEach(availableIcons, id: \.self) { sym in
                                let isSelected = iconName == sym
                                Button {
                                    iconName = sym
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(isSelected ? themeManager.accentColor.opacity(0.18) : Color.primary.opacity(0.04))
                                        Image(systemName: sym)
                                            .font(.system(size: 15))
                                            .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                    }
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button(localizationManager.currentLanguage == .italian ? "Annulla" : "Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    saveShortcut()
                } label: {
                    Text(localizationManager.currentLanguage == .italian ? "Salva Scorciatoia" : "Save Shortcut")
                        .font(UniFont.subheadline())
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary.opacity(0.3) : themeManager.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 440, height: 420)
        .background(.ultraThinMaterial)
        .onAppear {
            if let ex = existingShortcut {
                self.title = ex.title
                self.url = ex.url
                self.iconName = ex.iconName
            }
        }
    }
    
    private func saveShortcut() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var cleanUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanUrl.isEmpty && !cleanUrl.contains("://") {
            cleanUrl = "https://" + cleanUrl
        }
        
        if let ex = existingShortcut {
            dataManager.updateQuickShortcut(id: ex.id, title: cleanTitle, url: cleanUrl, iconName: iconName)
        } else {
            dataManager.addQuickShortcut(title: cleanTitle, url: cleanUrl, iconName: iconName)
        }
        dismiss()
    }
}

