//
//  CoursesView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif

struct CoursesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var selectedCourse: Course? = nil
    @State private var isPresentingNewCourseSheet = false
    @State private var isPresentingEditCourseSheet = false
    @State private var isPresentingAddLinkSheet = false
    @State private var isPresentingAddScheduleSheet = false
    @State private var courseToDelete: Course? = nil
    
    @State private var searchText = ""
    @State private var isSearchExpanded = false
    
    var filteredCourses: [Course] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return dataManager.courses
        }
        return dataManager.courses.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.professor.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Superiore con Titolo e Azioni
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    UniHeader(
                        localizationManager.t(.coursesTitle),
                        subtitle: "\(dataManager.courses.count) \(localizationManager.t(.navCourses).lowercased())"
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if !dataManager.syncedEvents.isEmpty {
                            Button {
                                dataManager.resyncAllCourseSchedules()
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(localizationManager.text(it: "Ricalcola orari", en: "Recalculate"))
                                }
                                .font(UniFont.caption())
                                .foregroundStyle(themeManager.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(themeManager.accentColor.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Ricalcola automaticamente tutti gli orari settimanali dei corsi dagli eventi sincronizzati", en: "Automatically recalculate course weekly schedules from synced events"))
                        }
                        
                        Button {
                            isPresentingNewCourseSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text(localizationManager.t(.addCourseButton))
                                    .font(UniFont.subheadline())
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 13)
                            .padding(.vertical, 6)
                            .background(themeManager.accentColor)
                            .foregroundStyle(themeManager.accentTextColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: themeManager.accentColor.opacity(0.22), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Ricerca Corso appena sotto al titolo della pagina
                if !dataManager.courses.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.t(.searchCoursesPlaceholder), text: $searchText)
                            .textFieldStyle(.plain)
                            .font(UniFont.subheadline())
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: 260, alignment: .leading)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, -2)
                }
                
                // Barra Orizzontale Card Verticali dei Corsi
                if !dataManager.courses.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filteredCourses) { course in
                                CourseVerticalCardView(
                                    course: course,
                                    isSelected: selectedCourse?.id == course.id,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                                            selectedCourse = course
                                        }
                                    }
                                )
                            }
                            
                            AddCourseVerticalCardView {
                                isPresentingNewCourseSheet = true
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.bottom, 12)
            .background(Color.primary.opacity(0.015))
            
            Divider()
            
            // Area Dettaglio Corso Selezionato
            if dataManager.courses.isEmpty {
                VStack {
                    Spacer()
                    UniEmptyStateView(
                        icon: "book.closed",
                        title: localizationManager.t(.noCoursesEmptyTitle),
                        subtitle: localizationManager.t(.noCoursesEmptyDesc),
                        buttonTitle: localizationManager.t(.addCourseButton)
                    ) {
                        isPresentingNewCourseSheet = true
                    }
                    .padding(.horizontal, 24)
                    Spacer()
                }
            } else if let course = selectedCourse {
                CourseDetailView(
                    course: binding(for: course),
                    onEdit: { isPresentingEditCourseSheet = true },
                    onDelete: { courseToDelete = course },
                    onAddLink: { isPresentingAddLinkSheet = true },
                    onAddSchedule: { isPresentingAddScheduleSheet = true }
                )
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "book.closed")
                        .font(.system(size: 38))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text(localizationManager.t(.selectCoursePlaceholder))
                        .font(UniFont.headline())
                        .foregroundStyle(.secondary)
                    Text(localizationManager.t(.selectCourseDesc))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if let targetId = dataManager.selectedCourseId,
               let found = dataManager.courses.first(where: { $0.id == targetId }) {
                selectedCourse = found
                dataManager.selectedCourseId = nil
            } else if selectedCourse == nil {
                selectedCourse = dataManager.courses.first
            }
        }
        .onChange(of: dataManager.selectedCourseId) { _, newId in
            if let newId = newId, let found = dataManager.courses.first(where: { $0.id == newId }) {
                selectedCourse = found
                dataManager.selectedCourseId = nil
            }
        }
        .onChange(of: dataManager.courses) { _, newCourses in
            if let sel = selectedCourse, !newCourses.contains(where: { $0.id == sel.id }) {
                selectedCourse = newCourses.first
            } else if selectedCourse == nil {
                selectedCourse = newCourses.first
            }
        }
        .sheet(isPresented: $isPresentingNewCourseSheet) {
            CourseEditorSheet(courseToEdit: nil) { newCourse in
                dataManager.courses.append(newCourse)
                dataManager.saveData()
                selectedCourse = newCourse
                
                NotificationManager.shared.notify(
                    title: "Corso universitario aggiunto",
                    message: "\(newCourse.name) (\(newCourse.cfu) CFU)",
                    type: .success,
                    icon: "book.closed.fill"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        .sheet(isPresented: $isPresentingEditCourseSheet) {
            if let course = selectedCourse {
                CourseEditorSheet(courseToEdit: course) { updated in
                    if let idx = dataManager.courses.firstIndex(where: { $0.id == updated.id }) {
                        dataManager.courses[idx] = updated
                        dataManager.saveData()
                        selectedCourse = updated
                        
                        NotificationManager.shared.notify(
                            title: "Corso aggiornato",
                            message: updated.name,
                            type: .info,
                            icon: "pencil"
                        )
                        NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddLinkSheet) {
            if let course = selectedCourse {
                AddLinkSheet { newLink in
                    if let idx = dataManager.courses.firstIndex(where: { $0.id == course.id }) {
                        dataManager.courses[idx].links.append(newLink)
                        dataManager.saveData()
                        selectedCourse = dataManager.courses[idx]
                        
                        NotificationManager.shared.notify(
                            title: "Link aggiunto a \(course.name)",
                            message: newLink.title,
                            type: .info,
                            icon: "link"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddScheduleSheet) {
            if let course = selectedCourse {
                AddScheduleSheet { newSchedule in
                    if let idx = dataManager.courses.firstIndex(where: { $0.id == course.id }) {
                        dataManager.courses[idx].schedule.append(newSchedule)
                        dataManager.saveData()
                        selectedCourse = dataManager.courses[idx]
                        
                        NotificationManager.shared.notify(
                            title: "Orario lezioni aggiornato",
                            message: "\(course.name) • \(newSchedule.dayName) \(newSchedule.startTime)-\(newSchedule.endTime)",
                            type: .info,
                            icon: "calendar.badge.clock"
                        )
                    }
                }
            }
        }
        .alert(
            localizationManager.text(it: "Elimina Corso", en: "Delete Course"),
            isPresented: Binding(get: { courseToDelete != nil }, set: { if !$0 { courseToDelete = nil } }),
            presenting: courseToDelete
        ) { c in
            Button(localizationManager.t(.cancel), role: .cancel) {
                courseToDelete = nil
            }
            Button(localizationManager.t(.delete), role: .destructive) {
                deleteCourse(c)
                courseToDelete = nil
            }
        } message: { c in
            Text(localizationManager.text(
                it: "Sei sicuro di voler eliminare \"\(c.name)\"? Verranno eliminati anche tutti gli esami, i compiti e le scadenze associate. L'operazione non può essere annullata.",
                en: "Are you sure you want to delete \"\(c.name)\"? All associated exams, assignments, and deadlines will also be deleted. This action cannot be undone."
            ))
        }
    }
    
    private func binding(for course: Course) -> Binding<Course> {
        Binding(
            get: {
                dataManager.courses.first(where: { $0.id == course.id }) ?? course
            },
            set: { updated in
                if let idx = dataManager.courses.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.courses[idx] = updated
                    dataManager.saveData()
                }
            }
        )
    }
    
    private func deleteCourse(_ course: Course) {
        dataManager.courses.removeAll { $0.id == course.id }
        dataManager.deadlines.removeAll { $0.courseId == course.id }
        dataManager.exams.removeAll { $0.courseId == course.id }
        dataManager.assignments.removeAll { $0.courseId == course.id }
        dataManager.saveData()
        selectedCourse = dataManager.courses.first
        
        NotificationManager.shared.notify(
            title: "Corso eliminato",
            message: course.name,
            type: .warning,
            icon: "trash"
        )
        NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
    }
}

// MARK: - Course Vertical Card (Card Verticale nella Barra)
struct CourseVerticalCardView: View {
    let course: Course
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isHovered = false
    
    var courseColor: Color {
        Color(hex: course.colorHex) ?? themeManager.accentColor
    }
    
    var isExpanded: Bool {
        isHovered
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 5) {
                    // Barra / Tondino colore e badge se espanso
                    HStack(spacing: 7) {
                        Circle()
                            .fill(courseColor)
                            .frame(width: 8, height: 8)
                        
                        if isExpanded {
                            Text("\(course.cfu) CFU")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundStyle(courseColor)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(courseColor.opacity(0.14), in: Capsule())
                                .transition(.opacity)
                        }
                        
                        Spacer(minLength: 2)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(courseColor)
                        }
                    }
                    
                    // Titolo del Corso (sempre visibile)
                    Text(course.name)
                        .font(UniFont.subheadline())
                        .fontWeight(isSelected ? .bold : .semibold)
                        .foregroundStyle(isSelected ? Color.primary : (isHovered ? Color.primary : Color.primary.opacity(0.85)))
                        .lineLimit(isExpanded ? 2 : 1)
                        .multilineTextAlignment(.leading)
                    
                    // Dettagli estesi: visibili SOLO su HOVER
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 3) {
                            if !course.professor.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 8))
                                    Text(course.professor)
                                        .lineLimit(1)
                                }
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            }
                            
                            HStack(spacing: 6) {
                                if !course.room.isEmpty {
                                    HStack(spacing: 3) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 8))
                                        Text(course.room)
                                            .lineLimit(1)
                                    }
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if !course.linkedFiles.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "folder.fill")
                                        Text("\(course.linkedFiles.count)")
                                    }
                                    .font(.system(size: 8.5, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: isExpanded ? 180 : 145, height: isExpanded ? 98 : 50, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? courseColor.opacity(0.12) : (isHovered ? Color.primary.opacity(0.05) : Color.primary.opacity(0.025)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? courseColor : (isHovered ? Color.primary.opacity(0.2) : Color.primary.opacity(0.08)), lineWidth: isSelected ? 1.5 : 1)
                )
                .shadow(color: isSelected ? courseColor.opacity(0.15) : Color.black.opacity(0.02), radius: isSelected ? 5 : 1, y: 1)
            }
            .buttonStyle(.plain)
            .onHover { h in
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isHovered = h
                }
            }
            
            // Pallino grigio per indicare il corso attualmente visualizzato
            Circle()
                .fill(isSelected ? Color.secondary.opacity(0.75) : Color.clear)
                .frame(width: 5, height: 5)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Add Course Vertical Card
