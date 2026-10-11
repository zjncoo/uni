//
//  UniMenuBarExtraView.swift
//  uni
//
//  Created by zinco.cc on 11/10/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct UniMenuBarExtraView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    fileprivate static let dateFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM"
        return f
    }()
    
    fileprivate static let dateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d"
        return f
    }()
    
    private var todayString: String {
        let isEn = localizationManager.currentLanguage == .english
        let str = isEn ? Self.dateFormatterEN.string(from: Date()) : Self.dateFormatterIT.string(from: Date())
        return str.prefix(1).uppercased() + str.dropFirst()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header del Menu Bar Extra
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(themeManager.accentColor)
                        .frame(width: 22, height: 22)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(themeManager.accentTextColor)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("uni")
                        .font(UniFont.headline())
                        .fontWeight(.bold)
                    Text(todayString)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    openMainWindow()
                } label: {
                    HStack(spacing: 4) {
                        Text(localizationManager.text(it: "Apri", en: "Open"))
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(themeManager.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.accentColor.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .focusEffectDisabled()
            }
            
            Divider()
            
            // 1. SEZIONE LEZIONI DI OGGI
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(localizationManager.text(it: "LEZIONE DI OGGI", en: "TODAY'S LECTURE"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                    Spacer()
                }
                
                if let next = dataManager.nextLectureToday() {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: next.course.colorHex) ?? themeManager.accentColor)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.course.name)
                                .font(UniFont.subheadline())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            HStack(spacing: 6) {
                                Text("\(next.schedule.startTime) - \(next.schedule.endTime)")
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                
                                if !next.schedule.room.isEmpty || !next.course.room.isEmpty {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(next.schedule.room.isEmpty ? next.course.room : next.schedule.room)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(next.isNow ? localizationManager.text(it: "IN CORSO", en: "NOW") : localizationManager.text(it: "PROSSIMA", en: "NEXT"))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(next.isNow ? .green : themeManager.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background((next.isNow ? Color.green : themeManager.accentColor).opacity(0.12), in: Capsule())
                    }
                    .padding(8)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text(localizationManager.text(it: "Nessuna lezione in programma oggi", en: "No lectures scheduled for today"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
            
            // 2. SCADENZE & CONSEGNE IMMINENTI
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(localizationManager.text(it: "IN SOSPESO", en: "PENDING ACTIVITIES"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                    Spacer()
                }
                
                let upcomingDeadlines = dataManager.deadlines.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }.prefix(2)
                let upcomingAssignments = dataManager.assignments.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }.prefix(2)
                
                if upcomingDeadlines.isEmpty && upcomingAssignments.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                        Text(localizationManager.text(it: "Tutto completato! Nessuna attività in sospeso", en: "All caught up! No pending activities"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } else {
                    ForEach(Array(upcomingDeadlines)) { deadline in
                        HStack(spacing: 8) {
                            Button {
                                if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
                                    dataManager.deadlines[idx].isCompleted.toggle()
                                    dataManager.saveData()
                                }
                            } label: {
                                Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 13))
                                    .foregroundStyle(deadline.isCompleted ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            .focusable(false)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(deadline.title)
                                    .font(UniFont.subheadline())
                                    .lineLimit(1)
                                
                                if let amount = deadline.amount {
                                    Text(String(format: "%.2f €", amount))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(themeManager.accentColor)
                                }
                            }
                            
                            Spacer()
                            
                            Text(formatDueDate(deadline.dueDate))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(deadline.dueDate < Date() ? .red : .secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    ForEach(Array(upcomingAssignments)) { assignment in
                        HStack(spacing: 8) {
                            Button {
                                if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
                                    dataManager.assignments[idx].isCompleted.toggle()
                                    dataManager.saveData()
                                }
                            } label: {
                                Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 13))
                                    .foregroundStyle(assignment.isCompleted ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            .focusable(false)
                            
                            Text(assignment.title)
                                .font(UniFont.subheadline())
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(formatDueDate(assignment.dueDate))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(assignment.dueDate < Date() ? .red : .secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Divider()
            
            // 3. STATISTICHE CARRIERA RAPIDE
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.t(.currentGPA).uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(dataManager.weightedAverage > 0 ? String(format: "%.2f", dataManager.weightedAverage) : "--")
                        .font(UniFont.subheadline())
                        .fontWeight(.bold)
                        .foregroundStyle(themeManager.accentColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(localizationManager.t(.totalCredits).uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text("\(dataManager.totalCfuAcquired) / \(dataManager.totalCfuTarget) CFU")
                        .font(UniFont.subheadline())
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 4)
            
            Divider()
            
            // 4. FOOTER: Esci dall'applicazione
            HStack {
                Spacer()
                Button {
                    #if canImport(AppKit)
                    NSApplication.shared.terminate(nil)
                    #endif
                } label: {
                    Text(localizationManager.text(it: "Esci da uni", en: "Quit uni"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .focusEffectDisabled()
            }
        }
        .padding(14)
        .frame(width: 310)
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return localizationManager.text(it: "Oggi", en: "Today")
        } else if calendar.isDateInTomorrow(date) {
            return localizationManager.text(it: "Domani", en: "Tomorrow")
        } else {
            let f = DateFormatter()
            f.dateFormat = "d MMM"
            return f.string(from: date)
        }
    }
    
    private func openMainWindow() {
        #if canImport(AppKit)
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeKey && $0.isVisible }) ?? NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
        #endif
    }
}
