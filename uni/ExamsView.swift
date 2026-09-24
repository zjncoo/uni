//
//  ExamsView.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI

struct ExamsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var filterStatus: ExamFilter = .all
    @State private var searchText = ""
    @State private var isPresentingNewExam = false
    @State private var examToEdit: Exam? = nil
    @State private var examToRegisterGrade: Exam? = nil
    
    enum ExamFilter: String, CaseIterable {
        case all = "all"
        case planned = "planned"
        case passed = "passed"
        
        func title(with lm: LocalizationManager) -> String {
            switch self {
            case .all: return lm.t(.filterAll)
            case .planned: return lm.currentLanguage == .italian ? "Da sostenere" : "Upcoming"
            case .passed: return lm.t(.completed)
            }
        }
    }
    
    var filteredExams: [Exam] {
        let base: [Exam]
        switch filterStatus {
        case .planned:
            base = dataManager.exams.filter { $0.status != .passed }.sorted { $0.examDate < $1.examDate }
        case .passed:
            base = dataManager.exams.filter { $0.status == .passed }.sorted { $0.examDate > $1.examDate }
        case .all:
            base = dataManager.exams.sorted { $0.examDate < $1.examDate }
        }
        
        let clean = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean.isEmpty {
            return base
        }
        return base.filter { exam in
            let courseName = dataManager.courses.first(where: { $0.id == exam.courseId })?.name ?? ""
            return exam.title.localizedCaseInsensitiveContains(clean) ||
                   exam.notes.localizedCaseInsensitiveContains(clean) ||
                   exam.room.localizedCaseInsensitiveContains(clean) ||
                   courseName.localizedCaseInsensitiveContains(clean) ||
                   exam.type.rawValue.localizedCaseInsensitiveContains(clean)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header
                UniHeader(
                    localizationManager.t(.examsTitle),
                    subtitle: localizationManager.t(.examsSubtitle)
                )
                
                // Statistiche di Laurea & Media Architettoniche
                HStack(spacing: 14) {
                    UniCard(padding: 18, cornerRadius: 0, style: .surface) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.t(.weightedAverage).uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text(dataManager.weightedAverage > 0 ? String(format: "%.2f", dataManager.weightedAverage) : "--")
                                    .font(UniFont.displayGigantic())
                                    .foregroundStyle(themeManager.accentColor)
                                Text("/ 30")
                                    .font(UniFont.title())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(dataManager.estimatedGraduationGrade > 0 ? localizationManager.t(.startGrade(Int(round(dataManager.estimatedGraduationGrade)))) : localizationManager.t(.awaitingExams))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    UniCard(padding: 18, cornerRadius: 0, style: .surface) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localizationManager.t(.cfuProgress).uppercased())
                                .font(UniFont.sectionLabel())
                                .foregroundStyle(.secondary)
                                .tracking(1.4)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text("\(dataManager.totalCfuAcquired)")
                                    .font(UniFont.displayGigantic())
                                Text("/ \(dataManager.totalCfuTarget) CFU")
                                    .font(UniFont.title())
                                    .foregroundStyle(.secondary)
                            }
                            
                            let progress = dataManager.totalCfuTarget > 0 ? min(Double(dataManager.totalCfuAcquired) / Double(dataManager.totalCfuTarget), 1.0) : 0.0
                            UniBlockProgress(value: progress, height: 8, cornerRadius: 0)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // What-If GPA Simulator Card
                WhatIfSimulatorCard()
                
                // Filtri e Barra di Ricerca
                if !dataManager.exams.isEmpty {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            ForEach(ExamFilter.allCases, id: \.self) { filter in
                                Button {
                                    filterStatus = filter
                                } label: {
                                    Text(filter.title(with: localizationManager))
                                        .font(UniFont.subheadline())
                                        .fontWeight(filterStatus == filter ? .semibold : .regular)
                                        .padding(.horizontal, 12)
                                        .background(filterStatus == filter ? themeManager.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                        .foregroundStyle(filterStatus == filter ? themeManager.accentColor : .primary)
                                        .overlay(Rectangle().stroke(filterStatus == filter ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.08), lineWidth: 1))
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
                            TextField(localizationManager.text(it: "Cerca esami...", en: "Search exams..."), text: $searchText)
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
                
                // Lista Esami
                if dataManager.exams.isEmpty {
                    UniEmptyStateView(
                        icon: "graduationcap",
                        title: localizationManager.t(.noExamsEmptyTitle),
                        subtitle: localizationManager.t(.noExamsEmptyDesc),
                        buttonTitle: localizationManager.t(.planExamAction)
                    ) {
                        isPresentingNewExam = true
                    }
                } else if filteredExams.isEmpty {
                    UniEmptyStateView(
                        icon: "tray",
                        title: "Nessun esame trovato",
                        subtitle: "Nessun appello corrisponde al filtro selezionato."
                    )
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredExams) { exam in
                            ExamRowView(
                                exam: exam,
                                onEdit: { examToEdit = exam },
                                onDelete: { deleteExam(exam) },
                                onRegisterGrade: { examToRegisterGrade = exam }
                            )
                        }
                    }
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $isPresentingNewExam) {
            ExamEditorSheet(examToEdit: nil) { newExam in
                dataManager.exams.append(newExam)
                dataManager.saveData()
                
                let courseName = dataManager.courses.first(where: { $0.id == newExam.courseId })?.name ?? "Esame"
                NotificationManager.shared.notify(
                    title: "Appello d'esame programmato",
                    message: "\(courseName): \(newExam.title)",
                    type: .info,
                    icon: "calendar.badge.plus"
                )
                NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
            }
        }
        .sheet(item: $examToEdit) { exam in
            ExamEditorSheet(examToEdit: exam) { updated in
                if let idx = dataManager.exams.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.exams[idx] = updated
                    dataManager.saveData()
                    NotificationManager.shared.notify(
                        title: "Dettagli esame aggiornati",
                        message: updated.title,
                        type: .info,
                        icon: "pencil"
                    )
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
            }
        }
        .sheet(item: $examToRegisterGrade) { exam in
            RegisterGradeSheet(exam: exam) { updated in
                if let idx = dataManager.exams.firstIndex(where: { $0.id == updated.id }) {
                    dataManager.exams[idx] = updated
                    dataManager.saveData()
                    
                    let gradeStr = updated.grade.flatMap { "\($0)/30\(updated.honors ? " e Lode" : "")" } ?? "Registrato"
                    NotificationManager.shared.notify(
                        title: "Voto registrato con successo! 🎓",
                        message: "\(updated.title): \(gradeStr). Nuova media: \(String(format: "%.2f", dataManager.weightedAverage))",
                        type: .success,
                        icon: "graduationcap.fill",
                        postToSystem: true
                    )
                    NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
                }
            }
        }
        .onAppear {
            if let targetId = dataManager.selectedExamId,
               let found = dataManager.exams.first(where: { $0.id == targetId }) {
                examToEdit = found
                dataManager.selectedExamId = nil
            }
        }
        .onChange(of: dataManager.selectedExamId) { _, newId in
            if let newId = newId, let found = dataManager.exams.first(where: { $0.id == newId }) {
                examToEdit = found
                dataManager.selectedExamId = nil
            }
        }
    }
    
    private func deleteExam(_ exam: Exam) {
        dataManager.exams.removeAll { $0.id == exam.id }
        dataManager.saveData()
        let isEn = localizationManager.currentLanguage == .english
        NotificationManager.shared.notify(
            title: isEn ? "Exam removed" : "Esame rimosso",
            message: exam.title,
            type: .warning,
            icon: "trash"
        )
        NotificationManager.shared.scheduleAllReminders(deadlines: dataManager.deadlines, exams: dataManager.exams, courses: dataManager.courses)
    }
}

