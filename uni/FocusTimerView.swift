//
//  FocusTimerView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import Combine
#if canImport(AppKit)
import AppKit
#endif

public struct FocusTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    // Timer Modes
    public enum TimerMode: String, CaseIterable {
        case focus25 = "Focus (25m)"
        case focus50 = "Focus (50m)"
        case shortBreak = "Pausa Breve (5m)"
        case longBreak = "Pausa Lunga (15m)"
        
        public var durationSeconds: Int {
            switch self {
            case .focus25: return 25 * 60
            case .focus50: return 50 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
        
        public var isFocus: Bool {
            self == .focus25 || self == .focus50
        }
        
        public func localizedTitle(isEnglish: Bool) -> String {
            switch self {
            case .focus25: return isEnglish ? "Focus (25m)" : "Focus (25m)"
            case .focus50: return isEnglish ? "Focus (50m)" : "Focus (50m)"
            case .shortBreak: return isEnglish ? "Short Break (5m)" : "Pausa Breve (5m)"
            case .longBreak: return isEnglish ? "Long Break (15m)" : "Pausa Lunga (15m)"
            }
        }
    }
    
    @State private var currentMode: TimerMode = .focus25
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var selectedCourseId: UUID? = nil
    
    // Timer publisher
    @State private var timerSubscription: AnyCancellable? = nil
    
    public init() {}
    
    private var totalDuration: Int {
        currentMode.durationSeconds
    }
    
    private var progress: Double {
        guard totalDuration > 0 else { return 0.0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    private var selectedCourseName: String {
        if let id = selectedCourseId, let course = dataManager.courses.first(where: { $0.id == id }) {
            return course.name
        }
        return localizationManager.text(it: "Studio Generale", en: "General Study")
    }
    
    public var body: some View {
        let isEn = localizationManager.currentLanguage == .english
        VStack(spacing: 24) {
            // Header con chiusura
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Focus & Pomodoro")
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    Text(localizationManager.text(it: "Sessione di studio concentrato", en: "Focused study session"))
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Selettore Materia
            HStack(spacing: 12) {
                Label(localizationManager.text(it: "Materia di studio:", en: "Study subject:"), systemImage: "book.closed")
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
                
                Picker("", selection: $selectedCourseId) {
                    Text(localizationManager.text(it: "Studio Generale", en: "General Study")).tag(UUID?.none)
                    ForEach(dataManager.courses) { course in
                        Text(course.name).tag(UUID?.some(course.id))
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 220)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.03))
            .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
            .clipShape(Rectangle())
            
            // Modalità Timer Tabs
            HStack(spacing: 6) {
                ForEach(TimerMode.allCases, id: \.self) { mode in
                    Button {
                        switchMode(to: mode)
                    } label: {
                        Text(mode.localizedTitle(isEnglish: isEn))
                            .font(UniFont.caption())
                            .fontWeight(currentMode == mode ? .semibold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(currentMode == mode ? themeManager.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                            .foregroundStyle(currentMode == mode ? themeManager.accentColor : .primary)
                            .overlay(Rectangle().stroke(currentMode == mode ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1))
                            .clipShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Timer Circolare
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.primary.opacity(0.06), lineWidth: 10)
                    .frame(width: 210, height: 210)
                
                // Active Progress Ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        currentMode.isFocus ? themeManager.accentColor : Color.green,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 210, height: 210)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.8), value: progress)
                
                // Contenuto Centrale
                VStack(spacing: 4) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 46, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)
                    
                    Text(currentMode.isFocus ? (isEn ? "FOCUS SESSION" : "SESSIONE CONCENTRAZIONE") : (isEn ? "REST BREAK" : "PAUSA RIPOSO"))
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(currentMode.isFocus ? themeManager.accentColor : .green)
                    
                    Text(selectedCourseName)
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 10)
            
            // Pulsanti di Controllo
            HStack(spacing: 16) {
                Button {
                    toggleTimer()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        Text(isRunning ? localizationManager.text(it: "Metti in Pausa", en: "Pause Session") : localizationManager.text(it: "Inizia Sessione", en: "Start Session"))
                    }
                    .font(UniFont.headline())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(themeManager.accentColor)
                    .foregroundStyle(themeManager.accentTextColor)
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(10)
                        .background(Color.primary.opacity(0.06))
                        .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                        .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Azzera timer", en: "Reset timer"))
                
                Button {
                    skipTimer()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(10)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Passa alla modalità successiva", en: "Skip to next mode"))
            }
            
            // Footer Tips
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(themeManager.accentColor)
                Text(currentMode.isFocus ? localizationManager.text(it: "Silenzia le notifiche e mantieni il focus per massimizzare la resa.", en: "Silence notifications and maintain deep focus.") : localizationManager.text(it: "Alzati, bevi un bicchiere d'acqua e distendi gli occhi dallo schermo.", en: "Stand up, drink water and rest your eyes away from the screen."))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 480)
        .background(
            Rectangle()
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            Rectangle()
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Timer Logic
    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        SoundManager.shared.play(.pop)
        isRunning = true
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timerFinished()
                }
            }
    }
    
    private func stopTimer() {
        if isRunning {
            SoundManager.shared.play(.pop)
        }
        isRunning = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    private func resetTimer() {
        SoundManager.shared.play(.remove)
        stopTimer()
        timeRemaining = currentMode.durationSeconds
    }
    
    private func switchMode(to mode: TimerMode) {
        stopTimer()
        currentMode = mode
        timeRemaining = mode.durationSeconds
    }
    
    private func skipTimer() {
        SoundManager.shared.play(.pop)
        stopTimer()
        if currentMode.isFocus {
            switchMode(to: .shortBreak)
        } else {
            switchMode(to: .focus25)
        }
    }
    
    private func timerFinished() {
        stopTimer()
        SoundManager.shared.play(.timer)
        
        let isFocus = currentMode.isFocus
        let lm = LocalizationManager.shared
        let title = isFocus ? lm.t(.focusCompleted) : lm.t(.breakEnded)
        let msg = isFocus
            ? lm.t(.greatWork(selectedCourseName))
            : lm.t(.readyToFocus)
        
        // Notifica sia In-App che macOS Notification Center
        NotificationManager.shared.notify(
            title: title,
            message: msg,
            type: isFocus ? .success : .info,
            icon: isFocus ? "flame.fill" : "cup.and.saucer.fill",
            postToSystem: true
        )
        
        // Transizione automatica
        if isFocus {
            switchMode(to: .shortBreak)
        } else {
            switchMode(to: .focus25)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
