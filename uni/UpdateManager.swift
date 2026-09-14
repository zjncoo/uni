//
//  UpdateManager.swift
//  uni
//
//  Auto-updater: checks GitHub Releases API, compares semver, and triggers
//  an out-of-sandbox bash script that downloads the DMG and replaces
//  /Applications/uni.app without user intervention.
//

import SwiftUI
import AppKit
import Combine

// MARK: - GitHub Release Model

struct GitHubRelease: Codable {
    let tagName: String      // e.g. "v1.2.0"
    let name: String?
    let body: String?        // Changelog markdown
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name, body
        case htmlUrl = "html_url"
    }

    /// Direct DMG download URL from the release assets
    var dmgDownloadURL: String {
        "https://github.com/zjncoo/uni/releases/download/\(tagName)/uni.dmg"
    }

    /// Cleaned version string (strips leading "v")
    var version: String {
        tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
    }

    /// Short changelog (first 300 chars)
    var shortChangelog: String {
        guard let body = body, !body.isEmpty else { return "" }
        let clean = body
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "### ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "* ", with: "• ")
        return String(clean.prefix(280))
    }
}

// MARK: - UpdateManager

@MainActor
class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    private let apiURL = "https://api.github.com/repos/zjncoo/uni/releases/latest"
    private let checkIntervalSeconds: TimeInterval = 86400 // once per day
    private let lastCheckKey = "uni_last_update_check"
    private let ignoredVersionKey = "uni_ignored_update_version"

    @Published var availableRelease: GitHubRelease? = nil
    @Published var updateState: UpdateState = .idle

    enum UpdateState: Equatable {
        case idle
        case checking
        case available(GitHubRelease)
        case downloading(Double)   // progress 0.0 – 1.0
        case installing
        case done
        case error(String)

        static func == (lhs: UpdateState, rhs: UpdateState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.checking, .checking), (.installing, .installing), (.done, .done): return true
            case (.downloading(let a), .downloading(let b)): return a == b
            case (.available(let a), .available(let b)): return a.tagName == b.tagName
            case (.error(let a), .error(let b)): return a == b
            default: return false
            }
        }
    }

    private init() {}

    // MARK: - Check for Updates

    func checkForUpdates(force: Bool = false) async {
        // Rate-limit: once per day unless forced
        if !force {
            let last = UserDefaults.standard.double(forKey: lastCheckKey)
            if Date().timeIntervalSince1970 - last < checkIntervalSeconds { return }
        }

        updateState = .checking
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckKey)

        do {
            var request = URLRequest(url: URL(string: apiURL)!)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.setValue("uni-macos-app/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10

            let (data, _) = try await URLSession.shared.data(for: request)
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)

            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let ignoredVersion = UserDefaults.standard.string(forKey: ignoredVersionKey) ?? ""

            if isNewer(release.version, than: currentVersion) && release.version != ignoredVersion {
                availableRelease = release
                updateState = .available(release)
            } else {
                updateState = .idle
            }
        } catch {
            updateState = .idle // Silent failure — don't bother user if network is unavailable
        }
    }

    // MARK: - Dismiss / Ignore

    func dismissUpdate() {
        if let release = availableRelease {
            UserDefaults.standard.set(release.version, forKey: ignoredVersionKey)
        }
        availableRelease = nil
        updateState = .idle
    }

    // MARK: - Install Update

    func installUpdate() async {
        guard let release = availableRelease else { return }

        // 1. Prepare the updater script in /tmp (outside sandbox)
        let tmpScript = URL(fileURLWithPath: "/tmp/uni_updater_\(Int(Date().timeIntervalSince1970)).sh")
        if let scriptURL = Bundle.main.url(forResource: "uni_updater", withExtension: "sh") {
            try? FileManager.default.copyItem(at: scriptURL, to: tmpScript)
        }
        
        if !FileManager.default.fileExists(atPath: tmpScript.path) {
            let embeddedScript = """
            #!/bin/bash
            set -euo pipefail
            DMG_URL="${1:-https://github.com/zjncoo/uni/releases/latest/download/uni.dmg}"
            OLD_PID="${2:-}"
            APP_DEST="/Applications/uni.app"
            TMP_DMG="/tmp/uni_update_$(date +%s).dmg"
            MOUNT_POINT="/Volumes/uni_update"
            echo "[uni-updater] Downloading uni.dmg from $DMG_URL..."
            curl -L --progress-bar -o "$TMP_DMG" "$DMG_URL"
            hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
            hdiutil attach "$TMP_DMG" -nobrowse -readonly -mountpoint "$MOUNT_POINT" -quiet
            sleep 1
            if [ ! -d "$MOUNT_POINT/uni.app" ]; then
                hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
                rm -f "$TMP_DMG"
                exit 1
            fi
            if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
                kill -TERM "$OLD_PID" 2>/dev/null || true
                sleep 2
                kill -KILL "$OLD_PID" 2>/dev/null || true
            fi
            pkill -x "uni" 2>/dev/null || true
            sleep 1
            rm -rf "$APP_DEST"
            cp -R "$MOUNT_POINT/uni.app" "$APP_DEST"
            xattr -rc "$APP_DEST" 2>/dev/null || true
            hdiutil detach "$MOUNT_POINT" -force -quiet 2>/dev/null || true
            rm -f "$TMP_DMG"
            sleep 0.5
            open -n "$APP_DEST"
            """
            do {
                try embeddedScript.write(to: tmpScript, atomically: true, encoding: .utf8)
            } catch {
                updateState = .error("Cannot write updater script: \(error.localizedDescription)")
                return
            }
        }
        
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tmpScript.path)

        let pid = String(ProcessInfo.processInfo.processIdentifier)
        let dmgURL = release.dmgDownloadURL

        updateState = .installing

        // 2. Show a Terminal window running the updater (visible progress for user)
        //    The script will quit this app and relaunch the new version.
        let script = """
        tell application "Terminal"
            activate
            set w to do script "/bin/bash \(tmpScript.path) '\(dmgURL)' \(pid)"
            set custom title of w to "uni • Aggiornamento in corso..."
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }

        if error != nil {
            // Fallback: launch directly via Process (no Terminal window)
            launchUpdaterSilently(scriptPath: tmpScript.path, dmgURL: dmgURL, pid: pid)
        }

        // App will be quit by the script; set state for UI in case delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.updateState = .done
        }
    }

    private func launchUpdaterSilently(scriptPath: String, dmgURL: String, pid: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath, dmgURL, pid]
        process.qualityOfService = .userInitiated
        try? process.run()
    }

    // MARK: - Semver Comparison

    private func isNewer(_ remote: String, than local: String) -> Bool {
        let rv = parseVersion(remote)
        let lv = parseVersion(local)
        for i in 0..<3 {
            let r = i < rv.count ? rv[i] : 0
            let l = i < lv.count ? lv[i] : 0
            if r > l { return true }
            if r < l { return false }
        }
        return false
    }

    private func parseVersion(_ v: String) -> [Int] {
        v.split(separator: ".").compactMap { Int($0) }
    }
}

// MARK: - Update Banner View (sidebar ribbon)

struct UpdateBannerView: View {
    @ObservedObject var updateManager = UpdateManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var isExpanded = false
    @State private var isInstalling = false

    var body: some View {
        if let release = updateManager.availableRelease, updateManager.updateState != .done {
            VStack(spacing: 0) {
                // Compact Banner
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 22, height: 22)
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.orange)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text(localizationManager.text(it: "Aggiornamento", en: "Update") + " \(release.version)")
                                .font(UniFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.07))
                }
                .buttonStyle(.plain)

                // Expanded Panel
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        if !release.shortChangelog.isEmpty {
                            Text(localizationManager.text(it: "Novità:", en: "What's new:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)

                            Text(release.shortChangelog)
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                                .lineSpacing(2)
                                .lineLimit(6)
                        }

                        HStack(spacing: 8) {
                            // Install button
                            Button {
                                isInstalling = true
                                Task {
                                    await updateManager.installUpdate()
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    if isInstalling {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                            .frame(width: 12, height: 12)
                                    } else {
                                        Image(systemName: "arrow.down.circle")
                                            .font(.system(size: 11))
                                    }
                                    Text(isInstalling
                                         ? localizationManager.text(it: "Installazione...", en: "Installing...")
                                         : localizationManager.text(it: "Installa ora", en: "Install now"))
                                        .font(UniFont.caption())
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(isInstalling)

                            // Dismiss button
                            Button {
                                withAnimation {
                                    updateManager.dismissUpdate()
                                }
                            } label: {
                                Text(localizationManager.text(it: "Ignora", en: "Dismiss"))
                                    .font(UniFont.caption())
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(Color.primary.opacity(0.06))
                                    .overlay(Rectangle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                    .clipShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.05))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()
            }
        }
    }
}
