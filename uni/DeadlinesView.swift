//
//  DeadlinesView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI

// MARK: - Unified Timeline Item
enum UnifiedTimelineItem: Identifiable {
    case deadline(Deadline)
    case assignment(Assignment)
    
    var id: String {
        switch self {
        case .deadline(let d): return "d-\(d.id.uuidString)"
        case .assignment(let a): return "a-\(a.id.uuidString)"
        }
    }
    
    var rawUUID: UUID {
        switch self {
        case .deadline(let d): return d.id
        case .assignment(let a): return a.id
        }
    }
    
    var dueDate: Date {
        switch self {
        case .deadline(let d): return d.dueDate
        case .assignment(let a): return a.dueDate
        }
    }
    
    var isCompleted: Bool {
        switch self {
        case .deadline(let d): return d.isCompleted
        case .assignment(let a): return a.isCompleted
        }
    }
    
    var courseId: UUID? {
        switch self {
        case .deadline(let d): return d.courseId
        case .assignment(let a): return a.courseId
        }
    }
    
    var isUrgent: Bool {
        switch self {
        case .deadline(let d):
            return !d.isCompleted && (d.priority == .high || (d.dueDate.timeIntervalSinceNow < 86400 * 3 && d.dueDate.timeIntervalSinceNow > -86400))
        case .assignment(let a):
            return !a.isCompleted && (a.dueDate.timeIntervalSinceNow < 86400 * 3 && a.dueDate.timeIntervalSinceNow > -86400)
        }
    }
}

// MARK: - Filter Enums
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

enum TimelineTypeFilter: String, CaseIterable {
    case all = "all"
    case deadlines = "deadlines"
    case assignments = "assignments"
    
    func title(with lm: LocalizationManager) -> String {
        switch self {
        case .all: return lm.text(it: "Tutti i tipi", en: "All types")
        case .deadlines: return lm.text(it: "Solo Scadenze", en: "Deadlines only")
        case .assignments: return lm.text(it: "Solo Consegne / Progetti", en: "Assignments only")
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .deadlines: return "clock"
        case .assignments: return "doc.text"
        }
    }
}

