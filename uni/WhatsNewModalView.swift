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
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(localizationManager.text(it: "Novità di uni", en: "What's New in uni"))
                            .font(UniFont.title())
                            .fontWeight(.bold)
                        
                        Text("v1.4.0")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(themeManager.accentColor.opacity(0.15))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(Capsule())
                    }
                    
                    Text(localizationManager.text(
                        it: "Abbiamo arricchito uni con una nuova gestione calendari, layout impegni a schede e un'esperienza d'avvio ancora più fluida.",
                        en: "We enriched uni with full calendar management, card-based schedule view, and a smoother launch experience."
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
                        .foregroundStyle(.secondary)
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
                        icon: "slider.horizontal.3",
                        iconColor: themeManager.accentColor,
                        title: localizationManager.text(
                            it: "Gestione Calendari & Integrazione Mac",
                            en: "Calendar Management & Mac Integration"
                        ),
                        description: localizationManager.text(
                            it: "Importa link iCal/webcal e sincronizza con un clic i calendari del tuo Mac (Google, Outlook, iCloud). Scegli quali mostrare e separa comodamente lezioni e impegni personali.",
                            en: "Import iCal/webcal links and sync your Mac's calendars (Google, Outlook, iCloud) in one click. Toggle individual calendars and keep academic lectures distinct from personal events."
                        )
                    )
                    
                    featureCard(
                        icon: "square.grid.2x2",
                        iconColor: .blue,
                        title: localizationManager.text(
                            it: "Impegni del Giorno & Schede Prossimi Giorni",
                            en: "Daily Schedule & Upcoming Days Cards"
                        ),
                        description: localizationManager.text(
                            it: "Consulta le tue lezioni ed esami di oggi con orari in evidenza e naviga i prossimi impegni a 3, 7 o 20 giorni con salto immediato alla data desiderata.",
                            en: "View today's lectures and exams with prominent schedules, and browse upcoming events across 3, 7, or 20 days with instant date jump."
                        )
                    )
                    
                    featureCard(
                        icon: "sparkles",
                        iconColor: .purple,
                        title: localizationManager.text(
                            it: "Schermata d'Avvio & Dettagli Personalizzati",
                            en: "Refined Launch & Personalized Touch"
                        ),
                        description: localizationManager.text(
                            it: "Nuova schermata di caricamento con indicatore circolare fluido, rispetto del tuo font personalizzato e un avvio più piacevole e curato nei minimi dettagli.",
                            en: "A redesigned launch experience featuring a smooth circular loader, user-tailored typography, and an overall more polished app opening."
                        )
                    )
                    
                    featureCard(
                        icon: "rectangle.grid.2x2.fill",
                        iconColor: .green,
                        title: localizationManager.text(
                            it: "Dashboard & Control Overview",
                            en: "Dashboard & Control Overview"
                        ),
                        description: localizationManager.text(
                            it: "Panoramica a griglia rapida con le tue prossime scadenze, file di studio dal Mac e scorciatoie per non perdere mai il ritmo.",
                            en: "Quick bento grid overview with your next deadlines, study files from your Mac, and shortcuts to keep your workflow in sync."
                        )
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
            }
            .frame(maxHeight: 380)
            
            Divider()
            
            // Footer con Tasto Esplora
            HStack {
                Spacer()
                
                Button {
                    close()
                } label: {
                    HStack(spacing: 6) {
                        Text(localizationManager.text(it: "Inizia a Esplorare", en: "Start Exploring"))
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
        .frame(minWidth: 540, maxWidth: 620)
    }
    
    private func featureCard(icon: String, iconColor: Color, title: String, description: String) -> some View {
        UniCard(padding: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(UniFont.headline())
                        .foregroundStyle(.primary)
                    
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
        UserDefaults.standard.set("1.4.0", forKey: "uni_last_seen_release_notes")
        dismiss()
    }
}