struct AddCourseVerticalCardView: View {
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                    Text(localizationManager.text(it: "Nuova Materia", en: "New Course"))
                        .font(UniFont.caption())
                        .fontWeight(.medium)
                        .foregroundStyle(isHovered ? themeManager.accentColor : .primary)
                }
                .padding(.horizontal, 12)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isHovered ? themeManager.accentColor.opacity(0.06) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                        .foregroundStyle(isHovered ? themeManager.accentColor : Color.primary.opacity(0.15))
                )
            }
            .buttonStyle(.plain)
            .onHover { h in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = h
                }
            }
            
            // Spaziatore trasparente per allineare l'altezza con le altre card
            Circle()
                .fill(Color.clear)
                .frame(width: 5, height: 5)
        }
    }
}

// MARK: - Course Detail View (Organized Modular Dashboard)
struct CourseDetailView: View {
    @Binding var course: Course
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onAddLink: () -> Void
    var onAddSchedule: () -> Void
    
    @State private var isDropTargeted = false
    @State private var slotToDelete: CourseSchedule? = nil
    @State private var linkToDelete: CourseLink? = nil
    @State private var fileToDelete: CourseLinkedFile? = nil
    @State private var quickNotesText: String = ""
    
    // Gestione Scadenze e Consegne del Corso
    @State private var isPresentingNewDeadlineSheet = false
    @State private var isPresentingNewAssignmentSheet = false
    @State private var deadlineToEdit: Deadline? = nil
    @State private var assignmentToEdit: Assignment? = nil
    @State private var deadlineToDelete: Deadline? = nil
    @State private var assignmentToDelete: Assignment? = nil
    @State private var selectedEmailForPicker: String? = nil
    
