//
//  ContentView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var updateManager: UpdateManager
    @EnvironmentObject var outlookManager: OutlookManager
    @ObservedObject private var screenshotAutomation = ScreenshotAutomation.shared
    
    @State private var selectedTab: String = "dashboard"
    @State private var isLoading: Bool = true
    
    // Animazione a cascata degli elementi UI (ispirata a Mastro)
    @State private var showSidebarUI: Bool = false
    @State private var showContentUI: Bool = false
    @State private var isSidebarHovered: Bool = false
    @State private var isShowingProgressiveNewItem: Bool = false
    
    // Quick Search & Focus Timer Modals
    @State private var isShowingQuickSearch = false
    @State private var isShowingInlineSearch = false
    @State private var isShowingFocusTimer = false
    @State private var isShowingOnboarding = false
    @State private var isShowingWhatsNew = false
    @State private var shouldShowOnboardingAfterWhatsNew = false
    @State private var isShowingSupportModal = false
    @State private var isSearchHovered = false
    @State private var isSupportHovered = false
    
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
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(500)
            } else {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        sidebarHeader
                        
                        sidebarSearchButton
                        
                        // Lista di Navigazione con Pulsanti Liquidi (stile editoriale, linee 1.5pt, zero jumping)
                        ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) {
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navOverview),
                                        icon: "square.grid.2x2",
                                        shortcutHint: "⌘1",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "dashboard" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "dashboard"
                                        dismissAllOverlays()
                                    }
                                    
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navCalendar),
                                        icon: "calendar",
                                        shortcutHint: "⌘2",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "calendar" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "calendar"
                                        dismissAllOverlays()
                                    }
                                    
                                    SidebarButtonLiquidUni(
                                        title: "Focus Timer",
                                        icon: "timer",
                                        shortcutHint: "⌘T",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: false,
                                        isDark: isDarkMode
                                    ) {
                                        dismissAllOverlays()
                                        isShowingFocusTimer = true
                                    }
                                    
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navCourses),
                                        icon: "book.closed",
                                        count: dataManager.courses.count,
                                        shortcutHint: "⌘3",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "courses" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "courses"
                                        dismissAllOverlays()
                                    }
                                    
                                    let activeDeadlines = dataManager.deadlines.filter { !$0.isCompleted }.count
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navDeadlines),
                                        icon: "clock",
                                        count: activeDeadlines,
                                        shortcutHint: "⌘4",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "deadlines" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "deadlines"
                                        dismissAllOverlays()
                                    }
                                    
                                    let pendingExams = dataManager.exams.filter { $0.status != .passed }.count
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navExams),
                                        icon: "graduationcap",
                                        count: pendingExams,
                                        shortcutHint: "⌘5",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "exams" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "exams"
                                        dismissAllOverlays()
                                    }
                                    
                                    let pendingAssignments = dataManager.assignments.filter { !$0.isCompleted }.count
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.t(.navAssignments),
                                        icon: "doc.text",
                                        count: pendingAssignments,
                                        shortcutHint: "⌘6",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: selectedTab == "assignments" && !isShowingInlineSearch && !isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        selectedTab = "assignments"
                                        dismissAllOverlays()
                                    }
                                    
                                    // The + button as a single dedicated identity in the navbar below assignments ("a little more away")
                                    SidebarButtonLiquidUni(
                                        title: localizationManager.text(it: "Aggiungi...", en: "Add New..."),
                                        icon: "plus",
                                        shortcutHint: "⌘N",
                                        isCollapsed: !isSidebarHovered,
                                        isSelected: isShowingProgressiveNewItem,
                                        isDark: isDarkMode
                                    ) {
                                        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                                            isShowingInlineSearch = false
                                            isShowingOverviewNewItemModal = false
                                            isShowingProgressiveNewItem.toggle()
                                        }
                                    }
                                    .padding(.top, 14)
                                }
                                .frame(width: 245, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            // Help & Feedback Button + Statistiche Compatte Media & CFU (in basso)
                            sidebarStatsFooter
                            
                            // BARRA INFERIORE NAVBAR: Impostazioni quadrata con bordi arrotondati 32x32 + Scorciatoie Rapide
                            sidebarBottomActionBar
                    }
                    .frame(width: isSidebarHovered ? 245 : 64, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.06))
                            .frame(width: 1),
                        alignment: .trailing
                    )
                    .clipped()
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
                            isSidebarHovered = hovering
                        }
                    }
                    
                    // Main Content (Detail)
                    Group {
                        if isShowingInlineSearch {
                            // When search is active, the rest of the right side disappears completely to give search maximum space!
                            UniSearchWorkspaceView(
                                selectedTab: $selectedTab,
                                onClose: {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                        isShowingInlineSearch = false
                                    }
                                },
                                onOpenNewDeadline: { isPresentingNewDeadlineSheet = true },
                                onOpenNewExam: { isPresentingNewExamSheet = true },
                                onOpenNewAssignment: { isPresentingNewAssignmentSheet = true },
                                onOpenNewCourse: { isPresentingNewCourseSheet = true },
                                onOpenFocusTimer: { isShowingFocusTimer = true }
                            )
                            .transition(.opacity)
                        } else {
                            // Normal right-side detail view
                            ZStack(alignment: .topLeading) {
                                detailMainView
                                    .transition(.opacity)
                                
                                // Progressive New Item 2/7 - 2/7 - 3/7 Panel: Full remaining screen edge-to-edge!
                                if isShowingProgressiveNewItem {
                                    ProgressiveNewItemView(isPresented: $isShowingProgressiveNewItem)
                                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                                        .zIndex(1200)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .background(WindowAccessor())
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
                Button("") { selectedTab = "dashboard"; dismissAllOverlays() }.keyboardShortcut("1", modifiers: [.command])
                Button("") { selectedTab = "calendar"; dismissAllOverlays() }.keyboardShortcut("2", modifiers: [.command])
                Button("") { selectedTab = "courses"; dismissAllOverlays() }.keyboardShortcut("3", modifiers: [.command])
                Button("") { selectedTab = "deadlines"; dismissAllOverlays() }.keyboardShortcut("4", modifiers: [.command])
                Button("") { selectedTab = "exams"; dismissAllOverlays() }.keyboardShortcut("5", modifiers: [.command])
                Button("") { selectedTab = "assignments"; dismissAllOverlays() }.keyboardShortcut("6", modifiers: [.command])
                Button("") { selectedTab = "settings"; dismissAllOverlays() }.keyboardShortcut(",", modifiers: [.command])
                
                // ⌘F Spotlight Search - Toggles Dedicated Search Workspace
                Button("") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dismissAddModals()
                        isShowingInlineSearch.toggle()
                    }
                }.keyboardShortcut("f", modifiers: [.command])
                
                // ⌘T Focus Timer
                Button("") {
                    dismissAllOverlays()
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
        .onChange(of: selectedTab) { _, _ in
            dismissAllOverlays()
        }
        .onChange(of: dataManager.navigationTab) { _, newTab in
            if let newTab = newTab {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    selectedTab = newTab
                }
                dataManager.navigationTab = nil
            }
        }
        .sheet(isPresented: $isShowingOnboarding) {
            OnboardingWizardView()
        }
        .sheet(isPresented: $updateManager.showUpdateModal) {
            UpdateModalView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $isShowingWhatsNew, onDismiss: {
            if shouldShowOnboardingAfterWhatsNew {
                shouldShowOnboardingAfterWhatsNew = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isShowingOnboarding = true
                }
            }
        }) {
            WhatsNewModalView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $isShowingSupportModal) {
            SupportFeedbackModalView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .onAppear {
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5.2"
            let lastSeen = UserDefaults.standard.string(forKey: "uni_last_seen_release_notes")
            
            if !dataManager.hasCompletedOnboarding {
                isShowingOnboarding = true
                UserDefaults.standard.set(currentVersion, forKey: "uni_last_seen_release_notes")
            } else if lastSeen != currentVersion {
                shouldShowOnboardingAfterWhatsNew = true
                isShowingWhatsNew = true
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
            // 1. Caricamento iniziale SplashScreen con ritardo per trasmettere valore
            try? await Task.sleep(for: .milliseconds(1850))
            withAnimation(.spring(response: 0.48, dampingFraction: 0.82)) {
                isLoading = false
            }
            // 2. Animazione d'ingresso a cascata dell'interfaccia
            triggerCascadingAnimation()
        }
        .onReceive(screenshotAutomation.$overrideTab) { newTab in
            if let newTab = newTab {
                selectedTab = newTab
                isSidebarHovered = true
                showSidebarUI = true
                showContentUI = true
                isLoading = false
                isShowingWhatsNew = false
                isShowingOnboarding = false
            }
        }
        .onReceive(screenshotAutomation.$overrideInlineSearch) { searchActive in
            if let searchActive = searchActive {
                isShowingInlineSearch = searchActive
                if searchActive {
                    isSidebarHovered = true
                    showSidebarUI = true
                    showContentUI = true
                    isLoading = false
                    isShowingWhatsNew = false
                    isShowingOnboarding = false
                }
            }
        }
        .onReceive(screenshotAutomation.$overrideLoading) { loading in
            if let loading = loading {
                isLoading = loading
                if !loading {
                    showSidebarUI = true
                    showContentUI = true
                    isSidebarHovered = true
                    isShowingWhatsNew = false
                    isShowingOnboarding = false
                }
            }
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
                CalendarView(selectedTab: $selectedTab)
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
        .background(WindowAccessor())
    }
    
    // MARK: - Sidebar Subviews
    private var sidebarHeader: some View {
        VStack(spacing: 0) {
            // Dedicated clearance for standard macOS traffic light buttons (close, minimize, zoom)
            Color.clear
                .frame(height: 26)
            
            HStack(spacing: 0) {
                // Fixed 64pt box centered at X = 32:
                ZStack {
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
                    } else {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(themeManager.accentColor)
                            .frame(width: 24, height: 24)
                    }
                    #endif
                }
                .frame(width: 64, height: 36, alignment: .center)
                
                Text("uni")
                    .font(UniFont.title())
                    .fontWeight(.bold)
                    .tracking(-0.6)
                    .foregroundStyle(.primary)
                    .frame(width: 181, alignment: .leading)
                    .opacity(isSidebarHovered ? 1 : 0)
                    .clipped()
            }
            .frame(width: 245, height: 36, alignment: .leading)
            .padding(.top, 4)
            .padding(.bottom, 6)
            
            // Architectural 1.5pt divider line (visible ONLY when expanded)
            Rectangle()
                .fill(isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.10))
                .frame(height: 1.5)
                .opacity(isSidebarHovered ? 1.0 : 0)
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
        }
        .frame(width: 245, alignment: .leading)
    }

    private var sidebarSearchButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dismissAddModals()
                isShowingInlineSearch.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Fixed 64pt box centered at X = 32:
                    ZStack {
                        if isShowingInlineSearch {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(themeManager.accentColor.opacity(isDarkMode ? 0.22 : 0.14))
                                .frame(width: 32, height: 32)
                        }
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isShowingInlineSearch ? themeManager.accentColor : (isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.6)))
                    }
                    .frame(width: 64, height: 40, alignment: .center)
                    
                    HStack(spacing: 6) {
                        Text(localizationManager.text(it: "Cerca...", en: "Search..."))
                            .font(UniFont.body())
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer(minLength: 0)
                        
                        Text("⌘F")
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary.opacity(0.6))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .padding(.trailing, 14)
                    .frame(width: 181, alignment: .leading)
                    .opacity(isSidebarHovered ? 1 : 0)
                    .clipped()
                }
                .frame(width: 245, height: 40, alignment: .leading)
                .contentShape(Rectangle())
                .opacity(isSearchHovered ? 0.50 : 1.0)
                
                // Architectural 1.5pt divider line (visible ONLY when expanded)
                Rectangle()
                    .fill(isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.10))
                    .frame(height: 1.5)
                    .opacity(isSidebarHovered ? 1.0 : 0)
                    .padding(.horizontal, 10)
            }
        }
        .buttonStyle(.plain)
        .help(localizationManager.text(it: "Cerca in tutto uni (⌘F)", en: "Search throughout uni (⌘F)"))
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isSearchHovered = hover
            }
        }
        .frame(width: 245, alignment: .leading)
    }

    private var sidebarStatsFooter: some View {
        VStack(spacing: 8) {
            // ? Help Button: positioned near the bottom, clean icon without circle around it
            Button {
                isShowingSupportModal = true
            } label: {
                HStack(spacing: 0) {
                    ZStack {
                        Image(systemName: "questionmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.6))
                    }
                    .frame(width: 64, height: 30, alignment: .center)
                    
                    Text(localizationManager.text(it: "Supporto & Idee", en: "Support & Feedback"))
                        .font(UniFont.body())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(width: 181, alignment: .leading)
                        .opacity(isSidebarHovered ? 1 : 0)
                        .clipped()
                }
                .frame(width: 245, height: 30, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(localizationManager.text(it: "Supporto & Suggerisci nuove funzionalità", en: "Support & Suggest new features"))
            
            // GPA & CFU Stats (visibili solo quando la navbar è allargata)
            if isSidebarHovered {
                VStack(spacing: 0) {
                    Divider()
                        .opacity(isDarkMode ? 0.2 : 0.4)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 6)
                    
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
                    .padding(.horizontal, 16)
                }
                .transition(.opacity)
            }
        }
        .frame(width: 245, alignment: .leading)
        .padding(.bottom, 4)
    }

    private var sidebarBottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(isDarkMode ? 0.2 : 0.4)
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
            
            HStack(spacing: 0) {
                // Fixed 64pt box for the 32x32 squared Settings button with rounded edges centered at X = 32:
                ZStack {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                            selectedTab = "settings"
                            dismissAllOverlays()
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedTab == "settings" ? (isDarkMode ? Color.white.opacity(0.18) : themeManager.accentColor.opacity(0.14)) : (isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.04)))
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 13.5, weight: .semibold))
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
                }
                .frame(width: 64, height: 32, alignment: .center)
                
                // Scorciatoie Rapide della Navbar (fino a 3 elementi massimi) - visibili quando la navbar è allargata
                HStack(spacing: 6) {
                    let shortcuts = dataManager.activeNavbarShortcuts
                    let showOnlyIcons = shortcuts.count > 1
                    
                    ForEach(shortcuts) { item in
                        NavbarQuickActionButton(
                            item: item,
                            showOnlyIcon: showOnlyIcons,
                            isDarkMode: isDarkMode,
                            onOpenFocusTimer: {
                                dismissAllOverlays()
                                isShowingFocusTimer = true
                            },
                            onOpenQuickSearch: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dismissAddModals()
                                    isShowingInlineSearch = true
                                }
                            },
                            onTriggerNew: { triggerContextualNew() }
                        )
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.trailing, 10)
                .frame(width: 181, alignment: .leading)
                .opacity(isSidebarHovered ? 1 : 0)
                .clipped()
            }
            .frame(width: 245, height: 32, alignment: .leading)
            .padding(.bottom, 6)
        }
        .frame(width: 245, alignment: .leading)
    }
    
    private func dismissAddModals() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
            isShowingProgressiveNewItem = false
            isShowingOverviewNewItemModal = false
        }
    }
    
    private func dismissAllOverlays() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
            isShowingProgressiveNewItem = false
            isShowingOverviewNewItemModal = false
            isShowingInlineSearch = false
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
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                isShowingOverviewNewItemModal = true
            }
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

