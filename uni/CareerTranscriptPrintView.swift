//
//  CareerTranscriptPrintView.swift
//  uni
//
//  Created by zinco.cc on 11/10/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers
import PDFKit
#endif

// MARK: - Career Transcript Print View (Layout Editoriale A4)
public struct CareerTranscriptPrintView: View {
    @ObservedObject var dataManager: DataManager
    @ObservedObject var localizationManager: LocalizationManager
    
    fileprivate static let datePrintFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()
    
    private var passedExams: [Exam] {
        dataManager.exams
            .filter { $0.status == .passed }
            .sorted(by: { (e1: Exam, e2: Exam) -> Bool in
                e1.examDate < e2.examDate
            })
    }
    
    private var pendingExams: [Exam] {
        dataManager.exams.filter { $0.status != .passed }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Istituzionale
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataManager.universityName.isEmpty ? "UNIVERSITÀ DEGLI STUDI" : dataManager.universityName.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    Text(localizationManager.text(it: "Libretto Universitario & Carriera", en: "Academic Career & Transcript"))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Text("\(localizationManager.text(it: "Studente", en: "Student")): \(dataManager.studentName.isEmpty ? "—" : dataManager.studentName)")
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(.black.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        UniPrintLogoView(size: 16)
                        Text("uni")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    Text("\(localizationManager.text(it: "Data emissione", en: "Issued on")): \(Self.datePrintFormatter.string(from: Date()))")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Box Indicatori Chiave (KPI)
            HStack(spacing: 12) {
                kpiCard(
                    title: localizationManager.text(it: "MEDIA PONDERATA", en: "WEIGHTED GPA"),
                    value: dataManager.weightedAverage > 0 ? String(format: "%.2f / 30", dataManager.weightedAverage) : "—",
                    color: .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "CFU ACQUISITI", en: "CREDITS EARNED"),
                    value: "\(dataManager.totalCfuAcquired) / \(dataManager.totalCfuTarget)",
                    color: .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "BASE LAUREA (/110)", en: "GRADUATION BASE"),
                    value: dataManager.baseGraduationGrade > 0 ? String(format: "%.1f", dataManager.baseGraduationGrade) : "—",
                    color: .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "ESAMI VERBALIZZATI", en: "PASSED EXAMS"),
                    value: "\(passedExams.count) / \(dataManager.exams.count)",
                    color: .black
                )
            }
            
            Divider()
            
            // Tabella Esami Superati
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.text(it: "ESAMI SUPERATI E VERBALIZZATI", en: "RECORDED PASSED EXAMS"))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                
                // Intestazione Colonne
                HStack {
                    Text(localizationManager.text(it: "INSEGNAMENTO", en: "COURSE"))
                        .font(.system(size: 9, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("CFU")
                        .font(.system(size: 9, weight: .medium))
                        .frame(width: 45, alignment: .center)
                    Text(localizationManager.text(it: "DATA", en: "DATE"))
                        .font(.system(size: 9, weight: .medium))
                        .frame(width: 85, alignment: .center)
                    Text(localizationManager.text(it: "VOTO", en: "GRADE"))
                        .font(.system(size: 9, weight: .medium))
                        .frame(width: 55, alignment: .trailing)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                if passedExams.isEmpty {
                    Text(localizationManager.text(it: "Nessun esame ancora verbalizzato.", en: "No passed exams recorded yet."))
                        .font(.system(size: 10.5, weight: .light))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(Array(passedExams.enumerated()), id: \.element.id) { index, exam in
                        let course = dataManager.courses.first(where: { $0.id == exam.courseId })
                        let courseName = course?.name ?? exam.title
                        let cfu = course?.cfu ?? 6
                        let dateStr = Self.datePrintFormatter.string(from: exam.examDate)
                        let gradeStr = exam.honors ? "30L" : (exam.grade.map { "\($0)" } ?? "—")
                        
                        HStack {
                            Text(courseName)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("\(cfu)")
                                .font(.system(size: 10, weight: .light, design: .monospaced))
                                .foregroundStyle(.black)
                                .frame(width: 45, alignment: .center)
                            
                            Text(dateStr)
                                .font(.system(size: 9, weight: .light))
                                .foregroundStyle(.secondary)
                                .frame(width: 85, alignment: .center)
                            
                            Text(gradeStr)
                                .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                                .foregroundStyle(.black)
                                .frame(width: 55, alignment: .trailing)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(index % 2 == 1 ? Color.black.opacity(0.02) : Color.clear)
                    }
                }
            }
            
            // Tabella Esami Rimanenti / In Corso
            if !pendingExams.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizationManager.text(it: "ESAMI ANCORA DA SOSTENERE", en: "PENDING EXAMS"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    
                    ForEach(pendingExams) { exam in
                        let course = dataManager.courses.first(where: { $0.id == exam.courseId })
                        let courseName = course?.name ?? exam.title
                        let cfu = course?.cfu ?? 6
                        
                        HStack {
                            Text(courseName)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(.black.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("\(cfu) CFU")
                                .font(.system(size: 9, weight: .light))
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .trailing)
                            
                            Text(localizationManager.text(it: "Da sostenere", en: "Pending"))
                                .font(.system(size: 9, weight: .light))
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                    }
                }
            }
            
            Spacer()
            
            // Footer Ufficiale uni (con Logo, Nome e Link al sito)
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    UniPrintLogoView(size: 14)
                    Text("uni")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(.black)
                }
                
                Text("•")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                
                Text(localizationManager.text(it: "Documento riassuntivo generato da uni per macOS • Senza valore legale di certificazione", en: "Summary career overview generated by uni for macOS • Without legal certification value"))
                    .font(.system(size: 8, weight: .light))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("uni.zinco.cc")
                    .font(.system(size: 8.5, weight: .regular))
                    .foregroundStyle(.black.opacity(0.85))
            }
            .padding(.top, 4)
        }
        .padding(32)
        .frame(width: 595)
        .frame(minHeight: 842)
        .background(Color.white)
    }
    
    private func kpiCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Career Transcript Export Manager
