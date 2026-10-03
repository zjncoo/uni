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
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5.0"
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
                        category: localizationManager.text(it: "INSERIMENTO RAPIDO", en: "PROGRESSIVE ADD"),
                        badgeColor: themeManager.accentColor,
                        icon: "plus.circle.fill",
                        iconColor: themeManager.accentColor,
                        title: localizationManager.text(
                            it: "Nuova Creazione Progressiva a Passaggi",
                            en: "Progressive Step-by-Step Item Creation"
                        ),
                        description: localizationManager.text(
                            it: "Flusso interattivo guidato per aggiungere corsi, esami, compiti e impegni accademici con suggerimenti intelligenti e validazione in tempo reale.",
                            en: "Streamlined interactive wizard to add courses, exams, assignments, and academic milestones with smart suggestions and live validation."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "DESIGN SYSTEM", en: "DESIGN SYSTEM"),
                        badgeColor: .blue,
                        icon: "sparkles.rectangle.stack.fill",
                        iconColor: .blue,
                        title: localizationManager.text(
                            it: "Estetica macOS Raffinata & Componenti Dedicati",
                            en: "Refined macOS Aesthetics & Native Components"
                        ),
                        description: localizationManager.text(
                            it: "Design completamente rinnovato con card glassmorfiche, indicatori di stato nitidi, micro-animazioni fluide e contrasto ottimizzato in Dark/Light mode.",
                            en: "Completely refreshed visual style with glassmorphic cards, crisp status indicators, fluid micro-interactions, and optimized contrast in Dark & Light modes."
                        )
                    )
                    
                    featureCard(
                        category: localizationManager.text(it: "CALENDARIO & VISTE", en: "CALENDAR & VIEWS"),
                        badgeColor: .green,
                        icon: "calendar.badge.clock",
                        iconColor: .green,
                        title: localizationManager.text(
                            it: "Timeline Calendario Riprogettata & Viste Accademiche",
                            en: "Redesigned Calendar Timeline & Academic Views"
                        ),
                        description: localizationManager.text(
                            it: "Vista oraria più pulita e leggibile per le lezioni, dashboard arricchita e viste Corsi, Compiti ed Esami con layout a griglia modernizzato.",
                            en: "Cleaner and more legible timetable for lectures, enriched dashboard metrics, and modernized grid views across Courses, Assignments, and Exams."
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

