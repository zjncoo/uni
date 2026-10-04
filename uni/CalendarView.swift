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

// MARK: - Day Events Summary
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
    var totalItemsCount: Int { eventsCount + deadlines.count + exams.count + assignments.count }
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
    
    var selectedTab: Binding<String>? = nil
    
    public init(selectedTab: Binding<String>? = nil) {
        self.selectedTab = selectedTab
    }
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var expandedDate: Date? = Date()
    @State private var lastTrackedToday: Date = Date()
    @State private var activeSheet: CalendarSheetType? = nil
    @State private var selectedScopeFilter: CalendarScopeFilter = .all
    @State private var specificSourceFilterId: UUID? = nil
    @State private var miniCalendarSearchText: String = ""
    @State private var isShowingSearchField: Bool = false
    @State private var isFiltersDropdownExpanded: Bool = false
    
    private let calendar = Calendar.current
    
    private func openDeadline(_ dl: Deadline) {
        dataManager.navigateTo(tab: "deadlines", deadlineId: dl.id, expand: true)
        selectedTab?.wrappedValue = "deadlines"
    }
    
    private func openAssignment(_ asg: Assignment) {
        dataManager.navigateTo(tab: "assignments", assignmentId: asg.id, expand: true)
        selectedTab?.wrappedValue = "assignments"
    }
    
    @Environment(\.colorScheme) private var systemColorScheme
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    private var daysOfWeekMini: [String] {
        if localizationManager.currentLanguage == .english {
            return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        } else {
            return ["Do", "Lu", "Ma", "Me", "Gi", "Ve", "Sa"]
        }
    }
    
    // MARK: - Eventi Filtrati per Ambito
    private var filteredEvents: [CalendarEventItem] {
        let enabledSources = Set(dataManager.calendarSources.filter { $0.isEnabled }.map { $0.id })
        
        return dataManager.syncedEvents.filter { event in
            if let sId = event.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            if let specId = specificSourceFilterId {
                return event.sourceId == specId
            }
            switch selectedScopeFilter {
            case .all: return true
            case .academicOnly: return event.isAcademic
            case .nonAcademicOnly: return !event.isAcademic
            case .source(let id): return event.sourceId == id
            }
        }
    }
    
    // MARK: - Pre-calculated Hash Map
    private var daySummaries: [Date: DayEventsSummary] {
        var dict: [Date: DayEventsSummary] = [:]
        let cal = Calendar.current
        
        for event in filteredEvents {
            let key = cal.startOfDay(for: event.startDate)
            dict[key, default: DayEventsSummary()].events.append(event)
        }
        
        let showUniAcademicItems: Bool = {
            if let specId = specificSourceFilterId {
                return dataManager.calendarSources.first(where: { $0.id == specId })?.isAcademic ?? false
            }
            switch selectedScopeFilter {
            case .all, .academicOnly: return true
            case .nonAcademicOnly: return false
            case .source(let id): return dataManager.calendarSources.first(where: { $0.id == id })?.isAcademic ?? false
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
    
    // MARK: - Cached Formatters
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
    
    private static let editorialHeaderFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE — d MMMM"
        return f
    }()
    
    private static let editorialHeaderFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE — d MMMM"
        return f
    }()
    
    private static let weekdayNameFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE"
        return f
    }()
    
    private static let weekdayNameFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE"
        return f
    }()
    
    private static let yearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f
    }()
    
    private static let timeOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "HH:mm"
        return f
    }()
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { scrollProxy in
            HStack(spacing: 0) {
                // LEFT SIDEBAR (Photo 2 reference): Mini calendar, Filters, Events & Tasks
                leftMiniCalendarSidebar(scrollProxy: scrollProxy)
                    .frame(width: 270)
                    .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.14) : Color(red: 0.96, green: 0.96, blue: 0.94))
                    .overlay(
                        Rectangle()
                            .fill(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08))
                            .frame(width: 1),
                        alignment: .trailing
                    )
                
                // MAIN SCROLLABLE DAYS AREA (Photo 1 reference + Photo 3 expanded view)
                VStack(spacing: 0) {
                    // Minimalist Top Bar: "Wed — 27 March" and "2026"
                    editorialTopBar(scrollProxy: scrollProxy)
                    
                    Divider().opacity(isDarkMode ? 0.2 : 0.4)
                    
                    // Main Scrollable List of Days
                    scrollableDaysList(scrollProxy: scrollProxy)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.09) : Color(red: 0.98, green: 0.98, blue: 0.98))
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .deadline:
                DeadlineEditorSheet(deadlineToEdit: nil, initialDate: selectedDate) { newDeadline in
                    dataManager.deadlines.append(newDeadline)
                    dataManager.saveData()
                    
                    let courseName = dataManager.courses.first(where: { $0.id == newDeadline.courseId })?.name
                    Task { await AppleCalendarManager.shared.sync(deadline: newDeadline, courseName: courseName) }
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Scadenza creata", en: "Deadline created"),
                        message: newDeadline.title,
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
                    
                    let courseName = dataManager.courses.first(where: { $0.id == newExam.courseId })?.name
                    Task { await AppleCalendarManager.shared.sync(exam: newExam, courseName: courseName) }
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Esame programmato", en: "Exam scheduled"),
                        message: newExam.title,
                        type: .info,
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
                    
                    let courseName = dataManager.courses.first(where: { $0.id == newAssignment.courseId })?.name
                    Task { await AppleCalendarManager.shared.sync(assignment: newAssignment, courseName: courseName) }
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Compito registrato", en: "Assignment recorded"),
                        message: newAssignment.title,
                        type: .success,
                        icon: "doc.text.fill"
                    )
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
        .onAppear {
            let now = dataManager.currentDate
            dataManager.refreshCurrentDate()
            if calendar.isDate(selectedDate, inSameDayAs: lastTrackedToday) {
                selectedDate = now
                currentMonth = now
                expandedDate = now
            }
            lastTrackedToday = now
        }
    }
    
    // MARK: - Minimalist Top Bar (Photo 1 reference)
    private func editorialTopBar(scrollProxy: ScrollViewProxy) -> some View {
        HStack(alignment: .center) {
            // Left: "Wed — 27 March"
            HStack(spacing: 8) {
                Text(formatEditorialDate(selectedDate))
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        let now = Date()
                        selectedDate = now
                        currentMonth = now
                        expandedDate = now
                        scrollProxy.scrollTo(dayScrollId(for: now), anchor: .center)
                    }
                } label: {
                    Text(localizationManager.t(.today).uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(themeManager.accentTextColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(themeManager.accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Torna ad oggi", en: "Go to today"))
            }
            
            Spacer()
            
            // Design icons & Year (Photo 1 reference: "2019" / "2026")
            HStack(spacing: 12) {
                // Quick add button
                Menu {
                    Button {
                        activeSheet = .assignment
                    } label: {
                        Label(localizationManager.t(.navAssignments), systemImage: "doc.text")
                    }
                    Button {
                        activeSheet = .exam
                    } label: {
                        Label(localizationManager.t(.navExams), systemImage: "graduationcap")
                    }
                    Button {
                        activeSheet = .deadline
                    } label: {
                        Label(localizationManager.t(.navDeadlines), systemImage: "clock")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                        .clipShape(Circle())
                }
                .menuStyle(.borderlessButton)
                .help(localizationManager.text(it: "Aggiungi evento", en: "Add event"))
                
                Text(Self.yearFormatter.string(from: selectedDate))
                    .font(UniFont.title())
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Left Mini Calendar Sidebar (Photo 2 reference)
    private func leftMiniCalendarSidebar(scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Header: "Calendar" + Search & Filter icons
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(themeManager.accentColor)
                        Text(localizationManager.text(it: "Calendario", en: "Calendar"))
                            .font(UniFont.headline())
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isShowingSearchField.toggle()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        activeSheet = .calendarManager
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Gestisci Calendari Collegati", en: "Manage Connected Calendars"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                if isShowingSearchField {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.text(it: "Filtra per testo...", en: "Filter text..."), text: $miniCalendarSearchText)
                            .textFieldStyle(.plain)
                            .font(UniFont.caption())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, 16)
                }
                
                // Mini Calendar Month Navigation & Grid
                miniMonthGrid(scrollProxy: scrollProxy)
                    .padding(.horizontal, 16)
                
                Divider()
                    .opacity(isDarkMode ? 0.2 : 0.4)
                    .padding(.horizontal, 14)
                
                // Filters with design icons
                filtersSection
                    .padding(.horizontal, 16)
                
                Divider()
                    .opacity(isDarkMode ? 0.2 : 0.4)
                    .padding(.horizontal, 14)
                
                // Quick Events List (Photo 2 style: "Events +")
                quickEventsSection
                    .padding(.horizontal, 16)
                
                // Quick Tasks List (Photo 2 style: "Tasks +")
                quickTasksSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Mini Month Calendar Grid
    private func miniMonthGrid(scrollProxy: ScrollViewProxy) -> some View {
        let summaries = daySummaries
        let days = generateDaysInMonth(for: currentMonth)
        
        return VStack(alignment: .leading, spacing: 10) {
            // Month Header with < > buttons
            HStack {
                Text(formatMonthYear(currentMonth))
                    .font(UniFont.body())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Weekday Initials (Su Mo Tu We Th Fr Sa)
            HStack(spacing: 0) {
                ForEach(daysOfWeekMini, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day Numbers Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) {
                ForEach(days) { item in
                    if let date = item.date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let dayKey = calendar.startOfDay(for: date)
                        let summary = summaries[dayKey] ?? DayEventsSummary()
                        let hasAnyEvents = summary.totalItemsCount > 0
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedDate = date
                                expandedDate = date
                                scrollProxy.scrollTo(dayScrollId(for: date), anchor: .top)
                            }
                        } label: {
                            VStack(spacing: 2) {
                                ZStack {
                                    if isSelected || isToday {
                                        Circle()
                                            .fill(isSelected ? Color.red : themeManager.accentColor.opacity(0.18))
                                            .frame(width: 24, height: 24)
                                    }
                                    
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 11, weight: isSelected || isToday ? .bold : .regular))
                                        .foregroundStyle(isSelected ? Color.white : (isToday ? themeManager.accentColor : Color.primary))
                                }
                                
                                // Event indicator dots per typology (All categories present on this day)
                                HStack(spacing: 2) {
                                    if summary.hasExam {
                                        Circle().fill(Color.red).frame(width: 3.5, height: 3.5)
                                    }
                                    if summary.hasDeadline {
                                        Circle().fill(Color.orange).frame(width: 3.5, height: 3.5)
                                    }
                                    if summary.hasAssignment {
                                        Circle().fill(Color.purple).frame(width: 3.5, height: 3.5)
                                    }
                                    if summary.academicEventsCount > 0 {
                                        Circle().fill(Color.blue).frame(width: 3.5, height: 3.5)
                                    }
                                    if summary.nonAcademicEventsCount > 0 {
                                        Circle().fill(Color.green).frame(width: 3.5, height: 3.5)
                                    }
                                    if !hasAnyEvents {
                                        Color.clear.frame(width: 3.5, height: 3.5)
                                    }
                                }
                                .frame(height: 4)
                            }
                            .frame(height: 32)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(12)
        .background(isDarkMode ? Color.white.opacity(0.03) : Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - Filters Section with Dropdown Menu
    private var currentFilterTitle: String {
        if let sid = specificSourceFilterId, let src = dataManager.calendarSources.first(where: { $0.id == sid }) {
            return src.title
        }
        switch selectedScopeFilter {
        case .academicOnly:
            return localizationManager.text(it: "Solo Scolastici", en: "Academic Only")
        case .nonAcademicOnly:
            return localizationManager.text(it: "Solo Personali", en: "Personal Only")
        case .source(let id):
            return dataManager.calendarSources.first(where: { $0.id == id })?.title ?? localizationManager.text(it: "Calendario", en: "Calendar")
        case .all:
            return localizationManager.text(it: "Tutti gli impegni", en: "All commitments")
        }
    }
    
    private var currentFilterIcon: String {
        if specificSourceFilterId != nil {
            return "circle.fill"
        }
        switch selectedScopeFilter {
        case .academicOnly:
            return "graduationcap.fill"
        case .nonAcademicOnly:
            return "person.fill"
        case .source:
            return "circle.fill"
        case .all:
            return "line.3.horizontal.decrease.circle"
        }
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localizationManager.text(it: "FILTRI CALENDARIO", en: "CALENDAR FILTERS").uppercased())
                .font(UniFont.sectionLabel())
                .foregroundStyle(.secondary)
                .tracking(1.0)
            
            // Dropdown trigger button
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                    isFiltersDropdownExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: currentFilterIcon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Text(currentFilterTitle)
                        .font(UniFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: isFiltersDropdownExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Expanded Dropdown List
            if isFiltersDropdownExpanded {
                VStack(spacing: 3) {
                    filterRow(
                        icon: "line.3.horizontal",
                        title: localizationManager.text(it: "Tutti gli impegni", en: "All commitments"),
                        isSelected: selectedScopeFilter == .all && specificSourceFilterId == nil
                    ) {
                        selectedScopeFilter = .all
                        specificSourceFilterId = nil
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isFiltersDropdownExpanded = false
                        }
                    }
                    
                    filterRow(
                        icon: "graduationcap.fill",
                        title: localizationManager.text(it: "Solo Scolastici", en: "Academic Only"),
                        isSelected: selectedScopeFilter == .academicOnly
                    ) {
                        selectedScopeFilter = .academicOnly
                        specificSourceFilterId = nil
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isFiltersDropdownExpanded = false
                        }
                    }
                    
                    filterRow(
                        icon: "person.fill",
                        title: localizationManager.text(it: "Solo Personali", en: "Personal Only"),
                        isSelected: selectedScopeFilter == .nonAcademicOnly
                    ) {
                        selectedScopeFilter = .nonAcademicOnly
                        specificSourceFilterId = nil
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isFiltersDropdownExpanded = false
                        }
                    }
                    
                    ForEach(dataManager.calendarSources) { src in
                        filterRow(
                            icon: "circle.fill",
                            iconColor: Color(hex: src.colorHex) ?? themeManager.accentColor,
                            title: src.title,
                            count: src.eventCount,
                            isSelected: specificSourceFilterId == src.id
                        ) {
                            if specificSourceFilterId == src.id {
                                specificSourceFilterId = nil
                            } else {
                                specificSourceFilterId = src.id
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isFiltersDropdownExpanded = false
                            }
                        }
                    }
                }
                .padding(6)
                .background(isDarkMode ? Color(red: 0.14, green: 0.14, blue: 0.16) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: Color.black.opacity(isDarkMode ? 0.35 : 0.08), radius: 8, x: 0, y: 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func filterRow(icon: String, iconColor: Color? = nil, title: String, count: Int? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(iconColor ?? (isSelected ? themeManager.accentColor : .secondary))
                    .frame(width: 16)
                
                Text(title)
                    .font(UniFont.caption())
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                
                Spacer()
                
                if let c = count, c > 0 {
                    Text("\(c)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                
                if isSelected {
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(isSelected ? themeManager.accentColor.opacity(0.10) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Quick Events Section (Photo 2 style: "Events +")
    private var quickEventsSection: some View {
        let dayEvents = daySummaries[calendar.startOfDay(for: selectedDate)]?.events ?? []
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localizationManager.text(it: "Eventi del Giorno", en: "Events"))
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    activeSheet = .exam
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Aggiungi evento o esame", en: "Add event or exam"))
            }
            
            if dayEvents.isEmpty {
                Text(localizationManager.text(it: "Nessun evento registrato", en: "No events recorded"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 2)
            } else {
                VStack(spacing: 6) {
                    ForEach(dayEvents.prefix(4)) { ev in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: ev.calendarColorHex ?? "#007AFF") ?? themeManager.accentColor)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(ev.title)
                                    .font(UniFont.caption())
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .foregroundStyle(.primary)
                                
                                Text(ev.isAllDay ? localizationManager.text(it: "Tutto il giorno", en: "All day") : localizationManager.formatTime(ev.startDate))
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.03) : Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Tasks Section (Photo 2 style: "Tasks +")
    private var quickTasksSection: some View {
        let dayDeadlines = daySummaries[calendar.startOfDay(for: selectedDate)]?.deadlines ?? []
        let dayAssignments = daySummaries[calendar.startOfDay(for: selectedDate)]?.assignments ?? []
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localizationManager.text(it: "Compiti & Attività", en: "Tasks"))
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    activeSheet = .deadline
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Aggiungi scadenza o compito", en: "Add deadline or task"))
            }
            
            if dayDeadlines.isEmpty && dayAssignments.isEmpty {
                Text(localizationManager.text(it: "Nessuna attività in sospeso", en: "No tasks pending"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 2)
            } else {
                VStack(spacing: 6) {
                    ForEach(dayDeadlines) { dl in
                        HStack(spacing: 8) {
                            Button {
                                toggleDeadline(dl)
                            } label: {
                                Image(systemName: dl.isCompleted ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 13))
                                    .foregroundStyle(dl.isCompleted ? Color.secondary : dl.priority.color)
                            }
                            .buttonStyle(.plain)
                            
                            Text(dl.title)
                                .font(UniFont.caption())
                                .strikethrough(dl.isCompleted)
                                .foregroundStyle(dl.isCompleted ? .secondary : .primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.03) : Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            openDeadline(dl)
                        }
                        .help(localizationManager.text(it: "Apri ed espandi dettagli scadenza", en: "Open and expand deadline details"))
                    }
                    
                    ForEach(dayAssignments) { asg in
                        HStack(spacing: 8) {
                            Button {
                                toggleAssignment(asg)
                            } label: {
                                Image(systemName: asg.isCompleted ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 13))
                                    .foregroundStyle(asg.isCompleted ? Color.secondary : themeManager.accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            Text(asg.title)
                                .font(UniFont.caption())
                                .strikethrough(asg.isCompleted)
                                .foregroundStyle(asg.isCompleted ? .secondary : .primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.03) : Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            openAssignment(asg)
                        }
                        .help(localizationManager.text(it: "Apri ed espandi dettagli compito", en: "Open and expand assignment details"))
                    }
                }
            }
        }
    }
    
    // MARK: - Scrollable Days List (Photo 1 reference)
    private func scrollableDaysList(scrollProxy: ScrollViewProxy) -> some View {
        let daysList = generateAllDaysInCurrentMonth()
        let summaries = daySummaries
        
        return ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 0) {
                ForEach(daysList, id: \.self) { date in
                    let dayKey = calendar.startOfDay(for: date)
                    let summary = summaries[dayKey] ?? DayEventsSummary()
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isExpanded = expandedDate != nil && calendar.isDate(date, inSameDayAs: expandedDate!)
                    
                    DayRowGeometricView(
                        date: date,
                        isSelected: isSelected,
                        isExpanded: isExpanded,
                        summary: summary,
                        isDarkMode: isDarkMode,
                        themeManager: themeManager,
                        localizationManager: localizationManager,
                        onSelect: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedDate = date
                                if expandedDate == date {
                                    expandedDate = nil
                                } else {
                                    expandedDate = date
                                }
                            }
                        },
                        onToggleDeadline: { dl in toggleDeadline(dl) },
                        onToggleAssignment: { asg in toggleAssignment(asg) },
                        onOpenDeadline: { dl in openDeadline(dl) },
                        onOpenAssignment: { asg in openAssignment(asg) },
                        onAddNewItem: { activeSheet = .deadline }
                    )
                    .id(dayScrollId(for: date))
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helpers
    private func dayScrollId(for date: Date) -> String {
        let comp = calendar.dateComponents([.year, .month, .day], from: date)
        return "day_\(comp.year ?? 0)_\(comp.month ?? 0)_\(comp.day ?? 0)"
    }
    
    private func generateAllDaysInCurrentMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var result: [Date] = []
        var d = monthInterval.start
        while d < monthInterval.end {
            result.append(d)
            guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
        return result
    }
    
    private func generateDaysInMonth(for date: Date) -> [CalendarGridDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let startOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingSpaces = (weekday + 6) % 7 // Sunday = 1, so Monday = 2
        
        var days: [CalendarGridDay] = []
        var idCounter = 0
        for _ in 0..<leadingSpaces {
            days.append(CalendarGridDay(id: idCounter, date: nil))
            idCounter += 1
        }
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return days }
        for day in 1...range.count {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarGridDay(id: idCounter, date: dayDate))
                idCounter += 1
            }
        }
        return days
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentMonth = newDate
                selectedDate = newDate
            }
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        if localizationManager.currentLanguage == .italian {
            return Self.monthYearFormatterIT.string(from: date).capitalized
        } else {
            return Self.monthYearFormatterEN.string(from: date).capitalized
        }
    }
    
    private func formatEditorialDate(_ date: Date) -> String {
        if localizationManager.currentLanguage == .italian {
            return Self.editorialHeaderFormatterIT.string(from: date).capitalized
        } else {
            return Self.editorialHeaderFormatterEN.string(from: date).capitalized
        }
    }
    
    private func toggleDeadline(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                dataManager.deadlines[idx].isCompleted.toggle()
                dataManager.saveData()
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
    }
    
    private func toggleAssignment(_ assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                dataManager.assignments[idx].isCompleted.toggle()
                dataManager.saveData()
            }
        }
    }
}

// MARK: - Day Row Geometric View (Photos 1 & 3 reference)
struct DayRowGeometricView: View {
    let date: Date
    let isSelected: Bool
    let isExpanded: Bool
    let summary: DayEventsSummary
    let isDarkMode: Bool
    let themeManager: ThemeManager
    let localizationManager: LocalizationManager
    let onSelect: () -> Void
    let onToggleDeadline: (Deadline) -> Void
    let onToggleAssignment: (Assignment) -> Void
    let onOpenDeadline: (Deadline) -> Void
    let onOpenAssignment: (Assignment) -> Void
    let onAddNewItem: () -> Void
    
    private let calendar = Calendar.current
    
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    private var weekdayName: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: localizationManager.currentLanguage == .italian ? "it_IT" : "en_US")
        f.dateFormat = "EEEE"
        return f.string(from: date).capitalized
    }
    
    @State private var isHovered: Bool = false
    
    private var rowTextColor: Color {
        if isSelected && !isExpanded {
            return themeManager.accentColor
        }
        return isDarkMode ? Color.white.opacity(0.92) : Color.black.opacity(0.88)
    }
    
    private var dividerLineColor: Color {
        isDarkMode ? Color.white.opacity(0.14) : Color.black.opacity(0.12)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Day Row: No all-around rectangles, just clean lines, bigger section, slimmer big numerals
            Button(action: onSelect) {
                HStack(alignment: .center, spacing: 18) {
                    // Left: Category Dots (Photo 1 reference)
                    HStack(spacing: 6) {
                        if summary.hasExam {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                        }
                        if summary.hasDeadline {
                            Circle().fill(Color.orange).frame(width: 8, height: 8)
                        }
                        if summary.hasAssignment {
                            Circle().fill(Color.purple).frame(width: 8, height: 8)
                        }
                        if summary.academicEventsCount > 0 {
                            Circle().fill(Color.blue).frame(width: 8, height: 8)
                        }
                        if summary.nonAcademicEventsCount > 0 {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                        }
                        if summary.totalItemsCount == 0 {
                            Circle().fill(Color.secondary.opacity(0.3)).frame(width: 6, height: 6)
                        }
                    }
                    .frame(minWidth: 44, alignment: .leading)
                    
                    // Weekday Name (Bigger day section)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weekdayName)
                            .font(.system(size: 26, weight: isSelected ? .semibold : .medium))
                            .tracking(-0.6)
                            .foregroundStyle(rowTextColor)
                        
                        if summary.totalItemsCount > 0 {
                            Text("\(summary.totalItemsCount) " + localizationManager.text(it: "impegni", en: "items"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Right: Slimmer, Large Geometric Numeral - less opaque when hovered
                    Text("\(dayNumber)")
                        .font(.system(size: 58, weight: .light, design: .default))
                        .foregroundStyle(rowTextColor)
                        .tracking(-2.0)
                        .frame(minWidth: 70, alignment: .trailing)
                        .opacity(isHovered ? 0.35 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isHovered)
                    
                    // Vertical category tag indicator on far right
                    Rectangle()
                        .fill(summary.hasExam ? Color.red : (summary.hasDeadline ? Color.orange : (summary.totalItemsCount > 0 ? Color.blue : Color.clear)))
                        .frame(width: 3, height: 44)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 28)
                .frame(height: 94)
                .background(Color.clear)
                .contentShape(Rectangle())
                .opacity(isHovered ? 0.50 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { h in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = h
                }
            }
            
            // EXPANDED DAY VIEW (Photo 3 reference: geometric hour timeline)
            if isExpanded {
                expandedGeometricTimelineView
                    .background(isDarkMode ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color(red: 0.94, green: 0.93, blue: 0.90))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Architectural 1.5pt Divider line like in attached photo
            Rectangle()
                .fill(dividerLineColor)
                .frame(height: 1.5)
        }
    }
    
    // MARK: - Photo 3 Expanded Geometric Schedule
    private var expandedGeometricTimelineView: some View {
        HStack(alignment: .top, spacing: 32) {
            // Left Column (Photo 3: "DAY 1 \n SATURDAY")
            VStack(alignment: .leading, spacing: 8) {
                Text("DAY \(dayNumber)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                Text(weekdayName.uppercased())
                    .font(UniFont.title())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .tracking(0.5)
                
                Spacer().frame(height: 12)
                
                Button {
                    onAddNewItem()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .frame(width: 140, alignment: .leading)
            .padding(.leading, 28)
            .padding(.vertical, 24)
            
            // Right Timeline with proportional event extension on timetable
            timetableTimelineContent
                .padding(.trailing, 28)
                .padding(.vertical, 16)
        }
    }
    
    // MARK: - Proportional Timetable Constants & Types
    private let hourHeight: CGFloat = 58.0
    
    private struct HourCommitmentItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String?
        let timeRange: String
        let startMinutes: Int      // Minutes from timetable start hour
        let durationMinutes: Int   // Length in minutes (proportional visual extension)
        let isSolidBlack: Bool
        let isDeadline: Bool
        let isCompleted: Bool
        let accentColor: Color?
        let rawDeadline: Deadline?
        let rawAssignment: Assignment?
        
        var laneIndex: Int = 0
        var totalLanes: Int = 1
    }
    
    // Dynamic Hour Range covering all timed events of the day
    private var timetableHourRange: (start: Int, end: Int) {
        let cal = Calendar.current
        var minH = 24
        var maxH = 0
        var hasTimedItems = false
        
        for ev in summary.events where !ev.isAllDay {
            let sh = cal.component(.hour, from: ev.startDate)
            let eh = cal.component(.hour, from: ev.endDate)
            let em = cal.component(.minute, from: ev.endDate)
            minH = min(minH, sh)
            maxH = max(maxH, em > 0 ? eh + 1 : eh)
            hasTimedItems = true
        }
        for ex in summary.exams {
            let sh = cal.component(.hour, from: ex.examDate)
            minH = min(minH, sh)
            maxH = max(maxH, sh + 2)
            hasTimedItems = true
        }
        for dl in summary.deadlines {
            let sh = cal.component(.hour, from: dl.dueDate)
            let sm = cal.component(.minute, from: dl.dueDate)
            if !(sh == 23 && sm >= 50) && sh >= 6 && sh <= 22 {
                minH = min(minH, sh)
                maxH = max(maxH, sh + 1)
                hasTimedItems = true
            }
        }
        for asg in summary.assignments {
            let sh = cal.component(.hour, from: asg.dueDate)
            let sm = cal.component(.minute, from: asg.dueDate)
            if !(sh == 23 && sm >= 50) && sh >= 6 && sh <= 22 {
                minH = min(minH, sh)
                maxH = max(maxH, sh + 1)
                hasTimedItems = true
            }
        }
        
        if !hasTimedItems {
            // Default daytime timetable for days without timed events
            return (8, 19)
        }
        
        let start = max(6, minH > 0 ? minH - 1 : minH)
        let end = min(24, max(maxH + 1, start + 8))
        return (start, end)
    }
    
    // Items due all-day or at midnight
    private var allDayItems: [HourCommitmentItem] {
        var results: [HourCommitmentItem] = []
        let cal = Calendar.current
        let range = timetableHourRange
        
        // 1. All-Day Calendar Events (Public holidays, full-day conferences, etc.)
        for ev in summary.events where ev.isAllDay {
            results.append(HourCommitmentItem(
                id: "ev_allday_\(ev.id)",
                title: ev.title,
                subtitle: ev.details.isEmpty ? (ev.location.isEmpty ? nil : ev.location) : ev.details,
                timeRange: localizationManager.text(it: "Tutto il giorno", en: "All day"),
                startMinutes: 0,
                durationMinutes: 0,
                isSolidBlack: false,
                isDeadline: false,
                isCompleted: false,
                accentColor: ev.isAcademic ? themeManager.accentColor : Color.purple,
                rawDeadline: nil,
                rawAssignment: nil
            ))
        }
        
        // 2. Deadlines due today or at midnight
        for dl in summary.deadlines {
            let h = cal.component(.hour, from: dl.dueDate)
            let m = cal.component(.minute, from: dl.dueDate)
            if (h == 23 && m >= 50) || h < range.start || h >= range.end {
                results.append(HourCommitmentItem(
                    id: "dl_allday_\(dl.id)",
                    title: dl.title,
                    subtitle: dl.priority.rawValue,
                    timeRange: localizationManager.text(it: "Scadenza oggi", en: "Due today"),
                    startMinutes: 0,
                    durationMinutes: 0,
                    isSolidBlack: false,
                    isDeadline: true,
                    isCompleted: dl.isCompleted,
                    accentColor: .orange,
                    rawDeadline: dl,
                    rawAssignment: nil
                ))
            }
        }
        
        // 3. Assignments due today or at midnight
        for asg in summary.assignments {
            let h = cal.component(.hour, from: asg.dueDate)
            let m = cal.component(.minute, from: asg.dueDate)
            if (h == 23 && m >= 50) || h < range.start || h >= range.end {
                results.append(HourCommitmentItem(
                    id: "asg_allday_\(asg.id)",
                    title: asg.title,
                    subtitle: asg.status.localized(with: localizationManager),
                    timeRange: localizationManager.text(it: "Compito", en: "Assignment"),
                    startMinutes: 0,
                    durationMinutes: 0,
                    isSolidBlack: false,
                    isDeadline: true,
                    isCompleted: asg.isCompleted,
                    accentColor: .blue,
                    rawDeadline: nil,
                    rawAssignment: asg
                ))
            }
        }
        return results
    }
    
    // Positioned Timetable Items with Exact Durations and Starts
    private var positionedTimetableItems: [HourCommitmentItem] {
        var items: [HourCommitmentItem] = []
        let cal = Calendar.current
        let range = timetableHourRange
        let startHour = range.start
        let totalTimetableMinutes = max(60, (range.end - range.start) * 60)
        
        // 1. Timed Calendar Events (Lectures, meetings, etc.)
        for ev in summary.events where !ev.isAllDay {
            let startH = cal.component(.hour, from: ev.startDate)
            let startM = cal.component(.minute, from: ev.startDate)
            let endH = cal.component(.hour, from: ev.endDate)
            let endM = cal.component(.minute, from: ev.endDate)
            
            let startMinutes = max(0, (startH - startHour) * 60 + startM)
            guard startMinutes < totalTimetableMinutes else { continue }
            
            let rawDuration = (endH - startH) * 60 + (endM - startM)
            let baseDuration = max(25, rawDuration > 0 ? rawDuration : 60)
            let durationMinutes = min(baseDuration, totalTimetableMinutes - startMinutes)
            
            let timeStr = formatEventTimeRange(startH: startH, startM: startM, endH: endH, endM: endM)
            
            items.append(HourCommitmentItem(
                id: "ev_\(ev.id)",
                title: ev.title,
                subtitle: ev.details.isEmpty ? (ev.location.isEmpty ? nil : ev.location) : ev.details,
                timeRange: timeStr,
                startMinutes: startMinutes,
                durationMinutes: durationMinutes,
                isSolidBlack: true,
                isDeadline: false,
                isCompleted: false,
                accentColor: ev.isAcademic ? themeManager.accentColor : Color.purple,
                rawDeadline: nil,
                rawAssignment: nil
            ))
        }
        
        // 2. Exams (2 hours standard visual duration)
        for ex in summary.exams {
            let startH = cal.component(.hour, from: ex.examDate)
            let startM = cal.component(.minute, from: ex.examDate)
            let startMinutes = max(0, (startH - startHour) * 60 + startM)
            guard startMinutes < totalTimetableMinutes else { continue }
            
            let durationMinutes = min(120, totalTimetableMinutes - startMinutes)
            let totalEndMin = startH * 60 + startM + 120
            let endH = (totalEndMin / 60) % 24
            let endM = totalEndMin % 60
            let timeStr = formatEventTimeRange(startH: startH, startM: startM, endH: endH, endM: endM)
            
            items.append(HourCommitmentItem(
                id: "exam_\(ex.id)",
                title: ex.title,
                subtitle: ex.room.isEmpty ? localizationManager.text(it: "Esame Universitario", en: "University Exam") : "Aula: \(ex.room)",
                timeRange: timeStr,
                startMinutes: startMinutes,
                durationMinutes: durationMinutes,
                isSolidBlack: true,
                isDeadline: false,
                isCompleted: ex.status == .passed,
                accentColor: .red,
                rawDeadline: nil,
                rawAssignment: nil
            ))
        }
        
        // 3. Timed Deadlines
        for dl in summary.deadlines {
            let h = cal.component(.hour, from: dl.dueDate)
            let m = cal.component(.minute, from: dl.dueDate)
            if !(h == 23 && m >= 50) && h >= range.start && h < range.end {
                let startMinutes = (h - startHour) * 60 + m
                guard startMinutes < totalTimetableMinutes else { continue }
                let durationMinutes = min(38, totalTimetableMinutes - startMinutes)
                
                let timeStr = formatSingleTime(h: h, m: m)
                
                items.append(HourCommitmentItem(
                    id: "dl_\(dl.id)",
                    title: dl.title,
                    subtitle: dl.priority.rawValue,
                    timeRange: timeStr,
                    startMinutes: startMinutes,
                    durationMinutes: durationMinutes,
                    isSolidBlack: false,
                    isDeadline: true,
                    isCompleted: dl.isCompleted,
                    accentColor: .orange,
                    rawDeadline: dl,
                    rawAssignment: nil
                ))
            }
        }
        
        // 4. Timed Assignments
        for asg in summary.assignments {
            let h = cal.component(.hour, from: asg.dueDate)
            let m = cal.component(.minute, from: asg.dueDate)
            if !(h == 23 && m >= 50) && h >= range.start && h < range.end {
                let startMinutes = (h - startHour) * 60 + m
                guard startMinutes < totalTimetableMinutes else { continue }
                let durationMinutes = min(38, totalTimetableMinutes - startMinutes)
                
                let timeStr = formatSingleTime(h: h, m: m)
                
                items.append(HourCommitmentItem(
                    id: "asg_\(asg.id)",
                    title: asg.title,
                    subtitle: asg.status.localized(with: localizationManager),
                    timeRange: timeStr,
                    startMinutes: startMinutes,
                    durationMinutes: durationMinutes,
                    isSolidBlack: false,
                    isDeadline: true,
                    isCompleted: asg.isCompleted,
                    accentColor: .blue,
                    rawDeadline: nil,
                    rawAssignment: asg
                ))
            }
        }
        
        // Assign overlapping lanes so concurrent events share columns side by side
        assignOverlappingLanes(items: &items)
        return items
    }
    
    // Collision detection and lane splitting for overlapping events
    private func assignOverlappingLanes(items: inout [HourCommitmentItem]) {
        guard !items.isEmpty else { return }
        items.sort {
            if $0.startMinutes != $1.startMinutes {
                return $0.startMinutes < $1.startMinutes
            }
            return $0.durationMinutes > $1.durationMinutes
        }
        
        var clusters: [[Int]] = []
        var currentCluster: [Int] = []
        var clusterEnd = -1
        
        for i in 0..<items.count {
            let s = items[i].startMinutes
            let e = items[i].startMinutes + items[i].durationMinutes
            
            if currentCluster.isEmpty {
                currentCluster.append(i)
                clusterEnd = e
            } else {
                if s < clusterEnd {
                    currentCluster.append(i)
                    clusterEnd = max(clusterEnd, e)
                } else {
                    clusters.append(currentCluster)
                    currentCluster = [i]
                    clusterEnd = e
                }
            }
        }
        if !currentCluster.isEmpty {
            clusters.append(currentCluster)
        }
        
        for cluster in clusters {
            var laneEndTimes: [Int] = []
            
            for itemIdx in cluster {
                let s = items[itemIdx].startMinutes
                let e = s + items[itemIdx].durationMinutes
                
                var assignedLane = -1
                for l in 0..<laneEndTimes.count {
                    if laneEndTimes[l] <= s {
                        assignedLane = l
                        laneEndTimes[l] = e
                        break
                    }
                }
                if assignedLane == -1 {
                    assignedLane = laneEndTimes.count
                    laneEndTimes.append(e)
                }
                items[itemIdx].laneIndex = assignedLane
            }
            
            let total = max(1, laneEndTimes.count)
            for itemIdx in cluster {
                items[itemIdx].totalLanes = total
            }
        }
    }
    
    // MARK: - Proportional Timetable Content
    private var timetableTimelineContent: some View {
        let range = timetableHourRange
        let hoursCount = max(1, range.end - range.start)
        let totalHeight = CGFloat(hoursCount) * hourHeight
        let items = positionedTimetableItems
        let allDay = allDayItems
        
        return VStack(alignment: .leading, spacing: 14) {
            // All-Day / Midnight Deadlines Strip
            if !allDay.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizationManager.text(it: "TUTTO IL GIORNO & SCADENZE", en: "ALL-DAY & DEADLINES"))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .tracking(1.0)
                    
                    VStack(spacing: 5) {
                        ForEach(allDay) { item in
                            geometricCommitmentCard(commitment: item, height: 38)
                                .frame(height: 38)
                        }
                    }
                }
                .padding(.bottom, 6)
            }
            
            // Timetable Grid with Proportional Items
            GeometryReader { geo in
                let labelWidth: CGFloat = 64.0
                let availableWidth = max(120, geo.size.width - labelWidth - 14)
                
                ZStack(alignment: .topLeading) {
                    // 1. Hour Lines & Labels
                    VStack(spacing: 0) {
                        ForEach(range.start..<range.end, id: \.self) { hour in
                            VStack(spacing: 0) {
                                HStack(alignment: .top, spacing: 14) {
                                    Text(formatHourLabel(hour: hour))
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .frame(width: labelWidth, alignment: .leading)
                                        .offset(y: -6)
                                    
                                    Rectangle()
                                        .fill(dividerLineColor.opacity(0.7))
                                        .frame(height: 0.8)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .frame(height: hourHeight)
                        }
                    }
                    
                    // 2. Positioned Events with Proportional Height Extension
                    ForEach(items) { item in
                        let topY = CGFloat(item.startMinutes) * (hourHeight / 60.0)
                        let rawHeight = CGFloat(item.durationMinutes) * (hourHeight / 60.0) - 2.0
                        let height = max(32.0, min(totalHeight - topY - 2.0, rawHeight))
                        
                        let spacingBetweenLanes: CGFloat = 8.0
                        let laneWidth = (availableWidth - CGFloat(item.totalLanes - 1) * spacingBetweenLanes) / CGFloat(item.totalLanes)
                        let leftX = labelWidth + 14 + CGFloat(item.laneIndex) * (laneWidth + spacingBetweenLanes)
                        
                        geometricCommitmentCard(commitment: item, height: height)
                            .frame(width: laneWidth, height: height)
                            .offset(x: leftX, y: topY)
                    }
                }
            }
            .frame(height: totalHeight)
            .clipped()
        }
    }
    
    // MARK: - Geometric Event Block (Refined with Proportional Height Support)
    private func geometricCommitmentCard(commitment: HourCommitmentItem, height: CGFloat) -> some View {
        let isDark = isDarkMode
        
        let cardBg: Color = {
            if commitment.isSolidBlack {
                return isDark ? Color(red: 0.17, green: 0.17, blue: 0.20) : Color(red: 0.10, green: 0.10, blue: 0.12)
            } else {
                return isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.92)
            }
        }()
        
        let cardBorder: Color = {
            if commitment.isSolidBlack {
                return isDark ? Color.white.opacity(0.20) : Color.black.opacity(0.85)
            } else {
                return isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.15)
            }
        }()
        
        let primaryText: Color = {
            if commitment.isSolidBlack {
                return Color.white
            } else {
                return isDark ? Color.white.opacity(0.95) : Color.black.opacity(0.88)
            }
        }()
        
        let secondaryText: Color = {
            if commitment.isSolidBlack {
                return Color.white.opacity(0.70)
            } else {
                return isDark ? Color.white.opacity(0.60) : Color.black.opacity(0.60)
            }
        }()
        
        return HStack(spacing: 10) {
            // Accent indicator or Checkbox for actionable items
            if commitment.isDeadline {
                Button {
                    if let dl = commitment.rawDeadline {
                        onToggleDeadline(dl)
                    } else if let asg = commitment.rawAssignment {
                        onToggleAssignment(asg)
                    }
                } label: {
                    Image(systemName: commitment.isCompleted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(primaryText)
                }
                .buttonStyle(.plain)
            } else if let acc = commitment.accentColor {
                Rectangle()
                    .fill(acc)
                    .frame(width: 3.5)
                    .padding(.vertical, 3)
            }
            
            // Title & Details
            VStack(alignment: .leading, spacing: height >= 60 ? 3 : 1) {
                Text(commitment.title)
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .strikethrough(commitment.isCompleted)
                    .foregroundStyle(primaryText)
                    .lineLimit(height >= 60 ? 2 : 1)
                
                if height >= 46, let sub = commitment.subtitle, !sub.isEmpty {
                    Text(sub)
                        .font(UniFont.caption())
                        .foregroundStyle(secondaryText)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 4)
            
            // Time range badge
            Text(commitment.timeRange)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, height >= 60 ? 8 : 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBg)
        .overlay(
            Rectangle()
                .stroke(cardBorder, lineWidth: 1)
        )
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        .onTapGesture {
            if let dl = commitment.rawDeadline {
                onOpenDeadline(dl)
            } else if let asg = commitment.rawAssignment {
                onOpenAssignment(asg)
            }
        }
    }
    
    private func formatEventTimeRange(startH: Int, startM: Int, endH: Int, endM: Int) -> String {
        if localizationManager.currentLanguage == .english {
            let sPeriod = startH < 12 ? "AM" : "PM"
            let sHour = startH == 0 ? 12 : (startH > 12 ? startH - 12 : startH)
            let ePeriod = endH < 12 ? "AM" : "PM"
            let eHour = endH == 0 ? 12 : (endH > 12 ? endH - 12 : endH)
            return String(format: "%d:%02d %@ - %d:%02d %@", sHour, startM, sPeriod, eHour, endM, ePeriod)
        } else {
            return String(format: "%02d:%02d - %02d:%02d", startH, startM, endH, endM)
        }
    }
    
    private func formatSingleTime(h: Int, m: Int) -> String {
        if localizationManager.currentLanguage == .english {
            let period = h < 12 ? "AM" : "PM"
            let displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h)
            return String(format: "%d:%02d %@", displayHour, m, period)
        } else {
            return String(format: "%02d:%02d", h, m)
        }
    }
    
    private func formatHourLabel(hour: Int) -> String {
        if localizationManager.currentLanguage == .english {
            let period = hour < 12 ? "AM" : "PM"
            let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return "\(displayHour) \(period)"
        } else {
            return String(format: "%02d:00", hour)
        }
    }
}

// MARK: - Calendar Grid Day
public struct CalendarGridDay: Identifiable {
    public let id: Int
    public let date: Date?
    
    public init(id: Int, date: Date?) {
        self.id = id
        self.date = date
    }
}

