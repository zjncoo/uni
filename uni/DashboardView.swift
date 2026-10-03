//
//  DashboardView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var quoteManager: QuoteManager
    
    @Binding var selectedTab: String
    @State private var isShowingEditPortalSheet = false
    @State private var isShowingCustomizeOverviewSheet = false
    
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
    
    private static let timeRangeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return f
    }()
    
    private static let todayFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f
    }()
    
    private static let todayFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()
    
    private static let timeOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    private static let dayMonthFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMM"
        return f
    }()
    
    private static let dayMonthFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "d MMM"
        return f
    }()
    
    private static let examDateFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMM yyyy"
        return f
    }()
    
    private static let examDateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "d MMM yyyy"
        return f
    }()
    
    private static let photo4MonthYearFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "MMM''yy"
        return f
    }()
    
    private static let photo4MonthYearFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMM''yy"
        return f
    }()
    
    private static let photo4WeekdayFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE"
        return f
    }()
    
    private static let photo4WeekdayFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE"
        return f
    }()
    
    private var photo4DayNumber: String {
        let day = Calendar.current.component(.day, from: Date())
        return String(format: "%02d", day)
    }
    
    private var photo4MonthYear: String {
        let f = localizationManager.currentLanguage == .italian ? Self.photo4MonthYearFormatterIT : Self.photo4MonthYearFormatterEN
        return f.string(from: Date()).capitalized
    }
    
    private var photo4Weekday: String {
        let f = localizationManager.currentLanguage == .italian ? Self.photo4WeekdayFormatterIT : Self.photo4WeekdayFormatterEN
        return f.string(from: Date()).capitalized
    }
    
    private struct DashboardLayoutRow: Identifiable {
        let id: String
        let sections: [DashboardSection]
    }
    
    private func computeLayoutRows(isWide: Bool) -> [DashboardLayoutRow] {
        let sections = dataManager.getDashboardSections()
        if !isWide {
            return sections.map { DashboardLayoutRow(id: $0.rawValue, sections: [$0]) }
        }
        var rows: [DashboardLayoutRow] = []
        var pendingHalf: DashboardSection? = nil
        
        for section in sections {
            let isFull = (section == .bentoGrid || section == .motivationalQuote)
            if isFull {
                if let half = pendingHalf {
                    rows.append(DashboardLayoutRow(id: half.rawValue, sections: [half]))
                    pendingHalf = nil
                }
                rows.append(DashboardLayoutRow(id: section.rawValue, sections: [section]))
            } else {
                if let half = pendingHalf {
                    rows.append(DashboardLayoutRow(id: "\(half.rawValue)_\(section.rawValue)", sections: [half, section]))
                    pendingHalf = nil
                } else {
                    pendingHalf = section
                }
            }
        }
        if let half = pendingHalf {
            rows.append(DashboardLayoutRow(id: half.rawValue, sections: [half]))
        }
        return rows
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header Architettonico Display (Photo 4 Reference)
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 20) {
                            // Date Header (Photo 4 Reference: "09 •" + "Jan'24\nTuesday")
                            HStack(alignment: .center, spacing: 12) {
                                HStack(spacing: 3) {
                                    Text(photo4DayNumber)
                                        .font(.system(size: 60, weight: .bold, design: .default))
                                        .tracking(-2)
                                        .foregroundStyle(.primary)
                                    
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                        .offset(y: -4)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(photo4MonthYear)
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                    
                                    Text(photo4Weekday)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                            
                            Spacer()
                            
                            // Widget Impegni del Giorno Odierno in alto a destra
                            topHeaderTodayWidget
                        }
                        
                        // Brief sentence that summarizes each day big aligned left, with clickable sections underlines (Photo 4)
                        overviewSummaryHeadlineView
                        
                        // Quick Status Bar below summary (Photo 4 reference)
                        overviewQuickStatsStrip
                    }
                    .padding(.bottom, 6)
                    
                    // Elementi Ordinabili Dinamicamente
                    let isWide = proxy.size.width > 720
                    let rows = computeLayoutRows(isWide: isWide)
                    
                    ForEach(rows) { row in
                        if row.sections.count == 2 {
                            HStack(alignment: .top, spacing: 18) {
                                sectionView(for: row.sections[0])
                                    .frame(maxWidth: .infinity)
                                sectionView(for: row.sections[1])
                                    .frame(maxWidth: .infinity)
                            }
                        } else if let single = row.sections.first {
                            sectionView(for: single)
                        }
                    }
                    
                    // Pulsante Modifica Layout Overview in fondo alla pagina
                    VStack(spacing: 12) {
                        Divider()
                            .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            Button {
                                isShowingCustomizeOverviewSheet = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.square.dashed")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(localizationManager.text(it: "Personalizza Blocchi & Layout", en: "Customize Blocks & Layout"))
                                        .font(UniFont.subheadline())
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.primary.opacity(0.05))
                                .foregroundStyle(.primary)
                                .overlay(Rectangle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
                                .clipShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Personalizza e riordina i riquadri della pagina Overview", en: "Customize and reorder sections of the Overview page"))
                            Spacer()
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $isShowingEditPortalSheet) {
            EditUniversityPortalSheet()
        }
        .sheet(isPresented: $isShowingCustomizeOverviewSheet) {
            CustomizeOverviewSheet()
        }
        .onAppear {
            dataManager.refreshCurrentDate()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            dataManager.refreshCurrentDate(force: true)
        }
        #if canImport(AppKit)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            dataManager.refreshCurrentDate()
        }
        #endif
    }
    
    // MARK: - Dispatcher Viste Sezioni
    @ViewBuilder
    private func sectionView(for section: DashboardSection) -> some View {
        switch section {
        case .bentoGrid:
            bentoGridSection
        case .motivationalQuote:
            motivationalQuoteSection
        case .todayLectures:
            todayLecturesSection
        case .upcomingDeadlines:
            upcomingDeadlinesSection
        case .activeCourses:
            activeCoursesSection
        case .assignments:
            assignmentsSection
        }
    }
    
    // MARK: - Banner Frase Motivazionale
    private var motivationalQuoteSection: some View {
        UniCard(padding: 12, cornerRadius: 0, style: .surface) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.accentColor)
                
                Text("“\(quoteManager.currentQuote)”")
                    .font(UniFont.body())
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                Button {
                    quoteManager.nextQuote()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Mostra un'altra frase motivazionale", en: "Show another motivational quote"))
            }
        }
    }

    // MARK: - Sezione Lezioni di Oggi
    private var todayLecturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(localizationManager.t(.todayAtUni).uppercased())
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Spacer()
                Button(localizationManager.t(.navCalendar)) {
                    selectedTab = "calendar"
                }
                .font(UniFont.caption())
                .foregroundStyle(themeManager.accentColor)
                .buttonStyle(.plain)
            }
            
            let todayEvents = getTodayEvents()
            if todayEvents.isEmpty {
                UniEmptyStateView(
                    icon: "calendar.badge.clock",
                    title: localizationManager.t(.noEventsToday),
                    subtitle: localizationManager.t(.noEventsTodayDesc),
                    buttonTitle: localizationManager.t(.navCalendar)
                ) {
                    selectedTab = "calendar"
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(todayEvents) { item in
                        let calColor = Color(hex: item.calendarColorHex ?? "") ?? (item.isAcademic ? themeManager.accentColor : Color.purple)
                        UniCard(padding: 12) {
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(calColor)
                                    .frame(width: 3)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(item.title)
                                            .font(UniFont.headline())
                                        Spacer()
                                        if let calTitle = item.calendarTitle, !calTitle.isEmpty {
                                            UniBadge(calTitle, color: calColor)
                                        } else {
                                            UniBadge(item.isAcademic ? item.category.rawValue : localizationManager.text(it: "Personale", en: "Personal"), color: item.category == .exam ? .red : calColor)
                                        }
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Label(formatTimeRange(start: item.startDate, end: item.endDate), systemImage: "clock")
                                        if !item.location.isEmpty {
                                            Label(item.location, systemImage: "mappin")
                                        }
                                    }
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sezione Materie Attive
    private var activeCoursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(localizationManager.t(.activeCourses).uppercased())
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Spacer()
                Button(localizationManager.t(.viewAll)) {
                    selectedTab = "courses"
                }
                .font(UniFont.caption())
                .foregroundStyle(themeManager.accentColor)
                .buttonStyle(.plain)
            }
            
            if dataManager.courses.isEmpty {
                UniEmptyStateView(
                    icon: "book.closed",
                    title: localizationManager.t(.noCoursesEmptyTitle),
                    subtitle: localizationManager.t(.noCoursesEmptyDesc),
                    buttonTitle: localizationManager.t(.addCourseButton)
                ) {
                    selectedTab = "courses"
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(dataManager.courses.prefix(4)) { course in
                        UniCard(padding: 12) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: course.colorHex) ?? themeManager.accentColor)
                                    .frame(width: 7, height: 7)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(course.name)
                                        .font(UniFont.headline())
                                        .lineLimit(1)
                                    Text("\(course.code.isEmpty ? localizationManager.text(it: "Corso", en: "Course") : course.code) • \(course.cfu) CFU\(course.professor.isEmpty ? "" : " • " + course.professor)")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if !course.notionURL.isEmpty {
                                    Button {
                                        AppSystemHelper.openNotionPage(urlString: course.notionURL)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.forward.app")
                                                .font(.system(size: 10))
                                            Text("Notion")
                                                .font(UniFont.caption())
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.primary.opacity(0.06))
                                        .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                        .clipShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .help(localizationManager.text(it: "Apri nell'app Notion", en: "Open in Notion app"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Sezione Prossime Scadenze (Con Link opening)
    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Text(localizationManager.t(.upcomingDeadlines).uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                }
                
                Spacer()
                
                Button {
                    selectedTab = "deadlines"
                } label: {
                    HStack(spacing: 4) {
                        Text(localizationManager.t(.allCount(pendingDeadlines.count)))
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            if pendingDeadlines.isEmpty {
                UniEmptyStateView(
                    icon: "clock",
                    title: localizationManager.t(.noDeadlinesEmptyTitle),
                    subtitle: localizationManager.t(.noDeadlinesDesc),
                    buttonTitle: localizationManager.t(.createDeadlineAction)
                ) {
                    selectedTab = "deadlines"
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(pendingDeadlines.prefix(5)) { deadline in
                        overviewDeadlineCard(deadline)
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Deadline Card
    @ViewBuilder
    private func overviewDeadlineCard(_ deadline: Deadline) -> some View {
        let dueBadge = computeDueBadge(for: deadline.dueDate)
        let course = dataManager.courses.first(where: { $0.id == deadline.courseId })
        let courseColor = course != nil ? (Color(hex: course!.colorHex) ?? themeManager.accentColor) : nil
        
        UniCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // RIGA 1: Checkbox + Corso + Titolo + Spacer + Link Rapido + Priorità
                HStack(alignment: .center, spacing: 9) {
                    // Checkbox
                    Button {
                        toggleDeadline(deadline)
                    } label: {
                        Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundStyle(deadline.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(deadline.isCompleted ? localizationManager.text(it: "Segna come incompleta", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completata", en: "Mark as completed"))
                    
                    // Corso Chip
                    if let c = course, let cColor = courseColor {
                        HStack(spacing: 4.5) {
                            Circle()
                                .fill(cColor)
                                .frame(width: 6, height: 6)
                            Text(c.name)
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(cColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                    
                    // Titolo
                    Text(deadline.title)
                        .font(UniFont.headline())
                        .strikethrough(deadline.isCompleted)
                        .lineLimit(1)
                        .foregroundStyle(deadline.isCompleted ? .secondary : .primary)
                    
                    Spacer(minLength: 8)
                    
                    // Link Rapido
                    if let firstLink = deadline.allLinks.first {
                        Button {
                            AppSystemHelper.openWebURL(urlString: firstLink)
                        } label: {
                            HStack(spacing: 3) {
                                Text(localizationManager.text(it: "Link", en: "Link"))
                                    .font(UniFont.caption())
                                    .fontWeight(.medium)
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3.5)
                            .background(Color.primary.opacity(0.06))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .help(firstLink)
                    }
                    
                    // Badge Priorità
                    UniBadge(deadline.priority.localizedName, color: deadline.priority.color)
                }
                
                // RIGA 2: Due Badge pill + Note
                HStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 4.5) {
                        Image(systemName: dueBadge.icon)
                            .font(.system(size: 10, weight: .bold))
                        Text(dueBadge.label)
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(dueBadge.color.opacity(dueBadge.isUrgent ? 0.14 : 0.08))
                    .foregroundStyle(dueBadge.color)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    
                    if !deadline.notes.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text(deadline.notes)
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dataManager.selectedDeadlineId = deadline.id
                selectedTab = "deadlines"
            }
        }
    }

    // MARK: - Sezione Assignments & File (Con Link opening)
    private var assignmentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Text(localizationManager.t(.assignmentsAndFiles).uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                }
                
                Spacer()
                
                Button {
                    selectedTab = "assignments"
                } label: {
                    HStack(spacing: 4) {
                        Text(localizationManager.t(.allCount(pendingAssignments.count)))
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            if pendingAssignments.isEmpty {
                UniEmptyStateView(
                    icon: "doc.text",
                    title: localizationManager.text(it: "Nessun assignment in corso", en: "No active assignments"),
                    subtitle: localizationManager.text(it: "Aggiungi progetti o relazioni e collega direttamente i file memorizzati sul tuo Mac.", en: "Add projects or papers and link files directly from your Mac."),
                    buttonTitle: localizationManager.text(it: "Nuovo Assignment", en: "New Assignment")
                ) {
                    selectedTab = "assignments"
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(pendingAssignments.prefix(5)) { assignment in
                        overviewAssignmentCard(assignment)
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Assignment Card
    @ViewBuilder
    private func overviewAssignmentCard(_ assignment: Assignment) -> some View {
        let dueBadge = computeDueBadge(for: assignment.dueDate)
        let course = dataManager.courses.first(where: { $0.id == assignment.courseId })
        let courseColor = course != nil ? (Color(hex: course!.colorHex) ?? themeManager.accentColor) : nil
        
        UniCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // RIGA 1: Checkbox + Corso + Titolo + Spacer + Peso % + Pulsante "Consegna ↗"
                HStack(alignment: .center, spacing: 9) {
                    // Checkbox
                    Button {
                        toggleAssignment(assignment)
                    } label: {
                        Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundStyle(assignment.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(assignment.isCompleted ? localizationManager.text(it: "Segna come incompleto", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completato", en: "Mark as completed"))
                    
                    // Corso Chip
                    if let c = course, let cColor = courseColor {
                        HStack(spacing: 4.5) {
                            Circle()
                                .fill(cColor)
                                .frame(width: 6, height: 6)
                            Text(c.name)
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(cColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                    
                    // Titolo
                    Text(assignment.title)
                        .font(UniFont.headline())
                        .strikethrough(assignment.isCompleted)
                        .lineLimit(1)
                        .foregroundStyle(assignment.isCompleted ? .secondary : .primary)
                    
                    // Peso percentuale
                    if assignment.weightPercent > 0 {
                        Text("\(assignment.weightPercent)%")
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(themeManager.accentColor.opacity(0.12))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    
                    Spacer(minLength: 8)
                    
                    // PULSANTE "HAND IN ↗" (Consegna rapida se c'è un link)
                    if let firstLink = assignment.allLinks.first {
                        Button {
                            AppSystemHelper.openWebURL(urlString: firstLink)
                        } label: {
                            HStack(spacing: 4) {
                                Text(localizationManager.text(it: "Consegna", en: "Hand in"))
                                    .font(UniFont.caption())
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4.5)
                            .background(themeManager.accentColor)
                            .foregroundStyle(themeManager.accentTextColor)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .help(firstLink)
                    }
                }
                
                // RIGA 2: Due Badge pill + File allegato (se presente)
                HStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 4.5) {
                        Image(systemName: dueBadge.icon)
                            .font(.system(size: 10, weight: .bold))
                        Text(dueBadge.label)
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(dueBadge.color.opacity(dueBadge.isUrgent ? 0.14 : 0.08))
                    .foregroundStyle(dueBadge.color)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    
                    // File allegato diretto
                    if let fileName = assignment.localFileName, let filePath = assignment.localFilePath {
                        Button {
                            AppSystemHelper.openLocalFile(path: filePath)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 9.5))
                                    .foregroundStyle(themeManager.accentColor)
                                Text(fileName)
                                    .font(UniFont.caption())
                                    .lineLimit(1)
                                if let size = assignment.localFileSize {
                                    Text("(\(size))")
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "arrow.up.forward")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.04))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary.opacity(0.09), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                        .help(filePath)
                    }
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedTab = "assignments"
            }
        }
    }
    
    // MARK: - Helpers
    private func statCard(title: String, value: String, detail: String, accent: Bool) -> some View {
        UniCard(padding: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                
                Text(value)
                    .font(UniFont.largeTitle())
                    .fontWeight(.bold)
                    .foregroundStyle(accent ? themeManager.accentColor : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Text(detail)
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var pendingDeadlines: [Deadline] {
        dataManager.deadlines
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var pendingAssignments: [Assignment] {
        dataManager.assignments
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var urgentDeadlinesCount: Int {
        pendingDeadlines.filter { $0.priority == .high }.count
    }
    
    private var nextExam: Exam? {
        dataManager.exams
            .filter { $0.status != .passed && $0.examDate >= Calendar.current.startOfDay(for: dataManager.currentDate) }
            .sorted { $0.examDate < $1.examDate }
            .first
    }
    
    private var nextExamTitle: String {
        guard let exam = nextExam else { return "--" }
        return exam.title
    }
    
    private var nextExamCountdown: String {
        guard let exam = nextExam else {
            return localizationManager.text(it: "Nessun appello fissato", en: "No upcoming exams")
        }
        let diff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: dataManager.currentDate), to: Calendar.current.startOfDay(for: exam.examDate)).day ?? 0
        if diff == 0 {
            return localizationManager.text(it: "Oggi!", en: "Today!")
        } else if diff == 1 {
            return localizationManager.text(it: "Domani!", en: "Tomorrow!")
        } else if diff < 0 {
            return localizationManager.text(it: "Concluso", en: "Concluded")
        } else {
            return localizationManager.text(it: "Tra \(diff) giorni", en: "In \(diff) days")
        }
    }
    
    private func getTodayEvents() -> [CalendarEventItem] {
        let cal = Calendar.current
        let today = dataManager.currentDate
        let enabledSources = Set(dataManager.calendarSources.filter { $0.isEnabled }.map { $0.id })
        return dataManager.syncedEvents.filter {
            if let sId = $0.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            return cal.isDate($0.startDate, inSameDayAs: today)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func toggleDeadline(_ deadline: Deadline) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
                dataManager.deadlines[idx].isCompleted.toggle()
                dataManager.saveData()
            }
        }
    }
    
    private func toggleAssignment(_ assignment: Assignment) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
                dataManager.assignments[idx].isCompleted.toggle()
                dataManager.saveData()
            }
        }
    }
    
    private struct OverviewDueBadge {
        let label: String
        let icon: String
        let color: Color
        let isUrgent: Bool
    }
    
    private func computeDueBadge(for date: Date) -> OverviewDueBadge {
        let cal = Calendar.current
        let now = Date()
        let timeStr = localizationManager.formatTime(date)
        let isEn = localizationManager.currentLanguage == .english
        let dmFormatter = isEn ? Self.dayMonthFormatterEN : Self.dayMonthFormatterIT
        let dmStr = dmFormatter.string(from: date)
        
        if date < now {
            let diff = cal.dateComponents([.day, .hour], from: date, to: now)
            let days = diff.day ?? 0
            let hours = diff.hour ?? 0
            let label: String
            if days > 0 {
                label = localizationManager.text(it: "Scaduto da \(days)g", en: "Overdue by \(days)d")
            } else {
                label = localizationManager.text(it: "Scaduto da \(max(1, hours))h", en: "Overdue by \(max(1, hours))h")
            }
            return OverviewDueBadge(label: "\(label) • \(timeStr)", icon: "exclamationmark.triangle.fill", color: .red, isUrgent: true)
        } else if cal.isDateInToday(date) {
            return OverviewDueBadge(
                label: localizationManager.text(it: "Scade oggi • \(timeStr)", en: "Due today • \(timeStr)"),
                icon: "flame.fill",
                color: .orange,
                isUrgent: true
            )
        } else if cal.isDateInTomorrow(date) {
            return OverviewDueBadge(
                label: localizationManager.text(it: "Domani • \(timeStr)", en: "Tomorrow • \(timeStr)"),
                icon: "clock.badge.exclamationmark",
                color: .orange,
                isUrgent: true
            )
        } else {
            let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: date)).day ?? 0
            if days <= 7 {
                return OverviewDueBadge(
                    label: localizationManager.text(it: "Tra \(days) gg (\(dmStr)) • \(timeStr)", en: "In \(days)d (\(dmStr)) • \(timeStr)"),
                    icon: "calendar",
                    color: themeManager.accentColor,
                    isUrgent: false
                )
            } else {
                return OverviewDueBadge(
                    label: "\(dmStr) • \(timeStr)",
                    icon: "calendar",
                    color: .secondary,
                    isUrgent: false
                )
            }
        }
    }
    
    private func todayDateFormatted() -> String {
        let f = localizationManager.currentLanguage == .italian ? Self.todayFormatterIT : Self.todayFormatterEN
        return f.string(from: dataManager.currentDate).capitalized
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let cal = Calendar.current
        let timeStr = localizationManager.formatTime(date)
        
        if cal.isDateInToday(date) {
            return localizationManager.text(it: "Oggi alle \(timeStr)", en: "Today at \(timeStr)")
        }
        if cal.isDateInTomorrow(date) {
            return localizationManager.text(it: "Domani alle \(timeStr)", en: "Tomorrow at \(timeStr)")
        }
        let f = localizationManager.currentLanguage == .italian ? Self.dayMonthFormatterIT : Self.dayMonthFormatterEN
        return "\(f.string(from: date)) • \(timeStr)"
    }
    
    private func isDueDateUrgent(_ date: Date) -> Bool {
        date.timeIntervalSince(dataManager.currentDate) < 86400 * 2
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let s = localizationManager.formatTime(start)
        let e = localizationManager.formatTime(end)
        return "\(s) - \(e)"
    }
    
    private func formatLectureWhen(_ lecture: CalendarEventItem) -> String {
        let cal = Calendar.current
        let timeRange = formatTimeRange(start: lecture.startDate, end: lecture.endDate)
        if cal.isDateInToday(lecture.startDate) {
            return localizationManager.text(it: "Oggi • \(timeRange)", en: "Today • \(timeRange)")
        }
        if cal.isDateInTomorrow(lecture.startDate) {
            return localizationManager.text(it: "Domani • \(timeRange)", en: "Tomorrow • \(timeRange)")
        }
        let f = localizationManager.currentLanguage == .italian ? Self.shortDayFormatterIT : Self.shortDayFormatterEN
        return "\(f.string(from: lecture.startDate)) • \(timeRange)"
    }
    
    private func formatExamDate(_ date: Date) -> String {
        let f = localizationManager.currentLanguage == .italian ? Self.examDateFormatterIT : Self.examDateFormatterEN
        return f.string(from: date)
    }
    
    private var nextUpcomingLecture: CalendarEventItem? {
        let now = dataManager.currentDate
        let enabledSources = Set(dataManager.calendarSources.filter { $0.isEnabled }.map { $0.id })
        return dataManager.syncedEvents
            .filter {
                if let sId = $0.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                    return false
                }
                return $0.endDate >= now && $0.isAcademic
            }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
    
    // MARK: - Sezione Bento 2x2 Modulare (Panoramica di Controllo)
    private var bentoGridSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(localizationManager.text(it: "PANORAMICA DI CONTROLLO", en: "CONTROL OVERVIEW"))
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                bentoHeroCard
                bentoLectureCard
                bentoExamCard
                bentoPortalCard
            }
        }
    }
    
    private struct NextUpcomingCommitment {
        let id: UUID
        let title: String
        let courseName: String?
        let dueDate: Date
        let isAssignment: Bool
        let badgeText: String
    }
    
    private var nextUpcomingCommitment: NextUpcomingCommitment? {
        let nextDeadline = pendingDeadlines.first
        let nextAssignment = pendingAssignments.first
        
        if let d = nextDeadline, let a = nextAssignment {
            if a.dueDate < d.dueDate {
                let course = dataManager.courses.first(where: { $0.id == a.courseId })?.name
                let badge = a.weightPercent > 0 ? "\(a.weightPercent)%" : (localizationManager.currentLanguage == .english ? "ASSIGNMENT" : "COMPITO")
                return NextUpcomingCommitment(id: a.id, title: a.title, courseName: course, dueDate: a.dueDate, isAssignment: true, badgeText: badge)
            } else {
                let course = dataManager.courses.first(where: { $0.id == d.courseId })?.name
                return NextUpcomingCommitment(id: d.id, title: d.title, courseName: course, dueDate: d.dueDate, isAssignment: false, badgeText: d.priority.localizedName.uppercased())
            }
        } else if let a = nextAssignment {
            let course = dataManager.courses.first(where: { $0.id == a.courseId })?.name
            let badge = a.weightPercent > 0 ? "\(a.weightPercent)%" : (localizationManager.currentLanguage == .english ? "ASSIGNMENT" : "COMPITO")
            return NextUpcomingCommitment(id: a.id, title: a.title, courseName: course, dueDate: a.dueDate, isAssignment: true, badgeText: badge)
        } else if let d = nextDeadline {
            let course = dataManager.courses.first(where: { $0.id == d.courseId })?.name
            return NextUpcomingCommitment(id: d.id, title: d.title, courseName: course, dueDate: d.dueDate, isAssignment: false, badgeText: d.priority.localizedName.uppercased())
        }
        return nil
    }

    // 1. Hero Card ad Accento Pieno
    private var bentoHeroCard: some View {
        Button {
            if let next = nextUpcomingCommitment {
                if next.isAssignment {
                    selectedTab = "assignments"
                } else {
                    selectedTab = "deadlines"
                    dataManager.selectedDeadlineId = next.id
                }
            } else {
                selectedTab = "deadlines"
            }
        } label: {
            UniCard(padding: 16, cornerRadius: 0, style: .accentHero) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            let headerTitle = nextUpcomingCommitment?.isAssignment == true
                                ? localizationManager.text(it: "PROSSIMO COMPITO", en: "NEXT ASSIGNMENT")
                                : localizationManager.text(it: "PROSSIMA SCADENZA", en: "NEXT DEADLINE")
                            Text(headerTitle)
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(themeManager.accentTextColor.opacity(0.85))
                                .tracking(1.4)
                            
                            if let next = nextUpcomingCommitment {
                                Text(formatDueDate(next.dueDate).uppercased())
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(themeManager.accentTextColor)
                            } else {
                                Text(localizationManager.text(it: "TUTTO IN REGOLA", en: "ALL CAUGHT UP"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(themeManager.accentTextColor)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(themeManager.accentTextColor.opacity(0.75))
                    }
                    
                    Spacer(minLength: 16)
                    
                    if let next = nextUpcomingCommitment {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.title)
                                .font(UniFont.title())
                                .foregroundStyle(themeManager.accentTextColor)
                                .lineLimit(2)
                            
                            if let cName = next.courseName {
                                Text(cName)
                                    .font(UniFont.caption())
                                    .foregroundStyle(themeManager.accentTextColor.opacity(0.85))
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        Text(localizationManager.text(it: "Nessuna consegna pendente", en: "No pending tasks"))
                            .font(UniFont.title())
                            .foregroundStyle(themeManager.accentTextColor)
                            .lineLimit(2)
                    }
                    
                    Spacer(minLength: 18)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 24, weight: .ultraLight))
                            .foregroundStyle(themeManager.accentTextColor)
                        
                        Spacer()
                        
                        if let next = nextUpcomingCommitment {
                            Text(next.badgeText)
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.0)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(themeManager.accentTextColor.opacity(0.18))
                                .foregroundStyle(themeManager.accentTextColor)
                                .clipShape(Rectangle())
                        }
                    }
                }
                .frame(minHeight: 145)
            }
        }
        .buttonStyle(.plain)
    }
    
    // 2. Card Prossima Lezione
    private var bentoLectureCard: some View {
        Button {
            selectedTab = "calendar"
        } label: {
            UniCard(padding: 16, cornerRadius: 0, style: .surface) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localizationManager.text(it: "PROSSIMA LEZIONE", en: "NEXT LECTURE"))
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                            
                            if let lecture = nextUpcomingLecture, lecture.startDate <= Date() && lecture.endDate >= Date() {
                                Text(localizationManager.text(it: "IN CORSO ORA", en: "IN PROGRESS"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.green)
                            } else if let lecture = nextUpcomingLecture {
                                Text(formatLectureWhen(lecture).uppercased())
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(themeManager.accentColor)
                            } else {
                                Text(localizationManager.text(it: "NESSUNA LEZIONE", en: "NO LECTURES"))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    
                    Spacer(minLength: 16)
                    
                    if let lecture = nextUpcomingLecture {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lecture.title)
                                .font(UniFont.title())
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(lecture.location.isEmpty ? localizationManager.text(it: "Aula N/D", en: "Room TBA") : lecture.location)
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text(localizationManager.text(it: "Nessuna lezione in programma", en: "No lectures today"))
                            .font(UniFont.title())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer(minLength: 18)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundStyle(themeManager.accentColor)
                }
                .frame(minHeight: 145)
            }
        }
        .buttonStyle(.plain)
    }
    
    // 3. Card Prossimo Esame
    private var bentoExamCard: some View {
        Button {
            selectedTab = "exams"
            if let exam = nextExam {
                dataManager.selectedExamId = exam.id
            }
        } label: {
            UniCard(padding: 16, cornerRadius: 0, style: .surface) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localizationManager.text(it: "PROSSIMO ESAME", en: "NEXT EXAM"))
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                            
                            Text(nextExamCountdown.uppercased())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(nextExam != nil ? themeManager.accentColor : .secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    
                    Spacer(minLength: 16)
                    
                    if let exam = nextExam {
                        let courseName = dataManager.courses.first(where: { $0.id == exam.courseId })?.name
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exam.title)
                                .font(UniFont.title())
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            if let cName = courseName {
                                Text(cName)
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        Text(localizationManager.text(it: "Nessun appello fissato", en: "No exams scheduled"))
                            .font(UniFont.title())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer(minLength: 18)
                    
                    Image(systemName: "graduationcap")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundStyle(themeManager.accentColor)
                }
                .frame(minHeight: 145)
            }
        }
        .buttonStyle(.plain)
    }
    
    // 4. Card Accesso Rapido & Scorciatoie Home (Riquadro a Spigoli Vivi a 90° con finitura Liquid Glass)
    private var bentoPortalCard: some View {
        UniCard(padding: 16, cornerRadius: 0, style: .surface) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(localizationManager.text(it: "ACCESSO RAPIDO", en: "QUICK SHORTCUTS"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.4)
                        
                        let count = dataManager.quickShortcuts.count
                        Text(count > 0 ? "\(count) \(localizationManager.text(it: "COLLEGAMENTI", en: "SHORTCUTS"))" : localizationManager.text(it: "NON CONFIGURATO", en: "NOT CONFIGURED"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(count > 0 ? themeManager.accentColor : .secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedTab = "settings"
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 11, weight: .regular))
                            Text(localizationManager.text(it: "Gestisci", en: "Manage"))
                                .font(UniFont.caption())
                        }
                        .foregroundStyle(.secondary.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.primary.opacity(0.04))
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Gestisci e aggiungi scorciatoie nelle impostazioni", en: "Manage and add shortcuts in settings"))
                }
                
                Spacer(minLength: 12)
                
                if dataManager.quickShortcuts.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(dataManager.universityName.isEmpty ? localizationManager.t(.universityPortal) : dataManager.universityName)
                            .font(UniFont.headline())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text(localizationManager.text(it: "Aggiungi link scorciatoia dalle Impostazioni", en: "Add shortcut links from Settings"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button {
                            selectedTab = "settings"
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text(localizationManager.text(it: "Configura Scorciatoie", en: "Configure Shortcuts"))
                                    .font(UniFont.caption())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(themeManager.accentColor.opacity(0.12))
                            .foregroundStyle(themeManager.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    VStack(spacing: 6) {
                        ForEach(dataManager.quickShortcuts.prefix(3)) { shortcut in
                            Button {
                                AppSystemHelper.openWebURL(urlString: shortcut.url)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: shortcut.iconName.isEmpty ? "link" : shortcut.iconName)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(themeManager.accentColor)
                                        .frame(width: 20, height: 20)
                                        .background(themeManager.accentColor.opacity(0.12))
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(shortcut.title)
                                            .font(UniFont.subheadline())
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        if let host = URL(string: shortcut.url)?.host {
                                            Text(host)
                                                .font(.system(size: 9.5))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.forward")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.6))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Color.primary.opacity(0.03))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .help(shortcut.url)
                        }
                        
                        if dataManager.quickShortcuts.count > 3 {
                            Button {
                                selectedTab = "settings"
                            } label: {
                                HStack {
                                    Text("+\(dataManager.quickShortcuts.count - 3) \(localizationManager.text(it: "altre scorciatoie...", en: "more shortcuts..."))")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(themeManager.accentColor)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9))
                                        .foregroundStyle(themeManager.accentColor)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(minHeight: 145)
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
            return "\(localizationManager.formatTime(item.date)) - \(localizationManager.formatTime(end))"
        }
        return localizationManager.formatTime(item.date)
    }
    
    // MARK: - Header Top-Right Today Commitments Widget
    private var topHeaderTodayWidget: some View {
        let todayItems = dataManager.getTodayCommitments()
        
        return HStack(alignment: .center, spacing: 10) {
            if todayItems.isEmpty {
                Button {
                    selectedTab = "calendar"
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(themeManager.accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizationManager.text(it: "Nessun impegno oggi", en: "No events today"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text(localizationManager.text(it: "Apri calendario →", en: "Open calendar →"))
                                .font(.system(size: 9.5))
                                .foregroundStyle(themeManager.accentColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Vai al calendario", en: "Go to calendar"))
            } else {
                let maxCards = 2
                let displayed = Array(todayItems.prefix(maxCards))
                let remaining = todayItems.count - displayed.count
                
                HStack(spacing: 8) {
                    ForEach(displayed) { item in
                        topHeaderTodayCard(item)
                    }
                    
                    if remaining > 0 {
                        Button {
                            selectedTab = "calendar"
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(themeManager.accentColor)
                                
                                Text(localizationManager.text(it: "+\(remaining) altro", en: "+\(remaining) more"))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(themeManager.accentColor)
                                
                                Text(localizationManager.text(it: "mostra altro", en: "more"))
                                    .font(.system(size: 8.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 78, height: 76)
                            .background(themeManager.accentColor.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(themeManager.accentColor.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Mostra tutti gli impegni nel calendario", en: "Show all events in calendar"))
                    } else {
                        Button {
                            selectedTab = "calendar"
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundStyle(themeManager.accentColor)
                                Text(localizationManager.text(it: "mostra altro", en: "more"))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Apri la pagina calendario", en: "Open calendar page"))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func topHeaderTodayCard(_ item: CalendarCommitmentItem) -> some View {
        Button {
            selectedTab = "calendar"
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(item.type.color(theme: themeManager))
                        .frame(width: 6, height: 6)
                    
                    Text(item.type.localizedName(using: localizationManager).uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(item.type.color(theme: themeManager))
                    
                    Spacer(minLength: 0)
                }
                
                Text(item.title)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 8.5))
                        .foregroundStyle(.secondary)
                    
                    Text(formatCommitmentTime(item))
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: 140, height: 76, alignment: .leading)
            .background(Color.primary.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(localizationManager.text(it: "Clicca per visualizzare sul calendario", en: "Click to view on calendar"))
    }
    
    // MARK: - Overview Summary Headline (Photo 4 Reference)
    @ViewBuilder
    private var overviewSummaryHeadlineView: some View {
        let now = Date()
        let cal = Calendar.current
        let hour = cal.component(.hour, from: now)
        
        let greeting: String = {
            let name = dataManager.studentName.trimmingCharacters(in: .whitespacesAndNewlines)
            let nameSuffix = name.isEmpty ? "" : ", \(name)"
            if localizationManager.currentLanguage == .italian {
                if hour < 12 { return "Buongiorno\(nameSuffix)." }
                if hour < 18 { return "Buon pomeriggio\(nameSuffix)." }
                return "Buonasera\(nameSuffix)."
            } else {
                if hour < 12 { return "Good morning\(nameSuffix)." }
                if hour < 18 { return "Good afternoon\(nameSuffix)." }
                return "Good evening\(nameSuffix)."
            }
        }()
        
        let enabledSources = Set(dataManager.calendarSources.filter { $0.isEnabled }.map { $0.id })
        let todayLectures = dataManager.syncedEvents.filter {
            if let sId = $0.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            return cal.isDateInToday($0.startDate) && ($0.isAcademic || $0.category == .lecture)
        }.count
        
        let todayAllEvents = dataManager.syncedEvents.filter {
            if let sId = $0.sourceId, !dataManager.calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            return cal.isDateInToday($0.startDate)
        }.count
        
        let todayDeadlines = dataManager.deadlines.filter { cal.isDateInToday($0.dueDate) && !$0.isCompleted }.count
        let todayExams = dataManager.exams.filter { cal.isDateInToday($0.examDate) }.count
        let todayAssignments = dataManager.assignments.filter { cal.isDateInToday($0.dueDate) && !$0.isCompleted }.count
        
        let freedomSummary: String = {
            let todayItems = dataManager.getTodayCommitments()
            if todayItems.isEmpty {
                return localizationManager.text(it: "Sei completamente libero oggi.", en: "You're completely free today.")
            }
            var latestHour = 0
            for item in todayItems {
                if let end = item.endDate {
                    let h = cal.component(.hour, from: end)
                    latestHour = max(latestHour, h)
                } else {
                    let h = cal.component(.hour, from: item.date)
                    latestHour = max(latestHour, h + 1)
                }
            }
            if latestHour > 0 {
                if localizationManager.currentLanguage == .italian {
                    return "Sei per lo più libero dopo le \(latestHour):00."
                } else {
                    let hour12 = latestHour > 12 ? "\(latestHour - 12) pm" : "\(latestHour) am"
                    return "You're mostly free after \(hour12)."
                }
            }
            return localizationManager.text(it: "Buona giornata di studio!", en: "Have a great study day!")
        }()
        
        VStack(alignment: .leading, spacing: 8) {
            // Big Greeting
            Text(greeting)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            // Sentence with Clickable Underlines (Photo 4)
            FlowSentenceLayout(spacing: 6, lineSpacing: 8) {
                PlainWordToken(text: localizationManager.text(it: "Oggi hai", en: "You have"))
                
                if todayLectures > 0 {
                    ClickableUnderlineWord(
                        text: localizationManager.text(
                            it: "\(todayLectures) \(todayLectures == 1 ? "lezione" : "lezioni") nel Calendario",
                            en: "\(todayLectures) \(todayLectures == 1 ? "class" : "classes") in Calendar"
                        ),
                        icon: "calendar",
                        destinationTab: "calendar",
                        selectedTab: $selectedTab
                    )
                } else if todayAllEvents > 0 {
                    ClickableUnderlineWord(
                        text: localizationManager.text(
                            it: "\(todayAllEvents) \(todayAllEvents == 1 ? "impegno" : "impegni") nel Calendario",
                            en: "\(todayAllEvents) \(todayAllEvents == 1 ? "event" : "events") in Calendar"
                        ),
                        icon: "calendar",
                        destinationTab: "calendar",
                        selectedTab: $selectedTab
                    )
                } else {
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "Calendario", en: "Calendar"),
                        icon: "calendar",
                        destinationTab: "calendar",
                        selectedTab: $selectedTab
                    )
                }
                
                PlainWordToken(text: ",")
                
                if todayDeadlines > 0 {
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "\(todayDeadlines) scadenze", en: "\(todayDeadlines) deadlines"),
                        icon: "clock",
                        destinationTab: "deadlines",
                        selectedTab: $selectedTab
                    )
                } else {
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "scadenze", en: "deadlines"),
                        icon: "clock",
                        destinationTab: "deadlines",
                        selectedTab: $selectedTab
                    )
                }
                
                if todayExams > 0 {
                    PlainWordToken(text: ",")
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "\(todayExams) esami", en: "\(todayExams) exams"),
                        icon: "graduationcap",
                        destinationTab: "exams",
                        selectedTab: $selectedTab
                    )
                }
                
                PlainWordToken(text: localizationManager.text(it: "e", en: "and"))
                
                if todayAssignments > 0 {
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "\(todayAssignments) compiti", en: "\(todayAssignments) assignments"),
                        icon: "doc.text",
                        destinationTab: "assignments",
                        selectedTab: $selectedTab
                    )
                } else {
                    ClickableUnderlineWord(
                        text: localizationManager.text(it: "compiti", en: "assignments"),
                        icon: "doc.text",
                        destinationTab: "assignments",
                        selectedTab: $selectedTab
                    )
                }
                
                PlainWordToken(text: localizationManager.text(it: "oggi.", en: "today."))
                PlainWordToken(text: freedomSummary)
            }
        }
    }
    
    // MARK: - Overview Quick Stats Strip (Photo 4 bottom row)
    @ViewBuilder
    private var overviewQuickStatsStrip: some View {
        HStack(spacing: 12) {
            if dataManager.weightedAverage > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(themeManager.accentColor)
                    Text("\(String(format: "%.2f", dataManager.weightedAverage)) / 30")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text(localizationManager.text(it: "Media", en: "GPA"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(Color.primary.opacity(0.04))
                .clipShape(Capsule())
            }
            
            if dataManager.totalCfuTarget > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.purple)
                    Text("\(dataManager.totalCfuAcquired)/\(dataManager.totalCfuTarget) CFU")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(Color.primary.opacity(0.04))
                .clipShape(Capsule())
            }
            
            if nextExam != nil {
                HStack(spacing: 5) {
                    Image(systemName: "clock.badge.exclamationmark.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.orange)
                    Text("\(localizationManager.text(it: "Prossimo Esame:", en: "Next Exam:")) \(nextExamCountdown)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4.5)
                .background(Color.primary.opacity(0.04))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
}

// MARK: - Flow Sentence Layout (Wraps words naturally with interactive tokens)
struct FlowSentenceLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Clickable Underlined Word
struct ClickableUnderlineWord: View {
    let text: String
    var icon: String? = nil
    let destinationTab: String
    @Binding var selectedTab: String
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovered = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = destinationTab
            }
        } label: {
            HStack(spacing: 5) {
                if let ic = icon {
                    Image(systemName: ic)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }
                Text(text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(isHovered ? themeManager.accentColor : .primary)
                    .underline(true, color: isHovered ? themeManager.accentColor : (themeManager.accentColor.opacity(0.8)))
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help("Vai a \(text)")
    }
}

// MARK: - Plain Word Token
struct PlainWordToken: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.primary)
    }
}


// MARK: - Edit University Portal Sheet
struct EditUniversityPortalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var universityName: String = ""
    @State private var universityPortalURL: String = ""
    @State private var studentName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Portale Universitario", en: "University Portal"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    Text(localizationManager.text(it: "Configura il link rapido al tuo ateneo e il tuo profilo", en: "Configure your university link and your profile"))
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section(localizationManager.text(it: "Dati Ateneo & Portale", en: "University & Portal Info")) {
                    TextField(localizationManager.text(it: "Nome Università / Facoltà (es. UniPD, PoliMi)", en: "University / Faculty Name (e.g. Harvard, PoliMi)"), text: $universityName)
                    TextField(localizationManager.text(it: "URL Portale (es. https://www.unipd.it)", en: "Portal URL (e.g. https://www.university.edu)"), text: $universityPortalURL)
                }
                
                Section(localizationManager.text(it: "Profilo Studente", en: "Student Profile")) {
                    TextField(localizationManager.text(it: "Il tuo nome (es. Marco)", en: "Your name (e.g. Alex)"), text: $studentName)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                if !dataManager.universityPortalURL.isEmpty {
                    Button(role: .destructive) {
                        dataManager.universityPortalURL = ""
                        dataManager.universityName = ""
                        dataManager.saveData()
                        dismiss()
                        NotificationManager.shared.notify(
                            title: localizationManager.t(.portalRemoved),
                            type: .info,
                            icon: "trash"
                        )
                    } label: {
                        Text(localizationManager.text(it: "Rimuovi Link", en: "Remove Link"))
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(localizationManager.t(.cancel)) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                    Button(localizationManager.text(it: "Salva", en: "Save")) {
                    dataManager.universityName = universityName.trimmingCharacters(in: .whitespacesAndNewlines)
                    dataManager.universityPortalURL = universityPortalURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    dataManager.studentName = studentName.trimmingCharacters(in: .whitespacesAndNewlines)
                    dataManager.saveData()
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.t(.portalUpdated),
                        message: localizationManager.t(.portalSaved(dataManager.universityName)),
                        type: .success,
                        icon: "globe.europe.africa.fill"
                    )
                    
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
            }
            .padding(16)
        }
        .frame(width: 480, height: 350)
        .onAppear {
            universityName = dataManager.universityName
            universityPortalURL = dataManager.universityPortalURL
            studentName = dataManager.studentName
        }
    }
}

// MARK: - Customize Overview Sheet
struct CustomizeOverviewSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var sections: [DashboardSection] = []
    
    private var availableSections: [DashboardSection] {
        DashboardSection.allCases.filter { !sections.contains($0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Personalizza Blocchi Overview", en: "Customize Overview Blocks"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Aggiungi, rimuovi o riordina i riquadri visualizzati nella schermata principale", en: "Add, remove, or reorder blocks displayed on your main overview screen"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            // Lista Sezioni (Attive + Disponibili)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // SEZIONE 1: Blocchi Attivi
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(localizationManager.text(it: "BLOCCHI ATTIVI NELL'OVERVIEW", en: "ACTIVE BLOCKS IN OVERVIEW"))
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            Text("\(sections.count)")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(themeManager.accentColor.opacity(0.15))
                                .foregroundStyle(themeManager.accentColor)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                            UniCard(padding: 12) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Rectangle()
                                            .fill(themeManager.accentColor.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                            .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.25), lineWidth: 1))
                                        Image(systemName: section.icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(themeManager.accentColor)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text("\(index + 1).")
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                            Text(section.localizedTitle(with: localizationManager))
                                                .font(UniFont.headline())
                                        }
                                        Text(section.localizedSubtitle(with: localizationManager))
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        // Sposta Su
                                        Button {
                                            moveUp(index: index)
                                        } label: {
                                            Image(systemName: "chevron.up")
                                                .font(.system(size: 11, weight: .bold))
                                                .frame(width: 26, height: 26)
                                                .background(Color.primary.opacity(0.05))
                                                .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                                .clipShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(index == 0)
                                        .opacity(index == 0 ? 0.3 : 1.0)
                                        .help(localizationManager.text(it: "Sposta più in alto", en: "Move higher"))
                                        
                                        // Sposta Giù
                                        Button {
                                            moveDown(index: index)
                                        } label: {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 11, weight: .bold))
                                                .frame(width: 26, height: 26)
                                                .background(Color.primary.opacity(0.05))
                                                .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                                .clipShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(index == sections.count - 1)
                                        .opacity(index == sections.count - 1 ? 0.3 : 1.0)
                                        .help(localizationManager.text(it: "Sposta più in basso", en: "Move lower"))
                                        
                                        // Rimuovi Blocco
                                        Button {
                                            removeSection(at: index)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 11))
                                                .foregroundStyle(.red)
                                                .frame(width: 26, height: 26)
                                                .background(Color.red.opacity(0.08))
                                                .overlay(Rectangle().stroke(Color.red.opacity(0.2), lineWidth: 1))
                                                .clipShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(sections.count <= 1)
                                        .opacity(sections.count <= 1 ? 0.3 : 1.0)
                                        .help(localizationManager.text(it: "Rimuovi questo blocco dall'Overview", en: "Remove this block from Overview"))
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // SEZIONE 2: Blocchi Disponibili da Aggiungere
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(localizationManager.text(it: "BLOCCHI DISPONIBILI DA AGGIUNGERE", en: "AVAILABLE BLOCKS TO ADD"))
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            Text("\(availableSections.count)")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.primary.opacity(0.06))
                                .foregroundStyle(Color.secondary)
                                .clipShape(Capsule())
                        }
                        
                        if availableSections.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(themeManager.accentColor)
                                Text(localizationManager.text(
                                    it: "Tutti i blocchi disponibili sono attualmente presenti nella tua Overview.",
                                    en: "All available blocks are currently included in your Overview."
                                ))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        } else {
                            ForEach(availableSections) { available in
                                UniCard(padding: 12) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.primary.opacity(0.05))
                                                .frame(width: 32, height: 32)
                                                .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                            Image(systemName: available.icon)
                                                .font(.system(size: 14))
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(available.localizedTitle(with: localizationManager))
                                                .font(UniFont.headline())
                                            Text(available.localizedSubtitle(with: localizationManager))
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            addSection(available)
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 11, weight: .bold))
                                                Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                                                    .font(UniFont.caption())
                                                    .fontWeight(.semibold)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(themeManager.accentColor.opacity(0.12))
                                            .foregroundStyle(themeManager.accentColor)
                                            .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                            .clipShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .help(localizationManager.text(it: "Aggiungi questo blocco all'Overview", en: "Add this block to Overview"))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 380)
            
            Divider()
            
            // Footer
            HStack {
                Button(localizationManager.text(it: "Ripristina Predefinito", en: "Reset Default")) {
                    resetToDefault()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(localizationManager.text(it: "Salva", en: "Save")) {
                    dataManager.dashboardSectionsOrder = sections.map { $0.rawValue }
                    dataManager.saveData()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 540, height: 530)
        .onAppear {
            sections = dataManager.getDashboardSections()
        }
    }
    
    private func moveUp(index: Int) {
        guard index > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            sections.swapAt(index, index - 1)
        }
    }
    
    private func moveDown(index: Int) {
        guard index < sections.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            sections.swapAt(index, index + 1)
        }
    }
    
    private func removeSection(at index: Int) {
        guard sections.count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            _ = sections.remove(at: index)
        }
    }
    
    private func addSection(_ section: DashboardSection) {
        withAnimation(.easeInOut(duration: 0.2)) {
            sections.append(section)
        }
    }
    
    private func resetToDefault() {
        withAnimation(.easeInOut(duration: 0.2)) {
            sections = [
                .bentoGrid,
                .assignments,
                .upcomingDeadlines,
                .motivationalQuote,
                .todayLectures,
                .activeCourses
            ]
        }
    }
}

