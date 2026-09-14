//
//  ContentView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var updateManager: UpdateManager
    @EnvironmentObject var outlookManager: OutlookManager
    
    @State private var selectedTab: String = "dashboard"
    
    // Quick Search & Focus Timer Modals
    @State private var isShowingQuickSearch = false
    @State private var isShowingFocusTimer = false
    @State private var isShowingOnboarding = false
    
    // Global Contextual Creation Sheets (⌘N)
    @State private var isPresentingNewDeadlineSheet = false
    @State private var isPresentingNewExamSheet = false
    @State private var isPresentingNewAssignmentSheet = false
    @State private var isPresentingNewCourseSheet = false
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Brand Logo ("uni" in minuscolo) con tasto rapido Spotlight ⌘K
                    HStack(spacing: 8) {
                        // App icon
                        #if canImport(AppKit)
                        if let nsImg = NSImage(named: "AppIcon") {
                            Image(nsImage: nsImg)
                                .resizable()
                                .interpolation(.high)
                                .frame(width: 22, height: 22)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
                        }
                        #endif
                        
                        Text("uni")
                            .font(UniFont.title())
                            .fontWeight(.semibold)
                            .tracking(-0.6)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Tasto Rapido Ricerca Spotlight ⌘F
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isShowingQuickSearch.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("⌘F")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.06))
                            .overlay(Rectangle().stroke(Color.primary.opacity(0.12), lineWidth: 1))
                            .clipShape(Rectangle())
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Cerca rapidamente in tutto uni (⌘F)", en: "Quick search throughout uni (⌘F)"))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                    
                    // Update available banner (shown above nav when a new release is ready)
                    UpdateBannerView()
                        .environmentObject(themeManager)
                        .environmentObject(localizationManager)
                    
                    Divider()
                        .padding(.bottom, 6)
                    
                    // Voci di Navigazione
                    List(selection: $selectedTab) {
                        Section {
                            NavigationLink(value: "dashboard") {
                                Label(localizationManager.t(.navOverview), systemImage: "square.grid.2x2")
                                    .font(UniFont.body())
                            }
                            
                            NavigationLink(value: "calendar") {
                                Label(localizationManager.t(.navCalendar), systemImage: "calendar")
                                    .font(UniFont.body())
                            }
                            
                            // Pomodoro Timer
                            Button {
                                isShowingFocusTimer = true
                            } label: {
                                HStack {
                                    Label("Focus Timer", systemImage: "timer")
                                        .font(UniFont.body())
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("⌘T")
                                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        } header: {
                            Text(localizationManager.t(.navGeneral).uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                        }
                        
                        // Sezione Materie / Didattica
                        Section {
                            NavigationLink(value: "courses") {
                                HStack {
                                    Label(localizationManager.t(.navCourses), systemImage: "book.closed")
                                        .font(UniFont.body())
                                    Spacer()
                                    if !dataManager.courses.isEmpty {
                                        Text("\(dataManager.courses.count)")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } header: {
                            Text(localizationManager.t(.navCoursesSection).uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                        }
                        
                        // Sezione Scadenze, Esami & Assignments
                        Section {
                            NavigationLink(value: "deadlines") {
                                HStack {
                                    Label(localizationManager.t(.navDeadlines), systemImage: "clock")
                                        .font(UniFont.body())
                                    Spacer()
                                    let count = dataManager.deadlines.filter { !$0.isCompleted }.count
                                    if count > 0 {
                                        Text("\(count)")
                                            .font(.system(size: 9.5, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(themeManager.accentColor.opacity(0.18))
                                            .foregroundStyle(themeManager.accentColor)
                                            .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                            .clipShape(Rectangle())
                                    }
                                }
                            }
                            
                            NavigationLink(value: "exams") {
                                HStack {
                                    Label(localizationManager.t(.navExams), systemImage: "graduationcap")
                                        .font(UniFont.body())
                                    Spacer()
                                    let upcoming = dataManager.exams.filter { $0.status != .passed }.count
                                    if upcoming > 0 {
                                        Text("\(upcoming)")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            NavigationLink(value: "assignments") {
                                HStack {
                                    Label(localizationManager.t(.navAssignments), systemImage: "doc.text")
                                        .font(UniFont.body())
                                    Spacer()
                                    let count = dataManager.assignments.filter { !$0.isCompleted }.count
                                    if count > 0 {
                                        Text("\(count)")
                                            .font(UniFont.caption())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } header: {
                            Text(localizationManager.t(.navActivitiesSection).uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                        }
                        
                        Section {
                            NavigationLink(value: "settings") {
                                Label(localizationManager.t(.navSettings), systemImage: "gearshape")
                                    .font(UniFont.body())
                            }
                        } header: {
                            Text((localizationManager.currentLanguage == .italian ? "SISTEMA" : "SYSTEM").uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                        }
                    }
                    .listStyle(.sidebar)
                    
                    // Footer Statistiche Architettonico (con indicatore di avanzamento a blocco)
                    if dataManager.weightedAverage > 0 || dataManager.totalCfuTarget > 0 {
                        VStack(spacing: 8) {
                            Divider()
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(localizationManager.t(.currentGPA).uppercased())
                                            .font(UniFont.sectionLabel())
                                            .foregroundStyle(.secondary)
                                            .tracking(1.0)
                                        Text(dataManager.weightedAverage > 0 ? String(format: "%.2f", dataManager.weightedAverage) : "--")
                                            .font(UniFont.headline())
                                            .foregroundStyle(themeManager.accentColor)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(localizationManager.t(.totalCredits).uppercased())
                                            .font(UniFont.sectionLabel())
                                            .foregroundStyle(.secondary)
                                            .tracking(1.0)
                                        Text("\(dataManager.totalCfuAcquired) / \(dataManager.totalCfuTarget)")
                                            .font(UniFont.headline())
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Barra Inferiore Sidebar con Bottone Mail Outlook
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            Button {
                                outlookManager.openOutlook()
                            } label: {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(themeManager.accentColor)
                                    .frame(width: 28, height: 28)
                                    .background(themeManager.accentColor.opacity(0.12))
                                    .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                                    .clipShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .help(localizationManager.text(it: "Apri Microsoft Outlook / Posta", en: "Open Microsoft Outlook / Mail"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                }
                .navigationSplitViewColumnWidth(min: 210, ideal: 240, max: 280)
            } detail: {
                Group {
                    switch selectedTab {
                    case "dashboard":
                        DashboardView(selectedTab: $selectedTab)
                    case "calendar":
                        CalendarView()
                    case "courses":
                        CoursesView()
                    case "deadlines":
                        DeadlinesView()
                    case "exams":
                        ExamsView()
                    case "assignments":
                        AssignmentsView()
                    case "settings":
                        SettingsView()
                    default:
                        DashboardView(selectedTab: $selectedTab)
                    }
                }
                .frame(minWidth: 620, minHeight: 520)
                .preferredColorScheme(themeManager.themeMode.colorScheme)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isShowingQuickSearch = true
                            }
                        } label: {
                            Label(localizationManager.text(it: "Cerca (⌘F)", en: "Search (⌘F)"), systemImage: "magnifyingglass")
                        }
                        .help(localizationManager.text(it: "Ricerca globale e comandi rapidi (⌘F)", en: "Global search and quick commands (⌘F)"))
                        
                        Button {
                            isShowingFocusTimer.toggle()
                        } label: {
                            Label(localizationManager.text(it: "Focus Timer (⌘T)", en: "Focus Timer (⌘T)"), systemImage: "timer")
                        }
                        .help(localizationManager.text(it: "Avvia sessione di studio con Focus Timer (⌘T)", en: "Start a Focus Timer study session (⌘T)"))
                        
                        Button {
                            triggerContextualNew()
                        } label: {
                            Label(localizationManager.text(it: "Nuovo (⌘N)", en: "New (⌘N)"), systemImage: "plus")
                        }
                        .help(localizationManager.text(it: "Aggiungi elemento contestuale (⌘N)", en: "Add contextual item (⌘N)"))
                    }
                }
            }
            
            // Quick Search Palette Modal Overlay (⌘F)
            if isShowingQuickSearch {
                QuickSearchPaletteView(
                    isPresented: $isShowingQuickSearch,
                    selectedTab: $selectedTab,
                    onOpenNewDeadline: { isPresentingNewDeadlineSheet = true },
                    onOpenNewExam: { isPresentingNewExamSheet = true },
                    onOpenNewAssignment: { isPresentingNewAssignmentSheet = true },
                    onOpenNewCourse: { isPresentingNewCourseSheet = true },
                    onOpenFocusTimer: { isShowingFocusTimer = true }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        // In-App Toast HUD Modifier
        .toastHUD()
        // Focus Study Timer Sheet
        .sheet(isPresented: $isShowingFocusTimer) {
            FocusTimerView()
        }
        // Contextual Creation Sheets (Triggered by ⌘N or ⌘K)
        .sheet(isPresented: $isPresentingNewDeadlineSheet) {
            DeadlineEditorSheet(deadlineToEdit: nil) { newOne in
                dataManager.deadlines.append(newOne)
                dataManager.saveData()
                NotificationManager.shared.notify(
                    title: localizationManager.t(.deadlineCreated),
                    message: newOne.title,
                    type: .success,
                    icon: "clock.badge.checkmark"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                let courseName = dataManager.courses.first(where: { $0.id == newOne.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(deadline: newOne, courseName: courseName) }
            }
        }
        .sheet(isPresented: $isPresentingNewExamSheet) {
            ExamEditorSheet(examToEdit: nil) { newExam in
                dataManager.exams.append(newExam)
                dataManager.saveData()
                NotificationManager.shared.notify(
                    title: localizationManager.t(.examScheduled),
                    message: newExam.title,
                    type: .info,
                    icon: "calendar.badge.plus"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                let courseName = dataManager.courses.first(where: { $0.id == newExam.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(exam: newExam, courseName: courseName) }
            }
        }
        .sheet(isPresented: $isPresentingNewAssignmentSheet) {
            AssignmentEditorSheet(assignmentToEdit: nil) { newOne in
                dataManager.assignments.append(newOne)
                dataManager.saveData()
                NotificationManager.shared.notify(
                    title: localizationManager.t(.assignmentCreated),
                    message: newOne.title,
                    type: .success,
                    icon: "doc.badge.plus"
                )
                let courseName = dataManager.courses.first(where: { $0.id == newOne.courseId })?.name
                Task { await AppleCalendarManager.shared.sync(assignment: newOne, courseName: courseName) }
            }
        }
        .sheet(isPresented: $isPresentingNewCourseSheet) {
            CourseEditorSheet(courseToEdit: nil) { newCourse in
                dataManager.courses.append(newCourse)
                dataManager.saveData()
                NotificationManager.shared.notify(
                    title: localizationManager.t(.courseAdded(newCourse.name, newCourse.cfu)),
                    type: .success,
                    icon: "book.closed.fill"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        // Global Keyboard Shortcuts
        .background(
            HStack {
                // ⌘1 ... ⌘6 Tab Switching
                Button("") { selectedTab = "dashboard" }.keyboardShortcut("1", modifiers: [.command])
                Button("") { selectedTab = "calendar" }.keyboardShortcut("2", modifiers: [.command])
                Button("") { selectedTab = "courses" }.keyboardShortcut("3", modifiers: [.command])
                Button("") { selectedTab = "deadlines" }.keyboardShortcut("4", modifiers: [.command])
                Button("") { selectedTab = "exams" }.keyboardShortcut("5", modifiers: [.command])
                Button("") { selectedTab = "assignments" }.keyboardShortcut("6", modifiers: [.command])
                Button("") { selectedTab = "settings" }.keyboardShortcut(",", modifiers: [.command])
                
                // ⌘F Spotlight Search
                Button("") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isShowingQuickSearch.toggle()
                    }
                }.keyboardShortcut("f", modifiers: [.command])
                
                // ⌘T Focus Timer
                Button("") {
                    isShowingFocusTimer.toggle()
                }.keyboardShortcut("t", modifiers: [.command])
                
                // ⌘N Contextual New Item
                Button("") {
                    triggerContextualNew()
                }.keyboardShortcut("n", modifiers: [.command])
            }
            .frame(width: 0, height: 0)
            .opacity(0)
        )
        .sheet(isPresented: $isShowingOnboarding) {
            OnboardingWizardView()
        }
        .onAppear {
            if !dataManager.hasCompletedOnboarding {
                isShowingOnboarding = true
            }
            NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleAllReminders(
                deadlines: dataManager.deadlines,
                exams: dataManager.exams,
                courses: dataManager.courses
            )
            AppleCalendarManager.shared.refreshStatus()
        }
    }
    
    private func triggerContextualNew() {
        switch selectedTab {
        case "courses":
            isPresentingNewCourseSheet = true
        case "exams":
            isPresentingNewExamSheet = true
        case "assignments":
            isPresentingNewAssignmentSheet = true
        default:
            // Per dashboard, calendar, deadlines
            isPresentingNewDeadlineSheet = true
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager.shared)
            .environmentObject(ThemeManager.shared)
            .environmentObject(LocalizationManager.shared)
            .environmentObject(QuoteManager.shared)
    }
}
#endif
