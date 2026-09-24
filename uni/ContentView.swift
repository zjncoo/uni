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
    @State private var isLoading: Bool = true
    
    // Animazione a cascata degli elementi UI (ispirata a Mastro)
    @State private var showSidebarUI: Bool = false
    @State private var showContentUI: Bool = false
    
    // Quick Search & Focus Timer Modals
    @State private var isShowingQuickSearch = false
    @State private var isShowingFocusTimer = false
    @State private var isShowingOnboarding = false
    
    // Global Contextual Creation Sheets (⌘N)
    @State private var isPresentingNewDeadlineSheet = false
    @State private var isPresentingNewExamSheet = false
    @State private var isPresentingNewAssignmentSheet = false
    @State private var isPresentingNewCourseSheet = false
    @State private var isShowingOverviewNewItemModal = false
    
    @Environment(\.colorScheme) private var systemColorScheme
    
    var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    private func triggerCascadingAnimation() {
        showSidebarUI = false
        showContentUI = false
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            showSidebarUI = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.78)) {
                showContentUI = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            UniBackgroundGradientView(isDarkMode: isDarkMode)
            
            if isLoading {
                UniSplashScreenView(dataManager: dataManager, isDarkMode: isDarkMode)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(500)
            } else {
                NavigationSplitView {
                    VStack(alignment: .leading, spacing: 0) {
                        if showSidebarUI {
                            sidebarHeader
                            
                            // Update available banner
                            UpdateBannerView()
                                .environmentObject(themeManager)
                                .environmentObject(localizationManager)
                            
                            Divider()
                                .opacity(isDarkMode ? 0.2 : 0.4)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 8)
                            
                            // Lista di Navigazione con Pulsanti Liquidi (stile Mastro)
                            ScrollView {
                                VStack(alignment: .leading, spacing: 14) {
                                    // Sezione Generale
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(localizationManager.t(.navGeneral).uppercased())
                                            .font(UniFont.sectionLabel())
                                            .foregroundStyle(.secondary)
                                            .tracking(1.4)
                                            .padding(.horizontal, 10)
                                            .padding(.bottom, 2)
                                        
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navOverview),
                                            icon: "square.grid.2x2",
                                            shortcutHint: "⌘1",
                                            isSelected: selectedTab == "dashboard",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "dashboard"
                                        }
                                        
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navCalendar),
                                            icon: "calendar",
                                            shortcutHint: "⌘2",
                                            isSelected: selectedTab == "calendar",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "calendar"
                                        }
                                        
                                        SidebarButtonLiquidUni(
                                            title: "Focus Timer",
                                            icon: "timer",
                                            shortcutHint: "⌘T",
                                            isSelected: false,
                                            isDark: isDarkMode
                                        ) {
                                            isShowingFocusTimer = true
                                        }
                                    }
                                    
                                    // Sezione Didattica / Materie
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(localizationManager.t(.navCoursesSection).uppercased())
                                            .font(UniFont.sectionLabel())
                                            .foregroundStyle(.secondary)
                                            .tracking(1.4)
                                            .padding(.horizontal, 10)
                                            .padding(.bottom, 2)
                                        
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navCourses),
                                            icon: "book.closed",
                                            count: dataManager.courses.count,
                                            shortcutHint: "⌘3",
                                            isSelected: selectedTab == "courses",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "courses"
                                        }
                                    }
                                    
                                    // Sezione Scadenze, Esami & Progetti
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(localizationManager.t(.navActivitiesSection).uppercased())
                                            .font(UniFont.sectionLabel())
                                            .foregroundStyle(.secondary)
                                            .tracking(1.4)
                                            .padding(.horizontal, 10)
                                            .padding(.bottom, 2)
                                        
                                        let activeDeadlines = dataManager.deadlines.filter { !$0.isCompleted }.count
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navDeadlines),
                                            icon: "clock",
                                            count: activeDeadlines,
                                            shortcutHint: "⌘4",
                                            isSelected: selectedTab == "deadlines",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "deadlines"
                                        }
                                        
                                        let pendingExams = dataManager.exams.filter { $0.status != .passed }.count
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navExams),
                                            icon: "graduationcap",
                                            count: pendingExams,
                                            shortcutHint: "⌘5",
                                            isSelected: selectedTab == "exams",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "exams"
                                        }
                                        
                                        let pendingAssignments = dataManager.assignments.filter { !$0.isCompleted }.count
                                        SidebarButtonLiquidUni(
                                            title: localizationManager.t(.navAssignments),
                                            icon: "doc.text",
                                            count: pendingAssignments,
                                            shortcutHint: "⌘6",
                                            isSelected: selectedTab == "assignments",
                                            isDark: isDarkMode
                                        ) {
                                            selectedTab = "assignments"
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                            
                            Spacer()
                            
                            // Statistiche Compatte Media & CFU
                            if dataManager.weightedAverage > 0 || dataManager.totalCfuTarget > 0 {
                                sidebarStatsFooter
                            }
                            
                            // BARRA INFERIORE NAVBAR: Impostazioni in basso a sinistra + Bottone Rapido Configurabile
                            sidebarBottomActionBar
                        }
                    }
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.06))
                            .frame(width: 1),
                        alignment: .trailing
                    )
                    .navigationSplitViewColumnWidth(min: 220, ideal: 245, max: 285)
                } detail: {
                    if showContentUI {
                        detailMainView
                            .transition(.opacity)
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
            
            // Overview New Item Modal Overlay (Triggered by + on Dashboard/Overview)
            if isShowingOverviewNewItemModal {
                OverviewNewItemModalView(
                    isPresented: $isShowingOverviewNewItemModal,
                    onSelectAssignment: { isPresentingNewAssignmentSheet = true },
                    onSelectDeadline: { isPresentingNewDeadlineSheet = true },
                    onSelectExam: { isPresentingNewExamSheet = true }
                )
                .transition(.opacity)
                .zIndex(1001)
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
        .sheet(isPresented: $updateManager.showUpdateModal) {
            UpdateModalView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
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
        .task {
            // 1. Caricamento iniziale SplashScreen con badge logo
            try? await Task.sleep(for: .milliseconds(1100))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                isLoading = false
            }
            // 2. Animazione d'ingresso a cascata dell'interfaccia
            triggerCascadingAnimation()
        }
    }
    
    // MARK: - Main Detail View
    @ViewBuilder
    private var detailMainView: some View {
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
                    triggerContextualNew()
                } label: {
                    Label(localizationManager.text(it: "Nuovo (⌘N)", en: "New (⌘N)"), systemImage: "plus")
                }
                .help(localizationManager.text(it: "Aggiungi elemento contestuale (⌘N)", en: "Add contextual item (⌘N)"))
            }
        }
    }
    
    // MARK: - Sidebar Subviews
    private var sidebarHeader: some View {
        HStack(spacing: 8) {
            #if canImport(AppKit)
            if let nsImg = NSImage(named: "AppIcon") {
                Image(nsImage: nsImg)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
            }
            #endif
            
            Text("uni")
                .font(UniFont.title())
                .fontWeight(.bold)
                .tracking(-0.6)
                .foregroundStyle(.primary)
            
            Spacer()
            
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
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(localizationManager.text(it: "Cerca rapidamente in tutto uni (⌘F)", en: "Quick search throughout uni (⌘F)"))
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private var sidebarStatsFooter: some View {
        VStack(spacing: 6) {
            Divider().opacity(isDarkMode ? 0.2 : 0.4)
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
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
    }

    private var sidebarBottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(isDarkMode ? 0.2 : 0.4)
            HStack(spacing: 6) {
                // Impostazioni con icona in basso a sinistra (32x32)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                        selectedTab = "settings"
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selectedTab == "settings" ? (isDarkMode ? Color.white.opacity(0.18) : themeManager.accentColor.opacity(0.14)) : (isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.04)))
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedTab == "settings" ? themeManager.accentColor : .secondary)
                    }
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(selectedTab == "settings" ? themeManager.accentColor.opacity(0.4) : (isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06)), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Impostazioni Generali (⌘,)", en: "General Settings (⌘,)"))
                
                // Scorciatoie Rapide della Navbar (fino a 3 elementi massimi)
                let shortcuts = dataManager.activeNavbarShortcuts
                let showOnlyIcons = shortcuts.count > 1
                
                ForEach(shortcuts) { item in
                    NavbarQuickActionButton(
                        item: item,
                        showOnlyIcon: showOnlyIcons,
                        isDarkMode: isDarkMode,
                        onOpenFocusTimer: { isShowingFocusTimer = true },
                        onOpenQuickSearch: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isShowingQuickSearch = true
                            }
                        },
                        onTriggerNew: { triggerContextualNew() }
                    )
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
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
        case "deadlines":
            isPresentingNewDeadlineSheet = true
        case "calendar":
            isPresentingNewDeadlineSheet = true
        case "dashboard":
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                isShowingOverviewNewItemModal = true
            }
        default:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                isShowingOverviewNewItemModal = true
            }
        }
    }
}