    var courseColor: Color {
        Color(hex: course.colorHex) ?? themeManager.accentColor
    }
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 20) {
                // Colonna Sinistra (50%): UN UNICO GRANDE BLOCCO INTEGRATO (Dati Corso, Orario, Note Rapide, Note Studio)
                leftUnifiedBlock
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                // Colonna Destra (50%): Scadenze del Corso, Notion Workspace, File Collegati e Risorse Esterne
                VStack(alignment: .leading, spacing: 18) {
                    courseDeadlinesModule
                    notionDesktopCard
                    linkedFilesModule
                    externalLinksModule
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(24)
        }
        .onAppear {
            quickNotesText = course.quickNotes
        }
        .onChange(of: course.id) { _, _ in
            quickNotesText = course.quickNotes
        }
        .onChange(of: quickNotesText) { _, newValue in
            if course.quickNotes != newValue {
                course.quickNotes = newValue
                dataManager.saveData()
            }
        }
        .sheet(isPresented: $isPresentingNewDeadlineSheet) {
            DeadlineEditorSheet(deadlineToEdit: nil, initialCourseId: course.id) { newDl in
                dataManager.deadlines.append(newDl)
                dataManager.saveData()
                SoundManager.shared.play(.success)
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Scadenza aggiunta", en: "Deadline added"),
                    message: "\(newDl.title) • \(course.name)",
                    type: .success,
                    icon: "clock.badge.checkmark"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        .sheet(isPresented: $isPresentingNewAssignmentSheet) {
            AssignmentEditorSheet(assignmentToEdit: nil, initialCourseId: course.id) { newAsg in
                dataManager.assignments.append(newAsg)
                dataManager.saveData()
                SoundManager.shared.play(.success)
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Consegna aggiunta", en: "Assignment added"),
                    message: "\(newAsg.title) • \(course.name)",
                    type: .success,
                    icon: "doc.badge.plus"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        .sheet(item: $deadlineToEdit) { dl in
            DeadlineEditorSheet(deadlineToEdit: dl, initialCourseId: course.id) { updated in
                if let idx = dataManager.deadlines.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.deadlines[idx] = updated
                    dataManager.saveData()
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
            }
        }
        .sheet(item: $assignmentToEdit) { asg in
            AssignmentEditorSheet(assignmentToEdit: asg, initialCourseId: course.id) { updated in
                if let idx = dataManager.assignments.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.assignments[idx] = updated
                    dataManager.saveData()
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
            }
        }
        .alert(
            localizationManager.text(it: "Elimina Scadenza", en: "Delete Deadline"),
            isPresented: Binding(get: { deadlineToDelete != nil }, set: { if !$0 { deadlineToDelete = nil } }),
            presenting: deadlineToDelete
        ) { dl in
            Button(localizationManager.t(.cancel), role: .cancel) { deadlineToDelete = nil }
            Button(localizationManager.t(.delete), role: .destructive) {
                SoundManager.shared.play(.remove)
                dataManager.deadlines.removeAll { $0.id == dl.id }
                dataManager.saveData()
                deadlineToDelete = nil
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        } message: { dl in
            Text(localizationManager.text(it: "Sei sicuro di voler eliminare la scadenza \"\(dl.title)\"?", en: "Are you sure you want to delete deadline \"\(dl.title)\"?"))
        }
        .alert(
            localizationManager.text(it: "Elimina Consegna", en: "Delete Assignment"),
            isPresented: Binding(get: { assignmentToDelete != nil }, set: { if !$0 { assignmentToDelete = nil } }),
            presenting: assignmentToDelete
        ) { asg in
            Button(localizationManager.t(.cancel), role: .cancel) { assignmentToDelete = nil }
            Button(localizationManager.t(.delete), role: .destructive) {
                SoundManager.shared.play(.remove)
                dataManager.assignments.removeAll { $0.id == asg.id }
                dataManager.saveData()
                assignmentToDelete = nil
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        } message: { asg in
            Text(localizationManager.text(it: "Sei sicuro di voler eliminare la consegna \"\(asg.title)\"?", en: "Are you sure you want to delete assignment \"\(asg.title)\"?"))
        }
    }
    
    // MARK: - Left Unified Block (Tutto un unico blocco integrato)
    private var leftUnifiedBlock: some View {
        UniCard(padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                // 1. Dati Principali del Corso
                courseHeaderSection
                
                Divider()
                
                // 2. Orario Settimanale
                scheduleSection
                
                Divider()
                
                // 3. Blocco Note Rapido d'Aula (Scratchpad)
                quickScratchpadSection
                
                Divider()
                
                // 4. Note & Programma di Studio
                notesSection
            }
        }
    }
    
    // MARK: - 1. Course Header Section (All'interno del blocco sinistro)
    private var courseHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Badge Identità & Azioni Rapide
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    if !course.code.isEmpty {
                        Text(course.code)
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 5))
                    }
                    
                    Text("\(course.cfu) CFU")
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(courseColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(courseColor.opacity(0.12), in: Capsule())
                    
                    if course.academicYear > 0 {
                        Text(localizationManager.text(it: "\(course.academicYear)° Anno", en: "Year \(course.academicYear)"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 5))
                    }
                    
                    Text(localizationManager.text(it: "\(course.semester)° Sem.", en: "Sem. \(course.semester)"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Button {
                        onEdit()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .semibold))
                            Text(localizationManager.text(it: "Modifica", en: "Edit"))
                                .font(UniFont.caption())
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(.bordered)
                    .help(localizationManager.text(it: "Modifica materia", en: "Edit course"))
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.bordered)
                    .help(localizationManager.text(it: "Elimina materia", en: "Delete course"))
                }
            }
            
            // Titolo del Corso
            Text(course.name)
                .font(UniFont.title())
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            if course.isAttendanceMandatory {
                HStack(spacing: 5) {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 10))
                    Text(localizationManager.text(it: "Frequenza Obbligatoria (min \(course.targetAttendancePercentage)%)", en: "Mandatory Attendance (min \(course.targetAttendancePercentage)%)"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.12), in: Capsule())
            }
            
            // Docente, Email & Aula
            VStack(alignment: .leading, spacing: 7) {
                if !course.professor.isEmpty || !course.allProfessorEmails.isEmpty {
                    HStack(spacing: 12) {
                        if !course.professor.isEmpty {
                            HStack(spacing: 5) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(courseColor)
                                Text(course.professor)
                                    .font(UniFont.subheadline())
                                    .fontWeight(.medium)
                            }
                        }
                        
                        let allEmails = course.allProfessorEmails
                        if !allEmails.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(allEmails, id: \.self) { email in
                                    Button {
                                        selectedEmailForPicker = email
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "envelope.fill")
                                                .font(.system(size: 10))
                                            Text(email)
                                                .font(UniFont.caption())
                                                .underline()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.secondary)
                                        }
                                        .foregroundStyle(themeManager.accentColor)
                                    }
                                    .buttonStyle(.plain)
                                    .help(localizationManager.text(it: "Invia email a \(email)", en: "Send email to \(email)"))
                                    .popover(isPresented: Binding(
                                        get: { selectedEmailForPicker == email },
                                        set: { if !$0 && selectedEmailForPicker == email { selectedEmailForPicker = nil } }
                                    ), arrowEdge: .bottom) {
                                        emailClientPickerPopover(for: email)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !course.room.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Text(localizationManager.text(it: "Aula:", en: "Room:") + " \(course.room)")
                            .font(UniFont.subheadline())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Email Client Picker Popover
    private func emailClientPickerPopover(for email: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header del Popover
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Invia Email al Docente", en: "Email Professor"))
                        .font(UniFont.headline())
                    if !course.professor.isEmpty {
                        Text("\(course.professor) • \(email)")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text(email)
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Text(localizationManager.text(it: "Scegli l'applicazione con cui comporre il messaggio:", en: "Choose which application to compose the email with:"))
                .font(UniFont.caption())
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Opzioni di Invio (Apple Mail vs Microsoft Outlook)
            VStack(spacing: 8) {
                // Opzione 1: Apple Mail
                Button {
                    selectedEmailForPicker = nil
                    AppSystemHelper.openInAppleMail(email: email, subject: course.name)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Apple Mail")
                                    .font(UniFont.subheadline())
                                    .fontWeight(.semibold)
                                Text(localizationManager.text(it: "macOS", en: "macOS"))
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(Color.blue)
                                    .clipShape(Capsule())
                            }
                            Text(localizationManager.text(it: "App Mail predefinita di sistema", en: "Default system Mail app"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.035))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Opzione 2: Microsoft Outlook
                Button {
                    selectedEmailForPicker = nil
                    AppSystemHelper.openInOutlook(email: email, subject: course.name)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(red: 0.0, green: 0.47, blue: 0.83).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.83))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Microsoft Outlook")
                                    .font(UniFont.subheadline())
                                    .fontWeight(.semibold)
                                Text("365")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Color(red: 0.0, green: 0.47, blue: 0.83).opacity(0.1))
                                    .foregroundStyle(Color(red: 0.0, green: 0.47, blue: 0.83))
                                    .clipShape(Capsule())
                            }
                            Text(localizationManager.text(it: "App Outlook o Office 365 Web", en: "Outlook app or Office 365 Web"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.035))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Azione rapida: Copia Indirizzo Email
            HStack {
                Button {
                    #if canImport(AppKit)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(email, forType: .string)
                    #endif
                    SoundManager.shared.play(.success)
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Email copiata! 📋", en: "Email copied! 📋"),
                        message: email,
                        type: .success,
                        icon: "doc.on.doc"
                    )
                    selectedEmailForPicker = nil
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                        Text(localizationManager.text(it: "Copia indirizzo", en: "Copy address"))
                            .font(UniFont.caption())
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(localizationManager.t(.cancel)) {
                    selectedEmailForPicker = nil
                }
                .font(UniFont.caption())
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 320)
    }
    
    // MARK: - Notion Desktop Card
    private var notionDesktopCard: some View {
        UniCard(padding: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(courseColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(courseColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(localizationManager.text(it: "Appunti del Corso su Notion", en: "Course Notes on Notion"))
                        .font(UniFont.headline())
                    Text(course.notionURL.isEmpty ? localizationManager.text(it: "Nessun link configurato.", en: "No link configured.") : localizationManager.text(it: "Apri workspace o pagina Notion associata a questo corso", en: "Open Notion workspace or page associated with this course"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if !course.notionURL.isEmpty {
                    Button {
                        AppSystemHelper.openNotionPage(urlString: course.notionURL)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.forward.app.fill")
                                .font(.system(size: 11))
                            Text(localizationManager.text(it: "Apri in Notion", en: "Open in Notion"))
                                .font(UniFont.subheadline())
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(courseColor)
                        .foregroundStyle(courseColor.contrastTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(localizationManager.text(it: "Collega Link Notion", en: "Link Notion")) {
                        onEdit()
                    }
                    .font(UniFont.subheadline())
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - 2. Schedule Section (All'interno del blocco sinistro)
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "ORARIO SETTIMANALE", en: "WEEKLY SCHEDULE"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    Text("(\(course.schedule.count))")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    onAddSchedule()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(localizationManager.text(it: "Aggiungi Orario", en: "Add Slot"))
                    }
                    .font(UniFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            if course.schedule.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary.opacity(0.6))
                    Text(localizationManager.text(it: "Nessun orario impostato per questo corso.", en: "No schedule set for this course."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(12)
                .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 6) {
                    ForEach(course.schedule) { slot in
                        HStack(spacing: 10) {
                            Text(slot.dayName)
                                .font(UniFont.subheadline())
                                .fontWeight(.bold)
                                .frame(width: 85, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text("\(localizationManager.formatTimeString(slot.startTime)) - \(localizationManager.formatTimeString(slot.endTime))")
                                    .font(UniFont.mono())
                            }
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            
                            if !slot.room.isEmpty {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 3) {
                                    Image(systemName: "mappin")
                                        .font(.system(size: 9))
                                    Text(slot.room)
                                }
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                slotToDelete = slot
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Rimuovi orario", en: "Remove schedule"))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.primary.opacity(0.025), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .alert(
            localizationManager.text(it: "Rimuovi Orario", en: "Remove Schedule"),
            isPresented: Binding(get: { slotToDelete != nil }, set: { if !$0 { slotToDelete = nil } }),
            presenting: slotToDelete
        ) { slot in
            Button(localizationManager.t(.cancel), role: .cancel) { slotToDelete = nil }
            Button(localizationManager.t(.delete), role: .destructive) {
                course.schedule.removeAll { $0.id == slot.id }
                dataManager.saveData()
                slotToDelete = nil
            }
        } message: { slot in
            Text(localizationManager.text(
                it: "Sei sicuro di voler rimuovere l'orario di \(slot.dayName)?",
                en: "Are you sure you want to remove the schedule for \(slot.dayName)?"
            ))
        }
    }
    
    // MARK: - Course Deadlines & Assignments Module (Colonna Destra: Solo In Sospeso)
    private var courseDeadlinesModule: some View {
        let deadlines = dataManager.deadlines.filter { $0.courseId == course.id && !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        let assignments = dataManager.assignments.filter { $0.courseId == course.id && !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        let totalCount = deadlines.count + assignments.count
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "SCADENZE & CONSEGNE", en: "DEADLINES & ASSIGNMENTS"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    Text("(\(totalCount))")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button {
                        isPresentingNewDeadlineSheet = true
                    } label: {
                        Label(localizationManager.text(it: "Nuova Scadenza", en: "New Deadline"), systemImage: "clock")
                    }
                    Button {
                        isPresentingNewAssignmentSheet = true
                    } label: {
                        Label(localizationManager.text(it: "Nuova Consegna / Compito", en: "New Assignment"), systemImage: "doc.text")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                    }
                    .font(UniFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(themeManager.accentColor)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            
            if totalCount == 0 {
                UniCard(padding: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 24))
                            .foregroundStyle(courseColor.opacity(0.7))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizationManager.text(it: "Nessuna scadenza o consegna in sospeso", en: "No pending deadlines or assignments"))
                                .font(UniFont.subheadline())
                                .fontWeight(.semibold)
                            Text(localizationManager.text(it: "Pianifica verifiche, progetti, relazioni o adempimenti", en: "Plan tests, project deadlines, or tasks"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            isPresentingNewDeadlineSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text(localizationManager.text(it: "Scadenza", en: "Deadline"))
                            }
                            .font(UniFont.caption())
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else {
                UniCard(padding: 10) {
                    VStack(spacing: 6) {
                        // Elenco Scadenze del Corso
                        ForEach(deadlines) { dl in
                            HStack(spacing: 9) {
                                Button {
                                    if let idx = dataManager.deadlines.firstIndex(where: { $0.id == dl.id }) {
                                        dataManager.deadlines[idx].isCompleted.toggle()
                                        if dataManager.deadlines[idx].isCompleted {
                                            SoundManager.shared.play(.success)
                                        } else {
                                            SoundManager.shared.play(.pop)
                                        }
                                        dataManager.saveData()
                                    }
                                } label: {
                                    Image(systemName: dl.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(dl.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 5) {
                                        Text(dl.title)
                                            .font(UniFont.subheadline())
                                            .fontWeight(.medium)
                                            .strikethrough(dl.isCompleted)
                                            .foregroundStyle(dl.isCompleted ? .secondary : .primary)
                                            .lineLimit(1)
                                        
                                        Text(localizationManager.text(it: "Scadenza", en: "Deadline"))
                                            .font(.system(size: 8.5, weight: .bold))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1.5)
                                            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 3))
                                            .foregroundStyle(.secondary)
                                        
                                        if let amount = dl.amount, amount > 0 {
                                            Text(String(format: "€%.2f", amount))
                                                .font(.system(size: 8.5, weight: .bold))
                                                .foregroundStyle(.orange)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1.5)
                                                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        let isPast = dl.dueDate < Date() && !dl.isCompleted
                                        Text(dl.dueDate.formatted(date: .abbreviated, time: .shortened))
                                            .font(UniFont.caption())
                                            .foregroundStyle(isPast ? .red : .secondary)
                                            .fontWeight(isPast ? .semibold : .regular)
                                        
                                        if isPast {
                                            Text(localizationManager.text(it: "Scaduta", en: "Overdue"))
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(.red)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    deadlineToEdit = dl
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Modifica", en: "Edit"))
                                
                                Button(role: .destructive) {
                                    deadlineToDelete = dl
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Elimina", en: "Delete"))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 6))
                        }
                        
                        // Elenco Consegne / Assignments del Corso
                        ForEach(assignments) { asg in
                            HStack(spacing: 9) {
                                Button {
                                    if let idx = dataManager.assignments.firstIndex(where: { $0.id == asg.id }) {
                                        dataManager.assignments[idx].isCompleted.toggle()
                                        if dataManager.assignments[idx].isCompleted {
                                            dataManager.assignments[idx].status = .completed
                                            SoundManager.shared.play(.success)
                                        } else {
                                            dataManager.assignments[idx].status = .notStarted
                                            SoundManager.shared.play(.pop)
                                        }
                                        dataManager.saveData()
                                    }
                                } label: {
                                    Image(systemName: asg.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(asg.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 5) {
                                        Text(asg.title)
                                            .font(UniFont.subheadline())
                                            .fontWeight(.medium)
                                            .strikethrough(asg.isCompleted)
                                            .foregroundStyle(asg.isCompleted ? .secondary : .primary)
                                            .lineLimit(1)
                                        
                                        Text(localizationManager.text(it: "Consegna", en: "Assignment"))
                                            .font(.system(size: 8.5, weight: .bold))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1.5)
                                            .background(courseColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
                                            .foregroundStyle(courseColor)
                                        
                                        if asg.weightPercent > 0 {
                                            Text("\(asg.weightPercent)%")
                                                .font(.system(size: 8.5, weight: .bold))
                                                .foregroundStyle(.blue)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1.5)
                                                .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        let isPast = asg.dueDate < Date() && !asg.isCompleted
                                        Text(asg.dueDate.formatted(date: .abbreviated, time: .shortened))
                                            .font(UniFont.caption())
                                            .foregroundStyle(isPast ? .red : .secondary)
                                            .fontWeight(isPast ? .semibold : .regular)
                                        
                                        if isPast {
                                            Text(localizationManager.text(it: "In ritardo", en: "Late"))
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(.red)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 1)
                                                .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    assignmentToEdit = asg
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Modifica", en: "Edit"))
                                
                                Button(role: .destructive) {
                                    assignmentToDelete = asg
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Elimina", en: "Delete"))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - External Links Module
    private var externalLinksModule: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "RISORSE & LINK ESTERNI", en: "RESOURCES & EXTERNAL LINKS"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    Text("(\(course.links.count))")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    onAddLink()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(localizationManager.text(it: "Aggiungi Risorsa", en: "Add Resource"))
                    }
                    .font(UniFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            if course.links.isEmpty {
                UniEmptyStateView(
                    icon: "link",
                    title: localizationManager.text(it: "Nessuna risorsa esterna", en: "No external resources"),
                    subtitle: localizationManager.text(it: "Collega portali del corso (Moodle), canali Teams/Zoom, cartelle Drive o slide.", en: "Link course portals, Teams/Zoom channels, Drive folders, or slides."),
                    buttonTitle: localizationManager.text(it: "Aggiungi Risorsa", en: "Add Resource")
                ) {
                    onAddLink()
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170, maximum: .infinity), spacing: 8)], spacing: 8) {
                    ForEach(course.links) { link in
                        UniCard(padding: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: link.type.iconName)
                                    .font(.system(size: 13))
                                    .foregroundStyle(courseColor)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(link.title)
                                        .font(UniFont.subheadline())
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                    Text(link.type.localizedName)
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    AppSystemHelper.openWebURL(urlString: link.url)
                                } label: {
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(.plain)
                                .help(localizationManager.text(it: "Apri nel browser", en: "Open in browser"))
                                
                                Button(role: .destructive) {
                                    linkToDelete = link
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .alert(
            localizationManager.text(it: "Rimuovi Link", en: "Remove Link"),
            isPresented: Binding(get: { linkToDelete != nil }, set: { if !$0 { linkToDelete = nil } }),
            presenting: linkToDelete
        ) { link in
            Button(localizationManager.t(.cancel), role: .cancel) { linkToDelete = nil }
            Button(localizationManager.t(.delete), role: .destructive) {
                course.links.removeAll { $0.id == link.id }
                dataManager.saveData()
                linkToDelete = nil
            }
        } message: { link in
            Text(localizationManager.text(
                it: "Sei sicuro di voler rimuovere il link \"\(link.title)\"?",
                en: "Are you sure you want to remove the link \"\(link.title)\"?"
            ))
        }
    }
    
    // MARK: - Linked Files & Folders Module (Preserves full Drag & Drop and File Opening)
    private var linkedFilesModule: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "DOCUMENTI & CARTELLE COLLEGATE", en: "DOCUMENTS & LINKED FOLDERS"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    Text("(\(course.linkedFiles.count))")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    selectAndLinkFiles()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(localizationManager.text(it: "Collega File o Cartella...", en: "Link Files..."))
                    }
                    .font(UniFont.caption())
                }
                .buttonStyle(.bordered)
                .help(localizationManager.text(it: "Seleziona e collega file o intere cartelle dal Mac senza duplicarli", en: "Select and link files or entire folders from your Mac without duplicating them"))
            }
            
            VStack(spacing: 8) {
                if course.linkedFiles.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: isDropTargeted ? "folder.badge.plus" : "folder.badge.plus")
                            .font(.system(size: 28))
                            .foregroundStyle(isDropTargeted ? courseColor : .secondary)
                        
                        Text(isDropTargeted ? localizationManager.text(it: "Rilascia qui per collegare al corso", en: "Drop here to link to course") : localizationManager.text(it: "Trascina qui file o intere cartelle dal Finder", en: "Drag & drop files or entire folders here from Finder"))
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                            .foregroundStyle(isDropTargeted ? courseColor : .primary)
                        
                        Text(localizationManager.text(it: "File e cartelle non vengono copiati: rimangono nella loro posizione originale sul Mac", en: "Files and folders are not copied: they stay in their original location on your Mac"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: isDropTargeted ? 2 : 1, dash: [5, 4])
                            )
                            .foregroundStyle(isDropTargeted ? courseColor : Color.primary.opacity(0.15))
                    )
                    .background(isDropTargeted ? courseColor.opacity(0.08) : Color.clear)
                } else {
                    // Drop Banner compatto quando ci sono già file o cartelle
                    HStack(spacing: 8) {
                        Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "folder.badge.plus")
                            .font(.system(size: 13))
                            .foregroundStyle(isDropTargeted ? courseColor : .secondary)
                        Text(isDropTargeted ? localizationManager.text(it: "Rilascia per collegare", en: "Drop to link") : localizationManager.text(it: "Trascina qui altri file o cartelle dal Finder", en: "Drag more files or folders here from Finder"))
                            .font(UniFont.caption())
                            .foregroundStyle(isDropTargeted ? courseColor : .secondary)
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(isDropTargeted ? courseColor : Color.primary.opacity(0.12))
                    )
                    .background(isDropTargeted ? courseColor.opacity(0.08) : Color.clear)
                    
                    // Lista dei file e cartelle collegati
                    ForEach(course.linkedFiles) { file in
                        UniCard(padding: 10) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(file.isDirectory ? Color.blue.opacity(0.12) : Color.primary.opacity(0.04))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: file.isDirectory ? "folder.fill" : iconForFileExtension(file.fileTypeExtension))
                                        .font(.system(size: file.isDirectory ? 16 : 14))
                                        .foregroundStyle(file.isDirectory ? Color.blue : courseColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(file.name)
                                            .font(UniFont.headline())
                                            .lineLimit(1)
                                        
                                        if file.isDirectory {
                                            Text(localizationManager.text(it: "Cartella", en: "Folder"))
                                                .font(.system(size: 9, weight: .bold))
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 1.5)
                                                .background(Color.blue.opacity(0.12))
                                                .foregroundStyle(Color.blue)
                                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        if !file.fileSize.isEmpty {
                                            Text(file.fileSize)
                                            Text("•")
                                        }
                                        Text(file.filePath)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Pulsante Apri File o Cartella
                                Button {
                                    AppSystemHelper.openLocalFile(path: file.filePath, bookmarkData: file.bookmarkData)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: file.isDirectory ? "folder" : "arrow.up.forward.app")
                                            .font(.system(size: 10))
                                        Text(file.isDirectory ? localizationManager.text(it: "Apri Cartella", en: "Open Folder") : localizationManager.text(it: "Apri", en: "Open"))
                                            .font(UniFont.caption())
                                    }
                                }
                                .buttonStyle(.bordered)
                                .help(file.isDirectory ? localizationManager.text(it: "Apri cartella nel Finder", en: "Open folder in Finder") : localizationManager.text(it: "Apri il file con l'app di default", en: "Open file with default application"))
                                
                                // Pulsante Mostra nel Finder
                                Button {
                                    AppSystemHelper.revealInFinder(path: file.filePath)
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 11))
                                }
                                .buttonStyle(.bordered)
                                .help(localizationManager.text(it: "Mostra nel Finder dove si trova", en: "Reveal in Finder"))
                                
                                // Pulsante Scollega
                                Button(role: .destructive) {
                                    fileToDelete = file
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help(file.isDirectory ? localizationManager.text(it: "Scollega cartella dal corso", en: "Unlink folder from course") : localizationManager.text(it: "Scollega file dal corso", en: "Unlink file from course"))
                            }
                        }
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                handleFileDrop(providers)
            }
        }
        .alert(
            localizationManager.text(it: "Scollega File / Cartella", en: "Unlink File / Folder"),
            isPresented: Binding(get: { fileToDelete != nil }, set: { if !$0 { fileToDelete = nil } }),
            presenting: fileToDelete
        ) { file in
            Button(localizationManager.t(.cancel), role: .cancel) { fileToDelete = nil }
            Button(localizationManager.t(.delete), role: .destructive) {
                SoundManager.shared.play(.remove)
                course.linkedFiles.removeAll { $0.id == file.id }
                dataManager.saveData()
                fileToDelete = nil
            }
        } message: { file in
            Text(localizationManager.text(
                it: "Sei sicuro di voler scollegare \"\(file.name)\" dal corso?",
                en: "Are you sure you want to unlink \"\(file.name)\" from this course?"
            ))
        }
    }
    
    // MARK: - 3. Quick Scratchpad Section (All'interno del blocco sinistro)
    private var quickScratchpadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "BLOCCO NOTE RAPIDO / AULA", en: "QUICK SCRATCHPAD / LECTURE"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                }
                
                Spacer()
                
                if !quickNotesText.isEmpty {
                    Text("\(quickNotesText.count) " + localizationManager.text(it: "caratteri", en: "chars"))
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $quickNotesText)
                    .font(.system(size: 12, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 95, maxHeight: 180)
                    .overlay(alignment: .topLeading) {
                        if quickNotesText.isEmpty {
                            Text(localizationManager.text(
                                it: "Scrivi qui appunti veloci d'aula, promemoria del docente, link Teams o formule al volo. Si salvano automaticamente...",
                                en: "Type quick class notes, professor reminders, meeting codes or formulas. Auto-saves..."
                            ))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary.opacity(0.6))
                            .padding(.top, 4)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                        }
                    }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.green.opacity(0.8))
                    Text(localizationManager.text(it: "Salvataggio automatico attivo", en: "Auto-saved"))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if !quickNotesText.isEmpty {
                        Button {
                            quickNotesText = ""
                        } label: {
                            Text(localizationManager.text(it: "Cancella", en: "Clear"))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.07), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 4. Notes Section (All'interno del blocco sinistro)
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.system(size: 11))
                        .foregroundStyle(courseColor)
                    Text(localizationManager.text(it: "NOTE & MATERIALI DI STUDIO", en: "NOTES & STUDY MATERIALS"))
                        .font(UniFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                }
                
                Spacer()
                
                Button(localizationManager.text(it: "Modifica", en: "Edit")) {
                    onEdit()
                }
                .font(UniFont.caption())
                .foregroundStyle(themeManager.accentColor)
                .buttonStyle(.plain)
            }
            
            if !course.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(course.notes)
                    .font(UniFont.body())
                    .foregroundStyle(.primary.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.primary.opacity(0.02), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            } else {
                Text(localizationManager.text(it: "Nessuna nota o indicazione inserita. Fai clic su Modifica per aggiungere appunti, libri di testo o programma.", en: "No notes added yet. Click Edit to add notes, textbooks, or syllabus."))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.primary.opacity(0.015), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Linked Files & Folders Helpers
    private func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        var didHandle = false
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            self.linkFileURL(url)
                        }
                    }
                }
                didHandle = true
            } else {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            self.linkFileURL(url)
                        }
                    } else if let url = item as? URL {
                        DispatchQueue.main.async {
                            self.linkFileURL(url)
                        }
                    }
                }
                didHandle = true
            }
        }
        return didHandle
    }
    
    private func linkFileURL(_ url: URL) {
        SoundManager.shared.play(.pop)
        let path = url.path
        let fileName = url.lastPathComponent
        guard !fileName.isEmpty else { return }
        
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        let isDirectory = isDir.boolValue
        
        if !course.linkedFiles.contains(where: { $0.filePath == path }) {
            let size = AppSystemHelper.formatFileSize(atPath: path)
            let bookmark = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            let linked = CourseLinkedFile(
                name: fileName,
                filePath: path,
                fileSize: size,
                fileTypeExtension: isDirectory ? "" : url.pathExtension.lowercased(),
                isDirectory: isDirectory,
                bookmarkData: bookmark
            )
            course.linkedFiles.append(linked)
            dataManager.saveData()
            
            let isEn = localizationManager.currentLanguage == .english
            let itemType = isDirectory ? (isEn ? "Folder" : "Cartella") : (isEn ? "File" : "File")
            
            NotificationManager.shared.notify(
                title: isDirectory
                    ? (isEn ? "Folder linked to course" : "Cartella collegata al corso")
                    : (isEn ? "File linked to course" : "File collegato al corso"),
                message: "\(fileName) (\(itemType)) → \(course.name)",
                type: .success,
                icon: isDirectory ? "folder.badge.plus" : "link.badge.plus"
            )
        }
    }
    
    private func selectAndLinkFiles() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.prompt = localizationManager.text(it: "Collega", en: "Link")
        panel.message = localizationManager.text(
            it: "Seleziona file o intere cartelle da collegare a questo corso (non verranno duplicati né spostati)",
            en: "Select files or entire folders to link to this course (they will not be duplicated or moved)"
        )
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                linkFileURL(url)
            }
        }
        #endif
    }
    
    private func iconForFileExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "doc.richtext"
        case "doc", "docx", "pages", "txt", "rtf", "md": return "doc.text"
        case "xls", "xlsx", "numbers", "csv": return "tablecells"
        case "ppt", "pptx", "key": return "play.rectangle"
        case "zip", "rar", "7z", "tar", "gz": return "archivebox"
        case "swift", "py", "java", "c", "cpp", "js", "ts", "html", "css": return "curlybraces"
        case "png", "jpg", "jpeg", "heic", "webp": return "photo"
        case "": return "folder.fill"
        default: return "doc"
        }
    }
}


