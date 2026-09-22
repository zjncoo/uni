//
//  UpdateManager.swift
//  uni
//
//  Auto-updater & Manual Update Checker for uni (macOS):
//  - Checks public version manifest (GitHub Pages CDN fallback) & GitHub Releases API
//  - Compares semantic versioning against CFBundleShortVersionString
//  - Interactive Update Modal (Pop-up sheet) with release notes & direct download
//  - Manual "Controlla Aggiornamenti" button in Settings with live feedback
//  - Direct DMG download with progress indicator and auto-mount via NSWorkspace
//

import SwiftUI
import AppKit
import Combine

// MARK: - GitHub Release Model

public struct GitHubRelease: Codable, Identifiable {
    public var id: String { tagName }
    public let tagName: String         // e.g. "v1.2.0"
    public let name: String?
    public let body: String?           // Changelog markdown
    public let htmlUrl: String?
    public let dmgDownloadUrl: String?

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name, body
        case htmlUrl = "html_url"
        case dmgDownloadUrl = "dmg_download_url"
    }

    /// Direct DMG download URL from the release assets or fallback
    public var dmgDownloadURL: String {
        if let custom = dmgDownloadUrl, !custom.isEmpty {
            return custom
        }
        return "https://github.com/zjncoo/uni/releases/download/\(tagName)/uni.dmg"
    }

    /// Cleaned version string (strips leading "v")
    public var version: String {
        tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
    }

    /// Formatted changelog
    public var formattedChangelog: String {
        guard let body = body, !body.isEmpty else { return "" }
        return body
            .replacingOccurrences(of: "### ", with: "• ")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "**", with: "")
    }
}

// MARK: - Update Check Status

public enum UpdateCheckStatus: Equatable {
    case idle
    case checking
    case upToDate(version: String)
    case updateAvailable(GitHubRelease)
    case error(String)

    public static func == (lhs: UpdateCheckStatus, rhs: UpdateCheckStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.checking, .checking):
            return true
        case (.upToDate(let a), .upToDate(let b)):
            return a == b
        case (.updateAvailable(let a), .updateAvailable(let b)):
            return a.tagName == b.tagName
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - UpdateManager

@MainActor
public class UpdateManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    public static let shared = UpdateManager()

    // Primary: fast & public GitHub Pages CDN (works even when repo is private)
    private let pagesURL = "https://uni.zinco.cc/version.json"
    // Secondary: standard GitHub Releases API
    private let apiURL = "https://api.github.com/repos/zjncoo/uni/releases/latest"

    private let checkIntervalSeconds: TimeInterval = 43200 // 12 hours
    private let lastCheckKey = "uni_last_update_check"
    private let ignoredVersionKey = "uni_ignored_update_version"
    private let autoCheckKey = "uni_auto_check_updates"

    @Published public var availableRelease: GitHubRelease? = nil
    @Published public var showUpdateModal: Bool = false
    @Published public var checkStatus: UpdateCheckStatus = .idle
    @Published public var lastCheckDate: Date? = nil

    // Download state
    @Published public var isDownloading: Bool = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var downloadErrorMessage: String? = nil
    @Published public var isDownloaded: Bool = false
    @Published public var downloadedFileURL: URL? = nil

    @Published public var autoCheckUpdates: Bool {
        didSet {
            UserDefaults.standard.set(autoCheckUpdates, forKey: autoCheckKey)
        }
    }

    private var downloadTask: URLSessionDownloadTask? = nil
    private var downloadSession: URLSession? = nil

    override private init() {
        let savedAuto = UserDefaults.standard.object(forKey: autoCheckKey) as? Bool ?? true
        self.autoCheckUpdates = savedAuto

        let lastTime = UserDefaults.standard.double(forKey: lastCheckKey)
        if lastTime > 0 {
            self.lastCheckDate = Date(timeIntervalSince1970: lastTime)
        }
        super.init()
    }

    // MARK: - Current App Info

    public var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    public var currentBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Check for Updates

    public func checkForUpdates(force: Bool = false, isManual: Bool = false) async {
        // Skip automatic check if disabled by user
        if !isManual && !autoCheckUpdates { return }

        // Rate-limit automatic checks
        if !force && !isManual {
            let last = UserDefaults.standard.double(forKey: lastCheckKey)
            if last > 0 && (Date().timeIntervalSince1970 - last < checkIntervalSeconds) {
                return
            }
        }

        checkStatus = .checking
        downloadErrorMessage = nil

        let now = Date()
        lastCheckDate = now
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastCheckKey)