struct DeadlinesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var filterMode: DeadlineFilter = .pending
    @State private var typeFilter: TimelineTypeFilter = .all
    @State private var selectedCourseId: UUID? = nil
    @State private var searchText = ""
    @State private var isShowingFilterPopover = false
    
    // Sheets per Scadenze
    @State private var isPresentingNewDeadline = false
    @State private var deadlineToEdit: Deadline? = nil
    @State private var deadlineToDelete: Deadline? = nil
    
    // Sheets per Assignments / Progetti
    @State private var isPresentingNewAssignment = false
    @State private var assignmentToEdit: Assignment? = nil
    @State private var assignmentToDelete: Assignment? = nil
    
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
    
    private var selectedCourseName: String {
        if let id = selectedCourseId, let course = dataManager.courses.first(where: { $0.id == id }) {
            return course.name
        }
        return localizationManager.text(it: "Tutti i Corsi", en: "All Courses")
    }
    
    // MARK: - Unified Sorted Timeline Items (i più imminenti sopra)
    var filteredItems: [UnifiedTimelineItem] {
        var items: [UnifiedTimelineItem] = []
        
        if typeFilter == .all || typeFilter == .deadlines {
            items.append(contentsOf: dataManager.deadlines.map { UnifiedTimelineItem.deadline($0) })
        }
        if typeFilter == .all || typeFilter == .assignments {
            items.append(contentsOf: dataManager.assignments.map { UnifiedTimelineItem.assignment($0) })
        }
        
        switch filterMode {
        case .pending:
            items = items.filter { !$0.isCompleted }
        case .urgent:
            items = items.filter { $0.isUrgent }
        case .completed:
            items = items.filter { $0.isCompleted }
        case .all:
            break
        }
        
        if let courseId = selectedCourseId {
            items = items.filter { $0.courseId == courseId }
        }
        
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !clean.isEmpty {
            items = items.filter { item in
                let courseName = dataManager.courses.first(where: { $0.id == item.courseId })?.name ?? ""
                switch item {
                case .deadline(let d):
                    return d.title.localizedCaseInsensitiveContains(clean) ||
                           d.notes.localizedCaseInsensitiveContains(clean) ||
                           courseName.localizedCaseInsensitiveContains(clean) ||
                           d.priority.localizedName.localizedCaseInsensitiveContains(clean)
                case .assignment(let a):
                    return a.title.localizedCaseInsensitiveContains(clean) ||
                           a.details.localizedCaseInsensitiveContains(clean) ||
                           courseName.localizedCaseInsensitiveContains(clean)
                }
            }
        }
        
        // SEMPRE in ordine di scadenza: i più imminenti sopra!
        if filterMode == .completed {
            return items.sorted { $0.dueDate > $1.dueDate }
        } else {
            return items.sorted { $0.dueDate < $1.dueDate }
        }
    }
    
    private var activeDeadlinesCount: Int {
        dataManager.deadlines.filter { !$0.isCompleted }.count
    }
    
    private var pendingAssignmentsCount: Int {
        dataManager.assignments.filter { !$0.isCompleted }.count
    }
    
    private var isAnyFilterActive: Bool {
        filterMode != .pending || typeFilter != .all || selectedCourseId != nil
    }
    
    private var activeFiltersCount: Int {
        var count = 0
        if filterMode != .pending { count += 1 }
        if typeFilter != .all { count += 1 }
        if selectedCourseId != nil { count += 1 }
        return count
    }
    
    private var filterSummaryText: String {
        if !isAnyFilterActive {
            return localizationManager.text(it: "Filtri: In sospeso", en: "Filters: Pending")
        }
        var parts: [String] = []
        if filterMode != .pending {
            parts.append(filterMode.title(with: localizationManager))
        }
        if typeFilter != .all {
            parts.append(typeFilter.title(with: localizationManager))
        }
        if let id = selectedCourseId, let c = dataManager.courses.first(where: { $0.id == id }) {
            parts.append(c.name)
        }
        return parts.joined(separator: " • ")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header con pulsante per nuova scadenza o nuova consegna
                HStack(alignment: .top) {
                    UniHeader(
                        localizationManager.t(.deadlinesTitle),
                        subtitle: localizationManager.text(
                            it: "\(activeDeadlinesCount) scadenze • \(pendingAssignmentsCount) consegne in sospeso",
                            en: "\(activeDeadlinesCount) deadlines • \(pendingAssignmentsCount) assignments pending"
                        )
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Pulsante Condividi / Esporta PDF in stile nativo Apple
                        Button {
                            DeadlinesExportManager.shared.exportPDF(
                                items: filteredItems,
                                filterDescription: filterSummaryText,
                                dataManager: dataManager,
                                localizationManager: localizationManager
                            )
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.primary)
                                .frame(width: 30, height: 30)
                                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .focusEffectDisabled()
                        .help(localizationManager.text(it: "Condividi ed esporta scadenze in PDF", en: "Share and export deadlines as PDF"))
                        
                        // Pulsante Rapido Aggiungi (apre lo stesso modal del + nella navbar)
                        Button {
                            dataManager.isShowingProgressiveNewItem = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text(localizationManager.text(it: "Aggiungi...", en: "Add New..."))
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
                }
                
                // Filtri Dropdown Popover & Barra di Ricerca
                if !dataManager.deadlines.isEmpty || !dataManager.assignments.isEmpty {
                    HStack(spacing: 10) {
                        // Bottone Filtri Dropdown Popover (Larghezza stabile: evita lo spostamento dell'ancora popover!)
                        Button {
                            isShowingFilterPopover.toggle()
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: isAnyFilterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(isAnyFilterActive ? themeManager.accentColor : .secondary)
                                
                                Text(localizationManager.text(it: "Filtri", en: "Filters"))
                                    .font(UniFont.subheadline())
                                    .fontWeight(isAnyFilterActive ? .semibold : .medium)
                                    .foregroundStyle(isAnyFilterActive ? themeManager.accentColor : .primary)
                                
                                if isAnyFilterActive {
                                    Text("\(activeFiltersCount)")
                                        .font(.system(size: 9.5, weight: .bold))
                                        .foregroundStyle(themeManager.accentTextColor)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1.5)
                                        .background(themeManager.accentColor, in: Capsule())
                                }
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isAnyFilterActive ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(isAnyFilterActive ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.10), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .focusEffectDisabled()
                        .popover(isPresented: $isShowingFilterPopover, arrowEdge: .bottom) {
                            DeadlinesFilterPopoverView(
                                filterMode: $filterMode,
                                typeFilter: $typeFilter,
                                selectedCourseId: $selectedCourseId,
                                isPresented: $isShowingFilterPopover
                            )
                            .focusEffectDisabled()
                            .environmentObject(dataManager)
                            .environmentObject(themeManager)
                            .environmentObject(localizationManager)
                        }
                        
                        // Chip riassuntivo filtri attivi (posto all'esterno per non alterare la larghezza del popover)
                        if isAnyFilterActive {
                            HStack(spacing: 6) {
                                Text(filterSummaryText)
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                Button {
                                    filterMode = .pending
                                    typeFilter = .all
                                    selectedCourseId = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Azzera filtri", en: "Clear filters"))
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.primary.opacity(0.04), in: Capsule())
                        }
                        
                        Spacer()
                        
                        // Search Bar (Glasslike)
                        HStack(spacing: 7) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                            TextField(localizationManager.text(it: "Cerca scadenze o consegne...", en: "Search deadlines or assignments..."), text: $searchText)
                                .textFieldStyle(.plain)
                                .font(UniFont.subheadline())
                                .frame(width: 190)
                            
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
                
                // Lista Cronologica Unificata
                ScrollViewReader { scrollProxy in
                    Group {
                        if dataManager.deadlines.isEmpty && dataManager.assignments.isEmpty {
                            UniEmptyStateView(
                                icon: "checklist",
                                title: localizationManager.text(it: "Nessuna attività registrata", en: "No activities recorded"),
                                subtitle: localizationManager.text(it: "Aggiungi scadenze amministrative, tasse o progetti didattici.", en: "Add administrative deadlines, tuition fees or coursework projects."),
                                buttonTitle: localizationManager.text(it: "Aggiungi Attività", en: "Add Activity")
                            ) {
                                dataManager.isShowingProgressiveNewItem = true
                            }
                        } else if filteredItems.isEmpty {
                            UniEmptyStateView(
                                icon: "checkmark.circle",
                                title: localizationManager.text(it: "Nessun elemento trovato", en: "No matching items"),
                                subtitle: localizationManager.t(.upToDate)
                            )
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    switch item {
                                    case .deadline(let deadline):
                                        DeadlineCardView(
                                            deadline: deadline,
                                            onToggleComplete: { toggleCompleteDeadline(deadline) },
                                            onEdit: { deadlineToEdit = deadline },
                                            onDelete: { deadlineToDelete = deadline }
                                        )
                                        .id(item.id)
                                        
                                    case .assignment(let assignment):
                                        AssignmentCardView(
                                            assignment: assignment,
                                            onToggleComplete: { toggleCompleteAssignment(assignment) },
                                            onUpdateStatus: { newStatus in updateAssignmentStatus(newStatus, for: assignment) },
                                            onEdit: { assignmentToEdit = assignment },
                                            onDelete: { assignmentToDelete = assignment },
                                            onPickFile: { pickLocalFile(for: assignment) },
                                            onRemoveFile: { removeLocalFile(for: assignment) },
                                            onAttachFileURL: { url in attachFile(url, to: assignment) }
                                        )
                                        .id(item.id)
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        handleTargetScroll(scrollProxy: scrollProxy)
                    }
                    .onChange(of: dataManager.expandedDeadlineId) { _, _ in
                        handleTargetScroll(scrollProxy: scrollProxy)
                    }
                    .onChange(of: dataManager.expandedAssignmentId) { _, _ in
                        handleTargetScroll(scrollProxy: scrollProxy)
                    }
                }
            }
            .padding(24)
        }
        // Sheets Scadenza
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
        // Sheets Assignment
        .sheet(isPresented: $isPresentingNewAssignment) {
            AssignmentEditorSheet(assignmentToEdit: nil) { newOne in
                dataManager.assignments.append(newOne)
                dataManager.saveData()
                
                let courseName = dataManager.courses.first(where: { $0.id == newOne.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(assignment: newOne, courseName: courseName) }
                
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Progetto / Consegna creata", en: "Assignment created"),
                    message: newOne.title,
                    type: .success,
                    icon: "doc.badge.plus"
                )
            }
        }
        .sheet(item: $assignmentToEdit) { assignment in
            AssignmentEditorSheet(assignmentToEdit: assignment) { updated in
                if let idx = dataManager.assignments.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.assignments[idx] = updated
                    dataManager.saveData()
                    
                    let courseName = dataManager.courses.first(where: { $0.id == updated.courseId })?.name
                    Task { await AppleCalendarManager.shared.sync(assignment: updated, courseName: courseName) }
                    
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Progetto aggiornato", en: "Assignment updated"),
                        message: updated.title,
                        type: .info,
                        icon: "doc.text"
                    )
                }
            }
        }
        // Alerts Eliminazione
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
        .alert(
            localizationManager.text(it: "Elimina Progetto / Consegna", en: "Delete Assignment"),
            isPresented: Binding(get: { assignmentToDelete != nil }, set: { if !$0 { assignmentToDelete = nil } }),
            presenting: assignmentToDelete
        ) { asg in
            Button(localizationManager.t(.cancel), role: .cancel) {
                assignmentToDelete = nil
            }
            Button(localizationManager.t(.delete), role: .destructive) {
                deleteAssignment(asg)
                assignmentToDelete = nil
            }
        } message: { asg in
            Text(localizationManager.text(
                it: "Sei sicuro di voler eliminare \"\(asg.title)\"? L'operazione non può essere annullata.",
                en: "Are you sure you want to delete \"\(asg.title)\"? This action cannot be undone."
            ))
        }
        .onAppear {
            handleNavigationTargets()
        }
        .onChange(of: dataManager.selectedDeadlineId) { _, _ in handleNavigationTargets() }
        .onChange(of: dataManager.selectedAssignmentId) { _, _ in handleNavigationTargets() }
    }
    
    // MARK: - Navigation Target Handlers
    private func handleNavigationTargets() {
        if let targetId = dataManager.selectedDeadlineId,
           let found = dataManager.deadlines.first(where: { $0.id == targetId }) {
            deadlineToEdit = found
            dataManager.selectedDeadlineId = nil
        } else if let targetAsgId = dataManager.selectedAssignmentId,
                  let found = dataManager.assignments.first(where: { $0.id == targetAsgId }) {
            assignmentToEdit = found
            dataManager.selectedAssignmentId = nil
        }
    }
    
    private func handleTargetScroll(scrollProxy: ScrollViewProxy) {
        if let expId = dataManager.expandedDeadlineId {
            dataManager.expandedDeadlineId = nil
            let targetKey = "d-\(expId.uuidString)"
            if let deadline = dataManager.deadlines.first(where: { $0.id == expId }), deadline.isCompleted && filterMode == .pending {
                filterMode = .all
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    scrollProxy.scrollTo(targetKey, anchor: .center)
                }
            }
        } else if let expAsgId = dataManager.expandedAssignmentId {
            dataManager.expandedAssignmentId = nil
            let targetKey = "a-\(expAsgId.uuidString)"
            if let assignment = dataManager.assignments.first(where: { $0.id == expAsgId }), assignment.isCompleted && filterMode == .pending {
                filterMode = .all
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    scrollProxy.scrollTo(targetKey, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Deadline Actions
    private func toggleCompleteDeadline(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            dataManager.deadlines[idx].isCompleted.toggle()
            let isNowCompleted = dataManager.deadlines[idx].isCompleted
            let updatedDeadline = dataManager.deadlines[idx]
            dataManager.saveData()
            
            let courseName = dataManager.courses.first(where: { $0.id == updatedDeadline.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(deadline: updatedDeadline, courseName: courseName) }
            
            SoundManager.shared.play(isNowCompleted ? .success : .pop)
            
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
    
    // MARK: - Assignment Actions
    private func toggleCompleteAssignment(_ assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            dataManager.assignments[idx].isCompleted.toggle()
            let completed = dataManager.assignments[idx].isCompleted
            dataManager.assignments[idx].status = completed ? .completed : .inProgress
            let updated = dataManager.assignments[idx]
            dataManager.saveData()
            
            let courseName = dataManager.courses.first(where: { $0.id == updated.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(assignment: updated, courseName: courseName) }
            
            SoundManager.shared.play(completed ? .success : .pop)
            
            NotificationManager.shared.notify(
                title: completed ? localizationManager.text(it: "Progetto completato! 🎉", en: "Assignment completed! 🎉") : localizationManager.text(it: "Progetto riaperto", en: "Assignment reopened"),
                message: assignment.title,
                type: completed ? .success : .info,
                icon: completed ? "checkmark.circle.fill" : "circle",
                postToSystem: true
            )
        }
    }
    
    private func updateAssignmentStatus(_ status: AssignmentStatus, for assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            dataManager.assignments[idx].status = status
            dataManager.assignments[idx].isCompleted = (status == .completed)
            let updated = dataManager.assignments[idx]
            dataManager.saveData()
            
            let courseName = dataManager.courses.first(where: { $0.id == updated.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(assignment: updated, courseName: courseName) }
            
            SoundManager.shared.play(status == .completed ? .success : .pop)
            
            NotificationManager.shared.notify(
                title: status.localized(with: localizationManager),
                message: assignment.title,
                type: status == .completed ? .success : .info,
                icon: status.iconName
            )
        }
    }
    
    private func deleteAssignment(_ assignment: Assignment) {
        SoundManager.shared.play(.remove)
        dataManager.assignments.removeAll { $0.id == assignment.id }
        dataManager.saveData()
        
        Task { await AppleCalendarManager.shared.remove(assignmentId: assignment.id) }
        
        NotificationManager.shared.notify(
            title: localizationManager.text(it: "Progetto eliminato", en: "Assignment removed"),
            message: assignment.title,
            type: .warning,
            icon: "trash"
        )
    }
    
    private func attachFile(_ url: URL, to assignment: Assignment) {
        SoundManager.shared.play(.pop)
        let path = url.path
        let name = url.lastPathComponent
        let size = AppSystemHelper.formatFileSize(atPath: path)
        
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            dataManager.assignments[idx].localFilePath = path
            dataManager.assignments[idx].localFileName = name
            dataManager.assignments[idx].localFileSize = size.isEmpty ? nil : size
            dataManager.saveData()
            
            NotificationManager.shared.notify(
                title: localizationManager.text(it: "File collegato con successo! 📎", en: "File attached! 📎"),
                message: "\(name) associato a '\(assignment.title)'",
                type: .success,
                icon: "paperclip",
                postToSystem: true
            )
        }
    }
    
    private func pickLocalFile(for assignment: Assignment) {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = localizationManager.text(it: "Collega File", en: "Attach File")
        panel.message = localizationManager.text(it: "Seleziona il file o la cartella del progetto dal tuo Mac", en: "Select file or folder for assignment")
        
        if panel.runModal() == .OK, let url = panel.url {
            attachFile(url, to: assignment)
        }
        #endif
    }
    
    private func removeLocalFile(for assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            let oldName = dataManager.assignments[idx].localFileName ?? "file"
            dataManager.assignments[idx].localFilePath = nil
            dataManager.assignments[idx].localFileName = nil
            dataManager.assignments[idx].localFileSize = nil
            dataManager.saveData()
            
            NotificationManager.shared.notify(
                title: localizationManager.text(it: "File scollegato", en: "File removed"),
                message: "\(oldName) rimosso da '\(assignment.title)'",
                type: .info,
                icon: "xmark.bin"
            )
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let f = localizationManager.currentLanguage == .english ? Self.dueDateFormatterEN : Self.dueDateFormatterIT
        return f.string(from: date).capitalized
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
                    
                    // Importo / Tassa (se presente)
                    if let amount = deadline.amount {
                        HStack(spacing: 3) {
                            Image(systemName: "eurosign.circle.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(String(format: "%.2f €", amount))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(deadline.isCompleted ? .secondary : themeManager.accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background((deadline.isCompleted ? Color.secondary : themeManager.accentColor).opacity(0.12), in: Capsule())
                    }
                    
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
    @State private var amountString: String = ""
    
    init(deadlineToEdit: Deadline?, initialDate: Date = Date(), initialCourseId: UUID? = nil, onSave: @escaping (Deadline) -> Void) {
        self.deadlineToEdit = deadlineToEdit
        self.onSave = onSave
        _title = State(initialValue: deadlineToEdit?.title ?? "")
        _courseId = State(initialValue: deadlineToEdit?.courseId ?? initialCourseId)
        _dueDate = State(initialValue: deadlineToEdit?.dueDate ?? initialDate)
        _priority = State(initialValue: deadlineToEdit?.priority ?? .medium)
        _notes = State(initialValue: deadlineToEdit?.notes ?? "")
        _localFilePath = State(initialValue: deadlineToEdit?.localFilePath)
        _localFileName = State(initialValue: deadlineToEdit?.localFileName)
        if let a = deadlineToEdit?.amount {
            _amountString = State(initialValue: String(format: "%.2f", a))
        } else {
            _amountString = State(initialValue: "")
        }
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
                    Text(localizationManager.text(it: "Adempimento amministrativo, tasse, ISEE, piano di studi o promemoria", en: "Administrative task, tuition fees, study plan, or calendar reminder"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section(localizationManager.text(it: "Dettagli", en: "Details")) {
                    TextField(localizationManager.text(it: "Es. Seconda rata tasse, ISEE, Domanda di laurea...", en: "e.g. Tuition fee, Study plan, Degree application..."), text: $title)
                    
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
                    
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundStyle(themeManager.accentColor)
                        TextField(localizationManager.text(it: "Importo / Tassa (€, opzionale)", en: "Fee / Amount (€, optional)"), text: $amountString)
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
                    let parsedAmount = Double(amountString.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines))
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
                        localFileName: localFileName,
                        amount: parsedAmount
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

// MARK: - Deadlines Filter Popover View
struct DeadlinesFilterPopoverView: View {
    @Binding var filterMode: DeadlineFilter
    @Binding var typeFilter: TimelineTypeFilter
    @Binding var selectedCourseId: UUID?
    @Binding var isPresented: Bool
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header del Popover
            HStack {
                Text(localizationManager.text(it: "Filtra Attività", en: "Filter Activities"))
                    .font(UniFont.headline())
                Spacer()
                if filterMode != .pending || typeFilter != .all || selectedCourseId != nil {
                    Button(localizationManager.text(it: "Reimposta", en: "Reset")) {
                        filterMode = .pending
                        typeFilter = .all
                        selectedCourseId = nil
                    }
                    .font(UniFont.caption())
                    .buttonStyle(.plain)
                    .foregroundStyle(themeManager.accentColor)
                }
            }
            
            Divider()
            
            // 1. STATO
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "STATO", en: "STATUS"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                
                ForEach(DeadlineFilter.allCases, id: \.self) { f in
                    DeadlinesFilterPopoverRow(
                        title: f.title(with: localizationManager),
                        isSelected: filterMode == f,
                        action: {
                            filterMode = f
                        }
                    )
                }
            }
            
            Divider()
            
            // 2. TIPOLOGIA
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.text(it: "TIPOLOGIA", en: "TYPE"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                
                ForEach(TimelineTypeFilter.allCases, id: \.self) { t in
                    DeadlinesFilterPopoverRow(
                        title: t.title(with: localizationManager),
                        iconName: t.iconName,
                        isSelected: typeFilter == t,
                        action: {
                            typeFilter = t
                        }
                    )
                }
            }
            
            if !dataManager.courses.isEmpty {
                Divider()
                
                // 3. MATERIA
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.text(it: "MATERIA", en: "COURSE"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                    
                    Menu {
                        Button {
                            selectedCourseId = nil
                        } label: {
                            HStack {
                                Text(localizationManager.text(it: "Tutte le Materie", en: "All Courses"))
                                if selectedCourseId == nil { Image(systemName: "checkmark") }
                            }
                        }
                        
                        Divider()
                        
                        ForEach(dataManager.courses) { course in
                            Button {
                                selectedCourseId = course.id
                            } label: {
                                HStack {
                                    Text(course.name)
                                    if selectedCourseId == course.id { Image(systemName: "checkmark") }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCourseId == nil ? localizationManager.text(it: "Tutte le Materie", en: "All Courses") : (dataManager.courses.first(where: { $0.id == selectedCourseId })?.name ?? ""))
                                .font(UniFont.subheadline())
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .contentShape(Rectangle())
                    }
                    .menuStyle(.borderlessButton)
                    .focusable(false)
                    .focusEffectDisabled()
                }
            }
        }
        .padding(14)
        .frame(width: 255)
    }
}

// MARK: - Riga Interattiva Popover con Area Click Estesa al Riquadro
struct DeadlinesFilterPopoverRow: View {
    let title: String
    var iconName: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                        .frame(width: 14)
                }
                
                Text(title)
                    .font(UniFont.subheadline())
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? themeManager.accentColor : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(isSelected ? themeManager.accentColor.opacity(0.12) : (isHovered ? Color.primary.opacity(0.06) : Color.clear))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .focusEffectDisabled()
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

