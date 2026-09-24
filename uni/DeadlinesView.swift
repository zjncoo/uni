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
    @State private var searchText = ""
    @State private var isPresentingNewDeadline = false
    @State private var deadlineToEdit: Deadline? = nil
    
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
    
    var filteredDeadlines: [Deadline] {
        let base: [Deadline]
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
        
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty {
            return base
        }
        return base.filter { deadline in
            let courseName = dataManager.courses.first(where: { $0.id == deadline.courseId })?.name ?? ""
            return deadline.title.localizedCaseInsensitiveContains(clean) ||
                   deadline.notes.localizedCaseInsensitiveContains(clean) ||
                   courseName.localizedCaseInsensitiveContains(clean) ||
                   deadline.priority.rawValue.localizedCaseInsensitiveContains(clean)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                UniHeader(
                    localizationManager.t(.deadlinesTitle),
                    subtitle: localizationManager.t(.deadlinesSubtitle(dataManager.deadlines.filter { !$0.isCompleted }.count))
                )
                
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
                
                // Lista
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
                                onDelete: { deleteDeadline(deadline) }
                            )
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
                
                NotificationManager.shared.notify(
                    title: "Scadenza creata",
                    message: "\(newOne.title) • Scade il \(formatDueDate(newOne.dueDate))",
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
                    
                    NotificationManager.shared.notify(
                        title: "Scadenza aggiornata",
                        message: updated.title,
                        type: .info,
                        icon: "pencil"
                    )
                }
            }
        }
        .onAppear {
            if let targetId = dataManager.selectedDeadlineId,
               let found = dataManager.deadlines.first(where: { $0.id == targetId }) {
                deadlineToEdit = found
                dataManager.selectedDeadlineId = nil
            }
        }
        .onChange(of: dataManager.selectedDeadlineId) { _, newId in
            if let newId = newId, let found = dataManager.deadlines.first(where: { $0.id == newId }) {
                deadlineToEdit = found
                dataManager.selectedDeadlineId = nil
            }
        }
    }
    
    private func toggleComplete(_ deadline: Deadline) {
        if let idx = dataManager.deadlines.firstIndex(where: { $0.id == deadline.id }) {
            dataManager.deadlines[idx].isCompleted.toggle()
            let isNowCompleted = dataManager.deadlines[idx].isCompleted
            dataManager.saveData()
            
            if isNowCompleted {
                SoundManager.shared.play(.success)
            } else {
                SoundManager.shared.play(.pop)
            }
            
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
    
    private func deleteDeadline(_ deadline: Deadline) {
        SoundManager.shared.play(.remove)
        dataManager.deadlines.removeAll { $0.id == deadline.id }
        dataManager.saveData()
        
        NotificationManager.shared.notify(
            title: "Scadenza eliminata",
            message: deadline.title,
            type: .warning,
            icon: "trash"
        )
        NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: date).capitalized
    }
    
    private func formatDueTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return "Ore \(f.string(from: date))"
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
    
    var isUrgent: Bool {
        !deadline.isCompleted && deadline.dueDate < Date().addingTimeInterval(86400 * 2) && deadline.dueDate > Date()
    }
    
    var body: some View {
        UniCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                // Riga Superiore: Checkbox, Titolo, Materia, Priorità, Freccina a destra
                HStack(alignment: .top, spacing: 12) {
                    Button(action: onToggleComplete) {
                        Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(deadline.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                    .help(deadline.isCompleted ? localizationManager.text(it: "Segna come incompleta", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completata", en: "Mark as completed"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(deadline.title)
                                .font(UniFont.headline())
                                .strikethrough(deadline.isCompleted)
                            
                            if let course = dataManager.courses.first(where: { $0.id == deadline.courseId }) {
                                UniBadge(course.name, color: Color(hex: course.colorHex) ?? themeManager.accentColor)
                            }
                            
                            UniBadge(deadline.priority.localizedName, color: deadline.priority.color)
                        }
                        
                        if !deadline.notes.isEmpty {
                            Text(deadline.notes)
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Freccina a destra per mostrare/nascondere allegati e azioni
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .frame(width: 26, height: 26)
                            .background(Color.primary.opacity(isExpanded ? 0.08 : 0.03), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(isExpanded ? localizationManager.text(it: "Comprimi allegati", en: "Collapse attachments") : localizationManager.text(it: "Mostra allegati e azioni", en: "Show attachments and actions"))
                }
                
                // Scadenza Ben Visibile (SOPRA gli allegati)
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 11, weight: .semibold))
                    Text(formatDueDate(deadline.dueDate))
                        .font(UniFont.caption())
                        .fontWeight(.medium)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(formatDueTime(deadline.dueDate))
                        .font(UniFont.caption())
                        .fontWeight(.medium)
                }
                .foregroundStyle(isUrgent ? .red : .primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isUrgent ? Color.red : Color.primary).opacity(0.05), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke((isUrgent ? Color.red : Color.primary).opacity(0.12), lineWidth: 1)
                )
                
                // Sezione Espandibile: Allegati e righina con pulsanti Edit ed Elimina
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                        
                        Text(localizationManager.text(it: "ALLEGATI & LINK", en: "ATTACHMENTS & LINKS"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        
                        if let link = deadline.linkURL, !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                                        Text(localizationManager.text(it: "Apri Link", en: "Open Link"))
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
                        } else {
                            Text(localizationManager.text(it: "Nessun allegato o link collegato a questa scadenza.", en: "No attachments or links linked to this deadline."))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        // Righina con i pulsanti Modifica ed Elimina
                        HStack(spacing: 8) {
                            Spacer()
                            
                            Button(action: onEdit) {
                                HStack(spacing: 5) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 11))
                                    Text(localizationManager.text(it: "Modifica", en: "Edit"))
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Modifica scadenza", en: "Edit deadline"))
                            
                            Button(role: .destructive, action: onDelete) {
                                HStack(spacing: 5) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 11))
                                    Text(localizationManager.text(it: "Elimina", en: "Delete"))
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.red.opacity(0.25), lineWidth: 1)
                                )
                                .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Elimina scadenza", en: "Delete deadline"))
                        }
                        .padding(.top, 4)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let f = DateFormatter()
        let isEn = localizationManager.currentLanguage == .english
        f.locale = isEn ? Locale(identifier: "en_US") : Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = isEn ? "EEEE, MMMM d, yyyy" : "EEEE d MMMM yyyy"
        return f.string(from: date).capitalized
    }
    
    private func formatDueTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return "Ore \(f.string(from: date))"
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
    @State private var linkURL: String = ""
    
    init(deadlineToEdit: Deadline?, initialDate: Date = Date(), onSave: @escaping (Deadline) -> Void) {
        self.deadlineToEdit = deadlineToEdit
        self.onSave = onSave
        _title = State(initialValue: deadlineToEdit?.title ?? "")
        _courseId = State(initialValue: deadlineToEdit?.courseId)
        _dueDate = State(initialValue: deadlineToEdit?.dueDate ?? initialDate)
        _priority = State(initialValue: deadlineToEdit?.priority ?? .medium)
        _notes = State(initialValue: deadlineToEdit?.notes ?? "")
        _linkURL = State(initialValue: deadlineToEdit?.linkURL ?? "")
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
                    
                    DatePicker(localizationManager.text(it: "Data e Ora", en: "Due Date & Time"), selection: $dueDate)
                    
                    Picker(localizationManager.text(it: "Priorità", en: "Priority"), selection: $priority) {
                        ForEach(Deadline.Priority.allCases, id: \.self) { p in
                            Text(p.localizedName).tag(p)
                        }
                    }
                }
                
                Section(localizationManager.text(it: "Link & Risorse Web", en: "Link & Web Resources")) {
                    TextField(localizationManager.text(it: "https://... (sito, portale consegna o link esterno)", en: "https://... (website, submission portal or link)"), text: $linkURL)
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
                    let cleanLink = linkURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    let updated = Deadline(
                        id: deadlineToEdit?.id ?? UUID(),
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        courseId: courseId,
                        dueDate: dueDate,
                        priority: priority,
                        isCompleted: deadlineToEdit?.isCompleted ?? false,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                        linkURL: cleanLink.isEmpty ? nil : cleanLink
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
        .frame(width: 460, height: 450)
    }
}