// MARK: - Custom Arc Loading Spinner (Ispirato allo screenshot allegato)
struct UniLoadingSpinnerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let isDarkMode: Bool
    var size: CGFloat = 34
    var lineWidth: CGFloat = 3.5
    
    @State private var isSpinning = false
    
    var body: some View {
        ZStack {
            // Traccia circolare di fondo neutrale e discreta
            Circle()
                .stroke(
                    isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.08),
                    lineWidth: lineWidth
                )
            
            // Arco di caricamento attivo con estremità arrotondate
            Circle()
                .trim(from: 0.0, to: 0.38)
                .stroke(
                    themeManager.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 0.95).repeatForever(autoreverses: false)) {
                isSpinning = true
            }
        }
    }
}

// MARK: - Refined Splash Screen (Logo senza contorni, font personalizzato e info versione)
struct UniSplashScreenView: View {
    @ObservedObject var dataManager: DataManager
    let isDarkMode: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5.2"
    }
    
    #if canImport(AppKit)
    private var appIconImage: NSImage? {
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
           let img = NSImage(contentsOf: iconURL) {
            return img
        }
        return NSImage(named: "AppIcon")
    }
    #endif
    
    var body: some View {
        ZStack {
            // Contenuto centrale del caricamento
            VStack(spacing: 20) {
                // 1. Logo dell'app senza contorni o box esterni
                #if canImport(AppKit)
                if let icon = appIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(isDarkMode ? 0.35 : 0.12), radius: 18, x: 0, y: 8)
                } else {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(themeManager.accentColor)
                }
                #else
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(themeManager.accentColor)
                #endif
                
                // 2. Titolo "uni" con font personalizzato scelto dall'utente e nome studente
                VStack(spacing: 6) {
                    Text("uni")
                        .font(UniFont.display(34, weight: .bold))
                        .tracking(-0.6)
                        .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.88))
                    
                    let studentName = dataManager.studentName.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(studentName.isEmpty ? "Spazio di Studio" : studentName)
                        .font(UniFont.subheadline())
                        .foregroundColor(.secondary)
                }
                
                // 3. Cerchio di caricamento circolare
                UniLoadingSpinnerView(isDarkMode: isDarkMode, size: 34, lineWidth: 3.5)
                    .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 4. In basso al centro in piccolo la versione dell'app e zinco.cc
            VStack {
                Spacer()
                Text("v\(appVersion) • zinco.cc")
                    .font(UniFont.caption())
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.4) : Color.black.opacity(0.38))
                    .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#if os(macOS)