// MARK: - Exam Row View
struct ExamRowView: View {
    let exam: Exam
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onRegisterGrade: () -> Void
    
    var body: some View {
        UniCard(padding: 14) {
            HStack(spacing: 14) {
                // Indicatore Voto o Data
                if exam.status == .passed, let grade = exam.grade {
                    VStack(spacing: 1) {
                        HStack(alignment: .top, spacing: 2) {
                            Text("\(grade)")
                                .font(UniFont.title())
                                .fontWeight(.bold)
                                .foregroundStyle(themeManager.accentColor)
                            if exam.honors {
                                Text("L")
                                    .font(UniFont.subheadline())
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeManager.accentColor)
                            }
                        }
                        Text("/ 30")
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 52)
                } else {
                    VStack(spacing: 1) {
                        Text(formatExamDay(exam.examDate))
                            .font(UniFont.headline())
                            .fontWeight(.bold)
                        Text(formatExamMonth(exam.examDate))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 52)
                }
                
                Divider()
                    .frame(height: 32)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(exam.title)
                            .font(UniFont.headline())
                        
                        if let course = dataManager.courses.first(where: { $0.id == exam.courseId }) {
                            UniBadge(course.name, color: Color(hex: course.colorHex) ?? themeManager.accentColor)
                            Text("\(course.cfu) CFU")
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Label(exam.type.localizedName, systemImage: "pencil.and.outline")
                        if !exam.room.isEmpty {
                            Label(exam.room, systemImage: "mappin")
                        }
                        if exam.status != .passed, let target = exam.targetGrade {
                            Text("Target: \(target)/30")
                                .foregroundStyle(themeManager.accentColor)
                        }
                    }
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                UniBadge(exam.status.localizedName, color: exam.status.badgeColor)
                
                if exam.status != .passed {
                    Button(localizationManager.text(it: "Registra Voto", en: "Record Grade")) {
                        onRegisterGrade()
                    }
                    .font(UniFont.subheadline())
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                Menu {
                    Button(localizationManager.text(it: "Modifica", en: "Edit"), action: onEdit)
                    Button(localizationManager.text(it: "Elimina", en: "Delete"), role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 18)
            }
        }
    }
    
    private func formatExamDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
    
    private func formatExamMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "MMM"
        return f.string(from: date).uppercased()
    }
}

