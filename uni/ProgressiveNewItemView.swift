//
//  ProgressiveNewItemView.swift
//  uni
//
//  Created by zinco.cc on 02/10/2026.
//

import SwiftUI

public enum ProgressiveItemType: String, CaseIterable, Identifiable {
    case assignment
    case exam
    case deadline
    
    public var id: String { rawValue }
    
    public func title(lm: LocalizationManager) -> String {
        switch self {
        case .assignment:
            return lm.t(.navAssignments)
        case .exam:
            return lm.t(.navExams)
        case .deadline:
            return lm.t(.navDeadlines)
        }
    }
    
    public func subtitle(lm: LocalizationManager) -> String {
        switch self {
        case .assignment:
            return lm.text(it: "Progetto, tesina o consegna per un corso", en: "Project, paper or assignment for a course")
        case .exam:
            return lm.text(it: "Appello d'esame parziale o finale", en: "Partial or final exam session")
        case .deadline:
            return lm.text(it: "Scadenza amministrativa, tasse o studio", en: "Administrative, tuition or study deadline")
        }
    }
    
    public var iconName: String {
        switch self {
        case .assignment: return "doc.text.fill"
        case .exam: return "graduationcap.fill"
        case .deadline: return "clock.fill"
        }
    }
}

public struct ProgressiveNewItemView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Binding var isPresented: Bool
    
    // Step 1: Selected Type
    @State private var selectedType: ProgressiveItemType? = nil
    
    // Step 2: Selected Course (nil means "None / Generale")
    @State private var hasSelectedCourseStep: Bool = false
    @State private var selectedCourseId: UUID? = nil
    @State private var courseSearchText: String = ""
    
    // Step 3: Item Form Details
    @State private var title: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var notes: String = ""
    @State private var localFilePath: String? = nil
    @State private var localFileName: String? = nil
    
    // Links (multiple links with +)
    @State private var linkURLs: [String] = [""]
    
    // Multiple files / folders
    public struct AttachedFileItem: Identifiable, Hashable {
        public let id = UUID()
        public var name: String
        public var path: String
        public var isDirectory: Bool
        public var size: String
        
        public init(name: String, path: String, isDirectory: Bool, size: String = "") {
            self.name = name
            self.path = path
            self.isDirectory = isDirectory
            self.size = size
        }
    }
    @State private var attachedFiles: [AttachedFileItem] = []
    
    // Deadline specific
    @State private var deadlinePriority: Deadline.Priority = .medium
    @State private var deadlineLink: String = ""
    
    // Exam specific
    @State private var examType: Exam.ExamType = .writtenOral
    @State private var examRoom: String = ""
    @State private var targetGrade: String = "30"
    
    // Assignment specific
    @State private var assignmentWeight: String = "20"
    @State private var assignmentLink: String = ""
    @State private var assignmentStatus: AssignmentStatus = .notStarted
    
    @State private var validationError: String? = nil
    
    @Environment(\.colorScheme) private var systemColorScheme
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    private var filteredCourses: [Course] {
        if courseSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return dataManager.courses
        }
        return dataManager.courses.filter {
            $0.name.localizedCaseInsensitiveContains(courseSearchText) ||
            $0.code.localizedCaseInsensitiveContains(courseSearchText)
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let col1Width = max(220, totalWidth * (2.0 / 7.0))
            let col2Width = max(220, totalWidth * (2.0 / 7.0))
            let col3Width = max(280, totalWidth * (3.0 / 7.0))
            
            ZStack(alignment: .topTrailing) {
                // Main Multi-Column Progressive Panel: Full Remaining Screen Edge-to-Edge!
                HStack(spacing: 0) {
                    // Column 1: Select Type (2/7)
                    typeSelectionColumn
                        .frame(width: col1Width)
                        .background(columnBackground(stepIndex: 1))
                        .overlay(
                            Rectangle()
                                .fill(dividerColor)
                                .frame(width: 1.5),
                            alignment: .trailing
                        )
                    
                    // Column 2: Select Course (2/7)
                    if selectedType != nil {
                        courseSelectionColumn
                            .frame(width: col2Width)
                            .background(columnBackground(stepIndex: 2))
                            .overlay(
                                Rectangle()
                                    .fill(dividerColor)
                                    .frame(width: 1.5),
                                alignment: .trailing
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        placeholderColumn(
                            stepNumber: "2",
                            title: localizationManager.text(it: "Seleziona Corso", en: "Select Course"),
                            subtitle: localizationManager.text(it: "Scegli prima il tipo di elemento da creare nella colonna a sinistra.", en: "Choose the item type on the left first.")
                        )
                        .frame(width: col2Width)
                        .background(columnBackground(stepIndex: 2))
                        .overlay(
                            Rectangle()
                                .fill(dividerColor)
                                .frame(width: 1.5),
                            alignment: .trailing
                        )
                    }
                    
                    // Column 3: Fill Details & Save (3/7)
                    if selectedType != nil && hasSelectedCourseStep {
                        detailsFormColumn
                            .frame(width: col3Width)
                            .background(columnBackground(stepIndex: 3))
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        placeholderColumn(
                            stepNumber: "3",
                            title: localizationManager.text(it: "Dettagli & Salva", en: "Details & Save"),
                            subtitle: localizationManager.text(it: "Completa i passaggi 1 e 2 per inserire titolo, data e opzioni di salvataggio.", en: "Complete steps 1 and 2 to configure title, date and save options.")
                        )
                        .frame(width: col3Width)
                        .background(columnBackground(stepIndex: 3))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDarkMode ? Color(red: 0.10, green: 0.10, blue: 0.12) : Color.white)
                
                // Top Right Quick Dismiss Button (Photo attached style: "✕ Close")
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        isPresented = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                        Text(localizationManager.text(it: "Chiudi", en: "Close"))
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 18)
                .padding(.trailing, 20)
                .help(localizationManager.text(it: "Chiudi (Esc)", en: "Close (Esc)"))
            }
        }
    }
    
    private var dividerColor: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
    }
    
    private func columnBackground(stepIndex: Int) -> Color {
        if isDarkMode {
            switch stepIndex {
            case 1: return Color(red: 0.12, green: 0.12, blue: 0.14)
            case 2: return Color(red: 0.14, green: 0.14, blue: 0.16)
            default: return Color(red: 0.16, green: 0.16, blue: 0.18)
            }
        } else {
            switch stepIndex {
            case 1: return Color(red: 0.98, green: 0.98, blue: 0.99)
            case 2: return Color(red: 0.96, green: 0.96, blue: 0.97)
            default: return Color(red: 1.0, green: 1.0, blue: 1.0)
            }
        }
    }
    
    // MARK: - Column 1: Item Type Selection
    private var typeSelectionColumn: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("1 / 3")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text(localizationManager.text(it: "TIPOLOGIA", en: "ITEM TYPE").uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                }
                
                Text(localizationManager.text(it: "Cosa vuoi aggiungere?", en: "What to create?"))
                    .font(UniFont.title())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            
            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(ProgressiveItemType.allCases) { type in
                        let isSelected = selectedType == type
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                selectedType = type
                                validationError = nil
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(isSelected ? themeManager.accentColor : (isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: type.iconName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(isSelected ? themeManager.accentTextColor : themeManager.accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(type.title(lm: localizationManager))
                                        .font(UniFont.headline())
                                        .fontWeight(isSelected ? .bold : .semibold)
                                        .foregroundStyle(.primary)
                                    
                                    Text(type.subtitle(lm: localizationManager))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer(minLength: 4)
                                
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(isSelected ? themeManager.accentColor : Color.secondary.opacity(0.4))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? themeManager.accentColor.opacity(0.10) : (isDarkMode ? Color.white.opacity(0.03) : Color.white))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? themeManager.accentColor : dividerColor, lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Column 2: Course Selection
    private var courseSelectionColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("2 / 3")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text(localizationManager.text(it: "MATERIA / CORSO", en: "COURSE / SUBJECT").uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                }
                
                Text(localizationManager.text(it: "A quale corso è legato?", en: "Related course?"))
                    .font(UniFont.title())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                TextField(localizationManager.text(it: "Cerca corso...", en: "Search course..."), text: $courseSearchText)
                    .textFieldStyle(.plain)
                    .font(UniFont.subheadline())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(dividerColor, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            // Course List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    // Option: None / Generico (only for deadlines or general items)
                    let isNoneSelected = hasSelectedCourseStep && selectedCourseId == nil
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            selectedCourseId = nil
                            hasSelectedCourseStep = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isNoneSelected ? themeManager.accentColor : (isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06)))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "asterisk")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(isNoneSelected ? themeManager.accentTextColor : .secondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizationManager.text(it: "Nessun corso (Generale)", en: "No course (General)"))
                                    .font(UniFont.headline())
                                    .foregroundStyle(.primary)
                                Text(localizationManager.text(it: "Attività non legata a una materia", en: "Not linked to a specific course"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if isNoneSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(themeManager.accentColor)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isNoneSelected ? themeManager.accentColor.opacity(0.10) : (isDarkMode ? Color.white.opacity(0.03) : Color.white))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isNoneSelected ? themeManager.accentColor : dividerColor, lineWidth: isNoneSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // User Courses
                    ForEach(filteredCourses) { course in
                        let isCourseSelected = hasSelectedCourseStep && selectedCourseId == course.id
                        let courseColor = Color(hex: course.colorHex) ?? themeManager.accentColor
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                selectedCourseId = course.id
                                hasSelectedCourseStep = true
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(courseColor)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(course.name)
                                        .font(UniFont.headline())
                                        .lineLimit(1)
                                        .foregroundStyle(.primary)
                                    
                                    HStack(spacing: 6) {
                                        if !course.code.isEmpty {
                                            Text(course.code)
                                                .font(UniFont.caption())
                                                .foregroundStyle(.secondary)
                                        }
                                        Text("\(course.cfu) CFU")
                                            .font(UniFont.caption())
                                            .foregroundStyle(courseColor)
                                    }
                                }
                                
                                Spacer()
                                
                                if isCourseSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(themeManager.accentColor)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isCourseSelected ? themeManager.accentColor.opacity(0.10) : (isDarkMode ? Color.white.opacity(0.03) : Color.white))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isCourseSelected ? themeManager.accentColor : dividerColor, lineWidth: isCourseSelected ? 1.5 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Column 3: Form Details & Clear Save Button
    private var detailsFormColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("3 / 3")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text(localizationManager.text(it: "DETTAGLI", en: "DETAILS").uppercased())
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                }
                
                Text(formTitle)
                    .font(UniFont.title())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Scrollable Form Fields
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 18) {
                    // Titolo
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localizationManager.text(it: "Titolo *", en: "Title *"))
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField(titlePlaceholder, text: $title)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                            .padding(10)
                            .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(validationError != nil && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : dividerColor, lineWidth: 1)
                            )
                    }
                    
                    // Data e Ora con Componente Custom & Ben Curato
                    UniCustomDateTimePicker(selectedDate: $dueDate, label: dateLabel)
                    
                    // Campi specifici per tipo
                    if selectedType == .exam {
                        // Tipo d'esame
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.text(it: "Tipologia di Prova", en: "Exam Format"))
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            Picker("", selection: $examType) {
                                ForEach(Exam.ExamType.allCases, id: \.self) { et in
                                    Text(et.rawValue).tag(et)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Aula / Luogo
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.text(it: "Aula o Link Teams", en: "Room or Teams link"))
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            TextField("es. Aula Magna / Teams", text: $examRoom)
                                .textFieldStyle(.plain)
                                .font(UniFont.body())
                                .padding(10)
                                .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    } else if selectedType == .deadline {
                        // Priorità Scadenza
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.text(it: "Priorità", en: "Priority"))
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            Picker("", selection: $deadlinePriority) {
                                ForEach(Deadline.Priority.allCases, id: \.self) { p in
                                    Text(p.rawValue).tag(p)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // File o Cartelle collegate con possibilità di aggiungerne multipli con "+"
                        filesAndFoldersSection
                        
                        // Link & Risorse Web con possibilità di aggiungerne con "+"
                        linksSection
                    } else if selectedType == .assignment {
                        // Stato iniziale
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.text(it: "Stato Iniziale", en: "Initial Status"))
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            Picker("", selection: $assignmentStatus) {
                                ForEach(AssignmentStatus.allCases, id: \.self) { st in
                                    Text(st.localized(with: localizationManager)).tag(st)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Peso percentuale
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.text(it: "Peso sul voto finale (%)", en: "Weight on grade (%)"))
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            TextField("20", text: $assignmentWeight)
                                .textFieldStyle(.plain)
                                .font(UniFont.body())
                                .padding(10)
                                .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        
                        // File o Cartelle collegate con possibilità di aggiungerne multipli con "+"
                        filesAndFoldersSection
                        
                        // Link consegna con possibilità di aggiungerne con "+"
                        linksSection
                    }
                    
                    // Descrizione / Note: non un campo a barra ma una linea che raddoppia se il testo è lungo
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localizationManager.text(it: "Descrizione / Note", en: "Description / Notes"))
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField(localizationManager.text(it: "Aggiungi note, specifiche o istruzioni...", en: "Add notes, specifications or instructions..."), text: $notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                            .lineLimit(1...8)
                            .padding(.vertical, 6)
                        
                        // Linea architettonica 1.5pt sotto il testo
                        Rectangle()
                            .fill(isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.12))
                            .frame(height: 1.5)
                    }
                    
                    if let err = validationError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(err)
                                .font(UniFont.caption())
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            
            Divider().opacity(0.5)
            
            // Bottom Action Bar with CLEAR SAVE BUTTON
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        isPresented = false
                    }
                } label: {
                    Text(localizationManager.text(it: "Annulla", en: "Cancel"))
                        .font(UniFont.subheadline())
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    saveItem()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                        Text(saveButtonTitle)
                            .font(UniFont.headline())
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(themeManager.accentTextColor)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(themeManager.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: themeManager.accentColor.opacity(0.35), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .background(isDarkMode ? Color.white.opacity(0.02) : Color.black.opacity(0.02))
        }
    }
    
    // MARK: - Placeholder for Inactive Steps
    private func placeholderColumn(stepNumber: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 14) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(dividerColor, lineWidth: 1.5)
                    .frame(width: 44, height: 44)
                Text(stepNumber)
                    .font(UniFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            Text(title)
                .font(UniFont.headline())
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(subtitle)
                .font(UniFont.caption())
                .foregroundStyle(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Helpers & Save Logic
    private var formTitle: String {
        guard let type = selectedType else { return "" }
        switch type {
        case .assignment:
            return localizationManager.text(it: "Nuovo Compito", en: "New Assignment")
        case .exam:
            return localizationManager.text(it: "Nuovo Esame", en: "New Exam")
        case .deadline:
            return localizationManager.text(it: "Nuova Scadenza", en: "New Deadline")
        }
    }
    
    private var titlePlaceholder: String {
        guard let type = selectedType else { return "" }
        switch type {
        case .assignment:
            return localizationManager.text(it: "es. Relazione di laboratorio", en: "e.g. Lab report")
        case .exam:
            return localizationManager.text(it: "es. Appello Scritto Generale", en: "e.g. Final Written Exam")
        case .deadline:
            return localizationManager.text(it: "es. Consegna documenti / Iscrizione", en: "e.g. Document submission")
        }
    }
    
    private var dateLabel: String {
        guard let type = selectedType else { return "" }
        switch type {
        case .assignment:
            return localizationManager.text(it: "Data di consegna *", en: "Due date *")
        case .exam:
            return localizationManager.text(it: "Data e ora dell'esame *", en: "Exam date & time *")
        case .deadline:
            return localizationManager.text(it: "Data di scadenza *", en: "Deadline date *")
        }
    }
    
    private var saveButtonTitle: String {
        guard let type = selectedType else {
            return localizationManager.text(it: "Salva", en: "Save")
        }
        switch type {
        case .assignment:
            return localizationManager.text(it: "Salva Compito", en: "Save Assignment")
        case .exam:
            return localizationManager.text(it: "Registra Esame", en: "Schedule Exam")
        case .deadline:
            return localizationManager.text(it: "Aggiungi Scadenza", en: "Add Deadline")
        }
    }
    
    // MARK: - Files and Folders Section
    private var filesAndFoldersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localizationManager.text(it: "File o Cartelle Collegate", en: "Linked Files or Folders"))
                    .font(UniFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    selectAndAttachFiles()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(localizationManager.text(it: "Allega", en: "Attach"))
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(themeManager.accentColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Allega file o cartelle dal Mac", en: "Attach files or folders from Mac"))
            }
            
            if !attachedFiles.isEmpty {
                VStack(spacing: 6) {
                    ForEach(attachedFiles) { fileItem in
                        HStack(spacing: 8) {
                            Image(systemName: fileItem.isDirectory ? "folder.fill" : "doc.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(themeManager.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fileItem.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                                
                                Text(fileItem.path)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Spacer()
                            
                            Button {
                                attachedFiles.removeAll { $0.id == fileItem.id }
                                if localFilePath == fileItem.path {
                                    localFilePath = attachedFiles.first?.path
                                    localFileName = attachedFiles.first?.name
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }
            
            UniFolderDropZoneView(
                localFilePath: Binding(
                    get: { attachedFiles.first?.path ?? localFilePath },
                    set: { newPath in
                        if let p = newPath, !p.isEmpty {
                            let url = URL(fileURLWithPath: p)
                            var isDir: ObjCBool = false
                            FileManager.default.fileExists(atPath: p, isDirectory: &isDir)
                            let item = AttachedFileItem(
                                name: url.lastPathComponent,
                                path: p,
                                isDirectory: isDir.boolValue,
                                size: AppSystemHelper.formatFileSize(atPath: p)
                            )
                            if !attachedFiles.contains(where: { $0.path == p }) {
                                attachedFiles.append(item)
                            }
                            localFilePath = p
                            localFileName = url.lastPathComponent
                        }
                    }
                ),
                localFileName: $localFileName,
                label: localizationManager.text(it: "Trascina qui uno o più file/cartelle", en: "Drag one or more files/folders here")
            )
        }
    }
    
    // MARK: - Links & Web Resources Section
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localizationManager.text(it: "Link & Risorse Web", en: "Links & Web Resources"))
                    .font(UniFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    linkURLs.append("")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(localizationManager.text(it: "Aggiungi", en: "Add"))
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(themeManager.accentColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(themeManager.accentColor)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Aggiungi un altro link", en: "Add another link"))
            }
            
            ForEach(linkURLs.indices, id: \.self) { idx in
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .font(.system(size: 11))
                            .foregroundStyle(themeManager.accentColor)
                        
                        TextField("https://...", text: $linkURLs[idx])
                            .textFieldStyle(.plain)
                            .font(UniFont.body())
                        
                        if linkURLs.count > 1 {
                            Button {
                                linkURLs.remove(at: idx)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    Rectangle()
                        .fill(isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.10))
                        .frame(height: 1)
                }
            }
        }
    }
    
    private func selectAndAttachFiles() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.prompt = localizationManager.text(it: "Allega", en: "Attach")
        if panel.runModal() == .OK {
            for url in panel.urls {
                let path = url.path
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                let item = AttachedFileItem(
                    name: url.lastPathComponent,
                    path: path,
                    isDirectory: isDir.boolValue,
                    size: AppSystemHelper.formatFileSize(atPath: path)
                )
                if !attachedFiles.contains(where: { $0.path == path }) {
                    attachedFiles.append(item)
                }
                if localFilePath == nil {
                    localFilePath = path
                    localFileName = url.lastPathComponent
                }
            }
        }
        #endif
    }
    
    private func saveItem() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanTitle.isEmpty {
            validationError = localizationManager.text(it: "Inserisci un titolo valido per procedere.", en: "Please enter a valid title.")
            return
        }
        
        guard let type = selectedType else { return }
        
        switch type {
        case .deadline:
            let cleanLinks = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            let newDeadline = Deadline(
                title: cleanTitle,
                courseId: selectedCourseId,
                dueDate: dueDate,
                priority: deadlinePriority,
                isCompleted: false,
                notes: notes,
                linkURL: cleanLinks.first,
                linkURLs: cleanLinks,
                localFilePath: attachedFiles.first?.path ?? localFilePath,
                localFileName: attachedFiles.first?.name ?? localFileName
            )
            dataManager.deadlines.append(newDeadline)
            dataManager.saveData()
            
            NotificationManager.shared.notify(
                title: localizationManager.t(.deadlineCreated),
                message: newDeadline.title,
                type: .success,
                icon: "clock.badge.checkmark"
            )
            NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            let courseName = dataManager.courses.first(where: { $0.id == newDeadline.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(deadline: newDeadline, courseName: courseName) }
            
        case .exam:
            guard let cId = selectedCourseId ?? dataManager.courses.first?.id else {
                validationError = localizationManager.text(it: "Per programmare un esame devi prima creare almeno un corso.", en: "Please create at least one course before scheduling an exam.")
                return
            }
            let newExam = Exam(
                courseId: cId,
                title: cleanTitle,
                examDate: dueDate,
                type: examType,
                room: examRoom,
                status: .planned,
                targetGrade: Int(targetGrade),
                notes: notes
            )
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
            
        case .assignment:
            guard let cId = selectedCourseId ?? dataManager.courses.first?.id else {
                validationError = localizationManager.text(it: "Per creare un compito devi prima creare almeno un corso.", en: "Please create at least one course before creating an assignment.")
                return
            }
            let cleanLinks = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            let newAssignment = Assignment(
                title: cleanTitle,
                courseId: cId,
                dueDate: dueDate,
                details: notes,
                weightPercent: Int(assignmentWeight) ?? 0,
                isCompleted: assignmentStatus == .completed,
                status: assignmentStatus,
                localFilePath: attachedFiles.first?.path ?? localFilePath,
                localFileName: attachedFiles.first?.name ?? localFileName,
                linkURL: cleanLinks.first,
                linkURLs: cleanLinks
            )
            dataManager.assignments.append(newAssignment)
            dataManager.saveData()
            
            NotificationManager.shared.notify(
                title: localizationManager.t(.assignmentCreated),
                message: newAssignment.title,
                type: .success,
                icon: "doc.badge.plus"
            )
            let courseName = dataManager.courses.first(where: { $0.id == newAssignment.courseId })?.name
            Task { await AppleCalendarManager.shared.sync(assignment: newAssignment, courseName: courseName) }
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            isPresented = false
        }
    }
}
