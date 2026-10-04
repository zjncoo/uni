//
//  DeadlinesView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI

struct DeadlinesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var filterMode: DeadlineFilter = .pending
    @State private var selectedCourseId: UUID? = nil
    @State private var searchText = ""
    @State private var isPresentingNewDeadline = false
    @State private var deadlineToEdit: Deadline? = nil
    @State private var deadlineToDelete: Deadline? = nil
    
    fileprivate static let dueDateFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f
    }()
    
    fileprivate static let dueDateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()

    fileprivate static let dayMonthFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "d MMM"
        return f
    }()

    fileprivate static let dayMonthFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "MMM d"
        return f
    }()
    
    fileprivate static let dueTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return f
    }()
    
    enum DeadlineFilter: String, CaseIterable {
        case pending = "pending"
        case urgent = "urgent"
        case completed = "completed"
        case all = "all"
        
        func title(with lm: LocalizationManager) -> String {
            switch self {
            case .pending: return lm.t(.filterPending)
            case .urgent: return lm.t(.filterUrgent)
            case .completed: return lm.t(.filterCompleted)
            case .all: return lm.t(.filterAll)
            }
        }
    }
    
    private var selectedCourseName: String {
        if let id = selectedCourseId, let course = dataManager.courses.first(where: { $0.id == id }) {
            return course.name
        }
        return localizationManager.text(it: "Tutti i Corsi", en: "All Courses")
    }
    
    var filteredDeadlines: [Deadline] {
        var base: [Deadline]
        switch filterMode {
        case .pending:
            base = dataManager.deadlines.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        case .urgent:
            base = dataManager.deadlines.filter { !$0.isCompleted && $0.priority == .high }.sorted { $0.dueDate < $1.dueDate }
        case .completed:
            base = dataManager.deadlines.filter { $0.isCompleted }.sorted { $0.dueDate > $1.dueDate }
        case .all:
            base = dataManager.deadlines.sorted { $0.dueDate < $1.dueDate }
        }
        
        if let courseId = selectedCourseId {
            base = base.filter { $0.courseId == courseId }
        }
        
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty {
            return base
        }
        return base.filter { deadline in
            let courseName = dataManager.courses.first(where: { $0.id == deadline.courseId })?.name ?? ""
            return deadline.title.localizedCaseInsensitiveContains(clean) ||
                   deadline.notes.localizedCaseInsensitiveContains(clean) ||
                   courseName.localizedCaseInsensitiveContains(clean) ||
                   deadline.priority.localizedName.localizedCaseInsensitiveContains(clean) ||
                   deadline.priority.rawValue.localizedCaseInsensitiveContains(clean)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header con pulsante per nuova scadenza
                HStack(alignment: .top) {
                    UniHeader(
                        localizationManager.t(.deadlinesTitle),
                        subtitle: localizationManager.t(.deadlinesSubtitle(dataManager.deadlines.filter { !$0.isCompleted }.count))
                    )
                    
                    Spacer()
                    
                    Button {
                        isPresentingNewDeadline = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text(localizationManager.t(.createDeadlineAction))
                                .font(UniFont.subheadline())
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background(themeManager.accentColor)
                        .foregroundStyle(themeManager.accentTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: themeManager.accentColor.opacity(0.25), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                
                // Filtri e Barra di Ricerca
                if !dataManager.deadlines.isEmpty {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            ForEach(DeadlineFilter.allCases, id: \.self) { filter in
                                Button {
                                    filterMode = filter
                                } label: {
                                    Text(filter.title(with: localizationManager))
                                        .font(UniFont.subheadline())
                                        .fontWeight(filterMode == filter ? .semibold : .regular)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(filterMode == filter ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                        .foregroundStyle(filterMode == filter ? themeManager.accentColor : .primary)
                                        .overlay(Rectangle().stroke(filterMode == filter ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1))
                                        .clipShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Menu a tendina per filtrare per Corso
                        Menu {
                            Button {
                                selectedCourseId = nil
                            } label: {
                                HStack {
                                    Text(localizationManager.text(it: "Tutti i Corsi", en: "All Courses"))
                                    if selectedCourseId == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            if !dataManager.courses.isEmpty {
                                Divider()
                                ForEach(dataManager.courses) { course in
                                    Button {
                                        selectedCourseId = course.id
                                    } label: {
                                        HStack {
                                            Text(course.name)
                                            if selectedCourseId == course.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: selectedCourseId == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text(selectedCourseName)
                                    .font(UniFont.subheadline())
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(selectedCourseId != nil ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                            .foregroundStyle(selectedCourseId != nil ? themeManager.accentColor : .primary)
                            .overlay(Rectangle().stroke(selectedCourseId != nil ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1))
                            .clipShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Search Bar (Glasslike)
                        HStack(spacing: 7) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            TextField(localizationManager.text(it: "Cerca scadenze...", en: "Search deadlines..."), text: $searchText)
                                .textFieldStyle(.plain)
                                .font(UniFont.subheadline())
                                .frame(width: 180)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                    }
                }
                
                ScrollViewReader { scrollProxy in
                    Group {
                        if dataManager.deadlines.isEmpty {
                            UniEmptyStateView(
                                icon: "checkmark.seal",
                                title: localizationManager.t(.noDeadlinesEmptyTitle),
                                subtitle: localizationManager.t(.noDeadlinesEmptyDesc),
                                buttonTitle: localizationManager.t(.createDeadlineAction)
                            ) {
                                isPresentingNewDeadline = true
                            }
                        } else if filteredDeadlines.isEmpty {
                            UniEmptyStateView(
                                icon: "checkmark.circle",
                                title: localizationManager.t(.noMatchingDeadlines),
                                subtitle: localizationManager.t(.upToDate)
                            )
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredDeadlines) { deadline in
                                    DeadlineCardView(
                                        deadline: deadline,
                                        onToggleComplete: { toggleComplete(deadline) },
                                        onEdit: { deadlineToEdit = deadline },
                                        onDelete: { deadlineToDelete = deadline }
                                    )
                                    .id(deadline.id)
                                }
                            }
                        }
                    }
                    .onAppear {
                        if let expId = dataManager.expandedDeadlineId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    scrollProxy.scrollTo(expId, anchor: .center)
                                }
                            }
                        }
                    }
                    .onChange(of: dataManager.expandedDeadlineId) { _, newId in
                        if let newId = newId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    scrollProxy.scrollTo(newId, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $isPresentingNewDeadline) {
            DeadlineEditorSheet(deadlineToEdit: nil) { newOne in
                dataManager.deadlines.append(newOne)
                dataManager.saveData()
                
                let courseName = dataManager.courses.first(where: { $0.id == newOne.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(deadline: newOne, courseName: courseName) }
                
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Scadenza creata", en: "Deadline created"),
                    message: "\(newOne.title) • \(localizationManager.text(it: "Scade il", en: "Due")) \(formatDueDate(newOne.dueDate))",
                    type: .success,
                    icon: "clock.badge.checkmark"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        .sheet(item: $deadlineToEdit) { deadline in
            DeadlineEditorSheet(deadlineToEdit: deadline) { updated in
                if let idx = dataManager.deadlines.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.deadlines[idx] = updated
                    dataManager.saveData()
                    
                    let courseName = dataManager.courses.first(where: { $0.id == updated.courseId })?.name
                    Task { await AppleCalendarManager.shared.sync(deadline: updated, courseName: courseName) }
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Scadenza aggiornata", en: "Deadline updated"),
                        message: updated.title,
                        type: .info,
                        icon: "pencil"
                    )
                }
            }
        }
        .alert(
            localizationManager.text(it: "Elimina Scadenza", en: "Delete Deadline"),
            isPresented: Binding(get: { deadlineToDelete != nil }, set: { if !$0 { deadlineToDelete = nil } }),
            presenting: deadlineToDelete
        ) { dl in
            Button(localizationManager.t(.cancel), role: .cancel) {
                deadlineToDelete = nil
            }
            Button(localizationManager.t(.delete), role: .destructive) {
                deleteDeadline(dl)
                deadlineToDelete = nil
            }
        } message: { dl in
            Text(localizationManager.text(
                it: "Sei sicuro di voler eliminare la scadenza \"\(dl.title)\"? L'operazione non può essere annullata.",
                en: "Are you sure you want to delete the deadline \"\(dl.title)\"? This action cannot be undone."
            ))
        }
        .onAppear {
            handleSelectedOrExpandedDeadline()
        }
        .onChange(of: dataManager.selectedDeadlineId) { _, _ in
            handleSelectedOrExpandedDeadline()
        }
        .onChange(of: dataManager.expandedDeadlineId) { _, _ in
            handleSelectedOrExpandedDeadline()
        }
    }
    
    private func handleSelectedOrExpandedDeadline() {
        if let expId = dataManager.expandedDeadlineId {
            if let found = dataManager.deadlines.first(where: { $0.id == expId }) {
                searchText = ""
                selectedCourseId = nil
                filterMode = found.isCompleted ? .completed : .pending
            }
        } else if let targetId = dataManager.selectedDeadlineId,
                  let found = dataManager.deadlines.first(where: { $0.id == targetId }) {
            deadlineToEdit = found
            dataManager.selectedDeadlineId = nil
        }
    }
    
    private func toggleComplete(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            dataManager.deadlines[idx].isCompleted.toggle()
            let isNowCompleted = dataManager.deadlines[idx].isCompleted
            let updatedDeadline = dataManager.deadlines[idx]
            dataManager.saveData()
            
            let courseName = dataManager.courses.first(where: { $0.id == updatedDeadline.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(deadline: updatedDeadline, courseName: courseName) }
            
            if isNowCompleted {
                SoundManager.shared.play(.success)
            } else {
                SoundManager.shared.play(.pop)
            }
            
            NotificationManager.shared.notify(
                title: isNowCompleted ? localizationManager.text(it: "Scadenza completata! 🎉", en: "Deadline completed! 🎉") : localizationManager.text(it: "Scadenza riattivata", en: "Deadline reactivated"),
                message: deadline.title,
                type: isNowCompleted ? .success : .info,
                icon: isNowCompleted ? "checkmark.circle.fill" : "circle",
                postToSystem: true
            )
            NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
        }
    }
    
    private func deleteDeadline(_ deadline: Deadline) {
        SoundManager.shared.play(.remove)
        dataManager.deadlines.removeAll { $0.id == deadline.id }
        dataManager.saveData()
        
        Task { await AppleCalendarManager.shared.remove(deadlineId: deadline.id) }
        
        NotificationManager.shared.notify(
            title: localizationManager.text(it: "Scadenza eliminata", en: "Deadline deleted"),
            message: deadline.title,
            type: .warning,
            icon: "trash"
        )
        NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let f = localizationManager.currentLanguage == .english ? Self.dueDateFormatterEN : Self.dueDateFormatterIT
        return f.string(from: date).capitalized
    }
    
    private func formatDueTime(_ date: Date) -> String {
        let timeStr = localizationManager.formatTime(date)
        return localizationManager.text(it: "Ore \(timeStr)", en: "At \(timeStr)")
    }

    
    private func isUrgent(_ date: Date) -> Bool {
        date.timeIntervalSinceNow < 86400 * 2 && date.timeIntervalSinceNow > 0
    }
}

// MARK: - Deadline Card View
struct DeadlineCardView: View {
    let deadline: Deadline
    var onToggleComplete: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isExpanded: Bool = false
    
    private struct DuePillInfo {
        let label: String
        let fullDate: String
        let icon: String
        let color: Color
        let isUrgent: Bool
    }
    
    private var dueInfo: DuePillInfo {
        let date = deadline.dueDate
        let isEn = localizationManager.currentLanguage == .english
        let fullFormatter = isEn ? DeadlinesView.dueDateFormatterEN : DeadlinesView.dueDateFormatterIT
        let timeStr = localizationManager.formatTime(date)
        let fullStr = "\(fullFormatter.string(from: date).capitalized) • \(timeStr)"
        
        if deadline.isCompleted {
            return DuePillInfo(
                label: localizationManager.text(it: "Completata", en: "Completed"),
                fullDate: fullStr,
                icon: "checkmark.circle.fill",
                color: .green,
                isUrgent: false
            )
        }
        
        let calendar = Calendar.current
        let now = Date()
        let dmFormatter = isEn ? DeadlinesView.dayMonthFormatterEN : DeadlinesView.dayMonthFormatterIT
        let dmStr = dmFormatter.string(from: date)
        
        if date < now {
            let diff = calendar.dateComponents([.day, .hour], from: date, to: now)
            let days = diff.day ?? 0
            let hours = diff.hour ?? 0
            let label = days > 0
                ? localizationManager.text(it: "Scaduta da \(days)g", en: "Overdue by \(days)d")
                : localizationManager.text(it: "Scaduta da \(max(1, hours))h", en: "Overdue by \(max(1, hours))h")
            return DuePillInfo(label: label, fullDate: fullStr, icon: "exclamationmark.triangle.fill", color: .red, isUrgent: true)
        } else if calendar.isDateInToday(date) {
            return DuePillInfo(
                label: localizationManager.text(it: "Scade oggi • \(timeStr)", en: "Due today • \(timeStr)"),
                fullDate: fullStr,
                icon: "flame.fill",
                color: .orange,
                isUrgent: true
            )
        } else if calendar.isDateInTomorrow(date) {
            return DuePillInfo(
                label: localizationManager.text(it: "Domani • \(timeStr)", en: "Tomorrow • \(timeStr)"),
                fullDate: fullStr,
                icon: "clock.badge.exclamationmark",
                color: .orange,
                isUrgent: true
            )
        } else {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
            if days <= 7 {
                return DuePillInfo(
                    label: localizationManager.text(it: "Tra \(days) giorni (\(dmStr))", en: "In \(days) days (\(dmStr))"),
                    fullDate: fullStr,
                    icon: "calendar",
                    color: deadline.priority == .high ? .red : themeManager.accentColor,
                    isUrgent: deadline.priority == .high
                )
            } else {
                return DuePillInfo(
                    label: "\(dmStr) • \(timeStr)",
                    fullDate: fullStr,
                    icon: "calendar",
                    color: .secondary,
                    isUrgent: false
                )
            }
        }
    }
    
    var body: some View {
        UniCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                // RIGA 1: Checkbox, Corso, Titolo, Priorità, Spacer, Link button, Edit, Elimina, Espansione
                HStack(alignment: .center, spacing: 10) {
                    // Checkbox
                    Button(action: onToggleComplete) {
                        Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(deadline.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(deadline.isCompleted ? localizationManager.text(it: "Segna come incompleta", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completata", en: "Mark as completed"))
                    
                    // Corso Badge
                    if let course = dataManager.courses.first(where: { $0.id == deadline.courseId }) {
                        UniBadge(course.name, color: Color(hex: course.colorHex) ?? themeManager.accentColor)
                    }
                    
                    // Titolo
                    Text(deadline.title)
                        .font(UniFont.headline())
                        .strikethrough(deadline.isCompleted)
                        .lineLimit(1)
                    
                    // Priorità
                    UniBadge(deadline.priority.localizedName, color: deadline.priority.color)
                    
                    Spacer(minLength: 8)
                    
                    // PULSANTE LINK IMMEDIATO (Mostrato subito senza dover espandere!)
                    if let firstLink = deadline.allLinks.first {
                        HStack(spacing: 3) {
                            Button {
                                AppSystemHelper.openWebURL(urlString: firstLink)
                            } label: {
                                HStack(spacing: 4) {
                                    Text(localizationManager.text(it: "Link", en: "Link"))
                                        .font(UniFont.caption())
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(themeManager.accentColor.opacity(0.12))
                                .foregroundStyle(themeManager.accentColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(themeManager.accentColor.opacity(0.32), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .help(firstLink)
                            
                            // Se ci sono più link, menu rapido
                            if deadline.allLinks.count > 1 {
                                Menu {
                                    ForEach(deadline.allLinks, id: \.self) { link in
                                        Button {
                                            AppSystemHelper.openWebURL(urlString: link)
                                        } label: {
                                            HStack {
                                                Image(systemName: "arrow.up.right")
                                                Text(link)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Text("+\(deadline.allLinks.count - 1)")
                                            .font(.system(size: 10, weight: .semibold))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 7))
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                    .background(themeManager.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    .foregroundStyle(themeManager.accentColor)
                                }
                                .menuStyle(.borderlessButton)
                                .help(localizationManager.text(it: "Tutti i link (\(deadline.allLinks.count))", en: "All links (\(deadline.allLinks.count))"))
                            }
                        }
                    }
                    
                    // Pulsante Modifica rapido
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 24, height: 24)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Modifica scadenza", en: "Edit deadline"))
                    
                    // Pulsante Elimina rapido
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundStyle(.red.opacity(0.85))
                            .frame(width: 24, height: 24)
                            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Elimina scadenza", en: "Delete deadline"))
                    
                    // Freccina per espandere/comprimere dettagli completi
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .frame(width: 24, height: 24)
                            .background(Color.primary.opacity(isExpanded ? 0.08 : 0.03), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(isExpanded ? localizationManager.text(it: "Comprimi dettagli", en: "Collapse details") : localizationManager.text(it: "Espandi dettagli e risorse", en: "Expand details and resources"))
                }
                
                // RIGA 2: Scadenza a colpo d'occhio + Chip File Mac (se presente)
                HStack(spacing: 8) {
                    // Badge Urgenza Scadenza
                    HStack(spacing: 5) {
                        Image(systemName: dueInfo.icon)
                            .font(.system(size: 10, weight: .semibold))
                        Text(dueInfo.label)
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(dueInfo.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(dueInfo.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(dueInfo.color.opacity(dueInfo.isUrgent ? 0.28 : 0.12), lineWidth: 1)
                    )
                    .help(dueInfo.fullDate)
                    
                    // Chip File Locale collegato (se presente)
                    if let fileName = deadline.localFileName, let filePath = deadline.localFilePath {
                        Button {
                            AppSystemHelper.openLocalFile(path: filePath)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(themeManager.accentColor)
                                Text(fileName)
                                    .font(UniFont.caption())
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                Image(systemName: "arrow.up.forward.square")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3.5)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help(filePath)
                    }
                    
                    Spacer()
                }
                
                // RIGA 3: Note / Dettagli (anteprima a 2 righe, espandibile)
                if !deadline.notes.isEmpty {
                    Text(deadline.notes)
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                        .padding(.top, 1)
                }
                
                // SEZIONE ESPANSA: Allegati e link completi
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .padding(.vertical, 2)
                        
                        Text(localizationManager.text(it: "RISORSE & LINK WEB", en: "RESOURCES & WEB LINKS"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        
                        if !deadline.allLinks.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(deadline.allLinks, id: \.self) { link in
                                    HStack(spacing: 8) {
                                        Image(systemName: "link")
                                            .font(.system(size: 12))
                                            .foregroundStyle(themeManager.accentColor)
                                        Text(link)
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        
                                        Spacer()
                                        
                                        Button {
                                            AppSystemHelper.openWebURL(urlString: link)
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.up.forward.square")
                                                Text(localizationManager.text(it: "Apri", en: "Open"))
                                            }
                                            .font(UniFont.caption())
                                            .fontWeight(.medium)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .help(link)
                                    }
                                    .padding(8)
                                    .background(Color.primary.opacity(0.03))
                                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(Color.primary.opacity(0.08), lineWidth: 1))
                                }
                            }
                        } else {
                            Text(localizationManager.text(it: "Nessun link collegato a questa scadenza.", en: "No links linked to this deadline."))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .onAppear {
            if dataManager.expandedDeadlineId == deadline.id {
                isExpanded = true
            }
        }
        .onChange(of: dataManager.expandedDeadlineId) { _, targetId in
            if targetId == deadline.id {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let f = localizationManager.currentLanguage == .english ? DeadlinesView.dueDateFormatterEN : DeadlinesView.dueDateFormatterIT
        return f.string(from: date).capitalized
    }
    
    private func formatDueTime(_ date: Date) -> String {
        let timeStr = localizationManager.formatTime(date)
        return localizationManager.text(it: "Ore \(timeStr)", en: "At \(timeStr)")
    }
}

// MARK: - Modal Editor Scadenza (Polished Sheet)
struct DeadlineEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var deadlineToEdit: Deadline?
    var onSave: (Deadline) -> Void
    
    @State private var title: String = ""
    @State private var courseId: UUID? = nil
    @State private var dueDate: Date = Date().addingTimeInterval(86400 * 3)
    @State private var priority: Deadline.Priority = .medium
    @State private var notes: String = ""
    @State private var linkURLs: [String] = [""]
    @State private var localFilePath: String? = nil
    @State private var localFileName: String? = nil
    
    init(deadlineToEdit: Deadline?, initialDate: Date = Date(), onSave: @escaping (Deadline) -> Void) {
        self.deadlineToEdit = deadlineToEdit
        self.onSave = onSave
        _title = State(initialValue: deadlineToEdit?.title ?? "")
        _courseId = State(initialValue: deadlineToEdit?.courseId)
        _dueDate = State(initialValue: deadlineToEdit?.dueDate ?? initialDate)
        _priority = State(initialValue: deadlineToEdit?.priority ?? .medium)
        _notes = State(initialValue: deadlineToEdit?.notes ?? "")
        _localFilePath = State(initialValue: deadlineToEdit?.localFilePath)
        _localFileName = State(initialValue: deadlineToEdit?.localFileName)
        let existing = deadlineToEdit?.allLinks ?? []
        _linkURLs = State(initialValue: existing.isEmpty ? [""] : existing)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(deadlineToEdit == nil ? localizationManager.text(it: "Nuova Scadenza", en: "New Deadline") : localizationManager.text(it: "Modifica Scadenza", en: "Edit Deadline"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Imposta data, ora e priorità per non dimenticare la consegna", en: "Set date, time and priority to stay ahead of deadlines"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section(localizationManager.text(it: "Dettagli", en: "Details")) {
                    TextField(localizationManager.text(it: "Descrizione scadenza", en: "Deadline title"), text: $title)
                    
                    if !dataManager.courses.isEmpty {
                        Picker(localizationManager.text(it: "Materia Associata", en: "Associated Course"), selection: $courseId) {
                            Text(localizationManager.text(it: "Nessuna / Generale", en: "None / General")).tag(UUID?.none)
                            ForEach(dataManager.courses) { course in
                                Text(course.name).tag(UUID?.some(course.id))
                            }
                        }
                    }
                    
                    UniCustomDateTimePicker(selectedDate: $dueDate, label: localizationManager.text(it: "Data e Ora Scadenza", en: "Due Date & Time"))
                    
                    Picker(localizationManager.text(it: "Priorità", en: "Priority"), selection: $priority) {
                        ForEach(Deadline.Priority.allCases, id: \.self) { p in
                            Text(p.localizedName).tag(p)
                        }
                    }
                }
                
                Section(localizationManager.text(it: "Cartella o File Locale", en: "Local Folder or File")) {
                    UniFolderDropZoneView(
                        localFilePath: $localFilePath,
                        localFileName: $localFileName,
                        label: localizationManager.text(it: "Collega una cartella del progetto o file", en: "Link a project folder or file")
                    )
                }
                
                Section {
                    ForEach(linkURLs.indices, id: \.self) { idx in
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .font(.system(size: 11))
                                .foregroundStyle(themeManager.accentColor)
                            TextField(localizationManager.text(it: "https://... (sito, portale consegna o link esterno)", en: "https://... (website, submission portal or link)"), text: $linkURLs[idx])
                                .textFieldStyle(.plain)
                            
                            if linkURLs.count > 1 {
                                Button {
                                    linkURLs.remove(at: idx)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Rimuovi questo link", en: "Remove this link"))
                            }
                        }
                    }
                    
                    Button {
                        linkURLs.append("")
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13))
                            Text(localizationManager.text(it: "Aggiungi altro link", en: "Add another link"))
                                .font(UniFont.caption())
                        }
                        .foregroundStyle(themeManager.accentColor)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                } header: {
                    HStack {
                        Text(localizationManager.text(it: "Link & Risorse Web", en: "Links & Web Resources"))
                        Spacer()
                        Button {
                            linkURLs.append("")
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .padding(4)
                                .background(themeManager.accentColor.opacity(0.12), in: Circle())
                                .foregroundStyle(themeManager.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Aggiungi link (+)", en: "Add link (+)"))
                    }
                }
                
                Section(localizationManager.text(it: "Note", en: "Notes")) {
                    TextField(localizationManager.text(it: "Note aggiuntive (opzionale)", en: "Additional notes (optional)"), text: $notes)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Salva", en: "Save")) {
                    let cleanLinks = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    let updated = Deadline(
                        id: deadlineToEdit?.id ?? UUID(),
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        courseId: courseId,
                        dueDate: dueDate,
                        priority: priority,
                        isCompleted: deadlineToEdit?.isCompleted ?? false,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                        linkURL: cleanLinks.first,
                        linkURLs: cleanLinks,
                        localFilePath: localFilePath,
                        localFileName: localFileName
                    )
                    onSave(updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 480, height: 560)
    }
}