// MARK: - Modal Registra Voto (Polished Sheet)
struct RegisterGradeSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    let exam: Exam
    var onSave: (Exam) -> Void
    
    @State private var grade: Int = 28
    @State private var honors: Bool = false
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.green)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Registra Voto", en: "Record Grade"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Verbalizza il voto per \(exam.title)", en: "Record final grade for \(exam.title)"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section(localizationManager.text(it: "Esito Esame", en: "Exam Outcome")) {
                    Stepper(localizationManager.text(it: "Voto: \(grade) / 30", en: "Grade: \(grade) / 30"), value: $grade, in: 18...30)
                    if grade == 30 {
                        Toggle(localizationManager.text(it: "Lode (30L)", en: "With Honors (30L)"), isOn: $honors)
                    }
                }
                
                Section(localizationManager.text(it: "Note Commissione", en: "Committee Notes")) {
                    TextField(localizationManager.text(it: "Note sull'esito o commissione (opzionale)", en: "Notes on outcome or professors (optional)"), text: $notes)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Verbalizza", en: "Save Grade")) {
                    var updated = exam
                    updated.status = .passed
                    updated.grade = grade
                    updated.honors = (grade == 30) ? honors : false
                    if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        updated.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    onSave(updated)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
            }
            .padding(16)
        }
        .frame(width: 440, height: 320)
    }
}