// MARK: - Navbar Quick Action Button (Pulsante Rapido Configurabile)
struct NavbarQuickActionButton: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var outlookManager: OutlookManager
    let item: NavbarShortcutItem
    let showOnlyIcon: Bool
    let isDarkMode: Bool
    let onOpenFocusTimer: () -> Void
    let onOpenQuickSearch: () -> Void
    let onTriggerNew: () -> Void
    
    var actionOption: NavbarQuickActionOption {
        NavbarQuickActionOption(rawValue: item.actionType) ?? .outlook
    }
    
    var targetCustomShortcut: QuickShortcutLink? {
        guard actionOption == .customShortcut, let customId = item.customShortcutId else { return nil }
        return dataManager.quickShortcuts.first(where: { $0.id == customId })
    }
    
    var buttonIcon: String {
        if let custom = targetCustomShortcut {
            return custom.iconName.isEmpty ? "link" : custom.iconName
        }
        return actionOption.defaultIcon
    }
    
    var buttonTooltip: String {
        if let custom = targetCustomShortcut {
            return custom.title
        }
        return actionOption.displayName(isItalian: localizationManager.currentLanguage == .italian)
    }
    
    var body: some View {
        Button {
            executeAction()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: buttonIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.accentColor)
                
                if !showOnlyIcon {
                    if let custom = targetCustomShortcut {
                        Text(custom.title)
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                    } else {
                        Text(actionOption.displayName(isItalian: localizationManager.currentLanguage == .italian))
                            .font(UniFont.caption())
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.horizontal, showOnlyIcon ? 0 : 8)
            .frame(width: showOnlyIcon ? 32 : nil, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(themeManager.accentColor.opacity(isDarkMode ? 0.14 : 0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(buttonTooltip)
    }
    
    private func executeAction() {
        switch actionOption {
        case .outlook:
            outlookManager.openOutlook()
        case .portal:
            if !dataManager.universityPortalURL.isEmpty {
                AppSystemHelper.openWebURL(urlString: dataManager.universityPortalURL)
            } else {
                NotificationManager.shared.notify(
                    title: localizationManager.text(it: "Portale non configurato", en: "Portal not configured"),
                    message: localizationManager.text(it: "Configura l'URL nelle impostazioni", en: "Configure the URL in settings"),
                    type: .info,
                    icon: "globe"
                )
            }
        case .focusTimer:
            onOpenFocusTimer()
        case .quickSearch:
            onOpenQuickSearch()
        case .newEntry:
            onTriggerNew()
        case .customShortcut:
            if let custom = targetCustomShortcut, !custom.url.isEmpty {
                AppSystemHelper.openWebURL(urlString: custom.url)
            }
        }
    }
}

// MARK: - Refined Splash Screen (Ispirata a Mastro con vetro liquido e badge)
struct UniSplashScreenView: View {
    @ObservedObject var dataManager: DataManager
    let isDarkMode: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(themeManager.accentColor.opacity(0.12))
                    .frame(width: 76, height: 76)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                    )
                
                #if canImport(AppKit)
                if let nsImg = NSImage(named: "AppIcon") {
                    Image(nsImage: nsImg)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(themeManager.accentColor)
                }
                #else
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(themeManager.accentColor)
                #endif
            }
            
            VStack(spacing: 5) {
                Text("uni")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                    .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.88))
                
                Text(dataManager.universityName.isEmpty ? "Spazio di Studio Universitario" : dataManager.universityName)
                    .font(UniFont.subheadline())
                    .foregroundColor(.secondary)
            }
            
            ProgressView()
                .scaleEffect(0.85)
                .padding(.top, 4)
        }
        .padding(36)
        .frame(width: 320)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isDarkMode ? Color.white.opacity(0.15) : Color.white.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 30, x: 0, y: 15)
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