@MainActor
public class CareerTranscriptExportManager {
    public static let shared = CareerTranscriptExportManager()
    
    public func exportPDF(dataManager: DataManager, localizationManager: LocalizationManager) {
        #if canImport(AppKit)
        let printView = CareerTranscriptPrintView(dataManager: dataManager, localizationManager: localizationManager)
        
        let targetWidth: CGFloat = 595
        let targetHeight: CGFloat = 842
        let renderer = ImageRenderer(content: printView)
        renderer.proposedSize = ProposedViewSize(width: targetWidth, height: nil)
        renderer.scale = 2.0
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        let dateClean = DateFormatter.shortDate.string(from: Date()).replacingOccurrences(of: "/", with: "-")
        let sanitizedUser = dataManager.studentName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let userPart = sanitizedUser.isEmpty ? "" : "_\(sanitizedUser)"
        savePanel.nameFieldStringValue = "uni_transcript\(userPart)_\(dateClean).pdf"
        savePanel.title = localizationManager.text(it: "Salva Libretto Universitario in PDF", en: "Save Career Transcript as PDF")
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else { return }
        
        var writeSuccess = false
        let pdfData = NSMutableData()
        
        if let consumer = CGDataConsumer(data: pdfData as CFMutableData) {
            renderer.render { size, context in
                let pageHeight = max(targetHeight, size.height)
                var box = CGRect(x: 0, y: 0, width: targetWidth, height: pageHeight)
                if let pdfContext = CGContext(consumer: consumer, mediaBox: &box, nil) {
                    pdfContext.beginPDFPage(nil)
                    context(pdfContext)
                    pdfContext.endPDFPage()
                    pdfContext.closePDF()
                }
            }
            
            if pdfData.length > 0 {
                do {
                    try (pdfData as Data).write(to: url, options: .atomic)
                    writeSuccess = true
                } catch {
                    print("Errore scrittura PDF libretto: \(error)")
                }
            }
        }
        
        // Fallback affidabile con PDFKit se il context vettoriale non ha scritto
        if !writeSuccess, let nsImage = renderer.nsImage {
            if let pdfPage = PDFPage(image: nsImage) {
                let pdfDoc = PDFDocument()
                pdfDoc.insert(pdfPage, at: 0)
                writeSuccess = pdfDoc.write(to: url)
            }
        }
        
        if writeSuccess {
            NotificationManager.shared.notify(
                title: localizationManager.text(it: "Libretto Esportato", en: "Transcript Exported"),
                message: localizationManager.text(it: "File PDF salvato con successo sul tuo Mac.", en: "PDF file saved successfully on your Mac."),
                type: .success,
                icon: "doc.text.fill"
            )
            
            // Mostra il file generato nel Finder
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        #endif
    }
}
