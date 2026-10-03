//
//  UniSearchEngine.swift
//  uni
//
//  Created by zinco.cc on 02/10/2026.
//

import Foundation
import SwiftUI

/// Motore di ricerca ottimizzato con tolleranza ai refusi (typo correction),
/// corrispondenza fuzzy (Levenshtein distance & subsequence), normalizzazione diacritici
/// e classificazione per rilevanza (ranking).
public enum UniSearchEngine {
    
    // MARK: - Normalization
    public static func normalize(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public static func tokenize(_ text: String) -> [String] {
        let clean = normalize(text)
        return clean.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    
    // MARK: - Levenshtein Distance
    public static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        if s1 == s2 { return 0 }
        let a1 = Array(s1)
        let a2 = Array(s2)
        let m = a1.count
        let n = a2.count
        if m == 0 { return n }
        if n == 0 { return m }
        
        var prev = Array(0...n)
        var curr = Array(repeating: 0, count: n + 1)
        
        for i in 1...m {
            curr[0] = i
            for j in 1...n {
                if a1[i - 1] == a2[j - 1] {
                    curr[j] = prev[j - 1]
                } else {
                    let ins = curr[j - 1]
                    let del = prev[j]
                    let rep = prev[j - 1]
                    curr[j] = 1 + min(ins, del, rep)
                }
            }
            prev = curr
        }
        return prev[n]
    }
    
    // MARK: - Subsequence Check
    public static func isSubsequence(query: String, target: String) -> Bool {
        guard !query.isEmpty else { return true }
        if query.count > target.count { return false }
        
        var qIdx = query.startIndex
        var tIdx = target.startIndex
        
        while qIdx < query.endIndex && tIdx < target.endIndex {
            if query[qIdx] == target[tIdx] {
                qIdx = query.index(after: qIdx)
            }
            tIdx = target.index(after: tIdx)
        }
        return qIdx == query.endIndex
    }
    
    // MARK: - Token Matching with Typo Correction
    public static func matchScore(queryToken: String, targetWord: String) -> Int {
        if queryToken.isEmpty || targetWord.isEmpty { return 0 }
        
        // 1. Corrispondenza esatta
        if queryToken == targetWord {
            return 100
        }
        
        // 2. Prefisso (es. "mate" -> "matematica")
        if targetWord.hasPrefix(queryToken) {
            return 85
        }
        
        // 3. Sottostringa interna (es. "ingeg" -> "bioingegneria")
        if targetWord.contains(queryToken) {
            return 70
        }
        
        // 4. Tolleranza ai refusi
        let qLen = queryToken.count
        let tLen = targetWord.count
        
        if qLen >= 3 && qLen <= 4 {
            let dist = levenshteinDistance(queryToken, targetWord)
            if dist <= 1 {
                return 60 - (dist * 15)
            }
        } else if qLen >= 5 {
            let dist = levenshteinDistance(queryToken, targetWord)
            if dist <= 2 {
                return 65 - (dist * 15)
            }
            if tLen > qLen + 1 {
                let targetChars = Array(targetWord)
                for start in 0...(tLen - qLen) {
                    let sub = String(targetChars[start..<min(start + qLen, tLen)])
                    let subDist = levenshteinDistance(queryToken, sub)
                    if subDist <= 1 {
                        return 50
                    }
                }
            }
        }
        
        // 5. Sottosequenza / acronimo
        if qLen >= 3 && isSubsequence(query: queryToken, target: targetWord) {
            return 40
        }
        
        return 0
    }
    
    // MARK: - Stopwords (Italian & English)
    private static let stopWords: Set<String> = [
        "il", "lo", "la", "i", "gli", "le", "un", "uno", "una",
        "di", "a", "da", "in", "con", "su", "per", "tra", "fra",
        "e", "ed", "o", "od", "del", "dello", "della", "dei", "degli", "delle",
        "dell", "all", "dall", "nell", "sull", "l", "d", "c",
        "al", "allo", "alla", "ai", "agli", "alle",
        "dal", "dallo", "dalla", "dai", "dagli", "dalle",
        "nel", "nello", "nella", "nei", "negli", "nelle",
        "sul", "sullo", "sulla", "sui", "sugli", "sulle",
        "the", "a", "an", "and", "or", "of", "to", "in", "for", "with", "on", "at", "by", "from", "is"
    ]
    
    // MARK: - Item Scoring & Ranking
    public static func score(item: PaletteItem, query: String) -> Int {
        let cleanQuery = normalize(query)
        if cleanQuery.isEmpty { return 1 }
        
        let queryTokens = tokenize(cleanQuery)
        if queryTokens.isEmpty { return 1 }
        
        let fullText = normalize("\(item.title) \(item.subtitle) \(item.badgeText ?? "") \(item.searchTerms)")
        let normalizedTitle = normalize(item.title)
        
        var totalScore = 0
        var matchedTokensCount = 0
        var meaningfulTokensCount = 0
        
        // 1. Direct phrase / substring bonus on entire content
        if normalizedTitle == cleanQuery {
            totalScore += 1500
        } else if normalizedTitle.hasPrefix(cleanQuery) {
            totalScore += 1000
        } else if normalizedTitle.contains(cleanQuery) {
            totalScore += 600
        }
        
        if fullText.contains(cleanQuery) {
            totalScore += 350
        }
        
        let titleWords = tokenize(item.title)
        let subtitleWords = tokenize(item.subtitle)
        let termWords = tokenize(item.searchTerms)
        let badgeWords = tokenize(item.badgeText ?? "")
        
        // Exact prefix or typo match on any title word (e.g. "fisia" -> "fisica", "analsi" -> "analisi", "alg" -> "algoritmi")
        for word in titleWords {
            if word == cleanQuery {
                totalScore += 1100
            } else if word.hasPrefix(cleanQuery) {
                totalScore += 750
            } else if cleanQuery.count >= 3 && word.count >= 3 {
                let dist = levenshteinDistance(cleanQuery, word)
                if dist <= 2 {
                    totalScore += 700 - (dist * 180)
                }
            }
        }
        
        // Category Intent Bonuses: strict separation between assignments and deadlines
        if cleanQuery.contains("compit") || cleanQuery.contains("assign") || cleanQuery.contains("consegn") || cleanQuery.contains("relazion") || cleanQuery.contains("progett") || cleanQuery.contains("file") || cleanQuery.contains("pdf") || cleanQuery.contains("homework") || cleanQuery.contains("eserciz") {
            if item.category == .assignments {
                totalScore += 650
            } else if item.category == .deadlines {
                totalScore -= 350
            }
        }
        
        if cleanQuery.contains("scadenz") || cleanQuery.contains("deadlin") || cleanQuery.contains("termin") || cleanQuery.contains("promemori") || cleanQuery.contains("data limit") || cleanQuery.contains("urgent") {
            if item.category == .deadlines {
                totalScore += 650
            } else if item.category == .assignments {
                totalScore -= 350
            }
        }
        
        if cleanQuery.contains("esam") || cleanQuery.contains("appell") || cleanQuery.contains("session") || cleanQuery.contains("oral") || cleanQuery.contains("scritt") || cleanQuery.contains("voto") {
            if item.category == .exams {
                totalScore += 500
            }
        }
        
        if cleanQuery.contains("cors") || cleanQuery.contains("materi") || cleanQuery.contains("docent") || cleanQuery.contains("prof") || cleanQuery.contains("cfu") {
            if item.category == .courses {
                totalScore += 500
            }
        }
        
        // Non-action items (user's real academic content) receive natural priority over generic actions
        if item.category != .actions {
            totalScore += 120
        }
        
        // 2. Token-by-token matching across all fields
        for token in queryTokens {
            let isStop = (queryTokens.count > 1) && stopWords.contains(token)
            if !isStop {
                meaningfulTokensCount += 1
            }
            
            var bestTokenScore = 0
            
            // Check direct contains on fullText for this token
            if fullText.contains(token) {
                bestTokenScore = max(bestTokenScore, 90)
            }
            
            for word in titleWords {
                let s = matchScore(queryToken: token, targetWord: word)
                if s > 0 {
                    bestTokenScore = max(bestTokenScore, Int(Double(s) * 4.0))
                }
            }
            
            for word in badgeWords {
                let s = matchScore(queryToken: token, targetWord: word)
                if s > 0 {
                    bestTokenScore = max(bestTokenScore, Int(Double(s) * 2.8))
                }
            }
            
            for word in subtitleWords {
                let s = matchScore(queryToken: token, targetWord: word)
                if s > 0 {
                    bestTokenScore = max(bestTokenScore, Int(Double(s) * 2.2))
                }
            }
            
            for word in termWords {
                let s = matchScore(queryToken: token, targetWord: word)
                if s > 0 {
                    bestTokenScore = max(bestTokenScore, Int(Double(s) * 1.8))
                }
            }
            
            if bestTokenScore > 0 {
                totalScore += bestTokenScore
                if !isStop {
                    matchedTokensCount += 1
                }
            }
        }
        
        // If query has non-stopwords and none matched, and fullText doesn't contain query, item doesn't match
        if meaningfulTokensCount > 0 {
            if matchedTokensCount == 0 && !fullText.contains(cleanQuery) {
                return 0
            }
            // Reward high coverage of query words
            if matchedTokensCount == meaningfulTokensCount {
                totalScore += 350
            }
        } else if totalScore <= 0 {
            return 0
        }
        
        return max(totalScore, 1)
    }
    
    // MARK: - Filter & Rank
    public static func filterAndRank(
        items: [PaletteItem],
        query: String,
        category: PaletteItem.Category
    ) -> [PaletteItem] {
        let cleanQuery = normalize(query)
        
        let categoryFiltered = items.filter { item in
            if category == .all { return true }
            return item.category == category
        }
        
        if cleanQuery.isEmpty {
            return categoryFiltered
        }
        
        var scoredItems: [(item: PaletteItem, score: Int)] = []
        scoredItems.reserveCapacity(categoryFiltered.count)
        
        for item in categoryFiltered {
            let sc = score(item: item, query: cleanQuery)
            if sc > 0 {
                scoredItems.append((item: item, score: sc))
            }
        }
        
        scoredItems.sort { $0.score > $1.score }
        return scoredItems.map { $0.item }
    }
}
