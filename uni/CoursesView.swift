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
            // Header Superiore con Titolo, Azioni e Barra di Ricerca
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    UniHeader(
                        localizationManager.t(.coursesTitle),
                        subtitle: "\(dataManager.courses.count) \(localizationManager.t(.navCourses).lowercased())"
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        if !dataManager.syncedEvents.isEmpty {
                            Button {
                                dataManager.resyncAllCourseSchedules()
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(localizationManager.text(it: "Ricalcola orari da calendario", en: "Recalculate schedule"))
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
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(themeManager.accentColor)
                            .foregroundStyle(themeManager.accentTextColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: themeManager.accentColor.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                
                // Barra Ricerca Compatta (se ci sono corsi)
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
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
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Top Color Accent Bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(courseColor)
                    .frame(height: 5)
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Badge CFU & Codice
                    HStack(spacing: 5) {
                        Text("\(course.cfu) CFU")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(courseColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(courseColor.opacity(0.14), in: Capsule())
                        
                        if !course.code.isEmpty {
                            Text(course.code)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 4))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(courseColor)
                        }
                    }
                    
                    // Titolo Corso
                    Text(course.name)
                        .font(UniFont.headline())
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 4)
                    
                    // Docente
                    if !course.professor.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 9))
                            Text(course.professor)
                                .lineLimit(1)
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    }
                    
                    // Badge Aula & Risorse
                    HStack(spacing: 6) {
                        if !course.room.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 8))
                                Text(course.room)
                                    .lineLimit(1)
                            }
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !course.linkedFiles.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "folder.fill")
                                Text("\(course.linkedFiles.count)")
                            }
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                        }
                        
                        if !course.links.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "link")
                                Text("\(course.links.count)")
                            }
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
            }
            .frame(width: 195, height: 145)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? courseColor.opacity(0.10) : (isHovered ? Color.primary.opacity(0.04) : Color.primary.opacity(0.02)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? courseColor : (isHovered ? Color.primary.opacity(0.25) : Color.primary.opacity(0.1)), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? courseColor.opacity(0.18) : Color.black.opacity(0.03), radius: isSelected ? 8 : 2, x: 0, y: isSelected ? 4 : 1)
        }
        .buttonStyle(.plain)
        .onHover { h in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = h
            }
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
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentColor.opacity(isHovered ? 0.18 : 0.08))
                        .frame(width: 38, height: 38)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                Text(localizationManager.text(it: "Nuova Materia", en: "New Course"))
                    .font(UniFont.subheadline())
                    .fontWeight(.medium)
                    .foregroundStyle(isHovered ? themeManager.accentColor : .primary)
                
                Text(localizationManager.text(it: "Aggiungi al piano", en: "Add to plan"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140, height: 145)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovered ? themeManager.accentColor.opacity(0.04) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .foregroundStyle(isHovered ? themeManager.accentColor : Color.primary.opacity(0.18))
            )
        }
        .buttonStyle(.plain)
        .onHover { h in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = h
            }
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
    
    var courseColor: Color {
        Color(hex: course.colorHex) ?? themeManager.accentColor
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Banner Superiore con Identità Materia & Azioni Rapide
                courseHeaderCard
                
                // 2. Card Notion Workspace (In Evidenza)
                notionDesktopCard
                
                // 3. Layout a Due Colonne Modulari
                HStack(alignment: .top, spacing: 18) {
                    // Colonna Sinistra: Orario Settimanale + Risorse Esterne
                    VStack(alignment: .leading, spacing: 18) {
                        scheduleModule
                        externalLinksModule
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    // Colonna Destra: File & Cartelle Collegate + Note
                    VStack(alignment: .leading, spacing: 18) {
                        linkedFilesModule
                        notesModule
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Course Header Card
    private var courseHeaderCard: some View {
        UniCard(padding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
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
                            
                            Text(localizationManager.text(it: "\(course.semester)° Semestre", en: "Semester \(course.semester)"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(course.name)
                            .font(UniFont.largeTitle())
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {
                            onEdit()
                        } label: {
                            HStack(spacing: 5) {
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
                            HStack(spacing: 5) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                Text(localizationManager.text(it: "Elimina", en: "Delete"))
                                    .font(UniFont.caption())
                            }
                        }
                        .buttonStyle(.bordered)
                        .help(localizationManager.text(it: "Elimina materia", en: "Delete course"))
                    }
                }
                
                Divider()
                
                // Docente, Email & Aula
                HStack(spacing: 16) {
                    if !course.professor.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(courseColor)
                            Text(course.professor)
                                .font(UniFont.subheadline())
                                .fontWeight(.medium)
                        }
                    }
                    
                    if !course.professorEmail.isEmpty {
                        Button {
                            if let mailURL = URL(string: "mailto:\(course.professorEmail)") {
                                #if canImport(AppKit)
                                NSWorkspace.shared.open(mailURL)
                                #endif
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 11))
                                Text(course.professorEmail)
                                    .font(UniFont.subheadline())
                                    .underline()
                            }
                            .foregroundStyle(themeManager.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Invia email al docente", en: "Send email to professor"))
                    }
                    
                    if !course.room.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Text(course.room)
                                .font(UniFont.subheadline())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
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
    
    // MARK: - Schedule Module
    private var scheduleModule: some View {
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
                UniEmptyStateView(
                    icon: "clock",
                    title: localizationManager.text(it: "Nessun orario impostato", en: "No schedule"),
                    subtitle: localizationManager.text(it: "Inserisci i giorni e le ore delle lezioni di questo corso.", en: "Enter days and times of classes."),
                    buttonTitle: localizationManager.text(it: "Aggiungi Orario", en: "Add Schedule")
                ) {
                    onAddSchedule()
                }
            } else {
                VStack(spacing: 7) {
                    ForEach(course.schedule) { slot in
                        UniCard(padding: 10) {
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
                        }
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
                                    AppSystemHelper.openLocalFile(path: file.filePath)
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
    
    // MARK: - Notes Module
    private var notesModule: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            
            UniCard(padding: 12) {
                if !course.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(course.notes)
                        .font(UniFont.body())
                        .foregroundStyle(.primary.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(localizationManager.text(it: "Nessuna nota o indicazione inserita. Fai clic su Modifica per aggiungere appunti, libri di testo o programma.", en: "No notes added yet. Click Edit to add notes, textbooks, or syllabus."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
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
            let linked = CourseLinkedFile(
                name: fileName,
                filePath: path,
                fileSize: size,
                fileTypeExtension: isDirectory ? "" : url.pathExtension.lowercased(),
                isDirectory: isDirectory
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
    @State private var room: String = ""
    @State private var semester: Int = 1
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
        _room = State(initialValue: courseToEdit?.room ?? "")
        _semester = State(initialValue: courseToEdit?.semester ?? 1)
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
                    Picker(localizationManager.text(it: "Semestre", en: "Semester"), selection: $semester) {
                        Text(localizationManager.text(it: "1° Semestre", en: "1st Semester")).tag(1)
                        Text(localizationManager.text(it: "2° Semestre", en: "2nd Semester")).tag(2)
                    }
                }
                
                Section(localizationManager.text(it: "Docente & Sede", en: "Professor & Location")) {
                    TextField(localizationManager.text(it: "Nome Docente", en: "Professor Name"), text: $professor)
                    TextField(localizationManager.text(it: "Email Docente", en: "Professor Email"), text: $professorEmail)
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
                    let updated = Course(
                        id: courseToEdit?.id ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        code: code.trimmingCharacters(in: .whitespacesAndNewlines),
                        cfu: cfu,
                        professor: professor.trimmingCharacters(in: .whitespacesAndNewlines),
                        professorEmail: professorEmail.trimmingCharacters(in: .whitespacesAndNewlines),
                        room: room.trimmingCharacters(in: .whitespacesAndNewlines),
                        semester: semester,
                        notionURL: notionURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        links: courseToEdit?.links ?? [],
                        schedule: courseToEdit?.schedule ?? [],
                        colorHex: colorHex,
                        notes: notes,
                        linkedFiles: courseToEdit?.linkedFiles ?? []
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
        .frame(width: 480, height: 560)
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
