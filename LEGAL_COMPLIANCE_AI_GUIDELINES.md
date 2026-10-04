# Universal Legal & Privacy Compliance Guidelines for AI-Assisted Software Development

> **Purpose:** Feed this file into any AI coding assistant (Antigravity, Cursor, Copilot, Claude, ChatGPT, etc.) at the start of any new software project (web app, desktop/mobile app, or open-source repository) to ensure built-in legal compliance, liability shielding, and privacy-by-design from Day 1.

---

## 1. Core Golden Principles

1. **Open Source & Free Apps Are NOT Immune:** Neither the GDPR, consumer protection laws, nor trademark statutes grant immunity to free, hobby, or open-source software once it is published on the open internet.
2. **Zero Unnecessary External CDN Calls:** Never leak user IP addresses to third-party CDNs (e.g., Google Fonts, CDN scripts) on initial page load. IP addresses are legally personal data in the EU (*Breyer C-582/14*).
3. **No Cookie Banner by Design:** Strive for 100% cookie-free and tracking-free architectures. If only purely technical storage (e.g., `localStorage` for theme or language) is used and no third-party profiling exists, no annoying cookie consent banner is legally required under the ePrivacy Directive.
4. **Contractual Liability Shielding:** Always pair open-source code licenses (e.g., MIT) with explicit **Terms of Use** containing capital-letter UCC §2-316 "AS IS" disclaimers, a liability cap (€0.00 / $0.00), and an academic/independent utility disclaimer.
5. **Nominative Fair Use for Trademarks:** You can mention third-party brands (Apple, Microsoft, Google, etc.) to describe technical compatibility, provided you follow the 3 Fair Use rules.

---

## 2. Privacy & Data Protection (GDPR, CCPA, ePrivacy)

### A. Asset Hosting & Font Rules (Munich Court Compliance)
- ❌ **NEVER** use `<link href="https://fonts.googleapis.com/...">` or dynamic third-party CDNs.
- ✅ **ALWAYS** self-host font files (`.woff2`) locally in your project folder (e.g., `/fonts/` or `/assets/fonts/`) and reference them via relative `@font-face` rules.
- ✅ **ALWAYS** bundle JavaScript libraries locally (or via npm build pipeline) instead of pulling from unvetted public CDNs that log user IPs.

### B. Feedback Forms & User Input Channels
Whenever creating a contact form, bug reporter, or feedback modal (e.g., connecting to Google Forms, Supabase, Formspree, or your own API):
- ✅ **Mandatory Explicit Consent:** Add an unticked checkbox:  
  `[ ] I have read the Privacy Policy and consent to the transmission and processing of this feedback.`
- ✅ **Submit Button Locked:** The submit button must be strictly `disabled` in the UI until the checkbox is checked and required fields are non-empty.
- ✅ **Data Minimization Warning:** Display a clear warning notice:  
  *"Please do not include sensitive data, personal passwords, academic IDs, or confidential details in your message."*
- ✅ **Optional Diagnostics:** Any hardware/software diagnostic data (e.g., OS version, app version) must be strictly non-identifying (no hardware serials, MAC addresses, or personal UUIDs) and clearly disclosed.
- ✅ **Data Retention & Deletion:** Declare a retention period (e.g., 12 months) and state how users can request deletion (e.g., emailing the developer).

### C. Local Storage & Cookie Minimization
- ❌ **NEVER** install third-party tracking pixels (Google Analytics, Meta Pixel, TikTok Ads, Hotjar) unless explicitly requested and backed by a comprehensive consent management platform (CMP).
- ✅ Limit browser storage to strictly technical essentials:
  - `localStorage: [app_name]_theme` (dark/light mode)
  - `localStorage: [app_name]_lang` (preferred locale)
- ✅ State in the Privacy Policy that these storage keys are purely technical and exempt from cookie banners under ePrivacy Directive Art. 5(3).

### D. Age Restrictions & Minors
- ✅ Specify the minimum intended age (e.g., 16+ or 13+ depending on local digital consent laws).
- ✅ Include an explicit statement: *"This software is not directed to children under 13 (US COPPA) or under 16 (EU GDPR). We do not knowingly collect personal data from minors."* Provide a parental contact route.

---

## 3. Terms of Use & Liability Shielding

Every public website or repository must include or link to a dedicated `terms.html` or `TERMS.md` containing:

### A. UCC §2-316 "AS IS" Warranty Disclaimer (Mandatory Capital Letters)
```text
THE SOFTWARE AND SERVICE ARE PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, 
WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE, TITLE, AND NON-INFRINGEMENT. NO ADVICE OR INFORMATION, WHETHER ORAL 
OR WRITTEN, OBTAINED FROM THE DEVELOPER SHALL CREATE ANY WARRANTY NOT EXPRESSLY 
STATED HEREIN.
```