        do {
            let release = try await fetchLatestRelease()
            let ignoredVersion = UserDefaults.standard.string(forKey: ignoredVersionKey) ?? ""

            if isNewer(release.version, than: currentVersion) {
                availableRelease = release
                checkStatus = .updateAvailable(release)

                if isManual || release.version != ignoredVersion {
                    showUpdateModal = true
                }
            } else {
                availableRelease = nil
                checkStatus = .upToDate(version: currentVersion)
            }
        } catch {
            if isManual {
                let msg = error.localizedDescription.contains("404")
                    ? "Nessuna release remota trovata al momento."
                    : "Impossibile contattare il server per verificare gli aggiornamenti."
                checkStatus = .error(msg)
            } else {
                checkStatus = .idle
            }
        }
    }

    // MARK: - Network Fetch (Dual Endpoint)

    private func fetchLatestRelease() async throws -> GitHubRelease {
        // 1. Try public Pages version.json first
        if let release = try? await fetchFromURL(pagesURL) {
            return release
        }

        // 2. Fallback to GitHub Releases API
        return try await fetchFromURL(apiURL)
    }

    private func fetchFromURL(_ urlString: String) async throws -> GitHubRelease {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("uni-macos-app/\(currentVersion)", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }

    // MARK: - Dismiss & Ignore

    public func dismissUpdate(ignoreVersion: Bool = false) {
        if ignoreVersion, let release = availableRelease {
            UserDefaults.standard.set(release.version, forKey: ignoredVersionKey)
        }
        showUpdateModal = false
    }

    // MARK: - Download & Installation

    public func downloadAndInstall() {
        guard let release = availableRelease else { return }
        guard let url = URL(string: release.dmgDownloadURL) else {
            openReleaseInBrowser()
            return
        }

        isDownloading = true
        downloadProgress = 0.0
        downloadErrorMessage = nil
        isDownloaded = false

        let config = URLSessionConfiguration.default
        downloadSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = downloadSession?.downloadTask(with: url)
        downloadTask?.resume()
    }

    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        isDownloading = false
        downloadProgress = 0.0
    }

    public func openReleaseInBrowser() {
        if let release = availableRelease, let urlString = release.htmlUrl, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "https://github.com/zjncoo/uni/releases/latest") {
            NSWorkspace.shared.open(url)
        }
    }

    public func openDownloadedDMG() {
        if let fileURL = downloadedFileURL {
            NSWorkspace.shared.open(fileURL)
        }
    }

    // MARK: - URLSessionDownloadDelegate

    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let progress = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0.0

        Task { @MainActor in
            self.downloadProgress = min(max(progress, 0.0), 1.0)
        }
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let downloadsFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let destination = downloadsFolder.appendingPathComponent("uni.dmg")

        try? FileManager.default.removeItem(at: destination)

        do {
            try FileManager.default.moveItem(at: location, to: destination)
            Task { @MainActor in
                self.isDownloading = false
                self.isDownloaded = true
                self.downloadedFileURL = destination
                // Open DMG in Finder
                NSWorkspace.shared.open(destination)
            }
        } catch {
            Task { @MainActor in
                self.isDownloading = false
                self.downloadErrorMessage = "Errore durante il salvataggio del file: \(error.localizedDescription)"
                // Fallback: apri browser
                self.openReleaseInBrowser()
            }
        }
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            Task { @MainActor in
                if (error as NSError).code != NSURLErrorCancelled {
                    self.isDownloading = false
                    self.downloadErrorMessage = "Download non riuscito: \(error.localizedDescription)"
                    // Fallback to browser
                    self.openReleaseInBrowser()
                }
            }
        }
    }

    // MARK: - Semver Comparison

    public func isNewer(_ remote: String, than local: String) -> Bool {
        let rv = parseVersion(remote)
        let lv = parseVersion(local)
        for i in 0..<max(rv.count, lv.count) {
            let r = i < rv.count ? rv[i] : 0
            let l = i < lv.count ? lv[i] : 0
            if r > l { return true }
            if r < l { return false }
        }
        return false
    }

    private func parseVersion(_ v: String) -> [Int] {
        let clean = v.trimmingCharacters(in: CharacterSet.decimalDigits.inverted.subtracting(["."]))
        return clean.split(separator: ".").compactMap { Int($0) }
    }
}

// MARK: - Update Modal Dialog (Pop-up Sheet)

public struct UpdateModalView: View {
    @ObservedObject var updateManager = UpdateManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.accentColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Aggiornamento Disponibile", en: "Update Available"))
                        .font(UniFont.title())
                        .foregroundStyle(.primary)

