//
//  OnboardingWizardView.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
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
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header con Step Indicator
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 8, height: 8)
                    Text("uni")
                        .font(UniFont.headline())
                        .fontWeight(.bold)
                    Text("• Setup Iniziale")
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Indicatori di avanzamento a pallini
                HStack(spacing: 6) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Capsule()
                            .fill(step == currentStep ? themeManager.accentColor : Color.primary.opacity(0.12))
                            .frame(width: step == currentStep ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
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
            .frame(height: 430)
            
            Divider()
            
            // Footer con Tasti Navigazione
            HStack {
                if currentStep > 1 {
                    Button("Indietro") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                if currentStep < totalSteps {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Continua")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(UniFont.headline())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(themeManager.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        completeOnboarding()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Inizia a usare uni")
                        }
                        .font(UniFont.headline())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(themeManager.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 640)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            studentName = dataManager.studentName
            universityName = dataManager.universityName
            universityPortalURL = dataManager.universityPortalURL
            calendarURL = dataManager.calendarFeedURL
            selectedTheme = themeManager.themeMode
        }
    }
    
    // MARK: - Step 1: Benvenuto & Lingua
    private var step1WelcomeView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Benvenuto su uni")
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                    .tracking(-0.5)
                
                Text("La tua centrale di controllo accademica per macOS. Elegante, priva di distrazioni e costruita su misura per la tua carriera universitaria.")
                    .font(UniFont.body())
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("SELEZIONA LA TUA LINGUA PREFERITA:")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
                HStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        let isSelected = localizationManager.currentLanguage == lang
                        Button {
                            withAnimation {
                                localizationManager.currentLanguage = lang
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(lang.flag)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 1) {
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
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isSelected ? themeManager.accentColor.opacity(0.1) : Color.primary.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(themeManager.accentColor)
                Text("Potrai cambiare lingua in qualsiasi momento dalle Impostazioni.")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - Step 2: Profilo & Ateneo
    private var step2ProfileView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Il tuo Profilo & Ateneo")
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                Text("Personalizza l'app con i tuoi riferimenti accademici.")
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 14) {
                // Nome Studente
                VStack(alignment: .leading, spacing: 6) {
                    Text("IL TUO NOME:")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    
                    TextField("es. Francesco", text: $studentName)
                        .textFieldStyle(.roundedBorder)
                        .font(UniFont.body())
                }
                
                // Nome Università
                VStack(alignment: .leading, spacing: 6) {
                    Text("NOME ATENEO / FACOLTÀ:")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    
                    TextField("es. Università di Padova, PoliMi, Alma Mater Bologna...", text: $universityName)
                        .textFieldStyle(.roundedBorder)
                        .font(UniFont.body())
                }
                
                // Link Portale / Sito Ateneo
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("LINK AL PORTALE O SITO WEB DELL'UNIVERSITÀ:")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        Spacer()
                        Text("(Facoltativo)")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        TextField("https://... (es. Esse3, portale studenti o home ateneo)", text: $universityPortalURL)
                            .textFieldStyle(.roundedBorder)
                            .font(UniFont.body())
                    }
                    
                    Text("Questo link comparirà in cima alla tua Overview per accedere al tuo portale universitario con un clic.")
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
                Text("Orario Lezioni & Calendario")
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                Text("Sincronizza automaticamente le lezioni e gli appelli.")
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            // Box Spiegazione
            UniCard(padding: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundStyle(themeManager.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cos'è il link iCal / Webcal?")
                            .font(UniFont.headline())
                        Text("La maggior parte delle università fornisce un link di sincronizzazione (formato .ics o webcal://) con l'orario delle tue lezioni, le aule e le date degli appelli d'esame. Incollandolo qui, uni sincronizzerà le lezioni automaticamente nel tuo calendario.")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("LINK FEED CALENDARIO ATENEO:")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
                TextField("https://.../orari.ics oppure webcal://...", text: $calendarURL)
                    .textFieldStyle(.roundedBorder)
                    .font(UniFont.body())
                
                Text("Non ce l'hai sottomano ora? Nessun problema: puoi lasciarlo vuoto e configurarlo in qualsiasi momento dal Calendario o dalle Impostazioni.")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Step 4: Personalizzazione Visiva
    private var step4AppearanceView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tema & Stile Visivo")
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                Text("Rendi uni perfetto per il tuo Mac.")
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            // Tema Chiaro / Scuro / Sistema
            VStack(alignment: .leading, spacing: 8) {
                Text("MODALITÀ TEMA:")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
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
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(isSelected ? themeManager.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Colore d'Accento
            VStack(alignment: .leading, spacing: 8) {
                Text("COLORE D'ACCENTO DELL'APP:")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
                HStack(spacing: 10) {
                    ForEach(["#0D5BFF", "#6366F1", "#EC4899", "#F59E0B", "#10B981", "#EF4444", "#111827"], id: \.self) { hex in
                        let isSelected = themeManager.accentColorHex.uppercased() == hex.uppercased()
                        Circle()
                            .fill(Color(hex: hex) ?? .blue)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: isSelected ? 2.5 : 0)
                                    .padding(-3)
                            )
                            .onTapGesture {
                                withAnimation {
                                    themeManager.accentColorHex = hex
                                }
                            }
                    }
                }
                .padding(.vertical, 4)
                
                Text("Potrai definire qualsiasi codice HEX sfumato a mano dalle Impostazioni.")
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Step 5: Breve Tutorial & Guida Rapida ("Tutto spiegato bene")
    private var step5TutorialView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Guida Rapida & Superpoteri")
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                Text("Ecco cosa puoi fare fin da subito con uni sul tuo Mac:")
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 10) {
                tutorialCard(
                    badge: "⌘F",
                    title: "Ricerca Spotlight",
                    desc: "Cerca istantaneamente corsi, esami, scadenze, file e avvia comandi rapidi."
                )
                
                tutorialCard(
                    badge: "⌘N",
                    title: "Creazione Rapida",
                    desc: "Aggiungi al volo una scadenza, un esame o un assignment contestuale."
                )
                
                tutorialCard(
                    badge: "⌘T",
                    title: "Pomodoro Focus Timer",
                    desc: "Sessioni di concentrazione da 25m/50m collegate alla materia di studio."
                )
                
                tutorialCard(
                    badge: "DROP",
                    title: "Drag & Drop File",
                    desc: "Trascina PDF e dispense dal Finder direttamente sugli assignment."
                )
                
                tutorialCard(
                    badge: "110",
                    title: "Simulatore What-If",
                    desc: "Calcola in anticipo l'impatto dei voti futuri su media e base di laurea."
                )
                
                tutorialCard(
                    badge: "HUD",
                    title: "Notifiche & Promemoria",
                    desc: "Ricevi banner macOS e Toast in-app a 24h e 1h dalla scadenza."
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
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    
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
        
        dataManager.hasCompletedOnboarding = true
        dataManager.saveData()
        
        NotificationManager.shared.notify(
            title: studentName.isEmpty ? "Benvenuto su uni! 🎓" : "Benvenuto, \(studentName)! 🎓",
            message: "Configurazione completata con successo. Buono studio!",
            type: .success,
            icon: "sparkles",
            postToSystem: true
        )
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
