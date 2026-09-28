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
    var academicEventsCount: Int { events.filter { $0.isAcademic }.count }
    var nonAcademicEventsCount: Int { events.filter { !$0.isAcademic }.count }
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
    
    private enum CalendarSheetType: Identifiable {
        case deadline
        case exam
        case assignment
        case calendarManager
        
        var id: Int {
            switch self {
            case .deadline: return 1
            case .exam: return 2
            case .assignment: return 3
            case .calendarManager: return 4
            }
        }
    }
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var activeSheet: CalendarSheetType? = nil
    @State private var isShowingNewItemModal: Bool = false
    @State private var selectedScopeFilter: CalendarScopeFilter = .all
    @State private var specificSourceFilterId: UUID? = nil
    @State private var upcomingHorizonDays: Int = 7
    @State private var isShowingUpcoming: Bool = false
    
    private let calendar = Calendar.current
    
    private var daysOfWeek: [String] {
        if localizationManager.currentLanguage == .english {
            return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        } else {
            return ["LUN", "MAR", "MER", "GIO", "VEN", "SAB", "DOM"]
        }
    }
    
    // MARK: - Eventi Filtrati per Ambito (Tutti, Scolastici, Personali o per Singolo Calendario)
    private var filteredEvents: [CalendarEventItem] {
        let enabledSources = Set(dataManager.calendarSources.filter { $0.isEnabled }.map { $0.id })
        
        return dataManager.syncedEvents.filter { event in
            // Se l'evento proviene da un calendario disabilitato dall'utente, escludilo
            if let sId = event.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            
            // Se è attivo un filtro per singolo calendario specifico
            if let specId = specificSourceFilterId {
                return event.sourceId == specId
            }
            
            switch selectedScopeFilter {
            case .all:
                return true
            case .academicOnly:
                return event.isAcademic
            case .nonAcademicOnly:
                return !event.isAcademic
            case .source(let id):
                return event.sourceId == id
            }
        }
    }
    
    // MARK: - Pre-calculated Hash Map (Eliminates O(N*M) Date Calculations)
    private var daySummaries: [Date: DayEventsSummary] {
        var dict: [Date: DayEventsSummary] = [:]
        let cal = Calendar.current
        
        for event in filteredEvents {
            let key = cal.startOfDay(for: event.startDate)
            dict[key, default: DayEventsSummary()].events.append(event)
        }
        
        // Elementi accademici nativi (esami, scadenze, assignment): mostrati in 'Tutti' o 'Scolastici'
        let showUniAcademicItems: Bool = {
            if let specId = specificSourceFilterId {
                return dataManager.calendarSources.first(where: { $0.id == specId })?.isAcademic ?? false
            }
            switch selectedScopeFilter {
            case .all, .academicOnly:
                return true
            case .nonAcademicOnly:
                return false
            case .source(let id):
                return dataManager.calendarSources.first(where: { $0.id == id })?.isAcademic ?? false
            }
        }()
        
        if showUniAcademicItems {
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
    
    private static let shortDayFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE d MMM"
        return f
    }()
    
    private static let shortDayFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE, MMM d"
        return f
    }()
    
    private static let dayOfWeekFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE"
        return f
    }()
    
    private static let dayOfWeekFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE"
        return f
    }()
    
    private static let fullDayFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f
    }()
    
    private static let fullDayFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()
    
    // MARK: - Impegni di Oggi Calcolati (Lezioni, Esami, Scadenze, Assignment)
    private var todayCommitments: [CalendarCommitmentItem] {
        var items: [CalendarCommitmentItem] = []
        let cal = Calendar.current
        
        for ev in filteredEvents {
            if cal.isDateInToday(ev.startDate) {
                let type: CalendarCommitmentItem.CommitmentType = {
                    switch ev.category {
                    case .exam: return .exam
                    case .deadline: return .deadline
                    case .lecture: return .lecture
                    case .personal, .other: return ev.isAcademic ? .lecture : .other
                    }
                }()
                
                items.append(CalendarCommitmentItem(
                    id: "event-\(ev.id)-\(Int(ev.startDate.timeIntervalSince1970))",
                    title: ev.title,
                    date: ev.startDate,
                    endDate: ev.endDate,
                    isAllDay: ev.startDate == ev.endDate || (cal.component(.hour, from: ev.startDate) == 0 && cal.component(.minute, from: ev.startDate) == 0 && cal.component(.hour, from: ev.endDate) == 0),
                    type: type,
                    categoryName: ev.category.rawValue,
                    colorHex: ev.calendarColorHex,
                    isCompleted: false,
                    courseName: ev.details.isEmpty ? nil : ev.details
                ))
            }
        }
        
        let showUniItems: Bool = {
            if let specId = specificSourceFilterId {
                return dataManager.calendarSources.first(where: { $0.id == specId })?.isAcademic ?? false
            }
            switch selectedScopeFilter {
            case .all, .academicOnly: return true
            case .nonAcademicOnly: return false
            case .source(let id): return dataManager.calendarSources.first(where: { $0.id == id })?.isAcademic ?? false
            }
        }()
        
        if showUniItems {
            for dl in dataManager.deadlines where cal.isDateInToday(dl.dueDate) {
                let course = dataManager.courses.first(where: { $0.id == dl.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "deadline-\(dl.id)",
                    title: dl.title,
                    date: dl.dueDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .deadline,
                    categoryName: "Deadline",
                    colorHex: nil,
                    isCompleted: dl.isCompleted,
                    courseName: course
                ))
            }
            for ex in dataManager.exams where cal.isDateInToday(ex.examDate) {
                let course = dataManager.courses.first(where: { $0.id == ex.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "exam-\(ex.id)",
                    title: ex.title,
                    date: ex.examDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .exam,
                    categoryName: "Exam",
                    colorHex: nil,
                    isCompleted: ex.status == .passed,
                    courseName: course
                ))
            }
            for asg in dataManager.assignments where cal.isDateInToday(asg.dueDate) {
                let course = dataManager.courses.first(where: { $0.id == asg.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "asg-\(asg.id)",
                    title: asg.title,
                    date: asg.dueDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .assignment,
                    categoryName: "Assignment",
                    colorHex: nil,
                    isCompleted: asg.isCompleted,
                    courseName: course
                ))
            }
        }
        
        return items.sorted(by: { $0.date < $1.date })
    }
    
    // MARK: - Prossimi Impegni (Orizzonte Dinamico: 3, 7, 20 giorni)
    private func upcomingCommitments(forDays days: Int) -> [CalendarCommitmentItem] {
        guard days > 0 else { return [] }
        var items: [CalendarCommitmentItem] = []
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: today),
              let horizonEnd = cal.date(byAdding: .day, value: days + 1, to: today),
              horizonEnd > tomorrow else {
            return []
        }
        
        let range = tomorrow..<horizonEnd
        
        for ev in filteredEvents {
            if range.contains(ev.startDate) {
                let type: CalendarCommitmentItem.CommitmentType = {
                    switch ev.category {
                    case .exam: return .exam
                    case .deadline: return .deadline
                    case .lecture: return .lecture
                    case .personal, .other: return ev.isAcademic ? .lecture : .other
                    }
                }()
                
                items.append(CalendarCommitmentItem(
                    id: "up-ev-\(ev.id)-\(Int(ev.startDate.timeIntervalSince1970))",
                    title: ev.title,
                    date: ev.startDate,
                    endDate: ev.endDate,
                    isAllDay: ev.startDate == ev.endDate,
                    type: type,
                    categoryName: ev.category.rawValue,
                    colorHex: ev.calendarColorHex,
                    isCompleted: false,
                    courseName: ev.details.isEmpty ? nil : ev.details
                ))
            }
        }
        
        let showUniItems: Bool = {
            if let specId = specificSourceFilterId {
                return dataManager.calendarSources.first(where: { $0.id == specId })?.isAcademic ?? false
            }
            switch selectedScopeFilter {
            case .all, .academicOnly: return true
            case .nonAcademicOnly: return false
            case .source(let id): return dataManager.calendarSources.first(where: { $0.id == id })?.isAcademic ?? false
            }
        }()
        
        if showUniItems {
            for dl in dataManager.deadlines where range.contains(dl.dueDate) {
                let course = dataManager.courses.first(where: { $0.id == dl.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "up-dl-\(dl.id)",
                    title: dl.title,
                    date: dl.dueDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .deadline,
                    categoryName: "Deadline",
                    colorHex: nil,
                    isCompleted: dl.isCompleted,
                    courseName: course
                ))
            }
            for ex in dataManager.exams where range.contains(ex.examDate) {
                let course = dataManager.courses.first(where: { $0.id == ex.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "up-ex-\(ex.id)",
                    title: ex.title,
                    date: ex.examDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .exam,
                    categoryName: "Exam",
                    colorHex: nil,
                    isCompleted: ex.status == .passed,
                    courseName: course
                ))
            }
            for asg in dataManager.assignments where range.contains(asg.dueDate) {
                let course = dataManager.courses.first(where: { $0.id == asg.courseId })?.name
                items.append(CalendarCommitmentItem(
                    id: "up-asg-\(asg.id)",
                    title: asg.title,
                    date: asg.dueDate,
                    endDate: nil,
                    isAllDay: false,
                    type: .assignment,
                    categoryName: "Assignment",
                    colorHex: nil,
                    isCompleted: asg.isCompleted,
                    courseName: course
                ))
            }
        }
        
        return items.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        let summaries = daySummaries
        let selectedDayKey = calendar.startOfDay(for: selectedDate)
        let selectedDaySummary = summaries[selectedDayKey] ?? DayEventsSummary()
        let days = generateDaysInMonth(for: currentMonth)
        let todayItems = todayCommitments
        
        ZStack {
            HStack(alignment: .top, spacing: 0) {
                // Colonna Sinistra: Griglia Calendario & Barra Sincronizzazione
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                // Banner Prominente: Data Odierna, Impegni di Oggi & Prossimi Impegni (Tendina 3, 7, 20 giorni)
                UniCard(padding: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        // 1. Barra Data Odierna e Pulsante "Oggi"
                        HStack(alignment: .center, spacing: 14) {
                            // Riquadro data di oggi
                            VStack(spacing: 0) {
                                Text(todayDayOfWeekName().uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(themeManager.accentTextColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 3)
                                    .background(themeManager.accentColor)
                                
                                Text("\(calendar.component(.day, from: Date()))")
                                    .font(UniFont.display(24))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                    .frame(width: 52, height: 34)
                                    .background(Color.primary.opacity(0.04))
                            }
                            .frame(width: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(localizationManager.text(it: "OGGI", en: "TODAY"))
                                        .font(UniFont.caption())
                                        .fontWeight(.bold)
                                        .foregroundStyle(themeManager.accentColor)
                                        .tracking(1.0)
                                    
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    
                                    Text(todayFullFormatted())
                                        .font(UniFont.headline())
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                                
                                if todayItems.isEmpty {
                                    Text(localizationManager.text(it: "Nessun impegno in programma per oggi", en: "No commitments scheduled for today"))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(localizationManager.text(
                                        it: "\(todayItems.count) impegni previsti per la giornata",
                                        en: "\(todayItems.count) commitments scheduled for today"
                                    ))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    currentMonth = Date()
                                    selectedDate = Date()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11))
                                    Text(localizationManager.t(.today))
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.accentColor)
                            .help(localizationManager.text(it: "Visualizza oggi", en: "Show today"))
                        }
                        
                        // 2. Impegni di Oggi a Colpo d'Occhio (Cards Rettangolari in Griglia)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text(localizationManager.text(it: "IMPEGNI DI OGGI A COLPO D'OCCHIO", en: "TODAY'S COMMITMENTS AT A GLANCE"))
                                    .font(.system(size: 9.5, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                                
                                Text("\(todayItems.count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(todayItems.isEmpty ? Color.primary.opacity(0.06) : themeManager.accentColor.opacity(0.15))
                                    .foregroundStyle(todayItems.isEmpty ? Color.secondary : themeManager.accentColor)
                                    .clipShape(Capsule())
                            }
                            
                            if todayItems.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal")
                                        .font(.system(size: 12))
                                        .foregroundStyle(themeManager.accentColor)
                                    Text(localizationManager.text(it: "Giornata libera! Nessuna lezione, scadenza o esame oggi.", en: "Day off! No lectures, deadlines, or exams today."))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 3)
                            } else {
                                let todayGrid = LazyVGrid(
                                    columns: [GridItem(.adaptive(minimum: 140, maximum: 175), spacing: 10, alignment: .top)],
                                    alignment: .leading,
                                    spacing: 10
                                ) {
                                    ForEach(todayItems) { item in
                                        todayCommitmentCard(item)
                                    }
                                }
                                .padding(.vertical, 2)
                                
                                if todayItems.count > 4 {
                                    ScrollView(.vertical, showsIndicators: true) {
                                        todayGrid
                                    }
                                    .frame(maxHeight: 330)
                                } else {
                                    todayGrid
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 1)
                        
                        // 3. Prossimi Giorni (Cliccabile: espande e mostra gli altri sotto)
                        let upcomingItems = upcomingCommitments(forDays: upcomingHorizonDays)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.22)) {
                                        isShowingUpcoming.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: isShowingUpcoming ? "chevron.down" : "chevron.right")
                                            .font(.system(size: 9.5, weight: .bold))
                                            .foregroundStyle(themeManager.accentColor)
                                        
                                        Text(localizationManager.text(it: "PROSSIMI GIORNI", en: "UPCOMING DAYS"))
                                            .font(.system(size: 9.5, weight: .bold))
                                            .foregroundStyle(.secondary)
                                            .tracking(0.8)
                                        
                                        Text("\(upcomingItems.count)")
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(upcomingItems.isEmpty ? Color.primary.opacity(0.06) : themeManager.accentColor.opacity(0.15))
                                            .foregroundStyle(upcomingItems.isEmpty ? Color.secondary : themeManager.accentColor)
                                            .clipShape(Capsule())
                                        
                                        Text(localizationManager.text(
                                            it: isShowingUpcoming ? "(nascondi)" : "(mostra)",
                                            en: isShowingUpcoming ? "(hide)" : "(show)"
                                        ))
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary.opacity(0.8))
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(
                                    it: isShowingUpcoming ? "Clicca per nascondere i prossimi giorni" : "Clicca per mostrare i prossimi giorni",
                                    en: isShowingUpcoming ? "Click to hide upcoming days" : "Click to show upcoming days"
                                ))
                                
                                Spacer()
                                
                                // Tendina Selezione Orizzonte (3, 7, 20 Giorni) con Stile Raffinato
                                Menu {
                                    Button {
                                        upcomingHorizonDays = 3
                                    } label: {
                                        if upcomingHorizonDays == 3 {
                                            Label(localizationManager.text(it: "Prossimi 3 giorni", en: "Next 3 days"), systemImage: "checkmark")
                                        } else {
                                            Text(localizationManager.text(it: "Prossimi 3 giorni", en: "Next 3 days"))
                                        }
                                    }
                                    Button {
                                        upcomingHorizonDays = 7
                                    } label: {
                                        if upcomingHorizonDays == 7 {
                                            Label(localizationManager.text(it: "Prossimi 7 giorni", en: "Next 7 days"), systemImage: "checkmark")
                                        } else {
                                            Text(localizationManager.text(it: "Prossimi 7 giorni", en: "Next 7 days"))
                                        }
                                    }
                                    Button {
                                        upcomingHorizonDays = 20
                                    } label: {
                                        if upcomingHorizonDays == 20 {
                                            Label(localizationManager.text(it: "Prossimi 20 giorni", en: "Next 20 days"), systemImage: "checkmark")
                                        } else {
                                            Text(localizationManager.text(it: "Prossimi 20 giorni", en: "Next 20 days"))
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 10))
                                            .foregroundStyle(themeManager.accentColor)
                                        Text(localizationManager.text(it: "Prossimi \(upcomingHorizonDays) giorni", en: "Next \(upcomingHorizonDays) days"))
                                            .font(UniFont.caption())
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 9))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3.5)
                                    .background(Color.primary.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                                    )
                                }
                                .menuStyle(.borderlessButton)
                            }
                            
                            // Appaiono solo quando isShowingUpcoming è true
                            if isShowingUpcoming {
                                if upcomingItems.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                        Text(localizationManager.text(
                                            it: "Nessun impegno nei prossimi \(upcomingHorizonDays) giorni.",
                                            en: "No commitments scheduled in the next \(upcomingHorizonDays) days."
                                        ))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 3)
                                } else {
                                    let upcomingGrid = LazyVGrid(
                                        columns: [GridItem(.adaptive(minimum: 140, maximum: 175), spacing: 10, alignment: .top)],
                                        alignment: .leading,
                                        spacing: 10
                                    ) {
                                        ForEach(upcomingItems) { item in
                                            upcomingCommitmentCard(item)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                    
                                    if upcomingItems.count > 4 {
                                        ScrollView(.vertical, showsIndicators: true) {
                                            upcomingGrid
                                        }
                                        .frame(maxHeight: 330)
                                    } else {
                                        upcomingGrid
                                    }
                                }
                            }
                        }
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentMonth = Date()
                                selectedDate = Date()
                            }
                        } label: {
                            Text(localizationManager.t(.today))
                                .font(UniFont.caption())
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.bordered)
                        
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
                
                // Barra Sincronizzazione Multi-Calendario & Gestione
                UniCard(padding: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            ZStack {
                                Rectangle()
                                    .fill(themeManager.accentColor.opacity(0.12))
                                    .frame(width: 32, height: 32)
                                    .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 14))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 6) {
                                    Text(localizationManager.text(it: "Calendari Collegati", en: "Connected Calendars"))
                                        .font(UniFont.headline())
                                    
                                    let activeCount = dataManager.calendarSources.filter { $0.isEnabled }.count
                                    Text("\(activeCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1.5)
                                        .background(themeManager.accentColor.opacity(0.15))
                                        .foregroundStyle(themeManager.accentColor)
                                        .clipShape(Capsule())
                                }
                                
                                if let lastSync = dataManager.lastSyncDate {
                                    Text(localizationManager.t(.feedLastUpdate(Self.syncDateFormatter.string(from: lastSync))))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(localizationManager.text(it: "Nessun calendario sincronizzato", en: "No calendar synced"))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Pulsante Gestisci Calendari
                            Button {
                                activeSheet = .calendarManager
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 11))
                                    Text(localizationManager.text(it: "Gestisci", en: "Manage"))
                                        .font(UniFont.caption())
                                }
                            }
                            .buttonStyle(.bordered)
                            .help(localizationManager.text(it: "Aggiungi feed iCal o replica i calendari del tuo PC", en: "Add iCal feeds or replicate PC calendars"))
                            
                            // Sincronizza tutti
                            if dataManager.isSyncingCalendar {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Button {
                                    Task {
                                        await dataManager.syncAllCalendars()
                                    }
                                } label: {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 11))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(themeManager.accentColor)
                                .help(localizationManager.text(it: "Sincronizza tutti i calendari", en: "Sync all calendars"))
                            }
                            // NOTA: Terzo bottoncino rimossa su richiesta utente
                        }
                        
                        Divider()
                        
                        // Barra Filtri Rapidi (Tutti / Scolastici / Personali) + Menu Singolo Calendario (SENZA EMOJI)
                        HStack(spacing: 8) {
                            Picker("", selection: $selectedScopeFilter) {
                                Text(localizationManager.text(it: "Tutti", en: "All")).tag(CalendarScopeFilter.all)
                                Text(localizationManager.text(it: "Scolastici", en: "Academic")).tag(CalendarScopeFilter.academicOnly)
                                Text(localizationManager.text(it: "Personali", en: "Personal")).tag(CalendarScopeFilter.nonAcademicOnly)
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 240)
                            .onChange(of: selectedScopeFilter) { _, _ in
                                specificSourceFilterId = nil
                            }
                            
                            Spacer()
                            
                            // Dropdown filtro singolo calendario (SENZA EMOJI)
                            Menu {
                                Button {
                                    specificSourceFilterId = nil
                                } label: {
                                    if specificSourceFilterId == nil {
                                        Label(localizationManager.text(it: "Tutti i Calendari", en: "All Calendars"), systemImage: "checkmark")
                                    } else {
                                        Text(localizationManager.text(it: "Tutti i Calendari", en: "All Calendars"))
                                    }
                                }
                                
                                if !dataManager.calendarSources.isEmpty {
                                    Divider()
                                    ForEach(dataManager.calendarSources) { src in
                                        Button {
                                            specificSourceFilterId = src.id
                                        } label: {
                                            if specificSourceFilterId == src.id {
                                                Label("\(src.title) (\(src.eventCount))", systemImage: "checkmark")
                                            } else {
                                                Label("\(src.title) (\(src.eventCount))", systemImage: src.isAcademic ? "graduationcap" : "person")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: specificSourceFilterId == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                        .foregroundStyle(specificSourceFilterId != nil ? themeManager.accentColor : .secondary)
                                    
                                    if let specId = specificSourceFilterId, let src = dataManager.calendarSources.first(where: { $0.id == specId }) {
                                        Text(src.title)
                                            .font(UniFont.caption())
                                            .lineLimit(1)
                                    } else {
                                        Text(localizationManager.text(it: "Filtra per calendario", en: "Filter calendar"))
                                            .font(UniFont.caption())
                                    }
                                }
                            }
                            .menuStyle(.borderlessButton)
                            .fixedSize()
                        }
                        
                        // Badge indicatore se è attivo un filtro calendario specifico
                        if let specId = specificSourceFilterId, let src = dataManager.calendarSources.first(where: { $0.id == specId }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: src.colorHex) ?? themeManager.accentColor)
                                    .frame(width: 8, height: 8)
                                
                                Text(localizationManager.text(it: "Filtro attivo:", en: "Active filter:") + " \(src.title)")
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                
                                Button {
                                    specificSourceFilterId = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                            }
                            .padding(.top, 2)
                        }
                        
                        // Messaggi di stato sync
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
                            .padding(.vertical, 1)
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
                            .padding(.vertical, 1)
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
                
                // Griglia dei Giorni del Mese (Ottimizzata a O(1), Clic Istantaneo & Hover)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(days) { item in
                        if let date = item.date {
                            let dayKey = calendar.startOfDay(for: date)
                            let summary = summaries[dayKey] ?? DayEventsSummary()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedDate = date
                                }
                            } label: {
                                DayCellView(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    eventsCount: summary.eventsCount,
                                    academicEventsCount: summary.academicEventsCount,
                                    nonAcademicEventsCount: summary.nonAcademicEventsCount,
                                    hasExam: summary.hasExam,
                                    hasDeadline: summary.hasDeadline,
                                    hasPendingDeadline: summary.hasPendingDeadline,
                                    hasAssignment: summary.hasAssignment,
                                    hasPendingAssignment: summary.hasPendingAssignment,
                                    accentColor: themeManager.accentColor
                                )
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            .help(localizationManager.text(it: "Clicca per visualizzare questo giorno", en: "Click to view this day"))
                        } else {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            Divider()
            
            // Colonna Destra: Eventi del Giorno Selezionato & Gestione Scadenze
            VStack(alignment: .leading, spacing: 14) {
                // Header Agenda con Navigazione Rapida Giorni e "+ Nuova Scadenza"
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
                    
                    // Frecce navigazione rapida giorno precedente / successivo
                    HStack(spacing: 4) {
                        Button {
                            if let prev = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedDate = prev
                                    currentMonth = prev
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .buttonStyle(.bordered)
                        .help(localizationManager.text(it: "Giorno precedente", en: "Previous day"))
                        
                        Button {
                            if let next = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedDate = next
                                    currentMonth = next
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .buttonStyle(.bordered)
                        .help(localizationManager.text(it: "Giorno successivo", en: "Next day"))
                    }
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
                            activeSheet = .deadline
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
                                                        
                                                        if let link = deadline.linkURL, !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                            Button {
                                                                AppSystemHelper.openWebURL(urlString: link)
                                                            } label: {
                                                                HStack(spacing: 3) {
                                                                    Image(systemName: "arrow.up.forward.square")
                                                                    Text("Link")
                                                                }
                                                                .font(UniFont.caption())
                                                                .foregroundStyle(themeManager.accentColor)
                                                            }
                                                            .buttonStyle(.plain)
                                                            .help(link)
                                                        }
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
                                                        
                                                        if let link = assignment.linkURL, !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                            Button {
                                                                AppSystemHelper.openWebURL(urlString: link)
                                                            } label: {
                                                                HStack(spacing: 3) {
                                                                    Image(systemName: "arrow.up.forward.square")
                                                                    Text("Link")
                                                                }
                                                                .font(UniFont.caption())
                                                                .foregroundStyle(themeManager.accentColor)
                                                            }
                                                            .buttonStyle(.plain)
                                                            .help(link)
                                                        }
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
                            
                            // 3. LEZIONI ED EVENTI ACCADEMICI / UNIVERSITARI
                            let academicEvents = dayEvents.filter { $0.isAcademic }
                            if !academicEvents.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(localizationManager.text(it: "LEZIONI & APPUNTAMENTI SCOLASTICI", en: "LECTURES & ACADEMIC EVENTS"))
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .tracking(0.8)
                                        Spacer()
                                        Text("\(academicEvents.count)")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    ForEach(academicEvents) { event in
                                        let calColor = Color(hex: event.calendarColorHex ?? "") ?? themeManager.accentColor
                                        UniCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                Rectangle()
                                                    .fill(calColor)
                                                    .frame(width: 3)
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack {
                                                        Text(event.title)
                                                            .font(UniFont.headline())
                                                        Spacer()
                                                        if let calTitle = event.calendarTitle, !calTitle.isEmpty {
                                                            UniBadge(calTitle, color: calColor)
                                                        } else {
                                                            UniBadge(event.category.rawValue, color: calColor)
                                                        }
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
                            
                            // 4. EVENTI PERSONALI & EXTRA-SCOLASTICI (MAC / ALTRI CALENDARI)
                            let nonAcademicEvents = dayEvents.filter { !$0.isAcademic }
                            if !nonAcademicEvents.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(localizationManager.text(it: "IMPEGNI PERSONALI & EXTRA-SCOLASTICI", en: "PERSONAL & NON-ACADEMIC EVENTS"))
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .tracking(0.8)
                                        Spacer()
                                        Text("\(nonAcademicEvents.count)")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    ForEach(nonAcademicEvents) { event in
                                        let calColor = Color(hex: event.calendarColorHex ?? "") ?? Color.purple
                                        UniCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                Rectangle()
                                                    .fill(calColor)
                                                    .frame(width: 3)
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack {
                                                        Text(event.title)
                                                            .font(UniFont.headline())
                                                        Spacer()
                                                        HStack(spacing: 4) {
                                                            Image(systemName: "person.fill")
                                                                .font(.system(size: 9))
                                                            Text(event.calendarTitle ?? localizationManager.text(it: "Personale", en: "Personal"))
                                                        }
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(calColor.opacity(0.15))
                                                        .foregroundStyle(calColor)
                                                        .clipShape(Capsule())
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
                .frame(width: 350)
                .frame(maxHeight: .infinity, alignment: .topLeading)
            }
            
            // Overview New Item Modal Overlay (Triggered by + in Calendar)
            if isShowingNewItemModal {
                OverviewNewItemModalView(
                    isPresented: $isShowingNewItemModal,
                    onSelectAssignment: { activeSheet = .assignment },
                    onSelectDeadline: { activeSheet = .deadline },
                    onSelectExam: { activeSheet = .exam }
                )
                .transition(.opacity)
                .zIndex(1001)
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .deadline:
                DeadlineEditorSheet(deadlineToEdit: nil, initialDate: selectedDate) { newDeadline in
                    dataManager.deadlines.append(newDeadline)
                    dataManager.saveData()
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Scadenza creata", en: "Deadline created"),
                        message: localizationManager.text(it: "\(newDeadline.title) inserita nel calendario", en: "\(newDeadline.title) added to calendar"),
                        type: .success,
                        icon: "calendar.badge.clock"
                    )
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
                .environmentObject(dataManager)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                
            case .exam:
                ExamEditorSheet(examToEdit: nil) { newExam in
                    dataManager.exams.append(newExam)
                    dataManager.saveData()
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Esame creato", en: "Exam created"),
                        message: localizationManager.text(it: "\(newExam.title) inserito nel calendario", en: "\(newExam.title) added to calendar"),
                        type: .success,
                        icon: "graduationcap"
                    )
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
                .environmentObject(dataManager)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                
            case .assignment:
                AssignmentEditorSheet(assignmentToEdit: nil) { newAssignment in
                    dataManager.assignments.append(newAssignment)
                    dataManager.saveData()
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Assignment creato", en: "Assignment created"),
                        message: localizationManager.text(it: "\(newAssignment.title) inserito nel calendario", en: "\(newAssignment.title) added to calendar"),
                        type: .success,
                        icon: "doc.text.fill"
                    )
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
                .environmentObject(dataManager)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                
            case .calendarManager:
                CalendarManagerModalView()
                    .environmentObject(dataManager)
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
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
        let f = localizationManager.currentLanguage == .italian ? Self.dayOfWeekFormatterIT : Self.dayOfWeekFormatterEN
        return f.string(from: Date()).uppercased()
    }
    
    private func todayFullFormatted() -> String {
        let f = localizationManager.currentLanguage == .italian ? Self.fullDayFormatterIT : Self.fullDayFormatterEN
        return f.string(from: Date()).capitalized
    }
    
    @ViewBuilder
    private func todayCommitmentCard(_ item: CalendarCommitmentItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Icona e Tipo
            HStack(alignment: .center) {
                Image(systemName: item.type.icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(item.type.color(theme: themeManager))
                    .frame(width: 24, height: 24)
                    .background(item.type.color(theme: themeManager).opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Spacer(minLength: 4)
                
                Text(item.type.localizedName(using: localizationManager))
                    .font(.system(size: 8.5, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2.5)
                    .background(item.type.color(theme: themeManager).opacity(0.12))
                    .foregroundStyle(item.type.color(theme: themeManager))
                    .clipShape(Capsule())
            }
            
            Spacer(minLength: 6)
            
            // Titolo in evidenza
            Text(item.title)
                .font(UniFont.headline())
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Materia / Dettagli
            if let course = item.courseName, !course.isEmpty {
                Text(course)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            
            Spacer(minLength: 8)
            
            Divider()
                .opacity(0.4)
                .padding(.bottom, 6)
            
            // Orario sotto al titolo
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 9.5))
                    .foregroundStyle(themeManager.accentColor)
                
                Text(formatCommitmentTime(item))
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary.opacity(0.9))
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
        }
        .padding(10)
        .frame(minWidth: 135, maxWidth: 165, minHeight: 150, maxHeight: 160, alignment: .topLeading)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(item.type.color(theme: themeManager).opacity(0.25), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func upcomingCommitmentCard(_ item: CalendarCommitmentItem) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = item.date
                currentMonth = item.date
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header: Data in evidenza + Badge tipo
                HStack(alignment: .center) {
                    Text(formatShortDay(item.date))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(themeManager.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Spacer(minLength: 4)
                    
                    Text(item.type.localizedName(using: localizationManager))
                        .font(.system(size: 8.5, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(item.type.color(theme: themeManager).opacity(0.12))
                        .foregroundStyle(item.type.color(theme: themeManager))
                        .clipShape(Capsule())
                }
                
                Spacer(minLength: 6)
                
                // Titolo in evidenza
                Text(item.title)
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let course = item.courseName, !course.isEmpty {
                    Text(course)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
                Spacer(minLength: 8)
                
                Divider()
                    .opacity(0.4)
                    .padding(.bottom, 6)
                
                // Orario sotto + Icona Salto
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9.5))
                        .foregroundStyle(.secondary)
                    
                    Text(formatCommitmentTime(item))
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary.opacity(0.9))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }
            }
            .padding(10)
            .frame(minWidth: 135, maxWidth: 165, minHeight: 150, maxHeight: 160, alignment: .topLeading)
            .background(Color.primary.opacity(0.025))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(localizationManager.text(it: "Seleziona questa data nel calendario", en: "Select this date in the calendar"))
    }
    
    private func formatShortDay(_ date: Date) -> String {
        if localizationManager.currentLanguage == .italian {
            return Self.shortDayFormatterIT.string(from: date).capitalized
        } else {
            return Self.shortDayFormatterEN.string(from: date)
        }
    }
    
    private func formatCommitmentTime(_ item: CalendarCommitmentItem) -> String {
        if item.isAllDay {
            return localizationManager.text(it: "Tutto il giorno", en: "All day")
        }
        let cal = Calendar.current
        let hour = cal.component(.hour, from: item.date)
        let min = cal.component(.minute, from: item.date)
        if hour == 0 && min == 0 && item.endDate == nil {
            return localizationManager.text(it: "Tutto il giorno", en: "All day")
        }
        if let end = item.endDate, end > item.date {
            return "\(Self.timeRangeFormatter.string(from: item.date)) - \(Self.timeRangeFormatter.string(from: end))"
        }
        return Self.timeRangeFormatter.string(from: item.date)
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
        
        guard let range = calendar.range(of: .day, in: .month, for: date), range.count > 0 else {
            return days
        }
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

// MARK: - Day Cell (High Performance, Instant Single-Click & Hover)
struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventsCount: Int
    let academicEventsCount: Int
    let nonAcademicEventsCount: Int
    let hasExam: Bool
    let hasDeadline: Bool
    let hasPendingDeadline: Bool
    let hasAssignment: Bool
    let hasPendingAssignment: Bool
    let accentColor: Color
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(spacing: 3) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(UniFont.body())
                .fontWeight(isToday ? .bold : (isSelected ? .semibold : .regular))
                .foregroundStyle(isToday ? accentColor : .primary)
            
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
                if academicEventsCount > 0 {
                    Circle().fill(accentColor).frame(width: 5, height: 5)
                }
                if nonAcademicEventsCount > 0 {
                    Circle().fill(Color.purple).frame(width: 5, height: 5)
                }
            }
            .frame(height: 5)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(isSelected ? accentColor.opacity(0.14) : (isHovered ? Color.primary.opacity(0.06) : (isToday ? Color.primary.opacity(0.04) : Color.primary.opacity(0.001))))
        )
        .overlay(
            Rectangle()
                .stroke(isSelected ? accentColor : (isHovered ? accentColor.opacity(0.35) : Color.clear), lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Calendar Grid Day
struct CalendarGridDay: Identifiable {
    let id: Int
    let date: Date?
}