                    if let release = updateManager.availableRelease {
                        HStack(spacing: 6) {
                            Text("uni v\(updateManager.currentVersion)")
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text("v\(release.version)")
                                .font(UniFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(themeManager.accentColor)
                        }
                    }
                }

                Spacer()

                Button {
                    updateManager.dismissUpdate()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(22)

            Divider()

            // Content & Changelog
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let release = updateManager.availableRelease {
                        if let name = release.name, !name.isEmpty {
                            Text(name)
                                .font(UniFont.headline())
                                .foregroundStyle(.primary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizationManager.text(it: "Novità introdotte:", en: "What's new:"))
                                .font(UniFont.subheadline())
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Text(release.formattedChangelog.isEmpty
                                 ? localizationManager.text(it: "Miglioramenti generali alle prestazioni e alla stabilità grafica.", en: "General performance and visual stability improvements.")
                                 : release.formattedChangelog)
                                .font(UniFont.body())
                                .lineSpacing(4)
                                .foregroundStyle(.primary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.03))
                        .overlay(
                            Rectangle()
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                    }

                    // Download Progress View
                    if updateManager.isDownloading {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(localizationManager.text(it: "Download pacchetto uni.dmg...", en: "Downloading uni.dmg package..."))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int(updateManager.downloadProgress * 100))%")
                                    .font(UniFont.caption())
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeManager.accentColor)
                            }

                            ProgressView(value: updateManager.downloadProgress)
                                .tint(themeManager.accentColor)

                            Button {
                                updateManager.cancelDownload()
                            } label: {
                                Text(localizationManager.text(it: "Annulla Download", en: "Cancel Download"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(themeManager.accentColor.opacity(0.06))
                        .overlay(
                            Rectangle().stroke(themeManager.accentColor.opacity(0.2), lineWidth: 1)
                        )
                    }

                    // Downloaded success banner
                    if updateManager.isDownloaded {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(localizationManager.text(it: "uni.dmg scaricato con successo!", en: "uni.dmg downloaded successfully!"))
                                    .font(UniFont.subheadline())
                                    .fontWeight(.semibold)
                                Text(localizationManager.text(it: "L'immagine disco è stata aperta nel Finder: trascina uni.app in Applicazioni per completare.", en: "Disk image mounted in Finder: drag uni.app into Applications to complete."))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                updateManager.openDownloadedDMG()
                            } label: {
                                Text(localizationManager.text(it: "Riapri DMG", en: "Reopen DMG"))
                                    .font(UniFont.caption())
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.08))
                        .overlay(Rectangle().stroke(Color.green.opacity(0.2), lineWidth: 1))
                    }

                    if let error = updateManager.downloadErrorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(22)
            }
            .frame(maxHeight: 280)

            Divider()

            // Footer Actions
            HStack(spacing: 12) {
                Button {
                    updateManager.dismissUpdate(ignoreVersion: true)
                } label: {
                    Text(localizationManager.text(it: "Ignora versione", en: "Skip this version"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    updateManager.dismissUpdate(ignoreVersion: false)
                } label: {
                    Text(localizationManager.text(it: "Più tardi", en: "Remind me later"))
                        .font(UniFont.subheadline())
                }
                .buttonStyle(.bordered)

                Button {
                    updateManager.openReleaseInBrowser()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.forward.app")
                        Text(localizationManager.text(it: "Browser", en: "Browser"))
                    }
                    .font(UniFont.subheadline())
                }
                .buttonStyle(.bordered)

                Button {
                    updateManager.downloadAndInstall()
                } label: {
                    HStack(spacing: 6) {
                        if updateManager.isDownloading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                        }
                        Text(updateManager.isDownloaded
                             ? localizationManager.text(it: "Riapri Installer", en: "Reopen Installer")
                             : localizationManager.text(it: "Scarica & Installa", en: "Download & Install"))
                    }
                    .font(UniFont.headline())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor)
                .disabled(updateManager.isDownloading)
            }
            .padding(18)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Update Banner View (Sidebar ribbon fallback)

public struct UpdateBannerView: View {
    @ObservedObject var updateManager = UpdateManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager

    public init() {}

    public var body: some View {
        if let release = updateManager.availableRelease {
            Button {
                updateManager.showUpdateModal = true
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 22, height: 22)
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.orange)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(localizationManager.text(it: "Aggiornamento v\(release.version)", en: "Update v\(release.version)"))
                            .font(UniFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.orange.opacity(0.08))
                .overlay(
                    Rectangle()
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
    }
}
