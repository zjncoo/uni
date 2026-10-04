//
//  AssignmentsView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

struct AssignmentsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var filterCompleted = false
    @State private var selectedCourseId: UUID? = nil
    @State private var searchText = ""
    @State private var isPresentingNewAssignment = false
    @State private var assignmentToEdit: Assignment? = nil
    @State private var assignmentToDelete: Assignment? = nil
    
    fileprivate static let dueFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "EEEE d MMMM yyyy, 'ore' HH:mm"
        return f
    }()
    
    fileprivate static let dueFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
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
    
    var filteredAssignments: [Assignment] {
        var base = dataManager.assignments
            .filter { filterCompleted ? $0.isCompleted : !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
        
        if let courseId = selectedCourseId {
            base = base.filter { $0.courseId == courseId }
        }
        
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty {
            return base
        }
        return base.filter { assignment in
            let courseName = dataManager.courses.first(where: { $0.id == assignment.courseId })?.name ?? ""
            let fileName = assignment.localFileName ?? ""
            return assignment.title.localizedCaseInsensitiveContains(clean) ||
                   assignment.details.localizedCaseInsensitiveContains(clean) ||
                   courseName.localizedCaseInsensitiveContains(clean) ||
                   fileName.localizedCaseInsensitiveContains(clean)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header con pulsante per nuovo assignment
                HStack(alignment: .top) {
                    UniHeader(
                        localizationManager.t(.assignmentsTitle),
                        subtitle: localizationManager.t(.assignmentsSubtitle(
                            dataManager.assignments.filter { !$0.isCompleted }.count,
                            dataManager.assignments.filter { $0.isCompleted }.count
                        ))
                    )
                    
                    Spacer()
                    
                    Button {
                        isPresentingNewAssignment = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text(localizationManager.t(.newAssignmentAction))
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
                if !dataManager.assignments.isEmpty {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            filterTab(title: localizationManager.t(.inProgress), active: !filterCompleted) {
                                filterCompleted = false
                            }
                            filterTab(title: localizationManager.t(.completed), active: filterCompleted) {
                                filterCompleted = true
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
                            TextField(localizationManager.text(it: "Cerca assignments...", en: "Search assignments..."), text: $searchText)
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
                        if dataManager.assignments.isEmpty {
                            UniEmptyStateView(
                                icon: "doc.text.badge.plus",
                                title: localizationManager.t(.noAssignmentsEmptyTitle),
                                subtitle: localizationManager.t(.noAssignmentsEmptyDesc),
                                buttonTitle: localizationManager.t(.newAssignmentAction)
                            ) {
                                isPresentingNewAssignment = true
                            }
                        } else if filteredAssignments.isEmpty {
                            UniEmptyStateView(
                                icon: filterCompleted ? "checkmark.circle" : "tray",
                                title: filterCompleted ? (localizationManager.currentLanguage == .italian ? "Nessun assignment completato" : "No completed assignments") : localizationManager.t(.allAssignmentsCompleted),
                                subtitle: filterCompleted ? (localizationManager.currentLanguage == .italian ? "I progetti completati compariranno qui." : "Completed projects will appear here.") : (localizationManager.currentLanguage == .italian ? "Nessun compito in sospeso." : "No pending assignments.")
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAssignments) { assignment in
                                    AssignmentCardView(
                                        assignment: assignment,
                                        onToggleComplete: { toggleComplete(assignment) },
                                        onUpdateStatus: { newStatus in updateStatus(newStatus, for: assignment) },
                                        onEdit: { assignmentToEdit = assignment },
                                        onDelete: { assignmentToDelete = assignment },
                                        onPickFile: { pickLocalFile(for: assignment) },
                                        onRemoveFile: { removeLocalFile(for: assignment) },
                                        onAttachFileURL: { url in attachFile(url, to: assignment) }
                                    )
                                    .id(assignment.id)
                                }
                            }
                        }
                    }
                    .onAppear {
                        if let expId = dataManager.expandedAssignmentId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    scrollProxy.scrollTo(expId, anchor: .center)
                                }
                            }
                        }
                    }
                    .onChange(of: dataManager.expandedAssignmentId) { _, newId in
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
        .sheet(isPresented: $isPresentingNewAssignment) {
            AssignmentEditorSheet(assignmentToEdit: nil) { newOne in
                dataManager.assignments.append(newOne)
                dataManager.saveData()
                
                let courseName = dataManager.courses.first(where: { $0.id == newOne.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(assignment: newOne, courseName: courseName) }
                
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Assignment creato", en: "Assignment created"),
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
                        title: localizationManager.text(it: "Assignment aggiornato", en: "Assignment updated"),
                        message: updated.title,
                        type: .info,
                        icon: "doc.text"
                    )
                }
            }
        }
        .alert(
            localizationManager.text(it: "Elimina Progetto / Compito", en: "Delete Assignment"),
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
            handleSelectedOrExpandedAssignment()
        }
        .onChange(of: dataManager.selectedAssignmentId) { _, _ in
            handleSelectedOrExpandedAssignment()
        }
        .onChange(of: dataManager.expandedAssignmentId) { _, _ in
            handleSelectedOrExpandedAssignment()
        }
    }
    
    private func handleSelectedOrExpandedAssignment() {
        if let expId = dataManager.expandedAssignmentId {
            if let found = dataManager.assignments.first(where: { $0.id == expId }) {
                searchText = ""
                selectedCourseId = nil
                filterCompleted = found.isCompleted
            }
        } else if let targetId = dataManager.selectedAssignmentId,
                  let found = dataManager.assignments.first(where: { $0.id == targetId }) {
            assignmentToEdit = found
            dataManager.selectedAssignmentId = nil
        }
    }
    
    private func filterTab(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(UniFont.subheadline())
                .fontWeight(active ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(active ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                .foregroundStyle(active ? themeManager.accentColor : .primary)
                .overlay(Rectangle().stroke(active ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1))
                .clipShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func toggleComplete(_ assignment: Assignment) {
        if let idx = dataManager.assignments.firstIndex(where: { $0.id == assignment.id }) {
            dataManager.assignments[idx].isCompleted.toggle()
            let completed = dataManager.assignments[idx].isCompleted
            dataManager.assignments[idx].status = completed ? .completed : .inProgress
            let updated = dataManager.assignments[idx]
            dataManager.saveData()
            
            let courseName = dataManager.courses.first(where: { $0.id == updated.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(assignment: updated, courseName: courseName) }
            
            if completed {
                SoundManager.shared.play(.success)
            } else {
                SoundManager.shared.play(.pop)
            }
            
            NotificationManager.shared.notify(
                title: completed ? localizationManager.text(it: "Assignment completato! 🎉", en: "Assignment completed! 🎉") : localizationManager.text(it: "Assignment riaperto", en: "Assignment reopened"),
                message: assignment.title,
                type: completed ? .success : .info,
                icon: completed ? "checkmark.circle.fill" : "circle",
                postToSystem: true
            )
        }
    }
    
    private func updateStatus(_ status: AssignmentStatus, for assignment: Assignment) {
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
            title: localizationManager.text(it: "Assignment rimosso", en: "Assignment removed"),
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
                title: "File collegato con successo! 📎",
                message: "\(name) (\(size.isEmpty ? "file" : size)) associato ad '\(assignment.title)'",
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
        panel.prompt = "Collega File"
        panel.message = "Seleziona il file o la cartella dell'assignment dal tuo Mac"
        
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
                title: "File scollegato",
                message: "\(oldName) rimosso da '\(assignment.title)'",
                type: .info,
                icon: "xmark.bin"
            )
        }
    }
}

// MARK: - Assignment Card
struct AssignmentCardView: View {
    let assignment: Assignment
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var onToggleComplete: () -> Void
    var onUpdateStatus: (AssignmentStatus) -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onPickFile: () -> Void
    var onRemoveFile: () -> Void
    var onAttachFileURL: (URL) -> Void
    
    @State private var isExpanded = false
    @State private var isDropTargeted = false
    
    private struct DuePillInfo {
        let label: String
        let fullDate: String
        let icon: String
        let color: Color
        let isUrgent: Bool
    }
    
    private var dueInfo: DuePillInfo {
        let date = assignment.dueDate
        let isEn = localizationManager.currentLanguage == .english
        let fullFormatter = isEn ? AssignmentsView.dueFormatterEN : AssignmentsView.dueFormatterIT
        let fullStr = fullFormatter.string(from: date).capitalized
        
        if assignment.isCompleted {
            return DuePillInfo(
                label: localizationManager.text(it: "Completato", en: "Completed"),
                fullDate: fullStr,
                icon: "checkmark.circle.fill",
                color: .green,
                isUrgent: false
            )
        }
        
        let calendar = Calendar.current
        let now = Date()
        let timeStr = localizationManager.formatTime(date)
        let dmFormatter = isEn ? AssignmentsView.dayMonthFormatterEN : AssignmentsView.dayMonthFormatterIT
        let dmStr = dmFormatter.string(from: date)
        
        if date < now {
            let diff = calendar.dateComponents([.day, .hour], from: date, to: now)
            let days = diff.day ?? 0
            let hours = diff.hour ?? 0
            let label = days > 0
                ? localizationManager.text(it: "Scaduto da \(days)g", en: "Overdue by \(days)d")
                : localizationManager.text(it: "Scaduto da \(max(1, hours))h", en: "Overdue by \(max(1, hours))h")
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
                    color: themeManager.accentColor,
                    isUrgent: false
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
                // RIGA 1: Checkbox, Corso, Titolo, Peso, Spacer, Hand In button, Stato, Edit, Elimina, Espansione
                HStack(alignment: .center, spacing: 10) {
                    // Checkbox
                    Button(action: onToggleComplete) {
                        Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(assignment.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(assignment.isCompleted ? localizationManager.text(it: "Segna come da completare", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completato", en: "Mark as completed"))
                    
                    // Corso Badge
                    if let course = dataManager.courses.first(where: { $0.id == assignment.courseId }) {
                        UniBadge(course.name, color: Color(hex: course.colorHex) ?? themeManager.accentColor)
                    }
                    
                    // Titolo
                    Text(assignment.title)
                        .font(UniFont.headline())
                        .strikethrough(assignment.isCompleted)
                        .lineLimit(1)
                    
                    // Peso %
                    if assignment.weightPercent > 0 {
                        Text("\(assignment.weightPercent)%")
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.accentColor.opacity(0.1))
                            .foregroundStyle(themeManager.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    
                    Spacer(minLength: 8)
                    
                    // PULSANTE "HAND IN ↗" (Mostrato subito senza espandere!)
                    if let firstLink = assignment.allLinks.first {
                        HStack(spacing: 3) {
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
                                .padding(.vertical, 5)
                                .background(themeManager.accentColor)
                                .foregroundStyle(themeManager.accentTextColor)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .shadow(color: themeManager.accentColor.opacity(0.25), radius: 3, y: 1)
                            }
                            .buttonStyle(.plain)
                            .help(firstLink)
                            
                            // Se ci sono più link, menu rapido compatto
                            if assignment.allLinks.count > 1 {
                                Menu {
                                    ForEach(assignment.allLinks, id: \.self) { link in
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
                                        Text("+\(assignment.allLinks.count - 1)")
                                            .font(.system(size: 10, weight: .semibold))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 7))
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                    .background(themeManager.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    .foregroundStyle(themeManager.accentColor)
                                }
                                .menuStyle(.borderlessButton)
                                .help(localizationManager.text(it: "Tutti i link (\(assignment.allLinks.count))", en: "All links (\(assignment.allLinks.count))"))
                            }
                        }
                    }
                    
                    // Menu a tendina per lo Stato
                    Menu {
                        Button {
                            onUpdateStatus(.notStarted)
                        } label: {
                            Label(localizationManager.text(it: "Non ancora iniziato", en: "Not Started"), systemImage: "circle.dashed")
                        }
                        
                        Button {
                            onUpdateStatus(.inProgress)
                        } label: {
                            Label(localizationManager.text(it: "In corso", en: "In Progress"), systemImage: "hourglass")
                        }
                        
                        Button {
                            onUpdateStatus(.completed)
                        } label: {
                            Label(localizationManager.text(it: "Completato", en: "Completed"), systemImage: "checkmark.circle.fill")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: assignment.status.iconName)
                                .font(.system(size: 9, weight: .semibold))
                            Text(assignment.status.localized(with: localizationManager))
                                .font(UniFont.caption())
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(assignment.status.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(assignment.status.color.opacity(0.28), lineWidth: 1)
                        )
                        .foregroundStyle(assignment.status.color)
                    }
                    .menuStyle(.borderlessButton)
                    
                    // Pulsante Modifica rapido
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 24, height: 24)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Modifica assignment", en: "Edit assignment"))
                    
                    // Pulsante Elimina rapido
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundStyle(.red.opacity(0.85))
                            .frame(width: 24, height: 24)
                            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(localizationManager.text(it: "Elimina assignment", en: "Delete assignment"))
                    
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
                    
                    // Chip File Locale collegato (immediatamente apribile al click!)
                    if let fileName = assignment.localFileName, let filePath = assignment.localFilePath {
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
                                if let size = assignment.localFileSize {
                                    Text("(\(size))")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
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
                
                // RIGA 3: Dettagli / Note (anteprima a 2 righe, espandibile)
                if !assignment.details.isEmpty {
                    Text(assignment.details)
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                        .padding(.top, 1)
                }
                
                // SEZIONE ESPANSA: Gestione avanzata file e link completi
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .padding(.vertical, 2)
                        
                        Text(localizationManager.text(it: "RISORSE & FILE LOCALI", en: "RESOURCES & LOCAL FILES"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        
                        // File collegato o Dropzone interattiva
                        HStack(spacing: 10) {
                            if let fileName = assignment.localFileName, let filePath = assignment.localFilePath {
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(themeManager.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        HStack(spacing: 5) {
                                            Text(fileName)
                                                .font(UniFont.headline())
                                                .lineLimit(1)
                                            if let size = assignment.localFileSize {
                                                Text("(\(size))")
                                                    .font(UniFont.caption())
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Text(filePath)
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Button {
                                        AppSystemHelper.openLocalFile(path: filePath)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up.forward.square")
                                            Text(localizationManager.text(it: "Apri File", en: "Open File"))
                                        }
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(themeManager.accentColor)
                                    
                                    Button {
                                        AppSystemHelper.revealInFinder(path: filePath)
                                    } label: {
                                        Image(systemName: "folder")
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(.bordered)
                                    .help(localizationManager.text(it: "Mostra in Finder", en: "Reveal in Finder"))
                                    
                                    Button(action: onPickFile) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(.bordered)
                                    .help(localizationManager.text(it: "Sostituisci file", en: "Replace file"))
                                    
                                    Button(role: .destructive, action: onRemoveFile) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(.bordered)
                                    .help(localizationManager.text(it: "Scollega file", en: "Unlink file"))
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "paperclip")
                                        .font(.system(size: 12))
                                        .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                                    
                                    Text(isDropTargeted ? localizationManager.text(it: "Rilascia qui il file per collegarlo!", en: "Drop file here to link it!") : localizationManager.text(it: "Trascina qui un file dal Mac o selezionalo...", en: "Drag and drop a file from your Mac or browse..."))
                                        .font(UniFont.caption())
                                        .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                                        .fontWeight(isDropTargeted ? .semibold : .regular)
                                }
                                
                                Spacer()
                                
                                Button(action: onPickFile) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus.square.dashed")
                                        Text(localizationManager.text(it: "Sfoglia...", en: "Browse..."))
                                    }
                                    .font(UniFont.caption())
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(10)
                        .background(
                            Rectangle()
                                .fill(isDropTargeted ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.03))
                        )
                        .overlay(
                            Rectangle()
                                .strokeBorder(
                                    isDropTargeted ? themeManager.accentColor : Color.primary.opacity(0.06),
                                    style: StrokeStyle(lineWidth: isDropTargeted ? 2 : 1, dash: isDropTargeted ? [4] : [])
                                )
                        )
                        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                            guard let provider = providers.first else { return false }
                            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                                if let url = url {
                                    DispatchQueue.main.async {
                                        onAttachFileURL(url)
                                    }
                                }
                            }
                            return true
                        }
                        
                        // Lista completa dei link web
                        if !assignment.allLinks.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(assignment.allLinks, id: \.self) { link in
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
                                    .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                                    .clipShape(Rectangle())
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .onAppear {
            if dataManager.expandedAssignmentId == assignment.id {
                isExpanded = true
            }
        }
        .onChange(of: dataManager.expandedAssignmentId) { _, targetId in
            if targetId == assignment.id {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
    }
}

// MARK: - Modal Editor Assignment (Polished Sheet)
struct AssignmentEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var assignmentToEdit: Assignment?
    var onSave: (Assignment) -> Void
    
    @State private var title: String = ""
    @State private var courseId: UUID = UUID()
    @State private var dueDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var details: String = ""
    @State private var weightPercent: Int = 0
    @State private var linkURLs: [String] = [""]
    @State private var status: AssignmentStatus = .notStarted
    @State private var localFilePath: String? = nil
    @State private var localFileName: String? = nil
    
    init(assignmentToEdit: Assignment?, onSave: @escaping (Assignment) -> Void) {
        self.assignmentToEdit = assignmentToEdit
        self.onSave = onSave
        _title = State(initialValue: assignmentToEdit?.title ?? "")
        _courseId = State(initialValue: assignmentToEdit?.courseId ?? UUID())
        _dueDate = State(initialValue: assignmentToEdit?.dueDate ?? Date().addingTimeInterval(86400 * 7))
        _details = State(initialValue: assignmentToEdit?.details ?? "")
        _weightPercent = State(initialValue: assignmentToEdit?.weightPercent ?? 0)
        let existing = assignmentToEdit?.allLinks ?? []
        _linkURLs = State(initialValue: existing.isEmpty ? [""] : existing)
        _status = State(initialValue: assignmentToEdit?.status ?? .notStarted)
        _localFilePath = State(initialValue: assignmentToEdit?.localFilePath)
        _localFileName = State(initialValue: assignmentToEdit?.localFileName)
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
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(assignmentToEdit == nil ? localizationManager.text(it: "Nuovo Assignment", en: "New Assignment") : localizationManager.text(it: "Modifica Assignment", en: "Edit Assignment"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Definisci la scadenza e le specifiche di consegna", en: "Set deadline and submission specifications"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            // Form
            Form {
                Section(localizationManager.text(it: "Dettagli", en: "Details")) {
                    TextField(localizationManager.text(it: "Titolo Assignment", en: "Assignment Title"), text: $title)
                    
                    if !dataManager.courses.isEmpty {
                        Picker(localizationManager.text(it: "Materia", en: "Course"), selection: $courseId) {
                            ForEach(dataManager.courses) { course in
                                Text(course.name).tag(course.id)
                            }
                        }
                    }
                    
                    Picker(localizationManager.text(it: "Stato", en: "Status"), selection: $status) {
                        ForEach(AssignmentStatus.allCases, id: \.self) { s in
                            Text(s.localized(with: localizationManager)).tag(s)
                        }
                    }
                    
                    UniCustomDateTimePicker(selectedDate: $dueDate, label: localizationManager.text(it: "Data e Ora di Consegna", en: "Due Date & Time"))
                    Stepper(localizationManager.text(it: "Peso sul voto: \(weightPercent)%", en: "Grade Weight: \(weightPercent)%"), value: $weightPercent, in: 0...100, step: 5)
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
                            TextField(localizationManager.text(it: "https://... (sito consegna, repository o specifiche)", en: "https://... (submission portal, repo or specs)"), text: $linkURLs[idx])
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
                
                Section(localizationManager.text(it: "Istruzioni / Note", en: "Instructions / Notes")) {
                    TextField(localizationManager.text(it: "Istruzioni o note per la consegna", en: "Instructions or notes for submission"), text: $details)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            // Footer
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Salva", en: "Save")) {
                    let cleanLinks = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    let updated = Assignment(
                        id: assignmentToEdit?.id ?? UUID(),
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        courseId: courseId,
                        dueDate: dueDate,
                        details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                        weightPercent: weightPercent,
                        isCompleted: status == .completed,
                        status: status,
                        localFilePath: localFilePath,
                        localFileName: localFileName,
                        localFileSize: assignmentToEdit?.localFileSize,
                        linkURL: cleanLinks.first,
                        linkURLs: cleanLinks
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
        .frame(width: 500, height: 570)
        .onAppear {
            if assignmentToEdit == nil, let firstCourse = dataManager.courses.first {
                courseId = firstCourse.id
            }
        }
    }
}