// MARK: - Modal Editor Corso (Polished macOS Sheet)
struct CourseEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var courseToEdit: Course?
    var onSave: (Course) -> Void
    
    @State private var name: String = ""
    @State private var code: String = ""
    @State private var cfu: Int = 6
    @State private var professor: String = ""
    @State private var professorEmail: String = ""
    @State private var professorEmails: [String] = [""]
    @State private var room: String = ""
    @State private var semester: Int = 1
    @State private var academicYear: Int = 1
    @State private var isAttendanceMandatory: Bool = false
    @State private var targetAttendancePercentage: Int = 75
    @State private var notionURL: String = ""
    @State private var notes: String = ""
    @State private var colorHex: String = "#0D5BFF"
    
    init(courseToEdit: Course?, onSave: @escaping (Course) -> Void) {
        self.courseToEdit = courseToEdit
        self.onSave = onSave
        _name = State(initialValue: courseToEdit?.name ?? "")
        _code = State(initialValue: courseToEdit?.code ?? "")
        _cfu = State(initialValue: courseToEdit?.cfu ?? 6)
        _professor = State(initialValue: courseToEdit?.professor ?? "")
        _professorEmail = State(initialValue: courseToEdit?.professorEmail ?? "")
        let existingEmails = courseToEdit?.allProfessorEmails ?? []
        _professorEmails = State(initialValue: existingEmails.isEmpty ? [""] : existingEmails)
        _room = State(initialValue: courseToEdit?.room ?? "")
        _semester = State(initialValue: courseToEdit?.semester ?? 1)
        _academicYear = State(initialValue: courseToEdit?.academicYear ?? 1)
        _isAttendanceMandatory = State(initialValue: courseToEdit?.isAttendanceMandatory ?? false)
        _targetAttendancePercentage = State(initialValue: courseToEdit?.targetAttendancePercentage ?? 75)
        _notionURL = State(initialValue: courseToEdit?.notionURL ?? "")
        _notes = State(initialValue: courseToEdit?.notes ?? "")
        _colorHex = State(initialValue: courseToEdit?.colorHex ?? "#0D5BFF")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sheet Header
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "book.closed")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(courseToEdit == nil ? localizationManager.text(it: "Nuova Materia", en: "New Course") : localizationManager.text(it: "Modifica Materia", en: "Edit Course"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Inserisci i dati principali del corso di studi", en: "Enter key course information"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            // Sheet Form
            Form {
                Section(localizationManager.text(it: "Dati Principali", en: "Main Details")) {
                    TextField(localizationManager.text(it: "Nome Materia", en: "Course Name"), text: $name)
                    TextField(localizationManager.text(it: "Codice Corso", en: "Course Code"), text: $code)
                    Stepper(localizationManager.text(it: "Crediti: \(cfu) CFU", en: "Credits: \(cfu) CFU"), value: $cfu, in: 1...30)
                    
                    Picker(localizationManager.text(it: "Anno di Corso", en: "Academic Year"), selection: $academicYear) {
                        Text(localizationManager.text(it: "1° Anno", en: "1st Year")).tag(1)
                        Text(localizationManager.text(it: "2° Anno", en: "2nd Year")).tag(2)
                        Text(localizationManager.text(it: "3° Anno", en: "3rd Year")).tag(3)
                        Text(localizationManager.text(it: "4° Anno", en: "4th Year")).tag(4)
                        Text(localizationManager.text(it: "5° Anno", en: "5th Year")).tag(5)
                        Text(localizationManager.text(it: "6° Anno", en: "6th Year")).tag(6)
                    }
                    
                    Picker(localizationManager.text(it: "Semestre", en: "Semester"), selection: $semester) {
                        Text(localizationManager.text(it: "1° Semestre", en: "1st Semester")).tag(1)
                        Text(localizationManager.text(it: "2° Semestre", en: "2nd Semester")).tag(2)
                    }
                }
                
                Section(localizationManager.text(it: "Frequenza & Presenze", en: "Attendance")) {
                    Toggle(localizationManager.text(it: "Frequenza Obbligatoria", en: "Mandatory Attendance"), isOn: $isAttendanceMandatory)
                    if isAttendanceMandatory {
                        Stepper(localizationManager.text(it: "Minimo Richiesto: \(targetAttendancePercentage)%", en: "Minimum Required: \(targetAttendancePercentage)%"), value: $targetAttendancePercentage, in: 50...100, step: 5)
                    }
                }
                
                Section(localizationManager.text(it: "Docente & Sede", en: "Professor & Location")) {
                    TextField(localizationManager.text(it: "Nome Docente", en: "Professor Name"), text: $professor)
                    
                    // Email Docenti con pulsante "+" per aggiungerne altre
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(localizationManager.text(it: "Email Docente / Collaboratori:", en: "Professor / Assistants Email:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    professorEmails.append("")
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 9, weight: .bold))
                                    Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                                        .font(UniFont.caption())
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(themeManager.accentColor.opacity(0.12))
                                .foregroundStyle(themeManager.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Aggiungi un'altra email per questo corso", en: "Add another email for this course"))
                        }
                        
                        ForEach(professorEmails.indices, id: \.self) { idx in
                            HStack(spacing: 8) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                
                                TextField(
                                    idx == 0
                                        ? localizationManager.text(it: "es. docente@universita.it", en: "e.g. professor@university.edu")
                                        : localizationManager.text(it: "Altra email (co-docente, assistente...)", en: "Additional email (co-lecturer, assistant...)"),
                                    text: $professorEmails[idx]
                                )
                                .textFieldStyle(.plain)
                                
                                if professorEmails.count > 1 {
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            professorEmails.remove(at: idx)
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.red.opacity(0.85))
                                    }
                                    .buttonStyle(.plain)
                                    .help(localizationManager.text(it: "Rimuovi questa email", en: "Remove this email"))
                                }
                            }
                        }
                    }
                    
                    TextField(localizationManager.text(it: "Aula", en: "Classroom"), text: $room)
                }
                
                Section(localizationManager.text(it: "Link Notion", en: "Notion Link")) {
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.text(it: "Link Notion", en: "Notion Link"), text: $notionURL)
                    }
                }
                
                Section(localizationManager.text(it: "Colore Materia", en: "Course Color")) {
                    HStack(spacing: 8) {
                        ForEach(["#0D5BFF", "#10B981", "#8B5CF6", "#F59E0B", "#EF4444", "#06B6D4", "#EC4899", "#6366F1"], id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 2 : 0)
                                )
                                .onTapGesture {
                                    colorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(localizationManager.text(it: "Note", en: "Notes")) {
                    TextField(localizationManager.text(it: "Note / Libri di testo", en: "Notes / Textbooks"), text: $notes)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            // Sheet Footer
            HStack {
                Button(localizationManager.t(.cancel)) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(localizationManager.text(it: "Salva", en: "Save")) {
                    let cleanEmails = professorEmails.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    let primaryEmail = cleanEmails.first ?? ""
                    let updated = Course(
                        id: courseToEdit?.id ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        code: code.trimmingCharacters(in: .whitespacesAndNewlines),
                        cfu: cfu,
                        professor: professor.trimmingCharacters(in: .whitespacesAndNewlines),
                        professorEmail: primaryEmail,
                        professorEmails: cleanEmails,
                        room: room.trimmingCharacters(in: .whitespacesAndNewlines),
                        semester: semester,
                        academicYear: academicYear,
                        isAttendanceMandatory: isAttendanceMandatory,
                        targetAttendancePercentage: targetAttendancePercentage,
                        attendedLectures: courseToEdit?.attendedLectures ?? 0,
                        totalLecturesCount: courseToEdit?.totalLecturesCount ?? 0,
                        notionURL: notionURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        links: courseToEdit?.links ?? [],
                        schedule: courseToEdit?.schedule ?? [],
                        colorHex: colorHex,
                        notes: notes,
                        linkedFiles: courseToEdit?.linkedFiles ?? [],
                        quickNotes: courseToEdit?.quickNotes ?? ""
                    )
                    onSave(updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 480, height: 600)
    }
}


// MARK: - Modal Aggiungi Link Esterno (Polished Sheet)
struct AddLinkSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    var onSave: (CourseLink) -> Void
    
    @State private var title: String = ""
    @State private var url: String = ""
    @State private var type: CourseLink.LinkType = .moodle
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "link")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Nuova Risorsa Esterna", en: "New External Resource"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Collega una pagina web, portale o cartella del corso", en: "Link a web page, portal or folder for this course"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section {
                    TextField(localizationManager.text(it: "Titolo (es. Portale Moodle, Teams, Drive)", en: "Title (e.g. Moodle Portal, Teams, Drive)"), text: $title)
                    TextField(localizationManager.text(it: "URL (https://...)", en: "URL (https://...)"), text: $url)
                    Picker(localizationManager.text(it: "Tipologia", en: "Type"), selection: $type) {
                        ForEach(CourseLink.LinkType.allCases, id: \.self) { kind in
                            Text(kind.localizedName).tag(kind)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Aggiungi", en: "Add")) {
                    let cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !cleanURL.isEmpty else { return }
                    let link = CourseLink(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? type.localizedName : title.trimmingCharacters(in: .whitespacesAndNewlines),
                        url: cleanURL,
                        type: type
                    )
                    onSave(link)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
                .disabled(url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 440, height: 300)
    }
}

// MARK: - Modal Aggiungi Orario (Polished Sheet)
struct AddScheduleSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    var onSave: (CourseSchedule) -> Void
    
    @State private var dayOfWeek: Int = 1
    @State private var startTime: String = "09:00"
    @State private var endTime: String = "11:00"
    @State private var room: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Orario di Lezione", en: "Class Schedule Slot"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Definisci il giorno e la fascia oraria", en: "Define the day and time slot"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section {
                    Picker(localizationManager.text(it: "Giorno", en: "Day"), selection: $dayOfWeek) {
                        Text(localizationManager.text(it: "Lunedì", en: "Monday")).tag(1)
                        Text(localizationManager.text(it: "Martedì", en: "Tuesday")).tag(2)
                        Text(localizationManager.text(it: "Mercoledì", en: "Wednesday")).tag(3)
                        Text(localizationManager.text(it: "Giovedì", en: "Thursday")).tag(4)
                        Text(localizationManager.text(it: "Venerdì", en: "Friday")).tag(5)
                        Text(localizationManager.text(it: "Sabato", en: "Saturday")).tag(6)
                    }
                    
                    TextField(localizationManager.text(it: "Ora Inizio (es. 09:00)", en: "Start Time (e.g. 09:00)"), text: $startTime)
                    TextField(localizationManager.text(it: "Ora Fine (es. 11:00)", en: "End Time (e.g. 11:00)"), text: $endTime)
                    TextField(localizationManager.text(it: "Aula (opzionale)", en: "Classroom (optional)"), text: $room)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Aggiungi", en: "Add")) {
                    let schedule = CourseSchedule(
                        dayOfWeek: dayOfWeek,
                        startTime: startTime.trimmingCharacters(in: .whitespacesAndNewlines),
                        endTime: endTime.trimmingCharacters(in: .whitespacesAndNewlines),
                        room: room.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    onSave(schedule)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
            }
            .padding(16)
        }
        .frame(width: 420, height: 320)
    }
}
