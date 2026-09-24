//
//  QuickSearchPaletteView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Search Result Item
public struct PaletteItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let category: Category
    public let iconName: String
    public let badgeText: String?
    public let color: Color
    public let searchTerms: String
    public let action: () -> Void
    
    public enum Category: String, CaseIterable {
        case all = "all"
        case courses = "courses"
        case deadlines = "deadlines"
        case assignments = "assignments"
        case exams = "exams"
        case calendar = "calendar"
        case actions = "actions"
        
        public var title: String {
            localizedTitle(with: LocalizationManager.shared)
        }
        
        public func localizedTitle(with lm: LocalizationManager) -> String {
            switch self {
            case .all: return lm.text(it: "Tutti", en: "All")
            case .courses: return lm.text(it: "Corsi", en: "Courses")
            case .deadlines: return lm.text(it: "Scadenze", en: "Deadlines")
            case .assignments: return lm.text(it: "Assignments", en: "Assignments")
            case .exams: return lm.text(it: "Esami", en: "Exams")
            case .calendar: return lm.text(it: "Lezioni", en: "Lectures")
            case .actions: return lm.text(it: "Azioni", en: "Actions")
            }
        }
        
        public var icon: String {
            switch self {
            case .all: return "square.grid.2x2.fill"
            case .courses: return "book.closed.fill"
            case .deadlines: return "clock.fill"
            case .assignments: return "doc.text.fill"
            case .exams: return "graduationcap.fill"
            case .calendar: return "calendar"
            case .actions: return "bolt.fill"
            }
        }
        
        public var headerTitle: String {
            localizedHeaderTitle(with: LocalizationManager.shared)
        }
        
        public func localizedHeaderTitle(with lm: LocalizationManager) -> String {
            switch self {
            case .all: return lm.text(it: "TUTTI I RISULTATI", en: "ALL RESULTS")
            case .courses: return lm.text(it: "CORSI & MATERIE", en: "COURSES & SUBJECTS")
            case .deadlines: return lm.text(it: "SCADENZE & CONSEGNE", en: "DEADLINES & DUE DATES")
            case .assignments: return lm.text(it: "ASSIGNMENTS & FILE", en: "ASSIGNMENTS & FILES")
            case .exams: return lm.text(it: "ESAMI & APPELLI", en: "EXAMS & SESSIONS")
            case .calendar: return lm.text(it: "LEZIONI & ORARI CALENDARIO", en: "LECTURES & SCHEDULE")
            case .actions: return lm.text(it: "AZIONI RAPIDE & COMANDI", en: "QUICK ACTIONS & COMMANDS")
            }
        }
    }
    
    public static func == (lhs: PaletteItem, rhs: PaletteItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Quick Search Palette View
public struct QuickSearchPaletteView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: String
    
    // Callbacks for sheets
    var onOpenNewDeadline: () -> Void
    var onOpenNewExam: () -> Void
    var onOpenNewAssignment: () -> Void
    var onOpenNewCourse: () -> Void
    var onOpenFocusTimer: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var searchText = ""
    @State private var selectedCategory: PaletteItem.Category = .all
    @State private var selectedIndex = 0
    @FocusState private var isFieldFocused: Bool
    @State private var eventMonitor: Any? = nil
    
    private var allItems: [PaletteItem] {
        var items: [PaletteItem] = []
        
        // 1. Azioni Rapide & Comandi
        items.append(PaletteItem(
            id: "action-new-deadline",
            title: localizationManager.text(it: "Nuova Scadenza", en: "New Deadline"),
            subtitle: localizationManager.text(it: "Aggiungi una consegna, compito o data limite", en: "Add a deadline, assignment due date"),
            category: .actions,
            iconName: "plus.circle.fill",
            badgeText: "⌘N",
            color: themeManager.accentColor,
            searchTerms: "nuova scadenza crea aggiungi compito promemoria deadline new task",
            action: {
                selectedTab = "deadlines"
                isPresented = false
                onOpenNewDeadline()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-exam",
            title: localizationManager.text(it: "Pianifica Esame", en: "Schedule Exam"),
            subtitle: localizationManager.text(it: "Registra o prepara un nuovo appello d'esame", en: "Register or prepare an exam session"),
            category: .actions,
            iconName: "graduationcap.fill",
            badgeText: nil,
            color: .orange,
            searchTerms: "pianifica esame esami appello sessione nuovo crea schedule exam",
            action: {
                selectedTab = "exams"
                isPresented = false
                onOpenNewExam()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-assignment",
            title: localizationManager.text(it: "Nuovo Assignment / File", en: "New Assignment / File"),
            subtitle: localizationManager.text(it: "Collega un report, codice, documento o consegna", en: "Link a report, code, document or assignment"),
            category: .actions,
            iconName: "doc.badge.plus",
            badgeText: nil,
            color: .blue,
            searchTerms: "nuovo assignment compiti compitino file pdf documento relazione progetto new",
            action: {
                selectedTab = "assignments"
                isPresented = false
                onOpenNewAssignment()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-course",
            title: localizationManager.text(it: "Nuovo Corso Universitario", en: "New University Course"),
            subtitle: localizationManager.text(it: "Aggiungi materia, CFU, professore e orario", en: "Add course, credits, professor and schedule"),
            category: .actions,
            iconName: "book.fill",
            badgeText: nil,
            color: .purple,
            searchTerms: "nuovo corso corsi materia materie cfu professore docente aula new course",
            action: {
                selectedTab = "courses"
                isPresented = false
                onOpenNewCourse()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-focus-timer",
            title: localizationManager.text(it: "Timer Studio / Pomodoro", en: "Study / Pomodoro Timer"),
            subtitle: localizationManager.text(it: "Avvia una sessione di concentrazione per un corso", en: "Start a focus study session for a course"),
            category: .actions,
            iconName: "timer",
            badgeText: "⌘T",
            color: themeManager.accentColor,
            searchTerms: "timer studio pomodoro concentrazione focus sessione",
            action: {
                isPresented = false
                onOpenFocusTimer()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-sync-calendar",
            title: localizationManager.text(it: "Sincronizza Calendario Orario", en: "Sync Academic Calendar"),
            subtitle: localizationManager.text(it: "Aggiorna lezioni dal feed universitario webcal/.ics", en: "Update lectures from university webcal/.ics feed"),
            category: .actions,
            iconName: "arrow.clockwise",
            badgeText: "⌘R",
            color: .secondary,
            searchTerms: "sincronizza calendario orario lezioni feed ics webcal refresh sync",
            action: {
                isPresented = false
                Task {
                    await dataManager.syncCalendarFeed()
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Calendario sincronizzato", en: "Calendar synchronized"),
                        message: localizationManager.text(it: "\(dataManager.syncedEvents.count) lezioni ed eventi aggiornati.", en: "\(dataManager.syncedEvents.count) events updated."),
                        type: .success,
                        icon: "calendar.badge.clock"
                    )
                }
            }
        ))
        
        items.append(PaletteItem(
            id: "action-settings",
            title: localizationManager.text(it: "Impostazioni & Personalizzazione", en: "Settings & Preferences"),
            subtitle: localizationManager.text(it: "Tema Chiaro/Scuro, Notifiche, Colori e Backup", en: "Light/Dark Theme, Notifications, Colors and Backup"),
            category: .actions,
            iconName: "gearshape.fill",
            badgeText: "⌘,",
            color: .secondary,
            searchTerms: "impostazioni preferenze settings tema colori notifiche backup profilo",
            action: {
                selectedTab = "settings"
                isPresented = false
            }
        ))
        
        // 2. Corsi & Materie
        for course in dataManager.courses {
            let color = Color(hex: course.colorHex) ?? themeManager.accentColor
            let prof = course.professor.isEmpty ? localizationManager.text(it: "Docente N/D", en: "Instructor N/A") : course.professor
            let room = course.room.isEmpty ? "" : " • " + localizationManager.text(it: "Aula ", en: "Room ") + course.room
            items.append(PaletteItem(
                id: "course-\(course.id)",
                title: course.name,
                subtitle: "Prof. \(prof) • \(course.cfu) CFU\(room)",
                category: .courses,
                iconName: "book.closed.fill",
                badgeText: "\(course.cfu) CFU",
                color: color,
                searchTerms: "corso corsi course courses materia materie \(course.code) \(course.name) \(course.professor) \(course.room) \(course.notes) \(course.cfu) cfu",
                action: {
                    selectedTab = "courses"
                    dataManager.selectedCourseId = course.id
                    isPresented = false
                }
            ))
        }
        
        // 3. Scadenze & Consegne
        for deadline in dataManager.deadlines {
            let courseName = dataManager.courses.first(where: { $0.id == deadline.courseId })?.name ?? localizationManager.text(it: "Generale", en: "General")
            let dateStr = DateFormatter.shortDate.string(from: deadline.dueDate)
            let isUrgent = !deadline.isCompleted && deadline.priority == .high
            let dueText = localizationManager.text(it: "Scade il", en: "Due")
            let linkText = (deadline.linkURL != nil && !deadline.linkURL!.isEmpty) ? " • Link" : ""
            items.append(PaletteItem(
                id: "deadline-\(deadline.id)",
                title: deadline.title,
                subtitle: "\(courseName) • \(dueText) \(dateStr)\(linkText)",
                category: .deadlines,
                iconName: deadline.isCompleted ? "checkmark.circle.fill" : (isUrgent ? "exclamationmark.circle.fill" : "clock.fill"),
                badgeText: deadline.isCompleted ? localizationManager.text(it: "Fatto", en: "Done") : deadline.priority.localizedName,
                color: deadline.isCompleted ? .green : deadline.priority.color,
                searchTerms: "scadenza scadenze deadline deadlines consegna consegne promemoria urgente task \(courseName) \(deadline.title) \(deadline.notes) \(deadline.priority.localizedName) \(deadline.isCompleted ? "fatto completata done" : "da fare aperta pending")",
                action: {
                    selectedTab = "deadlines"
                    dataManager.selectedDeadlineId = deadline.id
                    isPresented = false
                }
            ))
        }
        
        // 4. Assignments & File
        for assignment in dataManager.assignments {
            let courseName = dataManager.courses.first(where: { $0.id == assignment.courseId })?.name ?? localizationManager.text(it: "Generale", en: "General")
            let fileInfo = assignment.localFileName.flatMap { " • File: \($0)" } ?? ""
            let linkInfo = (assignment.linkURL != nil && !assignment.linkURL!.isEmpty) ? " • Link" : ""
            items.append(PaletteItem(
                id: "assignment-\(assignment.id)",
                title: assignment.title,
                subtitle: "\(courseName)\(fileInfo)\(linkInfo)",
                category: .assignments,
                iconName: assignment.localFilePath != nil ? "doc.text.fill" : "doc.text",
                badgeText: assignment.isCompleted ? localizationManager.text(it: "Completato", en: "Completed") : (assignment.localFileName != nil ? "File" : nil),
                color: assignment.isCompleted ? .green : .blue,
                searchTerms: "assignment assignments compito compiti progetto progetti relazione file documento pdf tesi homework consegna \(courseName) \(assignment.title) \(assignment.details) \(assignment.localFileName ?? "") \(assignment.isCompleted ? "fatto completato completed done" : "in corso da fare pending")",
                action: {
                    selectedTab = "assignments"
                    dataManager.selectedAssignmentId = assignment.id
                    isPresented = false
                }
            ))
        }
        
        // 5. Esami & Appelli
        for exam in dataManager.exams {
            let courseName = dataManager.courses.first(where: { $0.id == exam.courseId })?.name ?? localizationManager.text(it: "Esame", en: "Exam")
            let dateStr = DateFormatter.shortDate.string(from: exam.examDate)
            let roomStr = exam.room.isEmpty ? "" : " • " + localizationManager.text(it: "Aula ", en: "Room ") + exam.room
            let badge: String = {
                if exam.status == .passed {
                    return exam.grade.flatMap { "\($0)/30" } ?? localizationManager.text(it: "Superato", en: "Passed")
                }
                return exam.status.localizedName
            }()
            items.append(PaletteItem(
                id: "exam-\(exam.id)",
                title: exam.title,
                subtitle: "\(courseName) • \(exam.type.localizedName) • \(dateStr)\(roomStr)",
                category: .exams,
                iconName: "graduationcap.fill",
                badgeText: badge,
                color: exam.status.badgeColor,
                searchTerms: "esame esami exam exams appello appelli sessione prova voto cfu orale scritto \(courseName) \(exam.title) \(exam.type.localizedName) \(exam.room) \(exam.notes) \(exam.status.localizedName)",
                action: {
                    selectedTab = "exams"
                    dataManager.selectedExamId = exam.id
                    isPresented = false
                }
            ))
        }
        
        // 6. Lezioni & Orari Calendario
        for event in dataManager.syncedEvents.prefix(80) {
            let location = event.location.isEmpty ? localizationManager.text(it: "Aula N/D", en: "Room N/A") : event.location
            let dateStr = DateFormatter.shortDateTime.string(from: event.startDate)
            items.append(PaletteItem(
                id: "event-\(event.id)",
                title: event.title,
                subtitle: "\(location) • \(dateStr)",
                category: .calendar,
                iconName: "calendar.badge.clock",
                badgeText: localizationManager.text(it: "Lezione", en: "Lecture"),
                color: .teal,
                searchTerms: "lezione lezioni orario orari calendario aula calendar lecture event \(event.title) \(event.location) \(event.details)",
                action: {
                    selectedTab = "calendar"
                    isPresented = false
                }
            ))
        }
        
        return items
    }
    
    private var filteredItems: [PaletteItem] {
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let tokens = clean.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        return allItems.filter { item in
            // Filter by category pill if not "Tutti"
            if selectedCategory != .all && item.category != selectedCategory {
                return false
            }
            
            // If search is empty, return all matching the category
            if tokens.isEmpty {
                return true
            }
            
            // Match all tokens in title, subtitle, badge, or searchTerms
            let combined = "\(item.title) \(item.subtitle) \(item.badgeText ?? "") \(item.category.rawValue) \(item.searchTerms)".lowercased()
            return tokens.allSatisfy { token in
                combined.contains(token)
            }
        }
    }
    
    // Grouped categories present in filtered items
    private var presentCategories: [PaletteItem.Category] {
        let order: [PaletteItem.Category] = [.courses, .deadlines, .assignments, .exams, .calendar, .actions]
        let itemCats = Set(filteredItems.map { $0.category })
        return order.filter { itemCats.contains($0) }
    }
    
    public var body: some View {
        ZStack {
            // Sfondo oscurato con blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Finestra Spotlight
            VStack(spacing: 0) {
                // Header Barra di Ricerca
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                    
                    TextField(localizationManager.text(it: "Cerca corsi, scadenze, assignments, esami, comandi...", en: "Search courses, deadlines, assignments, exams, commands..."), text: $searchText)
                        .textFieldStyle(.plain)
                        .font(UniFont.headline())
                        .focused($isFieldFocused)
                        .onSubmit {
                            executeCurrentSelection()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text("ESC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.08))
                        .overlay(Rectangle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
                        .clipShape(Rectangle())
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                
                Divider()
                
                // Categorie Pills Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(PaletteItem.Category.allCases, id: \.self) { cat in
                            let count = countForCategory(cat)
                            Button {
                                selectedCategory = cat
                                selectedIndex = 0
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 10))
                                    Text(cat.localizedTitle(with: localizationManager))
                                    if count > 0 && cat != .all {
                                        Text("\(count)")
                                            .font(.system(size: 10, weight: .semibold))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(selectedCategory == cat ? Color.white.opacity(0.2) : Color.primary.opacity(0.08))
                                            .clipShape(Rectangle())
                                    }
                                }
                                .font(UniFont.caption())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedCategory == cat ? themeManager.accentColor : Color.primary.opacity(0.05))
                                .foregroundStyle(selectedCategory == cat ? Color.white : Color.primary)
                                .overlay(Rectangle().stroke(selectedCategory == cat ? themeManager.accentColor : Color.primary.opacity(0.1), lineWidth: 1))
                                .clipShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color.primary.opacity(0.02))
                
                Divider()
                
                // Lista Risultati
                if filteredItems.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text(localizationManager.text(it: "Nessun risultato trovato", en: "No results found"))
                            .font(UniFont.headline())
                        Text(localizationManager.text(it: "Prova a cercare per nome materia, codice corso, titolo scadenza o docente.", en: "Try searching by subject name, course code, deadline title or professor."))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 45)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 14) {
                                if selectedCategory == .all {
                                    // Visualizzazione raggruppata per sezione
                                    ForEach(presentCategories, id: \.self) { category in
                                        let itemsInCategory = filteredItems.filter { $0.category == category }
                                        if !itemsInCategory.isEmpty {
                                            VStack(alignment: .leading, spacing: 4) {
                                                // Header sezione
                                                HStack(spacing: 6) {
                                                    Image(systemName: category.icon)
                                                        .font(.system(size: 11, weight: .semibold))
                                                    Text("\(category.localizedHeaderTitle(with: localizationManager)) (\(itemsInCategory.count))")
                                                        .font(.system(size: 11, weight: .bold))
                                                        .tracking(0.8)
                                                }
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.top, 6)
                                                .padding(.bottom, 2)
                                                
                                                ForEach(itemsInCategory) { item in
                                                    let index = filteredItems.firstIndex(of: item) ?? 0
                                                    PaletteRow(
                                                        item: item,
                                                        isSelected: index == selectedIndex
                                                    )
                                                    .id(index)
                                                    .onTapGesture {
                                                        selectedIndex = index
                                                        item.action()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // Visualizzazione singola categoria filtrata
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                            PaletteRow(
                                                item: item,
                                                isSelected: index == selectedIndex
                                            )
                                            .id(index)
                                            .onTapGesture {
                                                selectedIndex = index
                                                item.action()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(10)
                        }
                        .frame(maxHeight: 400)
                        .onChange(of: selectedIndex) { _, newIndex in
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                
                Divider()
                
                // Footer con suggerimenti comandi
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 10))
                        Text(localizationManager.text(it: "Naviga", en: "Navigate"))
                    }
                    
                    HStack(spacing: 4) {
                        Text("↵")
                            .font(.system(size: 11, weight: .bold))
                        Text(localizationManager.text(it: "Apri", en: "Open"))
                    }
                    
                    Spacer()
                    
                    Text(localizationManager.text(it: "\(filteredItems.count) elementi trovati", en: "\(filteredItems.count) items found"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                .font(UniFont.caption())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.primary.opacity(0.02))
            }
            .frame(width: 620)
            .background(
                Rectangle()
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.35), radius: 35, x: 0, y: 18)
            )
            .overlay(
                Rectangle()
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
            )
        }
        .onAppear {
            selectedIndex = 0
            isFieldFocused = true
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
        .onChange(of: searchText) { _, _ in
            selectedIndex = 0
        }
    }
    
    private func countForCategory(_ cat: PaletteItem.Category) -> Int {
        if cat == .all { return allItems.count }
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let tokens = clean.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        return allItems.filter { item in
            guard item.category == cat else { return false }
            if tokens.isEmpty { return true }
            let combined = "\(item.title) \(item.subtitle) \(item.badgeText ?? "") \(item.category.rawValue) \(item.searchTerms)".lowercased()
            return tokens.allSatisfy { combined.contains($0) }
        }.count
    }
    
    private func executeCurrentSelection() {
        guard !filteredItems.isEmpty, selectedIndex < filteredItems.count else { return }
        filteredItems[selectedIndex].action()
    }
    
    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch event.keyCode {
            case 125: // Freccia Giù
                if self.selectedIndex < self.filteredItems.count - 1 {
                    self.selectedIndex += 1
                }
                return nil
            case 126: // Freccia Su
                if self.selectedIndex > 0 {
                    self.selectedIndex -= 1
                }
                return nil
            case 36: // Invio
                self.executeCurrentSelection()
                return nil
            case 53: // ESC
                self.isPresented = false
                return nil
            default:
                return event
            }
        }
    }
    
    private func removeKeyboardMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// MARK: - Palette Row
private struct PaletteRow: View {
    let item: PaletteItem
    let isSelected: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(item.color.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(Rectangle().stroke(item.color.opacity(0.3), lineWidth: 1))
                
                Image(systemName: item.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(item.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(UniFont.headline())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(item.subtitle)
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let badge = item.badgeText {
                Text(badge)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(isSelected ? themeManager.accentColor.opacity(0.25) : Color.primary.opacity(0.06))
                    .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                    .overlay(Rectangle().stroke(isSelected ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.1), lineWidth: 1))
                    .clipShape(Rectangle())
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(isSelected ? themeManager.accentColor.opacity(0.12) : (isHovering ? Color.primary.opacity(0.04) : Color.clear))
        )
        .overlay(
            Rectangle()
                .strokeBorder(isSelected ? themeManager.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

// MARK: - DateFormatter Helper
public extension DateFormatter {
    static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f
    }()
    
    static let shortDateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
}
