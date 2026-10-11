//
//  MinorLockoutView.swift
//  uni
//
//  Created by zinco.cc on 12/10/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// Schermata di blocco totale per utenti minorenni a tutela legale e conformità normativa
public struct MinorLockoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isShowingCorrectionSheet = false
    @State private var correctedBirthDate: Date = Calendar.current.date(byAdding: .year, value: -19, to: Date()) ?? Date()
    @State private var correctionError: String? = nil
    
    public init() {}
    
    private var detectedAge: Int {
        dataManager.userAge ?? 0
    }
    
    private var formattedBirthDate: String {
        if let d = dataManager.userBirthDate {
            return d.formatted(date: .long, time: .omitted)
        }
        return localizationManager.text(it: "Non specificata", en: "Not specified")
    }
    
    public var body: some View {
        ZStack {
            // Sfondo pieno con sfumatura di sicurezza
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    // Icona Scudo di Protezione
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.18), Color.orange.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                            )
                        
                        Image(systemName: "shield.slash.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.red, Color.orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    // Titolo & Badge Normativo
                    VStack(spacing: 8) {
                        Text(localizationManager.text(it: "Accesso Non Consentito", en: "Access Restricted"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(localizationManager.text(it: "VINCOLO LEGALE DI MAGGIORE ETÀ (18+)", en: "LEGAL AGE REQUIREMENT (18+)"))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.12))
                            .foregroundStyle(Color.red)
                            .clipShape(Capsule())
                    }
                    
                    // Card con Motivazione Legale Dettagliata
                    UniCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.red)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(localizationManager.text(it: "L'applicazione è riservata esclusivamente a maggiorenni", en: "This application is restricted to adults (18+)"))
                                        .font(UniFont.headline())
                                        .foregroundStyle(.primary)
                                    
                                    Text(localizationManager.text(
                                        it: "In conformità alle vigenti disposizioni di legge, ai Termini di Servizio e alle normative applicabili sulla protezione dei dati e dei minori, l'utilizzo dell'applicazione uni è legalmente vincolato al compimento del 18° anno di età.",
                                        en: "In compliance with applicable laws, Terms of Service, and child protection regulations, access to uni is strictly restricted to users aged 18 and older."
                                    ))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            
                            Divider()
                            
                            // Dati Inseriti Rilevati
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(localizationManager.text(it: "Data di Nascita Rilevata:", en: "Birth Date Entered:"))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    Text(formattedBirthDate)
                                        .font(UniFont.subheadline())
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(localizationManager.text(it: "Stato Rilevato:", en: "Status:"))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    Text(localizationManager.text(it: "Minorenne (\(detectedAge) anni)", en: "Minor (\(detectedAge) yrs)"))
                                        .font(UniFont.subheadline())
                                        .fontWeight(.bold)
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding(10)
                            .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
                            
                            Text(localizationManager.text(
                                it: "Tutte le funzionalità di gestione esami, scadenze, sincronizzazione calendari e archivio documenti sono state bloccate.",
                                en: "All features for exams, deadlines, calendar sync, and documents have been locked."
                            ))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .italic()
                        }
                    }
                    .frame(maxWidth: 520)
                    
                    // Azioni di Chiusura e Rettifica
                    VStack(spacing: 12) {
                        Button {
                            #if canImport(AppKit)
                            NSApplication.shared.terminate(nil)
                            #endif
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(localizationManager.text(it: "Esci dall'Applicazione", en: "Quit Application"))
                                    .font(UniFont.headline())
                            }
                            .frame(maxWidth: 260)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: Color.red.opacity(0.3), radius: 6, y: 2)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            correctionError = nil
                            isShowingCorrectionSheet = true
                        } label: {
                            Text(localizationManager.text(it: "Hai commesso un errore di digitazione? Rettifica la data", en: "Made a typo? Correct your birth date"))
                                .font(UniFont.caption())
                                .foregroundStyle(themeManager.accentColor)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(32)
                
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingCorrectionSheet) {
            correctionSheetView
        }
    }
    
    // MARK: - Correction Sheet
    private var correctionSheetView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 22))
                    .foregroundStyle(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Rettifica Data di Nascita", en: "Correct Birth Date"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    Text(localizationManager.text(it: "Dichiara la tua effettiva data di nascita sotto tua responsabilità.", en: "State your actual date of birth under your responsibility."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text(localizationManager.text(it: "SELEZIONA LA DATA DI NASCITA REALE:", en: "SELECT YOUR ACTUAL BIRTH DATE:"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
                
                DatePicker(
                    "",
                    selection: $correctedBirthDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .frame(maxHeight: 280)
                .padding(8)
                .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 10))
                
                let calcAge = Calendar.current.dateComponents([.year], from: correctedBirthDate, to: Date()).year ?? 0
                HStack {
                    Text(localizationManager.text(it: "Età calcolata:", en: "Calculated age:"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    Text("\(calcAge) " + localizationManager.text(it: "anni", en: "years"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(calcAge >= 18 ? .green : .red)
                    Spacer()
                    if calcAge >= 18 {
                        Text(localizationManager.text(it: "Requisito soddisfatto (18+)", en: "Requirement met (18+)"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.green)
                    } else {
                        Text(localizationManager.text(it: "Accesso non consentito (<18)", en: "Access not allowed (<18)"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.red)
                    }
                }
                
                if let err = correctionError {
                    Text(err)
                        .font(UniFont.caption())
                        .foregroundStyle(.red)
                }
            }
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) {
                    isShowingCorrectionSheet = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button {
                    let age = Calendar.current.dateComponents([.year], from: correctedBirthDate, to: Date()).year ?? 0
                    if age < 18 {
                        correctionError = localizationManager.text(
                            it: "Non puoi accedere: l'età inserita (\(age) anni) è inferiore a 18 anni.",
                            en: "Access denied: the entered age (\(age) years) is below 18."
                        )
                    } else {
                        dataManager.userBirthDate = correctedBirthDate
                        dataManager.isAgeVerified = true
                        dataManager.isMinorBlocked = false
                        dataManager.saveData()
                        isShowingCorrectionSheet = false
                        NotificationManager.shared.notify(
                            title: localizationManager.text(it: "Età verificata con successo", en: "Age verified successfully"),
                            message: localizationManager.text(it: "Accesso all'applicazione sbloccato", en: "App access unlocked"),
                            type: .success,
                            icon: "checkmark.shield.fill"
                        )
                    }
                } label: {
                    Text(localizationManager.text(it: "Conferma & Sblocca App", en: "Confirm & Unlock App"))
                        .font(UniFont.headline())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(themeManager.accentColor)
                        .foregroundStyle(themeManager.accentTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(width: 480)
    }
}