public struct WindowAccessor: NSViewRepresentable {
    public init() {}
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true
                window.toolbar = nil
                
                // Guarantee the 3 standard traffic light buttons are always active and visible
                window.standardWindowButton(.closeButton)?.isHidden = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = false
                window.standardWindowButton(.zoomButton)?.isHidden = false
            }
        }
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.toolbar = nil
                window.standardWindowButton(.closeButton)?.isHidden = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = false
                window.standardWindowButton(.zoomButton)?.isHidden = false
            }
        }
    }
}
#endif

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

// MARK: - Automated Screenshot Capture (triggered via --capture-screenshots)
#if os(macOS)
@MainActor
public class ScreenshotAutomation: ObservableObject {
    public static let shared = ScreenshotAutomation()
    
    @Published public var overrideTab: String? = nil
    @Published public var overrideLoading: Bool? = nil
    @Published public var overrideInlineSearch: Bool? = nil
    
    public func runCaptureSequence() async {
        guard CommandLine.arguments.contains("--capture-screenshots") else { return }
        print("📸 Starting automated screenshot capture sequence...")
        
        DataManager.shared.refreshCurrentDate()
        ThemeManager.shared.themeMode = .dark
        ThemeManager.shared.applyAppearance()
        
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        guard let window = NSApp.windows.first(where: { !($0 is NSPanel) }) else {
            print("❌ No main window found!")
            return
        }
        
        window.setContentSize(NSSize(width: 1440, height: 900))
        window.center()
        
        overrideLoading = false
        
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let rawDir = appSupport.appendingPathComponent("uni_screenshots", isDirectory: true)
        try? FileManager.default.createDirectory(at: rawDir, withIntermediateDirectories: true)
        
        let targets: [(name: String, tab: String, search: Bool)] = [
            ("dashboard", "dashboard", false),
            ("calendar", "calendar", false),
            ("deadlines", "deadlines", false),
            ("exams", "exams", false),
            ("search", "dashboard", true)
        ]
        
        for (index, target) in targets.enumerated() {
            print("📸 [\(index + 1)/5] Switching to '\(target.name)'...")
            overrideTab = target.tab
            overrideInlineSearch = target.search
            
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            if let targetView = window.contentView?.superview ?? window.contentView {
                let bounds = targetView.bounds
                let scale: CGFloat = 2.0
                let pixelWidth = Int(bounds.width * scale)
                let pixelHeight = Int(bounds.height * scale)
                
                if let rep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: pixelWidth,
                    pixelsHigh: pixelHeight,
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: .deviceRGB,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                ) {
                    rep.size = bounds.size
                    targetView.cacheDisplay(in: bounds, to: rep)
                    if let pngData = rep.representation(using: .png, properties: [:]) {
                        let fileURL = rawDir.appendingPathComponent("\(target.name).png")
                        do {
                            try pngData.write(to: fileURL)
                            let shotURL = rawDir.appendingPathComponent("shot_\(index + 1).png")
                            try? pngData.write(to: shotURL)
                            print("  ✅ Captured \(target.name).png (\(pixelWidth)x\(pixelHeight)) at \(fileURL.path)")
                        } catch {
                            print("  ❌ Write error for \(target.name): \(error)")
                        }
                    }
                }
            }
        }
        
        print("🎉 All 5 screenshots successfully saved to: \(rawDir.path)")
        try? await Task.sleep(nanoseconds: 600_000_000)
        NSApp.terminate(nil)
    }
}
#endif
