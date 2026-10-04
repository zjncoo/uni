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
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5.2"
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
                        category: localizationManager.text(it: "PRIVACY & TRASPARENZA", en: "PRIVACY & TRANSPARENCY"),
                        badgeColor: .indigo,
                        icon: "lock.shield.fill",
                        iconColor: .indigo,
                        title: localizationManager.text(
                            it: "Consenso Informato & Tutela Privacy",
                            en: "Informed Consent & Privacy Shield"
                        ),
                        description: localizationManager.text(
                            it: "Nuovo modulo di feedback protetto con consenso informato esplicito, minimizzazione dei dati personali e garanzia che corsi, orari ed esami rimangono al 100% locali sul tuo Mac.",
                            en: "New protected feedback submission with explicit consent, data minimization, and verified guarantees that courses, schedules, and exams remain 100% local on your Mac."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "CALENDARIO APPLE", en: "APPLE CALENDAR"),
                        badgeColor: .blue,
                        icon: "calendar.badge.plus",
                        iconColor: .blue,
                        title: localizationManager.text(
                            it: "Sincronizzazione Automatica su Apple Calendar",
                            en: "Automatic Apple Calendar Synchronization"
                        ),
                        description: localizationManager.text(
                            it: "Scadenze (📌), compiti (📝) ed esami (🎓) creati o aggiornati in qualsiasi vista vengono ora sincronizzati automaticamente nel calendario di sistema \"uni 📚\" su Mac ed iPhone.",
                            en: "Deadlines (📌), assignments (📝), and exams (🎓) created or edited in any view are now automatically synced to the native \"uni 📚\" system calendar across Mac and iPhone."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "STATO & BIDIREZIONALE", en: "STATE & COMPLETION"),
                        badgeColor: .green,
                        icon: "checkmark.circle.badge.questionmark.fill",
                        iconColor: .green,
                        title: localizationManager.text(
                            it: "Aggiornamento Real-Time & Completamento",
                            en: "Real-Time Updates & Task Completion"
                        ),
                        description: localizationManager.text(
                            it: "Completare una scadenza o registrare il voto di un esame aggiorna istantaneamente l'evento nel calendario macOS con prefisso ✅ e note dettagliate.",
                            en: "Completing a deadline or recording an exam grade instantly updates the macOS calendar event with ✅ status and course details."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "RICERCA GLOBALE", en: "GLOBAL SEARCH"),
                        badgeColor: .purple,
                        icon: "magnifyingglass.circle.fill",
                        iconColor: .purple,
                        title: localizationManager.text(
                            it: "Motore di Ricerca Avanzato & Palette ⌘K",
                            en: "Advanced Search Engine & ⌘K Palette"
                        ),
                        description: localizationManager.text(
                            it: "Indicizzazione istantanea di corsi, esami, scadenze, compiti ed eventi con ricerca fuzzy, filtri per categoria e navigazione diretta all'elemento.",
                            en: "Instant indexing of courses, exams, deadlines, assignments, and events with fuzzy matching, category filters, and direct item navigation."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "GESTIONE CALENDARI", en: "CALENDAR CONTROLS"),
                        badgeColor: themeManager.accentColor,
                        icon: "arrow.triangle.2.circlepath",
                        iconColor: themeManager.accentColor,
                        title: localizationManager.text(
                            it: "Controlli Sincronizzazione in Impostazioni & Hub",
                            en: "Sync Controls in Settings & Calendar Hub"
                        ),
                        description: localizationManager.text(
                            it: "Nuove schede dedicate con stato autorizzazioni, interruttore di attivazione e pulsante \"Sincronizza Tutto Adesso\" per riconciliare tutti gli elementi esistenti.",
                            en: "Dedicated control cards with authorization status, enable toggle, and a \"Sync All Now\" action to reconcile all existing academic milestones."
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

