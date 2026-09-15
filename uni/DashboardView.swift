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
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header Architettonico Display
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(todayDateFormatted().uppercased())
                                    .font(UniFont.sectionLabel())
                                    .foregroundStyle(.secondary)
                                    .tracking(1.4)
                                
                                Text("•")
                                    .foregroundStyle(.secondary)
                                
                                Text(dataManager.studentName.isEmpty ? "UNI WORKSPACE" : dataManager.studentName.uppercased())
                                    .font(UniFont.sectionLabel())
                                    .foregroundStyle(themeManager.accentColor)
                                    .tracking(1.2)
                            }
                            
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                if dataManager.weightedAverage > 0 {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(String(format: "%.2f", dataManager.weightedAverage))
                                            .font(UniFont.displayGigantic())
                                        Text("/ 30")
                                            .font(UniFont.headline())
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Text(dataManager.studentName.isEmpty ? localizationManager.t(.overviewTitle) : localizationManager.text(it: "Ciao, \(dataManager.studentName)", en: "Hey, \(dataManager.studentName)"))
                                        .font(UniFont.displayGigantic())
                                }
                                
                                if dataManager.totalCfuTarget > 0 {
                                    Text("• \(dataManager.totalCfuAcquired)/\(dataManager.totalCfuTarget) CFU")
                                        .font(UniFont.title())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            let cfuRatio: Double = dataManager.totalCfuTarget > 0 ? Double(dataManager.totalCfuAcquired) / Double(dataManager.totalCfuTarget) : 0.0
                            HStack(spacing: 8) {
                                Text("\(Int(round(cfuRatio * 100)))% \(localizationManager.text(it: "CARRIERA COMPLETATA", en: "CAREER COMPLETED"))")
                                    .font(.system(size: 9.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .tracking(1.0)
                                
                                if nextExam != nil {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text("\(localizationManager.text(it: "PROSSIMO ESAME", en: "NEXT EXAM")): \(nextExamCountdown.uppercased())")
                                        .font(.system(size: 9.5, weight: .medium))
                                        .foregroundStyle(themeManager.accentColor)
                                        .tracking(0.8)
                                }
                            }
                            .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        // Numero Monumentale in Filigrana
                        Text("\(dataManager.courses.count > 0 ? dataManager.courses.count : 1)")
                            .font(.system(size: 110, weight: .bold, design: .default))
                            .foregroundStyle(Color.primary.opacity(0.06))
                            .lineLimit(1)
                            .padding(.trailing, 8)
                    }
                    .padding(.bottom, 4)
                    
                    // Griglia Bento 2x2 Principale
                    bentoGridSection
                    
                    // Banner Frase Motivazionale Minimale con spigoli vivi a 90°
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
                    
                    // Layout Responsivo: 2 Colonne su schermi ampi, 1 Colonna su schermi compatti
                    if proxy.size.width > 720 {
                        HStack(alignment: .top, spacing: 18) {
                            leftColumn
                                .frame(maxWidth: .infinity)
                            rightColumn
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            leftColumn
                            rightColumn
                        }
                    }
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $isShowingEditPortalSheet) {
            EditUniversityPortalSheet()
        }
    }
    
    // MARK: - Colonna Sinistra (Lezioni & Corsi)
    private var leftColumn: some View {
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
                        UniCard(padding: 12) {
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(themeManager.accentColor)
                                    .frame(width: 3)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(item.title)
                                            .font(UniFont.headline())
                                        Spacer()
                                        UniBadge(item.category.rawValue, color: item.category == .exam ? .red : themeManager.accentColor)
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
            
            // Materie Attive
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
    }
    
    // MARK: - Colonna Destra (Scadenze & Assignments)
    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(localizationManager.t(.upcomingDeadlines).uppercased())
                    .font(UniFont.sectionLabel())
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                Spacer()
                Button(localizationManager.t(.allCount(pendingDeadlines.count))) {
                    selectedTab = "deadlines"
                }
                .font(UniFont.caption())
                .foregroundStyle(themeManager.accentColor)
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
                    ForEach(pendingDeadlines.prefix(4)) { deadline in
                        UniCard(padding: 12) {
                            HStack(alignment: .top, spacing: 10) {
                                Button {
                                    toggleDeadline(deadline)
                                } label: {
                                    Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(deadline.isCompleted ? .green : .secondary)
                                        .font(.system(size: 16))
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 1)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(deadline.title)
                                        .font(UniFont.headline())
                                        .strikethrough(deadline.isCompleted)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        if let course = dataManager.courses.first(where: { $0.id == deadline.courseId }) {
                                            Text(course.name)
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                            Text("•")
                                                .foregroundStyle(.secondary)
                                        }
                                        Text(formatDueDate(deadline.dueDate))
                                            .font(UniFont.caption())
                                            .foregroundStyle(isDueDateUrgent(deadline.dueDate) ? .red : .secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                UniBadge(deadline.priority.rawValue, color: deadline.priority.color)
                            }
                        }
                    }
                }
            }
            
            // Assignments
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(localizationManager.t(.assignmentsAndFiles).uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.4)
                    Spacer()
                    Button(localizationManager.t(.allCount(dataManager.assignments.count))) {
                        selectedTab = "assignments"
                    }
                    .font(UniFont.caption())
                    .foregroundStyle(themeManager.accentColor)
                    .buttonStyle(.plain)
                }
                
                let activeAssignments = dataManager.assignments.filter { !$0.isCompleted }
                if activeAssignments.isEmpty {
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
                        ForEach(activeAssignments.prefix(3)) { assignment in
                            UniCard(padding: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(assignment.title)
                                            .font(UniFont.headline())
                                            .lineLimit(1)
                                        Spacer()
                                        if assignment.weightPercent > 0 {
                                            Text("\(assignment.weightPercent)%")
                                                .font(UniFont.caption())
                                                .foregroundStyle(themeManager.accentColor)
                                        }
                                    }
                                    
                                    if let fileName = assignment.localFileName, let filePath = assignment.localFilePath {
                                        HStack(spacing: 6) {
                                            Image(systemName: "doc.fill")
                                                .font(.system(size: 11))
                                                .foregroundStyle(themeManager.accentColor)
                                            Text(fileName)
                                                .font(UniFont.caption())
                                                .lineLimit(1)
                                            if let size = assignment.localFileSize {
                                                Text("(\(size))")
                                                    .font(UniFont.caption())
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Button(localizationManager.text(it: "Apri File", en: "Open File")) {
                                                AppSystemHelper.openLocalFile(path: filePath)
                                            }
                                            .font(UniFont.caption())
                                            .buttonStyle(.bordered)
                                            .controlSize(.small)
                                        }
                                        .padding(5)
                                        .background(Color.primary.opacity(0.03))
                                        .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                                        .clipShape(Rectangle())
                                    }
                                }
                            }
                        }
                    }
                }
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
    
    private var urgentDeadlinesCount: Int {
        pendingDeadlines.filter { $0.priority == .high }.count
    }
    
    private var nextExam: Exam? {
        dataManager.exams
            .filter { $0.status != .passed && $0.examDate >= Calendar.current.startOfDay(for: Date()) }
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
        let diff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: exam.examDate)).day ?? 0
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
        let today = Date()
        return dataManager.syncedEvents.filter {
            cal.isDate($0.startDate, inSameDayAs: today)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func toggleDeadline(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            dataManager.deadlines[idx].isCompleted.toggle()
            dataManager.saveData()
        }
    }
    
    private func todayDateFormatted() -> String {
        let f = DateFormatter()
        if localizationManager.currentLanguage == .italian {
            f.locale = Locale(identifier: "it_IT")
            f.dateFormat = "EEEE d MMMM yyyy"
        } else {
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "EEEE, MMMM d, yyyy"
        }
        return f.string(from: Date()).capitalized
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let cal = Calendar.current
        let fTime = DateFormatter()
        fTime.dateFormat = "HH:mm"
        let timeStr = fTime.string(from: date)
        
        if cal.isDateInToday(date) {
            return localizationManager.text(it: "Oggi alle \(timeStr)", en: "Today at \(timeStr)")
        }
        if cal.isDateInTomorrow(date) {
            return localizationManager.text(it: "Domani alle \(timeStr)", en: "Tomorrow at \(timeStr)")
        }
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "d MMM"
        return "\(f.string(from: date)) • \(timeStr)"
    }
    
    private func isDueDateUrgent(_ date: Date) -> Bool {
        date.timeIntervalSinceNow < 86400 * 2
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "HH:mm"
        return "\(f.string(from: start)) - \(f.string(from: end))"
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
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "EEE d MMM"
        return "\(f.string(from: lecture.startDate)) • \(timeRange)"
    }
    
    private func formatExamDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = localizationManager.currentLanguage == .italian ? Locale(identifier: "it_IT") : Locale(identifier: "en_US")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }
    
    private var nextUpcomingLecture: CalendarEventItem? {
        let now = Date()
        return dataManager.syncedEvents
            .filter { $0.endDate >= now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
    
    // MARK: - Sezione Bento 2x2 Modulare
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
    
    // 1. Hero Card ad Accento Pieno
    private var bentoHeroCard: some View {
        Button {
            selectedTab = "deadlines"
            if let first = pendingDeadlines.first {
                dataManager.selectedDeadlineId = first.id
            }
        } label: {
            UniCard(padding: 16, cornerRadius: 0, style: .accentHero) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localizationManager.text(it: "PROSSIMA SCADENZA", en: "NEXT DEADLINE"))
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(themeManager.accentTextColor.opacity(0.85))
                                .tracking(1.4)
                            
                            if let first = pendingDeadlines.first {
                                Text(formatDueDate(first.dueDate).uppercased())
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
                    
                    if let first = pendingDeadlines.first {
                        let courseName = dataManager.courses.first(where: { $0.id == first.courseId })?.name
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(first.title)
                                .font(UniFont.title())
                                .foregroundStyle(themeManager.accentTextColor)
                                .lineLimit(2)
                            
                            if let cName = courseName {
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
                        
                        if let first = pendingDeadlines.first {
                            Text(first.priority.rawValue.uppercased())
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
                    TextField(localizationManager.text(it: "Il tuo nome (es. Francesco)", en: "Your name (e.g. Alex)"), text: $studentName)
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
