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
    @State private var searchText = ""
    @State private var isPresentingNewAssignment = false
    @State private var assignmentToEdit: Assignment? = nil
    
    var filteredAssignments: [Assignment] {
        let base = dataManager.assignments
            .filter { filterCompleted ? $0.isCompleted : !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
        
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
                // Header
                UniHeader(
                    localizationManager.t(.assignmentsTitle),
                    subtitle: localizationManager.t(.assignmentsSubtitle(
                        dataManager.assignments.filter { !$0.isCompleted }.count,
                        dataManager.assignments.filter { $0.isCompleted }.count
                    ))
                )
                
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
                
                // Lista
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
                                onDelete: { deleteAssignment(assignment) },
                                onPickFile: { pickLocalFile(for: assignment) },
                                onRemoveFile: { removeLocalFile(for: assignment) },
                                onAttachFileURL: { url in attachFile(url, to: assignment) }
                            )
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
                NotificationManager.shared.notify(
                    title: "Assignment creato",
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
                    NotificationManager.shared.notify(
                        title: "Assignment aggiornato",
                        message: updated.title,
                        type: .info,
                        icon: "doc.text"
                    )
                }
            }
        }
        .onAppear {
            if let targetId = dataManager.selectedAssignmentId,
               let found = dataManager.assignments.first(where: { $0.id == targetId }) {
                assignmentToEdit = found
                dataManager.selectedAssignmentId = nil
            }
        }
        .onChange(of: dataManager.selectedAssignmentId) { _, newId in
            if let newId = newId, let found = dataManager.assignments.first(where: { $0.id == newId }) {
                assignmentToEdit = found
                dataManager.selectedAssignmentId = nil
            }
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
            dataManager.saveData()
            
            if completed {
                SoundManager.shared.play(.success)
            } else {
                SoundManager.shared.play(.pop)
            }
            
            NotificationManager.shared.notify(
                title: completed ? "Assignment completato! 🎉" : "Assignment riaperto",
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
            dataManager.saveData()
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
        NotificationManager.shared.notify(
            title: "Assignment rimosso",
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
    
    var isDueDateUrgent: Bool {
        !assignment.isCompleted && assignment.dueDate < Date().addingTimeInterval(86400 * 2)
    }
    
    var body: some View {
        UniCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                // Riga Superiore: Checkbox, Titolo, Materia, Menu a tendina Stato, Freccina Espansione
                HStack(alignment: .top, spacing: 12) {
                    Button(action: onToggleComplete) {
                        Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(assignment.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                    .help(assignment.isCompleted ? localizationManager.text(it: "Segna come da completare", en: "Mark as incomplete") : localizationManager.text(it: "Segna come completato", en: "Mark as completed"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(assignment.title)
                                .font(UniFont.headline())
                                .strikethrough(assignment.isCompleted)
                            
                            if let course = dataManager.courses.first(where: { $0.id == assignment.courseId }) {
                                UniBadge(course.name, color: Color(hex: course.colorHex) ?? themeManager.accentColor)
                            }
                            
                            // Menu a tendina per lo Stato (In corso / Non ancora iniziato / Completato)
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
                                .padding(.vertical, 3)
                                .background(assignment.status.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(assignment.status.color.opacity(0.28), lineWidth: 1)
                                )
                                .foregroundStyle(assignment.status.color)
                            }
                            .menuStyle(.borderlessButton)
                            
                            if assignment.weightPercent > 0 {
                                Text(localizationManager.text(it: "Peso: \(assignment.weightPercent)%", en: "Weight: \(assignment.weightPercent)%"))
                                    .font(UniFont.caption())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(themeManager.accentColor.opacity(0.1))
                                    .foregroundStyle(themeManager.accentColor)
                                    .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                    .clipShape(Rectangle())
                            }
                        }
                        
                        if !assignment.details.isEmpty {
                            Text(assignment.details)
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
                
                // Data Scadenza (Ben visibile e posizionata SOPRA gli allegati)
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 11, weight: .semibold))
                    Text(formatDueDate(assignment.dueDate))
                        .font(UniFont.caption())
                        .fontWeight(.medium)
                }
                .foregroundStyle(isDueDateUrgent ? .red : .primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isDueDateUrgent ? Color.red : Color.primary).opacity(0.05), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke((isDueDateUrgent ? Color.red : Color.primary).opacity(0.12), lineWidth: 1)
                )
                
                // Sezione Espandibile: Allegati e righina con pulsanti Edit ed Elimina
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                        
                        Text(localizationManager.text(it: "ALLEGATI & RISORSE", en: "ATTACHMENTS & RESOURCES"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        
                        // SEZIONE COLLEGAMENTO FILE LOCALE SUL MAC (Con Drag & Drop nativo)
                        HStack(spacing: 10) {
                            if let fileName = assignment.localFileName, let filePath = assignment.localFilePath {
                                // File collegato
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 16))
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
                                    .help(localizationManager.text(it: "Apre il file con l'applicazione di default di macOS", en: "Opens file with macOS default application"))
                                    
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
                                // Nessun file collegato - Dropzone interattiva
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
                        
                        // SEZIONE LINK WEB (Se presente)
                        if let link = assignment.linkURL, !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                            .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                            .clipShape(Rectangle())
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
                            .help(localizationManager.text(it: "Modifica assignment", en: "Edit assignment"))
                            
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
                            .help(localizationManager.text(it: "Elimina assignment", en: "Delete assignment"))
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
        f.dateFormat = isEn ? "EEEE, MMMM d, yyyy 'at' HH:mm" : "EEEE d MMMM yyyy, 'ore' HH:mm"
        let prefix = isEn ? "Due: " : "Scadenza: "
        return "\(prefix)\(f.string(from: date).capitalized)"
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
    @State private var linkURL: String = ""
    @State private var status: AssignmentStatus = .notStarted
    
    init(assignmentToEdit: Assignment?, onSave: @escaping (Assignment) -> Void) {
        self.assignmentToEdit = assignmentToEdit
        self.onSave = onSave
        _title = State(initialValue: assignmentToEdit?.title ?? "")
        _courseId = State(initialValue: assignmentToEdit?.courseId ?? UUID())
        _dueDate = State(initialValue: assignmentToEdit?.dueDate ?? Date().addingTimeInterval(86400 * 7))
        _details = State(initialValue: assignmentToEdit?.details ?? "")
        _weightPercent = State(initialValue: assignmentToEdit?.weightPercent ?? 0)
        _linkURL = State(initialValue: assignmentToEdit?.linkURL ?? "")
        _status = State(initialValue: assignmentToEdit?.status ?? .notStarted)
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
                    
                    DatePicker(localizationManager.text(it: "Data di Consegna", en: "Due Date"), selection: $dueDate)
                    Stepper(localizationManager.text(it: "Peso sul voto: \(weightPercent)%", en: "Grade Weight: \(weightPercent)%"), value: $weightPercent, in: 0...100, step: 5)
                }
                
                Section(localizationManager.text(it: "Link & Risorse Web", en: "Link & Web Resources")) {
                    TextField(localizationManager.text(it: "https://... (sito consegna, repository o specifiche)", en: "https://... (submission portal, repo or specs)"), text: $linkURL)
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
                    let cleanLink = linkURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    let updated = Assignment(
                        id: assignmentToEdit?.id ?? UUID(),
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        courseId: courseId,
                        dueDate: dueDate,
                        details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                        weightPercent: weightPercent,
                        isCompleted: status == .completed,
                        status: status,
                        localFilePath: assignmentToEdit?.localFilePath,
                        localFileName: assignmentToEdit?.localFileName,
                        localFileSize: assignmentToEdit?.localFileSize,
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
        .frame(width: 480, height: 480)
        .onAppear {
            if assignmentToEdit == nil, let firstCourse = dataManager.courses.first {
                courseId = firstCourse.id
            }
        }
    }
}
