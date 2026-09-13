//
//  CoursesView.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
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
        HSplitView {
            // Colonna Elenco Corsi
            VStack(alignment: .leading, spacing: 12) {
                UniHeader(
                    localizationManager.t(.coursesTitle),
                    subtitle: "\(dataManager.courses.count) \(localizationManager.t(.navCourses).lowercased())",
                    actionTitle: localizationManager.t(.newCourseAction)
                ) {
                    isPresentingNewCourseSheet = true
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Barra di Ricerca
                if !dataManager.courses.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        TextField(localizationManager.t(.searchCoursesPlaceholder), text: $searchText)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                        
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
                    .padding(7)
                    .background(Color.primary.opacity(0.04))
                    .padding(.horizontal, 16)
                }
                
                if !dataManager.syncedEvents.isEmpty {
                    HStack {
                        Button {
                            dataManager.resyncAllCourseSchedules()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Ricalcola orari da calendario")
                            }
                            .font(UniFont.caption())
                            .foregroundStyle(themeManager.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help("Ricalcola automaticamente tutti gli orari settimanali dei corsi dagli eventi sincronizzati")
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                
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
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                } else {
                    List(selection: $selectedCourse) {
                        ForEach(filteredCourses) { course in
                            CourseRowView(course: course, isSelected: selectedCourse?.id == course.id)
                                .tag(course)
                                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
            .frame(minWidth: 220, idealWidth: 260, maxWidth: 340)
            
            // Colonna Dettaglio Corso Selezionato
            if let course = selectedCourse {
                CourseDetailView(
                    course: binding(for: course),
                    onEdit: { isPresentingEditCourseSheet = true },
                    onDelete: { deleteCourse(course) },
                    onAddLink: { isPresentingAddLinkSheet = true },
                    onAddSchedule: { isPresentingAddScheduleSheet = true }
                )
                .frame(minWidth: 360)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(localizationManager.t(.selectCoursePlaceholder))
                        .font(UniFont.headline())
                        .foregroundStyle(.secondary)
                    Text(localizationManager.t(.selectCourseDesc))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
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

// MARK: - Course Row
struct CourseRowView: View {
    let course: Course
    let isSelected: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: course.colorHex) ?? themeManager.accentColor)
                .frame(width: 7, height: 7)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(UniFont.headline())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 5) {
                    Text("\(course.cfu) CFU")
                    if !course.code.isEmpty {
                        Text("•")
                        Text(course.code)
                    }
                }
                .font(UniFont.caption())
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? themeManager.accentColor.opacity(0.12) : Color.clear)
        )
    }
}

// MARK: - Course Detail View
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header Materia
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                if !course.code.isEmpty {
                                    Text(course.code)
                                        .font(UniFont.caption())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.primary.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                Text("\(course.cfu) CFU")
                                    .font(UniFont.caption())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(themeManager.accentColor)
                                
                                Text("Semestre \(course.semester)")
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(course.name)
                                .font(UniFont.largeTitle())
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Button {
                                onEdit()
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.bordered)
                            .help("Modifica materia")
                            
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.bordered)
                            .help("Elimina materia")
                        }
                    }
                    
                    // Docente, Email & Aula
                    HStack(spacing: 14) {
                        if !course.professor.isEmpty {
                            HStack(spacing: 5) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                Text(course.professor)
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
                                        .font(.system(size: 10))
                                    Text(course.professorEmail)
                                        .underline()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(themeManager.accentColor)
                        }
                        if !course.room.isEmpty {
                            HStack(spacing: 5) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 10))
                                Text(course.room)
                            }
                        }
                    }
                    .font(UniFont.subheadline())
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // NOTION DEEP-LINK
                VStack(alignment: .leading, spacing: 8) {
                    Text("NOTION DESKTOP")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    
                    UniCard(padding: 14) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.primary.opacity(0.04))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "book.pages.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizationManager.text(it: "Appunti del Corso su Notion", en: "Course Notes on Notion"))
                                    .font(UniFont.headline())
                                Text(course.notionURL.isEmpty ? localizationManager.text(it: "Nessun link configurato.", en: "No link configured.") : localizationManager.text(it: "Apri workspace o pagina Notion", en: "Open Notion workspace or page"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            if !course.notionURL.isEmpty {
                                Button {
                                    AppSystemHelper.openNotionPage(urlString: course.notionURL)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arrow.up.forward.app.fill")
                                            .font(.system(size: 11))
                                        Text(localizationManager.text(it: "Apri in Notion", en: "Open in Notion"))
                                            .font(UniFont.subheadline())
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(themeManager.accentColor)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(localizationManager.text(it: "Collega Link", en: "Link Notion")) {
                                    onEdit()
                                }
                                .font(UniFont.subheadline())
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                // RISORSE & LINK ESTERNI
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("RISORSE & LINK ESTERNI")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        Spacer()
                        Button("+ Aggiungi Risorsa") {
                            onAddLink()
                        }
                        .font(UniFont.caption())
                        .foregroundStyle(themeManager.accentColor)
                        .buttonStyle(.plain)
                    }
                    
                    if course.links.isEmpty {
                        UniEmptyStateView(
                            icon: "link",
                            title: "Nessuna risorsa esterna",
                            subtitle: "Collega portali del corso, canali Teams/Zoom, cartelle Drive o slide.",
                            buttonTitle: "Aggiungi Risorsa"
                        ) {
                            onAddLink()
                        }
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: .infinity), spacing: 8)], spacing: 8) {
                            ForEach(course.links) { link in
                                UniCard(padding: 10) {
                                    HStack(spacing: 8) {
                                        Image(systemName: link.type.iconName)
                                            .font(.system(size: 13))
                                            .foregroundStyle(themeManager.accentColor)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(link.title)
                                                .font(UniFont.headline())
                                                .lineLimit(1)
                                            Text(link.type.rawValue)
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
                                        .help("Apri nel browser")
                                        
                                        Button(role: .destructive) {
                                            course.links.removeAll { $0.id == link.id }
                                            dataManager.saveData()
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 9))
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ORARIO SETTIMANALE LEZIONI
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ORARIO SETTIMANALE")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        Spacer()
                        Button("+ Aggiungi Orario") {
                            onAddSchedule()
                        }
                        .font(UniFont.caption())
                        .foregroundStyle(themeManager.accentColor)
                        .buttonStyle(.plain)
                    }
                    
                    if course.schedule.isEmpty {
                        UniEmptyStateView(
                            icon: "clock",
                            title: "Nessun orario",
                            subtitle: "Inserisci i giorni e le ore delle lezioni.",
                            buttonTitle: "Aggiungi Orario"
                        ) {
                            onAddSchedule()
                        }
                    } else {
                        VStack(spacing: 6) {
                            ForEach(course.schedule) { slot in
                                UniCard(padding: 10) {
                                    HStack {
                                        Text(slot.dayName)
                                            .font(UniFont.headline())
                                            .frame(width: 90, alignment: .leading)
                                        
                                        Text("\(slot.startTime) - \(slot.endTime)")
                                            .font(UniFont.mono())
                                            .foregroundStyle(.secondary)
                                        
                                        if !slot.room.isEmpty {
                                            Text("•")
                                                .foregroundStyle(.secondary)
                                            Text(slot.room)
                                                .font(UniFont.subheadline())
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(role: .destructive) {
                                            course.schedule.removeAll { $0.id == slot.id }
                                            dataManager.saveData()
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 9))
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // DOCUMENTI & CARTELLE COLLEGATE (DRAG & DROP - NON COPIATI, MA COLLEGATI)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 6) {
                            Text(localizationManager.text(it: "DOCUMENTI & CARTELLE COLLEGATE", en: "DOCUMENTS & LINKED FOLDERS"))
                                .font(UniFont.caption())
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
                                Text(localizationManager.text(it: "Collega File o Cartella...", en: "Link Files or Folder..."))
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
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                                
                                Text(isDropTargeted ? localizationManager.text(it: "Rilascia qui per collegare al corso", en: "Drop here to link to course") : localizationManager.text(it: "Trascina qui file o intere cartelle dal Finder", en: "Drag & drop files or entire folders here from Finder"))
                                    .font(UniFont.subheadline())
                                    .fontWeight(.medium)
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : .primary)
                                
                                Text(localizationManager.text(it: "File e cartelle non vengono copiati: rimangono nella loro posizione originale sul Mac", en: "Files and folders are not copied: they stay in their original location on your Mac"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 22)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: isDropTargeted ? 2 : 1, dash: [5, 4])
                                    )
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : Color.primary.opacity(0.12))
                            )
                            .background(isDropTargeted ? themeManager.accentColor.opacity(0.08) : Color.clear)
                        } else {
                            // Drop Banner compatto quando ci sono già file o cartelle
                            HStack(spacing: 8) {
                                Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "folder.badge.plus")
                                    .font(.system(size: 13))
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                                Text(isDropTargeted ? localizationManager.text(it: "Rilascia per collegare", en: "Drop to link") : localizationManager.text(it: "Trascina qui altri file o cartelle per collegarli a questo corso", en: "Drag more files or folders here to link them to this course"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                                Spacer()
                            }
                            .padding(9)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                    .foregroundStyle(isDropTargeted ? themeManager.accentColor : Color.primary.opacity(0.1))
                            )
                            .background(isDropTargeted ? themeManager.accentColor.opacity(0.08) : Color.clear)
                            
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
                                                .foregroundStyle(file.isDirectory ? Color.blue : themeManager.accentColor)
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
                                                        .clipShape(RoundedRectangle(cornerRadius: 3))
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
                                            SoundManager.shared.play(.remove)
                                            course.linkedFiles.removeAll { $0.id == file.id }
                                            dataManager.saveData()
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
                
                // NOTE
                if !course.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NOTE")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        UniCard(padding: 12) {
                            Text(course.notes)
                                .font(UniFont.body())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(24)
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
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
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