### B. Limitation of Liability & Dollar Cap
```text
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE AUTHOR, 
DEVELOPER, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY INDIRECT, PUNITIVE, INCIDENTAL, 
SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES, INCLUDING WITHOUT LIMITATION DAMAGES 
FOR LOSS OF PROFITS, GOODWILL, DATA, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF 
OR RELATING TO THE USE OF, OR INABILITY TO USE, THIS SOFTWARE.

THE TOTAL AGGREGATE LIABILITY FOR ALL CLAIMS UNDER THESE TERMS SHALL BE LIMITED 
EXCLUSIVELY TO ZERO EUROS (€0.00) OR THE TOTAL AMOUNT PAID BY THE USER TO THE 
DEVELOPER IN THE TWELVE (12) MONTHS PRECEDING THE CLAIM, WHICHEVER IS LESS.
```

### C. Independent Utility / Non-Official Tool Disclaimer
If the app assists with third-party systems (e.g., universities, banks, cloud providers):
```text
[App Name] is an independent personal productivity tool and is NOT an official 
system or service of [Third Party Name / University / Organization]. The User 
bears the sole and exclusive responsibility to verify all dates, deadlines, schedules, 
and official records directly on the official institutional portals.
```

### D. Separation of Open-Source Code vs. Proprietary Brand
```text
While the underlying source code may be licensed under an open-source license 
(such as the MIT License), all trademarks, service marks, application names, 
logos, icons, domain names, and distinctive visual dress remain the exclusive 
intellectual property of the developer and are not granted under the code license.
```

---

## 4. Trademarks & Nominative Fair Use

### The 3 Golden Rules:
1. **Never use a third-party brand in your product name:**
   - ❌ *"Apple Outlook Notifier"*, *"Esse3 Mac Suite"*
   - ✅ *"uni — Native Academic App for Mac (Compatible with Outlook and Esse3)"*
2. **Never copy third-party brand logos or graphical badges:**
   - ❌ Embedding official SVG vector logos of Apple, Microsoft, or universities without written permission.
   - ✅ Use your own custom icon or standard system glyphs/SF Symbols.
3. **Always include a Nominative Fair Use Disclaimer:**
   Include this text in `README.md`, `terms.html`, and `privacy.html`:
   ```text
   All product names, logos, brands, and registered trademarks mentioned herein 
   are property of their respective owners. All company, product, and service names 
   used in this application and website are for identification and technical 
   compatibility purposes only ("Nominative Fair Use"). Use of these names, logos, 
   and brands does not imply endorsement, affiliation, or sponsorship.
   ```

---

## 5. Mobile & Desktop App Permissions (macOS / iOS / Android)

When prompting for OS-level permissions (e.g., in Apple's `Info.plist`):
- ✅ **Explicit Privacy Guarantee in Permission Strings:**
  - `NSCalendarsUsageDescription`: *"Synchronizes your academic calendar events locally on your Mac. No event data ever leaves your device."*
  - `NSAppleEventsUsageDescription`: *"Accesses Microsoft Outlook locally on your Mac to show recent course communications. No credentials or emails are transmitted externally."*
- ✅ **Zero Telemetry by Default:** Do not embed crash analytics (Firebase Crashlytics, Sentry) unless anonymized, disclosed, and opt-out capable.
- ✅ **Sandboxing & Least Privilege:** Keep OS App Sandbox enabled (`com.apple.security.app-sandbox = YES`). Use security-scoped bookmarks for zero-copy file access instead of requesting broad filesystem access.

---

## 6. AI Agent Implementation Checklist

When tasked with generating or refactoring code for an app or website, run through this checklist before considering the task complete:

- [ ] **Fonts & Static Assets:** All fonts (`.woff2`) and scripts are 100% self-hosted; no external CDN links exist.
- [ ] **Storage Audit:** Only purely technical keys are stored in `localStorage`/cookies; no third-party marketing tags exist.
- [ ] **Form Protection:** All feedback/contact forms feature an unselected mandatory consent checkbox and data minimization warning.
- [ ] **Legal Pages Present:** A dedicated Privacy Policy (`privacy.html`) and Terms of Service (`terms.html`) exist and are linked in footers and app modals.
- [ ] **Data Controller Disclosed:** A real contact point (e.g., `work@zinco.cc`) is clearly stated for privacy requests.
- [ ] **Nominative Fair Use Declared:** All third-party platform names are paired with a trademark disclaimer.
- [ ] **Warranty Exclusions:** UCC §2-316 "AS IS" and liability caps are present in capitalized text.
- [ ] **No Misleading Marketing:** Descriptions avoid absolute promises (*"guarantees you never miss an exam"* ➔ *"designed to help you track exams"*).