// MARK: - Modal Editor Esame (Polished Sheet)
struct ExamEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var examToEdit: Exam?
    var onSave: (Exam) -> Void
    
    @State private var title: String = ""
    @State private var courseId: UUID = UUID()
    @State private var examDate: Date = Date().addingTimeInterval(86400 * 14)
    @State private var type: Exam.ExamType = .writtenOral
    @State private var room: String = ""
    @State private var status: Exam.ExamStatus = .planned
    @State private var targetGrade: Int = 28
    @State private var hasTargetGrade: Bool = false
    @State private var notes: String = ""
    
    init(examToEdit: Exam?, onSave: @escaping (Exam) -> Void) {
        self.examToEdit = examToEdit
        self.onSave = onSave
        _title = State(initialValue: examToEdit?.title ?? "")
        _courseId = State(initialValue: examToEdit?.courseId ?? UUID())
        _examDate = State(initialValue: examToEdit?.examDate ?? Date().addingTimeInterval(86400 * 14))
        _type = State(initialValue: examToEdit?.type ?? .writtenOral)
        _room = State(initialValue: examToEdit?.room ?? "")
        _status = State(initialValue: examToEdit?.status ?? .planned)
        _hasTargetGrade = State(initialValue: examToEdit?.targetGrade != nil)
        _targetGrade = State(initialValue: examToEdit?.targetGrade ?? 28)
        _notes = State(initialValue: examToEdit?.notes ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Rectangle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(Rectangle().stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1))
                    Image(systemName: "graduationcap")
                        .font(.system(size: 16))
                        .foregroundStyle(themeManager.accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(examToEdit == nil ? localizationManager.text(it: "Pianifica Esame", en: "Schedule Exam") : localizationManager.text(it: "Modifica Esame", en: "Edit Exam"))
                        .font(UniFont.title())
                        .fontWeight(.semibold)
                    Text(localizationManager.text(it: "Sessione d'appello e informazioni d'esame", en: "Exam session and course details"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(20)
            
            Divider()
            
            Form {
                Section(localizationManager.text(it: "Dettagli Appello", en: "Exam Session Details")) {
                    TextField(localizationManager.text(it: "Nome Appello (es. Primo Appello, Parziale)", en: "Session Title (e.g. First Session, Midterm)"), text: $title)
                    
                    if !dataManager.courses.isEmpty {
                        Picker(localizationManager.text(it: "Materia", en: "Course"), selection: $courseId) {
                            ForEach(dataManager.courses) { course in
                                Text(course.name).tag(course.id)
                            }
                        }
                    }
                    
                    DatePicker(localizationManager.text(it: "Data e Ora", en: "Date & Time"), selection: $examDate)
                    
                    Picker(localizationManager.text(it: "Tipologia", en: "Format"), selection: $type) {
                        ForEach(Exam.ExamType.allCases, id: \.self) { t in
                            Text(t.localizedName).tag(t)
                        }
                    }
                    
                    TextField(localizationManager.text(it: "Aula (opzionale)", en: "Classroom (optional)"), text: $room)
                }
                
                Section(localizationManager.text(it: "Obiettivi & Note", en: "Goals & Notes")) {
                    Picker(localizationManager.text(it: "Stato", en: "Status"), selection: $status) {
                        ForEach(Exam.ExamStatus.allCases, id: \.self) { s in
                            Text(s.localizedName).tag(s)
                        }
                    }
                    
                    Toggle(localizationManager.text(it: "Imposta Voto Obiettivo", en: "Set Target Grade"), isOn: $hasTargetGrade)
                    if hasTargetGrade {
                        Stepper(localizationManager.text(it: "Obiettivo: \(targetGrade) / 30", en: "Target: \(targetGrade) / 30"), value: $targetGrade, in: 18...30)
                    }
                    
                    TextField(localizationManager.text(it: "Note o requisiti per l'iscrizione", en: "Notes or enrollment requirements"), text: $notes)
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Button(localizationManager.t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(localizationManager.text(it: "Salva", en: "Save")) {
                    let updated = Exam(
                        id: examToEdit?.id ?? UUID(),
                        courseId: courseId,
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        examDate: examDate,
                        type: type,
                        room: room.trimmingCharacters(in: .whitespacesAndNewlines),
                        status: status,
                        grade: examToEdit?.grade,
                        honors: examToEdit?.honors ?? false,
                        targetGrade: hasTargetGrade ? targetGrade : nil,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
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
        .frame(width: 480, height: 550)
        .onAppear {
            if examToEdit == nil, let first = dataManager.courses.first {
                courseId = first.id
            }
        }
    }
}

// MARK: - What-If GPA & Graduation Simulator Card
struct WhatIfSimulatorCard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isExpanded = false
    @State private var selectedCourseId: UUID? = nil
    @State private var simulatedCFU = 6
    @State private var simulatedGrade = 28
    
    private var selectedCourse: Course? {
        guard let id = selectedCourseId else { return nil }
        return dataManager.courses.first(where: { $0.id == id })
    }
    
    private var currentAcquiredPoints: Double {
        var points = 0.0
        for exam in dataManager.exams where exam.status == .passed {
            if let grade = exam.grade, let course = dataManager.courses.first(where: { $0.id == exam.courseId }) {
                points += Double(grade * course.cfu)
            }
        }
        return points
    }
    
    private var currentCFU: Double {
        Double(dataManager.totalCfuAcquired)
    }
    
    private var simulatedTotalCFU: Double {
        currentCFU + Double(simulatedCFU)
    }
    
    private var projectedAverage: Double {
        guard simulatedTotalCFU > 0 else { return Double(simulatedGrade) }
        let totalPoints = currentAcquiredPoints + Double(simulatedGrade * simulatedCFU)
        return totalPoints / simulatedTotalCFU
    }
    
    private var averageDelta: Double {
        guard dataManager.weightedAverage > 0 else { return 0.0 }
        return projectedAverage - dataManager.weightedAverage
    }
    
    private var projectedGraduationBase: Double {
        (projectedAverage / 30.0) * 110.0
    }
    
    private var graduationBaseDelta: Double {
        guard dataManager.estimatedGraduationGrade > 0 else { return 0.0 }
        return projectedGraduationBase - dataManager.estimatedGraduationGrade
    }
    
    private var cfuWeightPercentage: Double {
        guard simulatedTotalCFU > 0 else { return 0.0 }
        return (Double(simulatedCFU) / simulatedTotalCFU) * 100.0
    }
    
    var body: some View {
        UniCard(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                // Header Toggle
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(themeManager.accentColor.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(themeManager.accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(localizationManager.text(it: "Simulatore Media & Proiezione Laurea (What-If)", en: "GPA Simulator & Degree Projection (What-If)"))
                                .font(UniFont.headline())
                                .foregroundStyle(.primary)
                            Text(isExpanded 
                                ? localizationManager.text(it: "Scegli un corso dai tuoi per simulare il suo peso reale in CFU sulla media", en: "Pick one of your courses to simulate its real CFU weight on your GPA")
                                : localizationManager.text(it: "Clicca per simulare il voto del prossimo esame", en: "Click to simulate your next exam grade"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                if isExpanded {
                    Divider()
                    
                    // Selettore Corso dai Propri Corsi
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(localizationManager.text(it: "CORSO DA SIMULARE:", en: "COURSE TO SIMULATE:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                                .tracking(0.6)
                            
                            Spacer()
                            
                            if let course = selectedCourse {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(hex: course.colorHex) ?? themeManager.accentColor)
                                        .frame(width: 7, height: 7)
                                    Text("\(course.cfu) CFU")
                                        .font(UniFont.caption())
                                        .fontWeight(.semibold)
                                        .foregroundStyle(themeManager.accentColor)
                                }
                            }
                        }
                        
                        Picker("", selection: $selectedCourseId) {
                            if !dataManager.courses.isEmpty {
                                ForEach(dataManager.courses) { course in
                                    let passed = dataManager.exams.contains(where: { $0.courseId == course.id && $0.status == .passed })
                                    let prefix = passed ? "✓ " : ""
                                    Text("\(prefix)\(course.name) (\(course.cfu) CFU)").tag(UUID?.some(course.id))
                                }
                            }
                            Text(localizationManager.text(it: "Personalizzato (CFU manuali)", en: "Custom (Manual CFU)")).tag(UUID?.none)
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 2)
                    
                    // Controlli Simulatore
                    HStack(spacing: 20) {
                        // CFU
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.text(it: "CFU ESAME:", en: "EXAM CREDITS:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                                .tracking(0.6)
                            
                            if selectedCourse == nil {
                                Picker("", selection: $simulatedCFU) {
                                    ForEach([1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 15, 18, 20, 24, 30], id: \.self) { cfu in
                                        Text("\(cfu) CFU").tag(cfu)
                                    }
                                }
                                .labelsHidden()
                                .frame(maxWidth: 130)
                            } else {
                                HStack(spacing: 6) {
                                    Text("\(simulatedCFU) CFU")
                                        .font(UniFont.headline())
                                        .foregroundStyle(themeManager.accentColor)
                                    Text(localizationManager.text(it: "(da piano)", en: "(course plan)"))
                                        .font(UniFont.caption())
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.primary.opacity(0.04))
                                .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                                .clipShape(Rectangle())
                            }
                        }
                        
                        // Voto Ipotetico
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(localizationManager.text(it: "VOTO IPOTETICO:", en: "HYPOTHETICAL GRADE:"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .tracking(0.6)
                                Spacer()
                                Text("\(simulatedGrade) / 30")
                                    .font(UniFont.headline())
                                    .foregroundStyle(themeManager.accentColor)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(simulatedGrade) },
                                set: { simulatedGrade = Int($0) }
                            ), in: 18...30, step: 1)
                            .tint(themeManager.accentColor)
                            .frame(minWidth: 150)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Nota informativa sul peso percentuale del corso sulla carriera
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 11))
                            .foregroundStyle(themeManager.accentColor)
                        
                        let courseName = selectedCourse?.name ?? localizationManager.text(it: "Esame", en: "Exam")
                        Text(localizationManager.text(
                            it: "\(courseName) pesa \(simulatedCFU) CFU su \(Int(simulatedTotalCFU)) CFU totali (\(String(format: "%.1f", cfuWeightPercentage))% dell'impatto sulla media)",
                            en: "\(courseName) weighs \(simulatedCFU) CFU out of \(Int(simulatedTotalCFU)) total CFU (\(String(format: "%.1f", cfuWeightPercentage))% impact on GPA)"
                        ))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    // Risultati Simulazione
                    HStack(spacing: 12) {
                        // Proiezione Nuova Media
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.text(it: "NUOVA MEDIA PREVISTA", en: "PROJECTED NEW AVERAGE"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(String(format: "%.2f", projectedAverage))
                                    .font(UniFont.largeTitle())
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeManager.accentColor)
                                
                                if dataManager.weightedAverage > 0 {
                                    let avgDeltaStr = String(format: "%+.2f", averageDelta)
                                    Text(avgDeltaStr)
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(averageDelta >= 0 ? Color.green.opacity(0.18) : Color.red.opacity(0.18))
                                        .foregroundStyle(averageDelta >= 0 ? Color.green : Color.red)
                                        .clipShape(Rectangle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.primary.opacity(0.03))
                        .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                        .clipShape(Rectangle())
                        
                        // Proiezione Base di Laurea
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.text(it: "BASE LAUREA (/110)", en: "GRADUATION BASE (/110)"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(String(format: "%.1f", projectedGraduationBase))
                                    .font(UniFont.largeTitle())
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                if dataManager.estimatedGraduationGrade > 0 {
                                    let gradDeltaStr = String(format: "%+.1f", graduationBaseDelta)
                                    Text(gradDeltaStr)
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(graduationBaseDelta >= 0 ? Color.green.opacity(0.18) : Color.red.opacity(0.18))
                                        .foregroundStyle(graduationBaseDelta >= 0 ? Color.green : Color.red)
                                        .clipShape(Rectangle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.primary.opacity(0.03))
                        .overlay(Rectangle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                        .clipShape(Rectangle())
                    }
                }
            }
        }
        .onAppear {
            if selectedCourseId == nil {
                if let firstPending = dataManager.courses.first(where: { course in
                    !dataManager.exams.contains(where: { $0.courseId == course.id && $0.status == .passed })
                }) ?? dataManager.courses.first {
                    selectedCourseId = firstPending.id
                    simulatedCFU = firstPending.cfu
                    if let target = dataManager.exams.first(where: { $0.courseId == firstPending.id && $0.targetGrade != nil })?.targetGrade {
                        simulatedGrade = target
                    }
                }
            }
        }
        .onChange(of: selectedCourseId) { _, newId in
            if let course = dataManager.courses.first(where: { $0.id == newId }) {
                simulatedCFU = course.cfu
                if let target = dataManager.exams.first(where: { $0.courseId == course.id && $0.targetGrade != nil })?.targetGrade {
                    simulatedGrade = target
                }
            }
        }
    }
}
