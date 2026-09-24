//
//  OverviewNewItemModalView.swift
//  uni
//
//  Created by zinco.cc on 24/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct OverviewNewItemModalView: View {
    @Binding var isPresented: Bool
    var onSelectAssignment: () -> Void
    var onSelectDeadline: () -> Void
    var onSelectExam: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var hoveredCard: String? = nil
    
    public var body: some View {
        ZStack {
            // Sfondo oscurato con blur
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // Modal Card in mezzo alla pagina
            VStack(spacing: 20) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.text(it: "Cosa vuoi aggiungere?", en: "What would you like to add?"))
                            .font(UniFont.title())
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(localizationManager.text(it: "Seleziona la tipologia di elemento da creare per la tua carriera universitaria", en: "Select the type of item to create for your university journey"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color.primary.opacity(0.06), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Chiudi (ESC)", en: "Close (ESC)"))
                }
                
                // Riquadri di scelta (Assignment, Deadline, Esame)
                HStack(spacing: 16) {
                    // 1. Assignment
                    choiceCard(
                        id: "assignment",
                        title: localizationManager.text(it: "Assignment", en: "Assignment"),
                        subtitle: localizationManager.text(it: "Progetto, consegna, tesina o esercizio pratico con link allegato.", en: "Project, homework, paper or exercise with web link."),
                        icon: "doc.text.fill",
                        badge: "⌘6",
                        accent: Color.blue
                    ) {
                        dismissAndTrigger(onSelectAssignment)
                    }
                    
                    // 2. Deadline
                    choiceCard(
                        id: "deadline",
                        title: localizationManager.text(it: "Scadenza", en: "Deadline"),
                        subtitle: localizationManager.text(it: "Data limite, tasse, iscrizioni bandi o promemoria di studio.", en: "Due date, tuition fees, submissions or study reminders."),
                        icon: "clock.fill",
                        badge: "⌘4",
                        accent: Color.orange
                    ) {
                        dismissAndTrigger(onSelectDeadline)
                    }
                    
                    // 3. Esame
                    choiceCard(
                        id: "exam",
                        title: localizationManager.text(it: "Esame", en: "Exam"),
                        subtitle: localizationManager.text(it: "Appello d'esame, aula, voto target e CFU di percorso.", en: "Exam session, room, target grade and degree CFU."),
                        icon: "graduationcap.fill",
                        badge: "⌘5",
                        accent: themeManager.accentColor
                    ) {
                        dismissAndTrigger(onSelectExam)
                    }
                }
            }
            .padding(24)
            .frame(width: 680)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.28), radius: 30, x: 0, y: 15)
            )
        }
        .onExitCommand {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPresented = false
            }
        }
    }
    
    private func dismissAndTrigger(_ action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            action()
        }
    }
    
    @ViewBuilder
    private func choiceCard(
        id: String,
        title: String,
        subtitle: String,
        icon: String,
        badge: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        let isHovered = hoveredCard == id
        
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(accent.opacity(isHovered ? 0.22 : 0.12))
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(accent)
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(UniFont.headline())
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isHovered ? accent : .secondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isHovered ? accent : .secondary)
                        .offset(x: isHovered ? 3 : 0)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovered ? accent.opacity(0.06) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isHovered ? accent.opacity(0.5) : Color.primary.opacity(0.08), lineWidth: isHovered ? 1.5 : 1)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredCard = hovering ? id : nil
        }
    }
}
