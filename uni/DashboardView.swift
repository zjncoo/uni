//
//  DashboardView.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
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
                VStack(alignment: .leading, spacing: 20) {
                    // Card Frase Motivazionale in Alto
                    UniCard(padding: 16) {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.accentColor.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(localizationManager.t(.quoteTitle))
                                        .font(UniFont.caption())
                                        .foregroundStyle(themeManager.accentColor)
                                        .tracking(1.0)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Button {
                                        quoteManager.nextQuote()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.system(size: 10))
                                            Text(localizationManager.t(.newQuoteAction))
                                                .font(UniFont.caption())
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Mostra un'altra frase motivazionale")
                                }
                                
                                Text("“\(quoteManager.currentQuote)”")
                                    .font(UniFont.headline())
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .lineSpacing(2)
                                    .animation(.easeInOut, value: quoteManager.currentQuote)
                            }
                        }
                    }
                    
                    // Card Portale Universitario Personalizzabile
                    UniCard(padding: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.accentColor.opacity(0.12))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "globe.europe.africa.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dataManager.universityName.isEmpty ? localizationManager.t(.universityPortal) : dataManager.universityName)
                                    .font(UniFont.headline())
                                    .foregroundStyle(.primary)
                                
                                Text(dataManager.universityPortalURL.isEmpty ? localizationManager.t(.portalLink) : localizationManager.t(.portalAccess))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                if !dataManager.universityPortalURL.isEmpty {
                                    Button {
                                        AppSystemHelper.openWebURL(urlString: dataManager.universityPortalURL)
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "arrow.up.forward.square")
                                            Text(localizationManager.t(.openPortal))
                                        }
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(themeManager.accentColor)
                                    .help(localizationManager.text(it: "Apre il portale universitario nel browser", en: "Opens the university portal in the browser"))
                                }
                                
                                Button {
                                    isShowingEditPortalSheet = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: dataManager.universityPortalURL.isEmpty ? "plus.circle" : "pencil")
                                        Text(dataManager.universityPortalURL.isEmpty ? localizationManager.t(.configureLink) : localizationManager.t(.editLink))
                                    }
                                    .font(UniFont.caption())
                                }
                                .buttonStyle(.bordered)
                                .help(localizationManager.text(it: "Personalizza nome ateneo e link web", en: "Customize university name and web link"))
                            }
                        }
                    }
                    
                    // Header principale con data e benvenuto personalizzato
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todayDateFormatted().uppercased())
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text(dataManager.studentName.isEmpty ? localizationManager.t(.overviewTitle) : localizationManager.text(it: "Ciao, \(dataManager.studentName) 👋", en: "Hey, \(dataManager.studentName) 👋"))
                                .font(UniFont.largeTitle())
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if !dataManager.courses.isEmpty {
                                Button {
                                    selectedTab = "deadlines"
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                        Text(localizationManager.t(.newDeadlineAction))
                                            .font(UniFont.subheadline())
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 6)
                                    .background(themeManager.accentColor)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Banner iniziale se non ci sono dati
                    if dataManager.courses.isEmpty && dataManager.deadlines.isEmpty && dataManager.exams.isEmpty {
                        UniCard(padding: 20) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(themeManager.accentColor)
                                        .frame(width: 7, height: 7)
                                    Text(localizationManager.t(.welcomeTitle))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .tracking(1.0)
                                }
                                
                                Text(localizationManager.t(.welcomeSubtitle))
                                    .font(UniFont.title())
                                    .fontWeight(.semibold)
                                
                                Text(localizationManager.t(.welcomeDesc))
                                    .font(UniFont.subheadline())
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: 540)
                                
                                HStack(spacing: 10) {
                                    Button {
                                        selectedTab = "courses"
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "book.closed")
                                            Text(localizationManager.t(.addCourseAction))
                                        }
                                        .font(UniFont.subheadline())
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(themeManager.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        selectedTab = "calendar"
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "link.badge.plus")
                                            Text(localizationManager.t(.linkCalendarAction))
                                        }
                                        .font(UniFont.subheadline())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.primary.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        selectedTab = "deadlines"
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "clock")
                                            Text(localizationManager.t(.createDeadlineAction))
                                        }
                                        .font(UniFont.subheadline())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.primary.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 2)
                            }
                        }
                    }
                    
                    // Sezione NEXT: Prossima Lezione, Prossime Scadenze, Prossimo Esame
                    nextSection
                    
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
                Text(localizationManager.t(.todayAtUni))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
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
                                    .clipShape(Capsule())
                                
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
                    Text(localizationManager.t(.activeCourses))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
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
                                        Text("\(course.code.isEmpty ? "Corso" : course.code) • \(course.cfu) CFU\(course.professor.isEmpty ? "" : " • " + course.professor)")
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
                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
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
                    Text(localizationManager.t(.assignmentsAndFiles))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
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
                        title: "Nessun assignment in corso",
                        subtitle: "Aggiungi progetti o relazioni e collega direttamente i file memorizzati sul tuo Mac.",
                        buttonTitle: "Nuovo Assignment"
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
                                            Button("Apri File") {
                                                AppSystemHelper.openLocalFile(path: filePath)
                                            }
                                            .font(UniFont.caption())
                                            .buttonStyle(.bordered)
                                            .controlSize(.small)
                                        }
                                        .padding(5)
                                        .background(Color.primary.opacity(0.03))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
    
    // MARK: - Sezione NEXT (Scorciatoie Rapide)
    private var nextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("NEXT")
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .tracking(0.8)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(localizationManager.text(it: "Prossimi appuntamenti (tocca per aprire)", en: "Up next shortcuts (tap to open)"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: 12)], spacing: 12) {
                nextLectureCard
                nextDeadlineCard
                nextExamCard
            }
        }
    }
    
    private var nextLectureCard: some View {
        Button {
            selectedTab = "calendar"
        } label: {
            UniCard(padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Color.teal.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.teal)
                        }
                        
                        Text(localizationManager.text(it: "PROSSIMA LEZIONE", en: "NEXT LECTURE"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)
                        
                        Spacer()
                        
                        if let lecture = nextUpcomingLecture, lecture.startDate <= Date() && lecture.endDate >= Date() {
                            UniBadge(localizationManager.text(it: "IN CORSO", en: "NOW"), color: .green)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                    
                    if let lecture = nextUpcomingLecture {
                        Text(lecture.title)
                            .font(UniFont.headline())
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 10))
                                Text(lecture.location.isEmpty ? localizationManager.text(it: "Aula N/D", en: "Room TBA") : lecture.location)
                                    .lineLimit(1)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(formatLectureWhen(lecture))
                                    .lineLimit(1)
                            }
                        }
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    } else {
                        Text(localizationManager.text(it: "Nessuna lezione imminente", en: "No upcoming lectures"))
                            .font(UniFont.headline())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text(localizationManager.text(it: "Tocca per consultare o sincronizzare l'orario", en: "Tap to view or sync calendar"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var nextDeadlineCard: some View {
        Button {
            selectedTab = "deadlines"
            if let first = pendingDeadlines.first {
                dataManager.selectedDeadlineId = first.id
            }
        } label: {
            UniCard(padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "clock.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.orange)
                        }
                        
                        Text(localizationManager.text(it: "PROSSIMA SCADENZA", en: "NEXT DEADLINE"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)
                        
                        Spacer()
                        
                        if let first = pendingDeadlines.first {
                            UniBadge(first.priority.rawValue, color: first.priority.color)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                    
                    if let deadline = pendingDeadlines.first {
                        let courseName = dataManager.courses.first(where: { $0.id == deadline.courseId })?.name
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deadline.title)
                                .font(UniFont.headline())
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            if let cName = courseName {
                                Text(cName)
                                    .font(UniFont.caption())
                                    .foregroundStyle(themeManager.accentColor)
                                    .lineLimit(1)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 10))
                            Text(formatDueDate(deadline.dueDate))
                                .lineLimit(1)
                            
                            if pendingDeadlines.count > 1 {
                                Spacer()
                                Text(localizationManager.text(it: "+\(pendingDeadlines.count - 1) altre", en: "+\(pendingDeadlines.count - 1) more"))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(UniFont.caption())
                        .foregroundStyle(isDueDateUrgent(deadline.dueDate) ? .red : .secondary)
                    } else {
                        Text(localizationManager.text(it: "Tutte le scadenze completate! 🎉", en: "All caught up! 🎉"))
                            .font(UniFont.headline())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text(localizationManager.text(it: "Nessuna consegna in sospeso", en: "No pending tasks"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var nextExamCard: some View {
        Button {
            selectedTab = "exams"
            if let exam = nextExam {
                dataManager.selectedExamId = exam.id
            }
        } label: {
            UniCard(padding: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.purple)
                        }
                        
                        Text(localizationManager.text(it: "PROSSIMO ESAME", en: "NEXT EXAM"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)
                        
                        Spacer()
                        
                        if let exam = nextExam {
                            UniBadge(exam.type.rawValue, color: .purple)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                    
                    if let exam = nextExam {
                        let courseName = dataManager.courses.first(where: { $0.id == exam.courseId })?.name
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exam.title)
                                .font(UniFont.headline())
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            if let cName = courseName {
                                Text(cName)
                                    .font(UniFont.caption())
                                    .foregroundStyle(themeManager.accentColor)
                                    .lineLimit(1)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                Text(formatExamDate(exam.examDate))
                                    .lineLimit(1)
                            }
                            
                            Text("•")
                            
                            Text(nextExamCountdown)
                                .fontWeight(.medium)
                                .foregroundStyle(themeManager.accentColor)
                                .lineLimit(1)
                        }
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    } else {
                        Text(localizationManager.text(it: "Nessun appello fissato", en: "No upcoming exams"))
                            .font(UniFont.headline())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text(localizationManager.text(it: "Tocca per pianificare o visualizzare gli esami", en: "Tap to schedule or view exams"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
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
