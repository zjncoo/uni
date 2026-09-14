//
//  CalendarView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Day Events Summary (Pre-grouped for Instant Performance)
struct DayEventsSummary {
    var events: [CalendarEventItem] = []
    var deadlines: [Deadline] = []
    var exams: [Exam] = []
    var assignments: [Assignment] = []
    
    var eventsCount: Int { events.count }
    var hasExam: Bool { !exams.isEmpty }
    var hasDeadline: Bool { !deadlines.isEmpty }
    var hasPendingDeadline: Bool { deadlines.contains(where: { !$0.isCompleted }) }
    var hasAssignment: Bool { !assignments.isEmpty }
    var hasPendingAssignment: Bool { assignments.contains(where: { !$0.isCompleted }) }
}

struct CalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var isShowingFeedConfig: Bool = false
    @State private var isPresentingNewDeadline: Bool = false
    
    private let calendar = Calendar.current
    
    private var daysOfWeek: [String] {
        if localizationManager.currentLanguage == .english {
            return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        } else {
            return ["LUN", "MAR", "MER", "GIO", "VEN", "SAB", "DOM"]
        }
    }
    
    // MARK: - Pre-calculated Hash Map (Eliminates O(N*M) Date Calculations)
    private var daySummaries: [Date: DayEventsSummary] {
        var dict: [Date: DayEventsSummary] = [:]
        let cal = Calendar.current
        
        for event in dataManager.syncedEvents {
            let key = cal.startOfDay(for: event.startDate)
            dict[key, default: DayEventsSummary()].events.append(event)
        }
        
        for deadline in dataManager.deadlines {
            let key = cal.startOfDay(for: deadline.dueDate)
            dict[key, default: DayEventsSummary()].deadlines.append(deadline)
        }
        
        for exam in dataManager.exams {
            let key = cal.startOfDay(for: exam.examDate)
            dict[key, default: DayEventsSummary()].exams.append(exam)
        }
        
        for assignment in dataManager.assignments {
            let key = cal.startOfDay(for: assignment.dueDate)
            dict[key, default: DayEventsSummary()].assignments.append(assignment)
        }
        
        return dict
    }
    
    // MARK: - Cached Static Date Formatters (Eliminates repeated allocations)
    private static let monthYearFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    private static let monthYearFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    private static let dayNumberFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE, d MMMM yyyy"
        return f
    }()
    
    private static let dayNumberFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()
    
    private static let syncDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMM, 'ore' HH:mm"
        return f
    }()
    
    private static let timeRangeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return f
    }()
    
    var body: some View {
        let summaries = daySummaries
        let selectedDayKey = calendar.startOfDay(for: selectedDate)
        let selectedDaySummary = summaries[selectedDayKey] ?? DayEventsSummary()
        let days = generateDaysInMonth(for: currentMonth)
        
        HSplitView {
            // Colonna Sinistra: Griglia Calendario & Barra Sincronizzazione
            VStack(alignment: .leading, spacing: 16) {
                // Banner Prominente Data Odierna in Grande
                UniCard(padding: 14) {
                    HStack(alignment: .center, spacing: 16) {
                        // Riquadro con numero giorno in grande
                        VStack(spacing: 0) {
                            Text(todayDayOfWeekName().uppercased())
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(themeManager.accentTextColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 3)
                                .background(themeManager.accentColor)
                            
                            Text("\(calendar.component(.day, from: Date()))")
                                .font(UniFont.display(30))
                                .fontWeight(.light)
                                .foregroundStyle(.primary)
                                .frame(width: 56, height: 40)
                                .background(Color.primary.opacity(0.04))
                        }
                        .frame(width: 56)
                        .clipShape(Rectangle())
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(localizationManager.currentLanguage == .italian ? "OGGI" : "TODAY")
                                    .font(UniFont.caption())
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeManager.accentColor)
                                    .tracking(1.0)
                                
                                Text("•")
                                    .foregroundStyle(.secondary)
                                
                                Text(todayFullFormatted())
                                    .font(UniFont.headline())
                                    .foregroundStyle(.primary)
                            }
                            
                            let todayEventsCount = summaries[calendar.startOfDay(for: Date())]?.eventsCount ?? 0
                            let todayDeadlinesCount = summaries[calendar.startOfDay(for: Date())]?.deadlines.count ?? 0
                            let todayExamsCount = summaries[calendar.startOfDay(for: Date())]?.exams.count ?? 0
                            let todayAssignmentsCount = summaries[calendar.startOfDay(for: Date())]?.assignments.count ?? 0
                            
                            HStack(spacing: 8) {
                                if todayEventsCount == 0 && todayDeadlinesCount == 0 && todayExamsCount == 0 && todayAssignmentsCount == 0 {
                                    Text(localizationManager.currentLanguage == .italian ? "Nessuna lezione o scadenza oggi" : "No lectures or deadlines today")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                } else {
                                    if todayEventsCount > 0 {
                                        Label(localizationManager.text(it: "\(todayEventsCount) lezioni", en: "\(todayEventsCount) lectures"), systemImage: "book.closed")
                                            .font(UniFont.caption())
                                            .foregroundStyle(themeManager.accentColor)
                                    }
                                    if todayDeadlinesCount > 0 {
                                        Label(localizationManager.text(it: "\(todayDeadlinesCount) scadenze", en: "\(todayDeadlinesCount) deadlines"), systemImage: "clock")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.orange)
                                    }
                                    if todayExamsCount > 0 {
                                        Label(localizationManager.text(it: "\(todayExamsCount) esami", en: "\(todayExamsCount) exams"), systemImage: "graduationcap")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.red)
                                    }
                                    if todayAssignmentsCount > 0 {
                                        Label(localizationManager.text(it: "\(todayAssignmentsCount) assignment", en: "\(todayAssignmentsCount) assignments"), systemImage: "doc.text")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.purple)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentMonth = Date()
                                selectedDate = Date()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "calendar")
                                Text(localizationManager.t(.today))
                            }
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.accentColor)
                        .help(localizationManager.text(it: "Visualizza oggi", en: "Show today"))
                    }
                }
                
                // Header Calendario Mese/Anno
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.t(.schoolCalendar))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        Text(formatMonthYear(currentMonth))
                            .font(UniFont.largeTitle())
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Barra Sincronizzazione Feed Corso
                UniCard(padding: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            ZStack {
                                Rectangle()
                                    .fill(themeManager.accentColor.opacity(0.12))
                                    .frame(width: 30, height: 30)
                                    .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                Image(systemName: "link.badge.plus")
                                    .font(.system(size: 13))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(localizationManager.t(.feedTitle))
                                    .font(UniFont.headline())
                                if let lastSync = dataManager.lastSyncDate {
                                    Text(localizationManager.t(.feedLastUpdate(Self.syncDateFormatter.string(from: lastSync))))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(localizationManager.t(.feedNone))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isShowingFeedConfig.toggle()
                                }
                            } label: {
                                Image(systemName: isShowingFeedConfig ? "chevron.up" : "gearshape")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.bordered)
                            .help("Configura feed")
                            
                            if dataManager.isSyncingCalendar {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Button {
                                    Task {
                                        await dataManager.syncCalendarFeed()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text(localizationManager.t(.syncButton))
                                    }
                                    .font(UniFont.caption())
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(themeManager.accentColor)
                                .disabled(dataManager.calendarFeedURL.isEmpty)
                            }
                            
                            Button {
                                dataManager.exportToAppleCalendar()
                            } label: {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.bordered)
                            .help(localizationManager.t(.syncExportApple))
                        }
                        
                        // Visualizzazione messaggi di stato sync
                        if let success = dataManager.syncSuccessMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 11))
                                Text(success)
                                    .font(UniFont.caption())
                                    .foregroundStyle(.green)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        } else if let err = dataManager.syncErrorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 11))
                                Text(err)
                                    .font(UniFont.caption())
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        
                        if isShowingFeedConfig {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizationManager.t(.pasteFeedURL))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    TextField("https://.../calendario.ics o webcal://...", text: $dataManager.calendarFeedURL)
                                        .textFieldStyle(.roundedBorder)
                                        .font(UniFont.caption())
                                    
                                    Button(localizationManager.t(.saveAndSync)) {
                                        dataManager.saveData()
                                        isShowingFeedConfig = false
                                        Task {
                                            await dataManager.syncCalendarFeed()
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                HStack {
                                    Text(localizationManager.t(.orUploadICS))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Button {
                                        selectAndImportICSFile()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.badge.plus")
                                            Text(localizationManager.t(.chooseICSFile))
                                        }
                                        .font(UniFont.caption())
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                }
                
                // Intestazione Giorni della Settimana (LUN, MAR...)
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Griglia dei Giorni del Mese (Ottimizzata a O(1))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(days) { item in
                        if let date = item.date {
                            let dayKey = calendar.startOfDay(for: date)
                            let summary = summaries[dayKey] ?? DayEventsSummary()
                            
                            DayCellView(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                eventsCount: summary.eventsCount,
                                hasExam: summary.hasExam,
                                hasDeadline: summary.hasDeadline,
                                hasPendingDeadline: summary.hasPendingDeadline,
                                hasAssignment: summary.hasAssignment,
                                hasPendingAssignment: summary.hasPendingAssignment
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(22)
            .frame(minWidth: 400)
            
            // Colonna Destra: Eventi del Giorno Selezionato & Gestione Scadenze
            VStack(alignment: .leading, spacing: 14) {
                // Header Agenda con pulsante Rapido "+ Nuova Scadenza"
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.t(.dayAgenda))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        Text(formatSelectedDay(selectedDate))
                            .font(UniFont.title())
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button {
                        isPresentingNewDeadline = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                            Text(localizationManager.currentLanguage == .italian ? "Nuova Scadenza" : "New Deadline")
                                .font(UniFont.caption())
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(.bordered)
                    .help("Crea una nuova scadenza per questo giorno")
                }
                .padding(.top, 22)
                .padding(.horizontal, 18)
                
                let dayEvents = selectedDaySummary.events
                let dayDeadlines = selectedDaySummary.deadlines
                let dayExams = selectedDaySummary.exams
                let dayAssignments = selectedDaySummary.assignments
                
                if dayEvents.isEmpty && dayDeadlines.isEmpty && dayExams.isEmpty && dayAssignments.isEmpty {
                    VStack {
                        Spacer()
                        UniEmptyStateView(
                            icon: "calendar",
                            title: localizationManager.t(.noEventsToday),
                            subtitle: localizationManager.t(.noEventsThisDay),
                            buttonTitle: localizationManager.currentLanguage == .italian ? "Aggiungi Scadenza" : "Add Deadline"
                        ) {
                            isPresentingNewDeadline = true
                        }
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            // 1. ESAMI DEL GIORNO
                            if !dayExams.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(localizationManager.currentLanguage == .italian ? "ESAMI DEL GIORNO" : "EXAMS")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .tracking(0.8)
                                    
                                    ForEach(dayExams) { exam in
                                        UniCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                Rectangle()
                                                    .fill(Color.red)
                                                    .frame(width: 3)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    HStack {
                                                        Text(exam.title)
                                                            .font(UniFont.headline())
                                                        Spacer()
                                                        UniBadge(localizationManager.text(it: "Esame", en: "Exam"), color: .red)
                                                    }
                                                    if !exam.room.isEmpty {
                                                        Label(exam.room, systemImage: "mappin")
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 2. SCADENZE DEL GIORNO (Aggiornate e Interattive)
                            if !dayDeadlines.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(localizationManager.currentLanguage == .italian ? "SCADENZE DEL GIORNO" : "DEADLINES")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .tracking(0.8)
                                        Spacer()
                                        Text("\(dayDeadlines.filter { !$0.isCompleted }.count) in sospeso")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    ForEach(dayDeadlines) { deadline in
                                        UniCard(padding: 12) {
                                            HStack(spacing: 10) {
                                                // Checkbox interattiva completamento rapido
                                                Button {
                                                    toggleDeadline(deadline)
                                                } label: {
                                                    Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                                                        .font(.system(size: 16))
                                                        .foregroundStyle(deadline.isCompleted ? .secondary : deadline.priority.color)
                                                }
                                                .buttonStyle(.plain)
                                                .help(deadline.isCompleted ? "Segna come da fare" : "Segna come completata")
                                                
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack {
                                                        Text(deadline.title)
                                                            .font(UniFont.headline())
                                                            .strikethrough(deadline.isCompleted)
                                                            .foregroundStyle(deadline.isCompleted ? .secondary : .primary)
                                                        Spacer()
                                                        UniBadge(deadline.priority.rawValue, color: deadline.priority.color)
                                                    }
                                                    
                                                    HStack(spacing: 8) {
                                                        if let courseId = deadline.courseId, let course = dataManager.courses.first(where: { $0.id == courseId }) {
                                                            Label(course.name, systemImage: "book.closed")
                                                                .font(UniFont.caption())
                                                                .foregroundStyle(.secondary)
                                                        }
                                                        
                                                        Label(Self.timeRangeFormatter.string(from: deadline.dueDate), systemImage: "clock")
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    if !deadline.notes.isEmpty {
                                                        Text(deadline.notes)
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                            .lineLimit(2)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 2.5 ASSIGNMENTS DEL GIORNO
                            if !dayAssignments.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(localizationManager.currentLanguage == .italian ? "ASSIGNMENT DEL GIORNO" : "ASSIGNMENTS")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .tracking(0.8)
                                        Spacer()
                                        let pending = dayAssignments.filter { !$0.isCompleted }.count
                                        if pending > 0 {
                                            Text(localizationManager.text(it: "\(pending) in sospeso", en: "\(pending) pending"))
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    ForEach(dayAssignments) { assignment in
                                        UniCard(padding: 12) {
                                            HStack(spacing: 10) {
                                                Button {
                                                    toggleAssignment(assignment)
                                                } label: {
                                                    Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                                        .font(.system(size: 16))
                                                        .foregroundStyle(assignment.isCompleted ? .secondary : Color.purple)
                                                }
                                                .buttonStyle(.plain)
                                                .help(localizationManager.text(it: assignment.isCompleted ? "Segna come da fare" : "Segna come completato", en: assignment.isCompleted ? "Mark as pending" : "Mark as completed"))
                                                
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack {
                                                        Text(assignment.title)
                                                            .font(UniFont.headline())
                                                            .strikethrough(assignment.isCompleted)
                                                            .foregroundStyle(assignment.isCompleted ? .secondary : .primary)
                                                        Spacer()
                                                        if assignment.weightPercent > 0 {
                                                            UniBadge("\(assignment.weightPercent)%", color: .purple)
                                                        }
                                                    }
                                                    
                                                    HStack(spacing: 8) {
                                                        if let course = dataManager.courses.first(where: { $0.id == assignment.courseId }) {
                                                            Label(course.name, systemImage: "book.closed")
                                                                .font(UniFont.caption())
                                                                .foregroundStyle(.secondary)
                                                        }
                                                        Label(Self.timeRangeFormatter.string(from: assignment.dueDate), systemImage: "clock")
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    if !assignment.details.isEmpty {
                                                        Text(assignment.details)
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                            .lineLimit(2)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 3. LEZIONI ED EVENTI DEL CORSO
                            if !dayEvents.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(localizationManager.currentLanguage == .italian ? "LEZIONI & APPUNTAMENTI" : "LECTURES & EVENTS")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .tracking(0.8)
                                    
                                    ForEach(dayEvents) { event in
                                        UniCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                Rectangle()
                                                    .fill(themeManager.accentColor)
                                                    .frame(width: 3)
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack {
                                                        Text(event.title)
                                                            .font(UniFont.headline())
                                                        Spacer()
                                                        UniBadge(event.category.rawValue, color: themeManager.accentColor)
                                                    }
                                                    
                                                    HStack(spacing: 10) {
                                                        Label(formatTimeRange(start: event.startDate, end: event.endDate), systemImage: "clock")
                                                        if !event.location.isEmpty {
                                                            Label(event.location, systemImage: "mappin")
                                                        }
                                                    }
                                                    .font(UniFont.caption())
                                                    .foregroundStyle(.secondary)
                                                    
                                                    if !event.details.isEmpty {
                                                        Text(event.details)
                                                            .font(UniFont.caption())
                                                            .foregroundStyle(.secondary)
                                                            .lineLimit(2)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)
                    }
                }
            }
            .frame(minWidth: 300, maxWidth: 420)
        }
        .sheet(isPresented: $isPresentingNewDeadline) {
            DeadlineEditorSheet(deadlineToEdit: nil, initialDate: selectedDate) { newDeadline in
                dataManager.deadlines.append(newDeadline)
                dataManager.saveData()
                
                NotificationManager.shared.notify(
                    title: "Scadenza creata",
                    message: "\(newDeadline.title) inserita nel calendario",
                    type: .success,
                    icon: "calendar.badge.clock"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
    }
    
    // MARK: - Actions & Helpers
    private func toggleDeadline(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                dataManager.deadlines[idx].isCompleted.toggle()
                let isNowCompleted = dataManager.deadlines[idx].isCompleted
                dataManager.saveData()
                
                NotificationManager.shared.notify(
                    title: isNowCompleted ? "Scadenza completata! 🎉" : "Scadenza riattivata",
                    message: deadline.title,
                    type: isNowCompleted ? .success : .info,
                    icon: isNowCompleted ? "checkmark.circle.fill" : "circle",
                    postToSystem: true
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
    }
    
    private func toggleAssignment(_ assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                dataManager.assignments[idx].isCompleted.toggle()
                let isNowCompleted = dataManager.assignments[idx].isCompleted
                dataManager.saveData()
                
                NotificationManager.shared.notify(
                    title: isNowCompleted
                        ? LocalizationManager.shared.text(it: "Assignment completato! 🎉", en: "Assignment completed! 🎉")
                        : LocalizationManager.shared.text(it: "Assignment riattivato", en: "Assignment reopened"),
                    message: assignment.title,
                    type: isNowCompleted ? .success : .info,
                    icon: isNowCompleted ? "checkmark.circle.fill" : "circle",
                    postToSystem: false
                )
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        if localizationManager.currentLanguage == .italian {
            return Self.monthYearFormatterIT.string(from: date).capitalized
        } else {
            return Self.monthYearFormatterEN.string(from: date).capitalized
        }
    }
    
    private func formatSelectedDay(_ date: Date) -> String {
        if localizationManager.currentLanguage == .italian {
            return Self.dayNumberFormatterIT.string(from: date).capitalized
        } else {
            return Self.dayNumberFormatterEN.string(from: date).capitalized
        }
    }
    
    private func todayDayOfWeekName() -> String {
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "EEE"
        return f.string(from: Date()).uppercased()
    }
    
    private func todayFullFormatted() -> String {
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: Date()).capitalized
    }

    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let s = Self.timeRangeFormatter.string(from: start)
        let e = Self.timeRangeFormatter.string(from: end)
        return "\(s) - \(e)"
    }
    
    private func generateDaysInMonth(for date: Date) -> [CalendarGridDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let startOfMonth = monthInterval.start
        
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingSpaces = (weekday + 5) % 7
        
        var days: [CalendarGridDay] = []
        var idCounter = 0
        
        for _ in 0..<leadingSpaces {
            days.append(CalendarGridDay(id: idCounter, date: nil))
            idCounter += 1
        }
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        for day in 1...range.count {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarGridDay(id: idCounter, date: dayDate))
                idCounter += 1
            }
        }
        
        return days
    }
    
    private func selectAndImportICSFile() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.init(filenameExtension: "ics") ?? .text]
        panel.prompt = "Importa Calendario"
        panel.message = "Seleziona il file .ics del tuo corso di studi"
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            dataManager.importICSFromFile(url: selectedURL)
        }
        #endif
    }
}

// MARK: - Day Cell (High Performance)
struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventsCount: Int
    let hasExam: Bool
    let hasDeadline: Bool
    let hasPendingDeadline: Bool
    let hasAssignment: Bool
    let hasPendingAssignment: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 3) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(UniFont.body())
                .fontWeight(isToday ? .bold : (isSelected ? .semibold : .regular))
                .foregroundStyle(isToday ? themeManager.accentColor : .primary)
            
            // Indicatori di eventi
            HStack(spacing: 3) {
                if hasExam {
                    Circle().fill(Color.red).frame(width: 5, height: 5)
                }
                if hasDeadline {
                    Circle()
                        .fill(hasPendingDeadline ? Color.orange : Color.secondary.opacity(0.5))
                        .frame(width: 5, height: 5)
                }
                if hasAssignment {
                    Circle()
                        .fill(hasPendingAssignment ? Color.purple : Color.secondary.opacity(0.5))
                        .frame(width: 5, height: 5)
                }
                if eventsCount > 0 {
                    Circle().fill(themeManager.accentColor).frame(width: 5, height: 5)
                }
            }
            .frame(height: 5)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(isSelected ? themeManager.accentColor.opacity(0.12) : (isToday ? Color.primary.opacity(0.04) : Color.clear))
        )
        .overlay(
            Rectangle()
                .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Calendar Grid Day
struct CalendarGridDay: Identifiable {
    let id: Int
    let date: Date?
}
