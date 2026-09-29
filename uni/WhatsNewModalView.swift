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
                        
                        Text("v1.4.1")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(themeManager.accentColor.opacity(0.15))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(Capsule())
                    }
                    
                    Text(localizationManager.text(
                        it: "Questo aggiornamento corregge la sincronizzazione dei calendari di sistema su macOS e introduce l'avanzamento automatico della data odierna.",
                        en: "This update fixes Mac calendar sync on macOS and brings automatic real-time date advancement."
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
                        icon: "checkmark.seal.fill",
                        iconColor: themeManager.accentColor,
                        title: localizationManager.text(
                            it: "Sincronizzazione Calendario Mac Risolta",
                            en: "Mac Calendar Sync Resolved"
                        ),
                        description: localizationManager.text(
                            it: "Risolto il problema di autorizzazione EventKit nelle versioni distribuite. Ora puoi replicare e sincronizzare istantaneamente tutti i calendari del tuo Mac (iCloud, Google, Exchange).",
                            en: "Resolved EventKit authorization issues in distributed builds. You can now instantly replicate and sync all Mac calendars (iCloud, Google, Exchange)."
                        )
                    )
                    
                    featureCard(
                        icon: "clock.arrow.circlepath",
                        iconColor: .blue,
                        title: localizationManager.text(
                            it: "Avanzamento Automatico Data Odierna",
                            en: "Automatic Real-Time Date Updates"
                        ),
                        description: localizationManager.text(
                            it: "La dashboard e il calendario avanzano automaticamente sul nuovo giorno a mezzanotte o al risveglio dal blocco schermo senza bisogno di riavviare l'app.",
                            en: "The dashboard and calendar views now seamlessly advance to the new day at midnight or upon waking the Mac without requiring an app restart."
                        )
                    )
                    
                    featureCard(
                        icon: "slider.horizontal.3",
                        iconColor: .purple,
                        title: localizationManager.text(
                            it: "Gestione Calendari & Impegni a Schede",
                            en: "Calendar Hub & Schedule Cards"
                        ),
                        description: localizationManager.text(
                            it: "Importa feed iCal/webcal, gestisci la visibilità per singola sorgente e consulta gli impegni a 3, 7 e 20 giorni con layout a schede moderne.",
                            en: "Import iCal/webcal feeds, toggle visibility per calendar source, and navigate upcoming commitments across 3, 7, and 20 days."
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
        UserDefaults.standard.set("1.4.1", forKey: "uni_last_seen_release_notes")
        dismiss()
    }
}
