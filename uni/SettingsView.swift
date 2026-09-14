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
    @State private var isShowingOnboarding = false
    @State private var showingClearAlert = false
    @State private var newQuoteText: String = ""
    @State private var editStudentName: String = ""
    @State private var editUniversityName: String = ""
    @State private var editUniversityPortalURL: String = ""
    
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
                
                // SEZIONE 9: INFORMAZIONI, CREDITI & LICENZA
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
    
    private func modeTitle(for mode: AppThemeMode) -> String {
        switch mode {
        case .light: return localizationManager.t(.themeLight)
        case .dark: return localizationManager.t(.themeDark)
        case .system: return localizationManager.t(.themeSystem)
        }
    }
}
