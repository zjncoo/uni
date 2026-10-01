//
//  OnboardingWizardView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct OnboardingWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var currentStep: Int = 1
    private let totalSteps = 5
    
    // Step Data
    @State private var studentName: String = ""
    @State private var universityName: String = ""
    @State private var universityPortalURL: String = ""
    @State private var calendarURL: String = ""
    @State private var selectedTheme: AppThemeMode = .system
    
    public init() {}
    
    private func stepTitle(for step: Int) -> String {
        switch step {
        case 1: return localizationManager.text(it: "Lingua", en: "Language")
        case 2: return localizationManager.text(it: "Profilo & Ateneo", en: "Profile & Campus")
        case 3: return localizationManager.text(it: "Calendario & Orario", en: "Schedule & Calendar")
        case 4: return localizationManager.text(it: "Stile & Tema", en: "Style & Theme")
        case 5: return localizationManager.text(it: "Panoramica & Guida", en: "Overview & Guide")
        default: return ""
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header con Step Indicator e Titolo
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(themeManager.accentColor)
                            .frame(width: 8, height: 8)
                        Text("uni")
                            .font(UniFont.headline())
                        Text("• " + (dataManager.hasCompletedOnboarding
                            ? localizationManager.text(it: "Setup & Configurazione", en: "Setup & Configuration")
                            : localizationManager.text(it: "Setup Iniziale", en: "Initial Setup")))
                            .font(UniFont.subheadline())
                            .foregroundStyle(.secondary)
                        
                        if dataManager.hasCompletedOnboarding {
                            Text(localizationManager.text(it: "DATI SALVATI", en: "PRE-FILLED"))
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.12))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(localizationManager.text(it: "Passo", en: "Step")) \(currentStep) / \(totalSteps) • \(stepTitle(for: currentStep))")
                        .font(UniFont.caption())
                        .foregroundStyle(themeManager.accentColor)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Indicatori di avanzamento a segmenti rettangolari
                HStack(spacing: 5) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                currentStep = step
                            }
                        } label: {
                            Rectangle()
                                .fill(step == currentStep ? themeManager.accentColor : Color.primary.opacity(step < currentStep ? 0.3 : 0.12))
                                .frame(width: step == currentStep ? 24 : 8, height: 5)
                        }
                        .buttonStyle(.plain)
                        .help("Passo \(step): \(stepTitle(for: step))")
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            Divider()
            
            // Corpo dello Step Attivo
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch currentStep {
                    case 1:
                        step1WelcomeView
                    case 2:
                        step2ProfileView
                    case 3:
                        step3CalendarView
                    case 4:
                        step4AppearanceView
                    case 5:
                        step5TutorialView
                    default:
                        step1WelcomeView
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
            .frame(height: 460)
            
            Divider()
            
            // Footer con Tasti Navigazione
            HStack {
                if currentStep > 1 {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 10))
                            Text(localizationManager.text(it: "Indietro", en: "Back"))
                        }
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.primary.opacity(0.04))
                        .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text("\(localizationManager.text(it: "Passo", en: "Step")) \(currentStep) / \(totalSteps)")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if currentStep < totalSteps {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(localizationManager.text(it: "Continua", en: "Continue"))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                        }
                        .font(UniFont.headline())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(themeManager.accentColor)
                        .foregroundStyle(themeManager.accentTextColor)
                        .overlay(Rectangle().stroke(themeManager.accentColor, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        completeOnboarding()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text(dataManager.hasCompletedOnboarding
                                ? localizationManager.text(it: "Salva Configurazione & Continua", en: "Save Configuration & Continue")
                                : localizationManager.text(it: "Inizia a usare uni", en: "Start using uni"))
                        }
                        .font(UniFont.headline())
                        .padding(.horizontal, 22)
                        .padding(.vertical, 9)
                        .background(themeManager.accentColor)
                        .foregroundStyle(themeManager.accentTextColor)
                        .overlay(Rectangle().stroke(themeManager.accentColor, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 680)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            studentName = dataManager.studentName
            universityName = dataManager.universityName
            universityPortalURL = dataManager.universityPortalURL
            calendarURL = dataManager.calendarFeedURL
            if calendarURL.isEmpty, let webcal = dataManager.calendarSources.first(where: { $0.sourceType == .webcal }) {
                calendarURL = webcal.url
            }
            selectedTheme = themeManager.themeMode
        }
    }
    
    // MARK: - Step 1: Benvenuto & Lingua
    private var step1WelcomeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(themeManager.accentColor.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(themeManager.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.text(it: "Benvenuto su uni", en: "Welcome to uni"))
                            .font(UniFont.largeTitle())
                            .tracking(-0.5)
                        Text(dataManager.hasCompletedOnboarding
                             ? localizationManager.text(it: "Verifica e aggiorna la tua configurazione accademica.", en: "Review and adjust your academic workspace configuration.")
                             : localizationManager.text(it: "La tua centrale di controllo accademica per macOS.", en: "Your personal academic command center for macOS."))
                            .font(UniFont.subheadline())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text(localizationManager.text(it: "SELEZIONA LA TUA LINGUA PREFERITA:", en: "SELECT YOUR PREFERRED LANGUAGE:"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                HStack(spacing: 14) {
                    ForEach(AppLanguage.allCases) { lang in
                        let isSelected = localizationManager.currentLanguage == lang
                        Button {
                            withAnimation {
                                localizationManager.currentLanguage = lang
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(lang.flag)
                                    .font(.system(size: 24))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.displayName)
                                        .font(UniFont.headline())
                                    Text(lang == .italian ? "Interfaccia in italiano" : "Interface in English")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(themeManager.accentColor)
                                }
                            }
                            .padding(14)
                            .background(
                                Rectangle()
                                    .fill(isSelected ? themeManager.accentColor.opacity(0.1) : Color.primary.opacity(0.035))
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(themeManager.accentColor)
                Text(localizationManager.text(it: "Potrai cambiare lingua e ogni parametro in qualsiasi momento dalle Impostazioni.", en: "You can change language and any setting anytime from Settings."))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Step 2: Profilo & Ateneo
    private var step2ProfileView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "Il tuo Profilo & Ateneo", en: "Your Profile & University"))
                    .font(UniFont.largeTitle())
                Text(localizationManager.text(it: "Personalizza l'app con i tuoi riferimenti accademici.", en: "Personalize the app with your academic details."))
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            // Live Preview Card
            UniCard(padding: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(themeManager.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.text(it: "ANTEPRIMA DASHBOARD:", en: "DASHBOARD PREVIEW:"))
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Text("Ciao, \(studentName.trimmingCharacters(in: .whitespaces).isEmpty ? (localizationManager.currentLanguage == .italian ? "Studente" : "Student") : studentName) 👋")
                                .font(UniFont.headline())
                            if !universityName.trimmingCharacters(in: .whitespaces).isEmpty {
                                Text("• \(universityName)")
                                    .font(UniFont.subheadline())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 14) {
                // Nome Studente
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.text(it: "IL TUO NOME:", en: "YOUR NAME:"))
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "person")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.text(it: "es. Marco", en: "e.g. Alex"), text: $studentName)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.04))
                    .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
                
                // Nome Università
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.text(it: "NOME ATENEO / FACOLTÀ:", en: "UNIVERSITY / FACULTY NAME:"))
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "graduationcap")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.text(it: "es. Università di Padova, PoliMi, Bologna...", en: "e.g. Harvard, Oxford, MIT..."), text: $universityName)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.04))
                    .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
                
                // Link Portale / Sito Ateneo
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(localizationManager.text(it: "LINK AL PORTALE WEB:", en: "WEB PORTAL LINK:"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.4)
                        Spacer()
                        Text(localizationManager.text(it: "(Facoltativo)", en: "(Optional)"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        TextField("https://...", text: $universityPortalURL)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.04))
                    .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                    
                    Text(localizationManager.text(it: "Questo link comparirà nella tua Overview per accedere al portale universitario con un clic.", en: "This link will appear in your Overview to access your campus portal with one click."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Step 3: Calendario & Orario Lezioni
    private var step3CalendarView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "Orario Lezioni & Calendario", en: "Lectures & Calendar Schedule"))
                    .font(UniFont.largeTitle())
                Text(localizationManager.text(it: "Sincronizza automaticamente le lezioni, gli esami e gli impegni.", en: "Automatically synchronize lectures, exam dates, and commitments."))
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            // Hero Card: Sincronizzazione 1-Click Calendari Mac
            UniCard(padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(themeManager.accentColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(themeManager.accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(localizationManager.text(it: "Sincronizza Calendari del Mac (1 Click)", en: "Sync Mac Calendars (1 Click)"))
                                    .font(UniFont.headline())
                                
                                Spacer()
                                
                                if dataManager.isSyncingCalendar {
                                    HStack(spacing: 6) {
                                        ProgressView()
                                            .controlSize(.small)
                                        Text(localizationManager.text(it: "Sincronizzazione...", en: "Syncing..."))
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Button {
                                        Task {
                                            _ = await dataManager.importAllMacCalendars()
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.system(size: 11, weight: .bold))
                                            Text(localizationManager.text(it: "Sincronizza tutti", en: "Sync all"))
                                                .font(UniFont.caption())
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(themeManager.accentColor)
                                    .help(localizationManager.text(it: "Sincronizza tutti i calendari del Mac", en: "Sync all Mac calendars"))
                                }
                            }
                            
                            Text(localizationManager.text(
                                it: "Importa e replica istantaneamente tutti i calendari attivi sul tuo Mac (Google Calendar, Outlook, iCloud, Exchange). uni riconosce le lezioni e le separa dagli impegni personali.",
                                en: "Instantly import and replicate all active Mac calendars (Google, Outlook, iCloud, Exchange). uni separates academic lectures from personal events."
                            ))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                            
                            // Messaggi di stato o badge
                            if let success = dataManager.syncSuccessMessage {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.system(size: 12))
                                    Text(success)
                                        .font(UniFont.caption())
                                        .foregroundStyle(.green)
                                }
                                .padding(.top, 2)
                            } else if let err = dataManager.syncErrorMessage {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 12))
                                    Text(err)
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 2)
                            } else {
                                let macCalCount = dataManager.calendarSources.filter { $0.sourceType == .appleCalendar }.count
                                if macCalCount > 0 {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(themeManager.accentColor)
                                            .font(.system(size: 12))
                                        Text(localizationManager.text(
                                            it: "\(macCalCount) calendari del PC collegati e sincronizzati",
                                            en: "\(macCalCount) PC calendars connected & synced"
                                        ))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    }
                                    .padding(.top, 2)
                                }
                            }
                        }
                    }
                }
            }
            
            // Feed iCal Ateneo
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(localizationManager.text(it: "FEED CALENDARIO ATENEO (ICAL / WEBCAL):", en: "CAMPUS CALENDAR FEED URL (ICAL / WEBCAL):"))
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                    Spacer()
                    Text(localizationManager.text(it: "(Facoltativo)", en: "(Optional)"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    TextField("https://.../orari.ics oppure webcal://...", text: $calendarURL)
                        .textFieldStyle(.plain)
                        .font(UniFont.body())
                }
                .padding(8)
                .background(Color.primary.opacity(0.04))
                .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                
                Text(localizationManager.text(it: "Puoi incollare il link ics da Esse3, Cineca o dal sito studenti, oppure configurarlo in qualsiasi momento dal Calendario.", en: "You can paste the ics feed from Esse3, Cineca, or your student portal anytime."))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Step 4: Personalizzazione Visiva & Tipografia
    private var step4AppearanceView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "Stile Visivo & Tipografia", en: "Visual Style & Typography"))
                    .font(UniFont.largeTitle())
                Text(localizationManager.text(it: "Configura il tema, lo stile tipografico e il colore d'accento.", en: "Configure your theme, typography style, and accent color."))
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            // Tema Chiaro / Scuro / Sistema
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.text(it: "MODALITÀ TEMA:", en: "THEME MODE:"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                HStack(spacing: 12) {
                    ForEach(AppThemeMode.allCases) { mode in
                        let isSelected = themeManager.themeMode == mode
                        Button {
                            withAnimation {
                                themeManager.themeMode = mode
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: mode.icon)
                                    .font(.system(size: 13))
                                Text(themeTitle(for: mode))
                                    .font(UniFont.headline())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                Rectangle()
                                    .fill(isSelected ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Stile Tipografico
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.text(it: "STILE TIPOGRAFICO:", en: "TYPOGRAPHY STYLE:"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                HStack(spacing: 8) {
                    ForEach(AppFontDesign.allCases) { design in
                        let isSelected = themeManager.fontDesign == design && themeManager.customFontFamily.isEmpty
                        Button {
                            withAnimation {
                                themeManager.customFontFamily = ""
                                themeManager.fontDesign = design
                            }
                        } label: {
                            Text(design.displayName)
                                .font(.system(size: 11.5, weight: .light, design: design.swiftUIDesign))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(isSelected ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                .foregroundStyle(isSelected ? themeManager.accentColor : .primary)
                                .overlay(
                                    Rectangle()
                                        .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Colore d'Accento
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.text(it: "COLORE D'ACCENTO DELL'APP:", en: "APP ACCENT COLOR:"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                HStack(spacing: 8) {
                    ForEach(ThemeManager.presets, id: \.hex) { preset in
                        let isSelected = themeManager.accentColorHex.uppercased() == preset.hex.uppercased()
                        Button {
                            withAnimation {
                                themeManager.accentColorHex = preset.hex
                            }
                        } label: {
                            Rectangle()
                                .fill(Color(hex: preset.hex) ?? .blue)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.primary, lineWidth: isSelected ? 2.5 : 0)
                                        .padding(-3)
                                )
                        }
                        .buttonStyle(.plain)
                        .help(preset.name)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    // MARK: - Step 5: Breve Tutorial & Guida Rapida
    private var step5TutorialView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "Guida Rapida & Superpoteri", en: "Quick Start & Shortcuts"))
                    .font(UniFont.largeTitle())
                Text(localizationManager.text(it: "Tutto è pronto. Ecco le funzioni chiave di uni a tua disposizione:", en: "Everything is set. Here are key features at your fingertips:"))
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 10) {
                tutorialCard(
                    badge: "CAL",
                    title: localizationManager.text(it: "Calendario & Impegni", en: "Calendar & Schedule"),
                    desc: localizationManager.text(it: "Impegni di oggi, tendina 3/7/20 giorni, replica PC in 1 click e separazione lezioni.", en: "Today's commitments, 3/7/20 days horizon, 1-click PC replicate, and academic separation.")
                )
                tutorialCard(
                    badge: "⌘F",
                    title: localizationManager.text(it: "Ricerca Spotlight", en: "Spotlight Search"),
                    desc: localizationManager.text(it: "Cerca istantaneamente corsi, esami, scadenze, file e avvia comandi rapidi.", en: "Quickly search courses, exams, tasks, files, and commands.")
                )
                
                tutorialCard(
                    badge: "⌘N",
                    title: localizationManager.text(it: "Creazione Rapida", en: "Quick Create"),
                    desc: localizationManager.text(it: "Aggiungi al volo una scadenza, un esame o un assignment.", en: "Instantly create a deadline, exam, or assignment.")
                )
                
                tutorialCard(
                    badge: "⌘T",
                    title: localizationManager.text(it: "Pomodoro Focus Timer", en: "Focus Timer"),
                    desc: localizationManager.text(it: "Sessioni di concentrazione da 25m/50m collegate alla materia di studio.", en: "Productivity focus sessions tied to your courses.")
                )
                
                tutorialCard(
                    badge: "110",
                    title: localizationManager.text(it: "Simulatore What-If", en: "What-If Simulator"),
                    desc: localizationManager.text(it: "Calcola in anticipo l'impatto dei voti futuri su media e base di laurea.", en: "Simulate future grades to preview your projected GPA.")
                )
                
                tutorialCard(
                    badge: "HUD",
                    title: localizationManager.text(it: "Notifiche & Promemoria", en: "Alerts & Reminders"),
                    desc: localizationManager.text(it: "Ricevi banner macOS e Toast in-app a 24h e 1h dalla scadenza.", en: "Receive native macOS banners and floating toasts.")
                )
            }
        }
    }
    
    private func tutorialCard(badge: String, title: String, desc: String) -> some View {
        UniCard(padding: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.accentColor.opacity(0.18))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Spacer()
                }
                
                Text(title)
                    .font(UniFont.headline())
                    .lineLimit(1)
                
                Text(desc)
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }
    
    // MARK: - Complete Onboarding
    private func completeOnboarding() {
        dataManager.studentName = studentName.trimmingCharacters(in: .whitespacesAndNewlines)
        dataManager.universityName = universityName.trimmingCharacters(in: .whitespacesAndNewlines)
        dataManager.universityPortalURL = universityPortalURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trimmedCal = calendarURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCal.isEmpty {
            dataManager.calendarFeedURL = trimmedCal
            Task {
                await dataManager.syncCalendarFeed()
            }
        }
        
        let isAlreadyCompleted = dataManager.hasCompletedOnboarding
        dataManager.hasCompletedOnboarding = true
        dataManager.saveData()
        
        if isAlreadyCompleted {
            NotificationManager.shared.notify(
                title: localizationManager.text(it: "Configurazione salvata! 🎓", en: "Setup saved! 🎓"),
                message: localizationManager.text(it: "I tuoi riferimenti accademici e le preferenze sono stati aggiornati.", en: "Your academic details and preferences have been updated."),
                type: .success,
                icon: "checkmark.circle",
                postToSystem: true
            )
        } else {
            NotificationManager.shared.notify(
                title: studentName.isEmpty ? "Benvenuto su uni! 🎓" : "Benvenuto, \(studentName)! 🎓",
                message: "Configurazione completata con successo. Buono studio!",
                type: .success,
                icon: "sparkles",
                postToSystem: true
            )
        }
        dismiss()
    }
    
    private func themeTitle(for mode: AppThemeMode) -> String {
        switch mode {
        case .light: return localizationManager.t(.themeLight)
        case .dark: return localizationManager.t(.themeDark)
        case .system: return localizationManager.t(.themeSystem)
        }
    }
}

