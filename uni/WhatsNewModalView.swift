//
//  WhatsNewModalView.swift
//  uni
//
//  Created by zinco.cc on 28/09/2026.
//

import SwiftUI

public struct WhatsNewModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    public init() {}
    
    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.4.2"
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(themeManager.accentColor.opacity(0.14))
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(themeManager.accentColor.opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(localizationManager.text(it: "NOTE DI RILASCIO", en: "RELEASE NOTES"))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(themeManager.accentColor.opacity(0.12))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(Capsule())
                        
                        Text("v\(currentVersion)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2.5)
                            .background(Color.primary.opacity(0.04))
                            .overlay(Capsule().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    
                    Text(localizationManager.text(it: "Novità introdotte in uni", en: "What's New in uni"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(localizationManager.text(
                        it: "Ecco i miglioramenti, le correzioni di sistema e le nuove opzioni disponibili.",
                        en: "Explore the new features, system enhancements, and workflow improvements."
                    ))
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            Divider()
            
            // Lista Novità Illustrata
            ScrollView {
                VStack(spacing: 14) {
                    featureCard(
                        category: localizationManager.text(it: "CALENDARI MAC", en: "MAC CALENDARS"),
                        badgeColor: .blue,
                        icon: "calendar.badge.clock",
                        iconColor: .blue,
                        title: localizationManager.text(
                            it: "Sincronizzazione Calendari Mac a 1 Click",
                            en: "1-Click Mac Calendar Sync"
                        ),
                        description: localizationManager.text(
                            it: "Ora puoi replicare e sincronizzare istantaneamente tutti i calendari del tuo Mac (iCloud, Google, Exchange), sia dalla vista Calendario che direttamente durante la configurazione guidata.",
                            en: "Instantly replicate and sync all Mac calendars (iCloud, Google, Exchange), accessible both in the Calendar page and right inside the setup wizard."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "AGGIORNAMENTI", en: "AUTO-UPDATES"),
                        badgeColor: .orange,
                        icon: "arrow.triangle.2.circlepath.circle.fill",
                        iconColor: .orange,
                        title: localizationManager.text(
                            it: "Controllo Automatico Giornaliero",
                            en: "Daily Automatic Update Checks"
                        ),
                        description: localizationManager.text(
                            it: "L'app controlla automaticamente la disponibilità di nuove versioni una volta al giorno in background, anche se la lasci sempre aperta senza riavviare il Mac.",
                            en: "uni now automatically checks for updates once a day in the background, even when running continuously without being restarted."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "INSTALLAZIONE", en: "INSTALLATION"),
                        badgeColor: .green,
                        icon: "arrow.down.doc.fill",
                        iconColor: .green,
                        title: localizationManager.text(
                            it: "Installazione Pulita Senza Conflitti",
                            en: "Clean Installation Without Conflicts"
                        ),
                        description: localizationManager.text(
                            it: "Quando scarichi un aggiornamento, uni apre il file DMG nel Finder e chiude automaticamente il processo in esecuzione per permetterti di sostituire l'app senza conflitti di sistema.",
                            en: "When installing updates, uni mounts the DMG in Finder and gracefully quits so macOS Finder can replace the app in /Applications with zero file locks."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "SISTEMA", en: "SYSTEM"),
                        badgeColor: themeManager.accentColor,
                        icon: "clock.arrow.circlepath",
                        iconColor: themeManager.accentColor,
                        title: localizationManager.text(
                            it: "Avanzamento Automatico Data Odierna",
                            en: "Automatic Real-Time Date Advancement"
                        ),
                        description: localizationManager.text(
                            it: "La dashboard e il calendario avanzano in tempo reale alla nuova giornata a mezzanotte o al risveglio dal blocco schermo senza richiedere un riavvio.",
                            en: "The dashboard and schedule views now seamlessly advance to the new date at midnight or upon waking from screen lock without restarting."
                        )
                    )
                    
                    // Box informativo sul prossimo step (Setup pre-popolato)
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(themeManager.accentColor)
                            .padding(.top, 1)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localizationManager.text(it: "Cosa succede ora?", en: "What happens next?"))
                                .font(UniFont.headline())
                                .foregroundStyle(.primary)
                            
                            Text(localizationManager.text(
                                it: "Cliccando il tasto sottostante si aprirà il setup di riepilogo con tutti i tuoi dati già salvati (nome, ateneo, link e calendari), così da verificare o aggiornare rapidamente le tue impostazioni.",
                                en: "Clicking below opens your setup review with all existing information already pre-filled (student details, campus links, and calendars) to easily check or adjust your configuration."
                            ))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                        }
                    }
                    .padding(14)
                    .background(themeManager.accentColor.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(themeManager.accentColor.opacity(0.18), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 18)
            }
            .frame(maxHeight: 390)
            
            Divider()
            
            // Footer con Tasto Azione Chiaro
            HStack {
                Text(localizationManager.text(it: "uni per macOS • Sviluppata per studenti", en: "uni for macOS • Crafted for students"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    close()
                } label: {
                    HStack(spacing: 6) {
                        Text(localizationManager.text(it: "Verifica Setup & Continua", en: "Review Setup & Continue"))
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(Color.primary.opacity(0.02))
        }
        .frame(minWidth: 560, maxWidth: 620)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func featureCard(
        category: String,
        badgeColor: Color,
        icon: String,
        iconColor: Color,
        title: String,
        description: String
    ) -> some View {
        UniCard(padding: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(category)
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor.opacity(0.12))
                            .foregroundStyle(badgeColor)
                            .clipShape(Capsule())
                        
                        Text(title)
                            .font(UniFont.headline())
                            .foregroundStyle(.primary)
                    }
                    
                    Text(description)
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private func close() {
        UserDefaults.standard.set(currentVersion, forKey: "uni_last_seen_release_notes")
        dismiss()
    }
}

