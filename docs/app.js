/**
 * uni — Official Showcase Script
 * Features:
 *  1. Automatic browser language detection (IT / EN) + manual toggle with persistence.
 *  2. Synthesized acoustic soundboard using Web Audio API mirroring SoundManager.swift.
 *  3. Interactive Dynamic Island Pill Notification simulation.
 *  4. Dynamic today date formatted for the mockup.
 *  5. Motion-primitive style intersection animations.
 */

// ===================================================================
// 1. Translations Dictionary (Italian & English)
// ===================================================================
const i18n = {
  it: {
    nav_features: "Funzionalità",
    nav_preview: "Interfaccia",
    nav_download: "Scarica .dmg",

    hero_badge: "100% Swift & AppKit nativo per Mac",
    hero_title: "L'app accademica per Mac.<br><span class=\"hero-title-accent\">Progettata come si deve.</span>",
    hero_subtitle: "Tutti i tuoi corsi, orari 24h sincronizzati dal calendario dell'ateneo, scadenze, esami e la posta di Outlook. 100% nativa per macOS, privata e senza distrazioni.",
    hero_cta_dmg: "Scarica per Mac (.dmg)",
    hero_cta_sub: "Universal • Apple Silicon & Intel",
    hero_cta_github: "Vedi su GitHub",

    stat_privacy: "Privato & Locale sul tuo Mac",
    stat_sync: "Orario iCal Rigoroso",
    stat_search: "Palette di Ricerca Globale",
    stat_nocopy: "File Duplicati (Zero-Copy)",

    pill_title: "Scadenza completata",
    pill_desc: "Progetto Finale archiviato con successo 🎉",
    pill_test_btn: "Test notifica",

    mock_search: "Cerca materie...",
    mock_group_general: "GENERALE",
    mock_nav_overview: "Panoramica",
    mock_nav_cal: "Calendario",
    mock_group_didactics: "DIDATTICA",
    mock_nav_courses: "Materie (6)",
    mock_nav_deadlines: "Scadenze",
    mock_nav_exams: "Esami",
    mock_nav_assignments: "Assignments",

    mock_today_badge: "OGGI",
    mock_greeting: "“L'eccellenza non è un atto, ma un'abitudine.”",
    mock_add_deadline: "Nuova Scadenza",
    mock_stat_gpa: "Media Ponderata",
    mock_stat_base: "Base laurea: ~105.7",
    mock_stat_cfu: "CFU Acquisiti",
    mock_stat_ontrack: "In perfetto orario",
    mock_stat_next: "Prossimo Appello",
    mock_stat_days: "Tra 9 giorni • Aula 2B",

    mock_outlook_inbox: "Posta in Arrivo • Microsoft Outlook Mac",
    mock_outlook_refresh: "Aggiorna",
    mock_courses_header: "MATERIE ATTIVE & FILE COLLEGATI (ZERO-COPY)",

    feat_badge: "Progettata per macOS",
    feat_title: "Tutto ciò che serve per studiare.<br>Senza fronzoli.",
    feat_subtitle: "Disegnata per dialogare in modo naturale con il Finder, con i calendari universitari e con le email dei docenti.",

    bento1_tag: "Panoramica & NEXT",
    bento1_title: "Panoramica Istantanea & Sezione NEXT",
    bento1_desc: "A colpo d'occhio trovi la prossima lezione in aula, la scadenza più urgente e il prossimo appello d'esame. Clicca sui riquadri per accedere direttamente alla sezione desiderata.",

    bento2_tag: "Calendario & Orario",
    bento2_title: "Orario Settimanale 24h",
    bento2_desc: "Sincronizzazione iCal/webcal con l'ateneo o configurazione manuale. Aule, docenti e orari sempre sotto controllo.",

    bento3_tag: "Scadenze & Task",
    bento3_title: "Scadenze con Priorità",
    bento3_desc: "Countdown automatico al minuto, badge di urgenza, allegati locali zero-copy e filtri per materia.",

    bento4_tag: "Carriera & Esami",
    bento4_title: "Media Ponderata & Voto Laurea",
    bento4_desc: "Calcolo automatico della media ponderata, CFU registrati e simulazione della base di partenza per la laurea.",

    bento5_tag: "Ricerca Rapida",
    bento5_title: "Palette di Ricerca Globale ⌘K / ⌘F",
    bento5_desc: "Richiama in qualunque momento la ricerca stile Spotlight di macOS: trova istantaneamente corsi, dispense PDF, appelli d'esame e lezioni con filtri a pillola.",

    zoom_screenshot: "Clicca per ingrandire",

    dl_title: "Scarica uni per il tuo Mac.",
    dl_desc: "Compatibile con macOS (Apple Silicon & Intel). Scarica l'immagine disco .dmg oppure compila l'app direttamente dal codice sorgente su GitHub.",
    dl_btn_dmg: "Scarica uni per macOS (.dmg)",
    dl_btn_dmg_sub: "Universal • Apple Silicon & Intel",
    dl_btn_zip: "Scarica Archivio (.zip)",
    dl_btn_zip_sub: "Pacchetto Completo • 1.1 MB",
    dl_btn_github: "Apri Repository GitHub",
    dl_btn_github_sub: "Codice Sorgente Open Source",
    step1: "Scarica il file .dmg o .zip",
    step2: "Trascina uni in Applicazioni",
    step3: "Avvia e organizza i tuoi corsi",
    dmg_showcase_hint: "Esperienza d'installazione refined: apri il .dmg e trascina semplicemente l'app nella cartella Applicazioni.",

    nav_faq: "FAQ",
    faq_badge: "FAQ & Assistenza",
    faq_title: "Domande Frequenti",
    faq_subtitle: "Tutto quello che c'è da sapere su compatibilità, sincronizzazione calendari, privacy e licenza di uni.",
    faq_q1: "Cos'è uni e quali vantaggi offre rispetto ad altre app?",
    faq_a1: "uni è un workspace accademico sviluppato nativamente per macOS in Swift e AppKit. A differenza di app web o basate su Electron, è ultra-reattiva, consuma pochissima memoria RAM (&lt;40 MB), funziona al 100% offline ed è perfettamente integrata con il Finder e l'ecosistema Mac.",
    faq_q2: "Quali versioni di macOS e processori Mac sono supportati?",
    faq_a2: "uni è compilata come binario Universale nativo per macOS 13.0 (Ventura), macOS 14.0 (Sonoma) e macOS 15.0 (Sequoia) o successivi, pienamente compatibile sia con processori Apple Silicon (M1, M2, M3, M4) che con processori Intel.",
    faq_q3: "Come funziona la sincronizzazione con i calendari universitari (Esse3, Cineca)?",
    faq_a3: "uni supporta lo standard iCalendar (iCal/webcal RFC 5545). È sufficiente incollare il link del feed o importare il file .ics fornito dal proprio ateneo: l'app ripulisce i titoli da codici inutili, individua docenti, aule ed imposta l'orario settimanale rigoroso a 24 ore.",
    faq_q4: "I miei dati accademici e le mie email sono al sicuro e privati?",
    faq_a4: "Sì, al 100%. uni segue una rigida politica di privacy locale: nessun dato viene mai inviato a server esterni, non è presente alcuna telemetria o tracciamento e le comunicazioni con Outlook avvengono solo tramite AppleScript locale sul tuo Mac.",
    faq_q5: "L'app è gratuita e open source?",
    faq_a5: "Sì, uni è completamente gratuita e rilasciata con codice sorgente aperto sotto licenza libera MIT su GitHub, senza abbonamenti né acquisti in-app.",
    faq_q6: "Cosa significa gestione file Zero-Copy con il Finder?",
    faq_a6: "Quando colleghi dispense, slide o PDF a una materia in uni, i file rimangono esattamente nelle loro cartelle originali nel Finder tramite security-scoped bookmarks, senza occupare spazio su disco duplicato.",

    footer_sub: "Progettata con cura per gli studenti universitari su Mac.",
    footer_credit: "Designed by <a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>"
  },

  en: {
    nav_features: "Features",
    nav_preview: "Interface",
    nav_download: "Download .dmg",

    hero_badge: "100% Native Swift & AppKit for Mac",
    hero_title: "The academic app for Mac.<br><span class=\"hero-title-accent\">Crafted as it should be.</span>",
    hero_subtitle: "All your courses, 24-hour schedules synced from your university calendar, deadlines, exams, and Outlook mail. 100% native macOS, private and distraction-free.",
    hero_cta_dmg: "Download for Mac (.dmg)",
    hero_cta_sub: "Universal • Apple Silicon & Intel",
    hero_cta_github: "View on GitHub",

    stat_privacy: "100% Private & Local to your Mac",
    stat_sync: "Strict 24h iCal Format",
    stat_search: "Global Search Palette",
    stat_nocopy: "Zero-Copy Linked Files",

    pill_title: "Deadline Completed",
    pill_desc: "Final Project archived successfully 🎉",
    pill_test_btn: "Test notification",

    mock_search: "Search courses...",
    mock_group_general: "GENERAL",
    mock_nav_overview: "Overview",
    mock_nav_cal: "Calendar",
    mock_group_didactics: "COURSES & WORK",
    mock_nav_courses: "Courses (6)",
    mock_nav_deadlines: "Deadlines",
    mock_nav_exams: "Exams",
    mock_nav_assignments: "Assignments",

    mock_today_badge: "TODAY",
    mock_greeting: "“Excellence is not an act, but a habit.”",
    mock_add_deadline: "New Deadline",
    mock_stat_gpa: "Weighted GPA",
    mock_stat_base: "Graduation estimate: ~105.7",
    mock_stat_cfu: "Credits Earned",
    mock_stat_ontrack: "Right on schedule",
    mock_stat_next: "Next Exam Session",
    mock_stat_days: "In 9 days • Room 2B",

    mock_outlook_inbox: "Inbox • Microsoft Outlook Mac",
    mock_outlook_refresh: "Refresh",
    mock_courses_header: "ACTIVE COURSES & LINKED FILES (ZERO-COPY)",

    feat_badge: "Crafted for macOS",
    feat_title: "Everything you need for your studies.<br>Zero clutter.",
    feat_subtitle: "Designed to feel right at home with Finder, your campus calendar, and faculty emails.",

    bento1_tag: "Overview & NEXT",
    bento1_title: "Instant Overview & NEXT Widget",
    bento1_desc: "Get an immediate view of your next scheduled lecture and classroom, top-priority deadline, and upcoming exam session. Click any card to jump straight into that section.",

    bento2_tag: "Calendar & Timetable",
    bento2_title: "24h Weekly Timetable",
    bento2_desc: "Sync your university iCal/webcal calendar or configure classes manually. Rooms, professors, and class hours always at your fingertips.",

    bento3_tag: "Deadlines & Tasks",
    bento3_title: "Prioritized Academic Deadlines",
    bento3_desc: "Minute-by-minute countdown, priority urgency tags, zero-copy linked study files, and course-specific filters.",

    bento4_tag: "Career & Exams",
    bento4_title: "Weighted GPA & Degree Projection",
    bento4_desc: "Automatic weighted average calculation, recorded credits (CFU/ECTS), and real-time degree starting score projection.",

    bento5_tag: "Quick Search",
    bento5_title: "Spotlight-Style Global Search ⌘K / ⌘F",
    bento5_desc: "Summon the macOS-native search palette at any time: instantly locate courses, PDF slides, exam dates, and lectures with interactive pill filters.",

    zoom_screenshot: "Click to zoom",

    dl_title: "Download uni for your Mac.",
    dl_desc: "Compatible with macOS (Apple Silicon & Intel). Download the .dmg disk image or build directly from the source on GitHub.",
    dl_btn_dmg: "Download uni for macOS (.dmg)",
    dl_btn_dmg_sub: "Universal • Apple Silicon & Intel",
    dl_btn_zip: "Download Archive (.zip)",
    dl_btn_zip_sub: "Complete Package • 1.1 MB",
    dl_btn_github: "Open GitHub Repository",
    dl_btn_github_sub: "Open Source Repository",
    step1: "Download the .dmg or .zip file",
    step2: "Drag uni to Applications",
    step3: "Launch and organize your courses",
    dmg_showcase_hint: "Refined installation experience: open the .dmg and drag the app into your Applications folder.",

    nav_faq: "FAQ",
    faq_badge: "FAQ & Support",
    faq_title: "Frequently Asked Questions",
    faq_subtitle: "Everything you need to know regarding compatibility, calendar syncing, privacy, and licensing for uni.",
    faq_q1: "What is uni and what makes it different from web-based tools?",
    faq_a1: "uni is an academic workspace crafted natively for macOS using Swift and AppKit. Unlike web wrappers or heavy Electron applications, it starts up instantly, uses minimal RAM (&lt;40 MB), works 100% offline, and integrates seamlessly with Finder and the Apple ecosystem.",
    faq_q2: "Which macOS versions and Mac processors are supported?",
    faq_a2: "uni is built as a Universal binary for macOS 13.0 (Ventura), macOS 14.0 (Sonoma), and macOS 15.0 (Sequoia) or newer, running at peak performance on Apple Silicon (M1, M2, M3, M4) and Intel Macs.",
    faq_q3: "How does university calendar synchronization work (Esse3, Cineca)?",
    faq_a3: "uni supports the iCalendar standard (iCal/webcal RFC 5545). Simply paste your university feed link or import an .ics file: uni cleans course titles, identifies lecturers and classrooms, and builds your 24-hour weekly timetable.",
    faq_q4: "Are my student records and faculty emails secure and private?",
    faq_a4: "Yes, 100%. uni enforces a strict offline-first, local-only architecture: no data is ever sent to external cloud servers, there is zero telemetry tracking, and Outlook integration executes purely via local AppleScript on your Mac.",
    faq_q5: "Is uni free and open source?",
    faq_a5: "Yes, uni is completely free and released under the permissive open-source MIT License on GitHub, with no subscriptions or in-app purchases.",
    faq_q6: "What is Zero-Copy linked file management with Finder?",
    faq_a6: "When you link lecture slides or syllabus PDFs to a subject, files remain in their original folders in Finder via security-scoped bookmarks, without wasting duplicate SSD storage space.",

    footer_sub: "Carefully designed for university students on Mac.",
    footer_credit: "Designed by <a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>"
  }
};

// ===================================================================
// 2. Language Detection & Switching
// ===================================================================
let currentLanguage = 'it';

function detectInitialLanguage() {
  // 1. Check local storage
  const saved = localStorage.getItem('uni_site_lang');
  if (saved && (saved === 'it' || saved === 'en')) {
    return saved;
  }
  // 2. Check browser language (navigator.language)
  const browserLang = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
  if (browserLang.startsWith('it')) {
    return 'it';
  }
  return 'en';
}

function setLanguage(lang) {
  currentLanguage = lang;
  localStorage.setItem('uni_site_lang', lang);
  document.documentElement.lang = lang;

  // Update language switcher UI active class
  document.querySelectorAll('.lang-option').forEach(el => {
    el.classList.toggle('active', el.getAttribute('data-lang') === lang);
  });

  // Update all translatable elements with data-i18n
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (i18n[lang] && i18n[lang][key]) {
      el.innerHTML = i18n[lang][key];
    }
  });

  // Update dynamic date in mockup
  updateMockupDate(lang);
}

function initLanguageSwitcher() {
  const switchPill = document.getElementById('langSwitch');
  if (switchPill) {
    switchPill.addEventListener('click', () => {
      const nextLang = currentLanguage === 'it' ? 'en' : 'it';
      setLanguage(nextLang);
      playWebSound('pop');
    });

    switchPill.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        const nextLang = currentLanguage === 'it' ? 'en' : 'it';
        setLanguage(nextLang);
        playWebSound('pop');
      }
    });
  }
}

// ===================================================================
// 3. Dynamic Mockup Date
// ===================================================================
function updateMockupDate(lang) {
  const now = new Date();
  const dayNameEl = document.getElementById('mockDayName');
  const dayNumEl = document.getElementById('mockDayNum');
  const fullDateEl = document.getElementById('mockFullDate');

  if (dayNumEl) {
    dayNumEl.textContent = now.getDate();
  }

  const locale = lang === 'it' ? 'it-IT' : 'en-US';
  if (dayNameEl) {
    const shortDay = now.toLocaleDateString(locale, { weekday: 'short' }).replace('.', '').toUpperCase();
    dayNameEl.textContent = shortDay;
  }
  if (fullDateEl) {
    const full = now.toLocaleDateString(locale, { weekday: 'long', day: 'numeric', month: 'long' });
    fullDateEl.textContent = full.charAt(0).toUpperCase() + full.slice(1);
  }
}

// ===================================================================
// 4. Synthesized Audio Engine (Web Audio API)
//    Meticulously crafts the tone, harmonic decay, and warmth of
//    the macOS acoustic samples: Pop, Tink, Morse, Ping, Blow.
// ===================================================================
let audioCtx = null;

function getAudioContext() {
  if (!audioCtx) {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    audioCtx = new AudioContext();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

function playWebSound(type) {
  try {
    const ctx = getAudioContext();
    const t = ctx.currentTime;

    switch (type) {
      case 'pop': {
        // Soft acoustic wooden pop (Pop.aiff)
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(320, t);
        osc.frequency.exponentialRampToValueAtTime(80, t + 0.08);

        gain.gain.setValueAtTime(0.32, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.08);

        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(t);
        osc.stop(t + 0.08);
        break;
      }

      case 'success': {
        // Crystalline dual chime (Tink.aiff)
        [1560, 2340].forEach((freq, i) => {
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = 'triangle';
          osc.frequency.setValueAtTime(freq, t + i * 0.04);

          gain.gain.setValueAtTime(0.28, t + i * 0.04);
          gain.gain.exponentialRampToValueAtTime(0.001, t + i * 0.04 + 0.35);

          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t + i * 0.04);
          osc.stop(t + i * 0.04 + 0.36);
        });
        break;
      }

      case 'notification': {
        // Soft double chirp (Morse.aiff style)
        [880, 1174].forEach((freq, i) => {
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, t + i * 0.07);

          gain.gain.setValueAtTime(0.24, t + i * 0.07);
          gain.gain.exponentialRampToValueAtTime(0.001, t + i * 0.07 + 0.12);

          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(t + i * 0.07);
          osc.stop(t + i * 0.07 + 0.13);
        });
        break;
      }

      case 'timer': {
        // Resonant meditation ping (Ping.aiff)
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(987.77, t); // B5 note

        gain.gain.setValueAtTime(0.35, t);
        gain.gain.exponentialRampToValueAtTime(0.0008, t + 0.85);

        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(t);
        osc.stop(t + 0.86);
        break;
      }

      case 'remove': {
        // Delicate air whoosh (Blow.aiff)
        const bufferSize = ctx.sampleRate * 0.12;
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          data[i] = Math.random() * 2 - 1;
        }

        const noise = ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(450, t);
        filter.Q.setValueAtTime(3.0, t);

        const gain = ctx.createGain();
        gain.gain.setValueAtTime(0.25, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.12);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(ctx.destination);
        noise.start(t);
        noise.stop(t + 0.12);
        break;
      }
    }
  } catch (err) {
    console.warn('Web Audio synthesis not allowed or supported:', err);
  }
}

// ===================================================================
// 5. Interactive Pill Notification HUD Demo
// ===================================================================
function initPillHUDDemo() {
  const pill = document.getElementById('pillHUD');
  const triggerBtn = document.getElementById('triggerPillDemo');
  const pillTitle = document.getElementById('pillTitle');
  const pillDesc = document.getElementById('pillMessage');

  const demoMessages = {
    it: [
      { title: "Scadenza completata", desc: "Progetto Finale d'Esame archiviato 🎉" },
      { title: "Outlook LATEST", desc: "Nuova email dal Prof. Rossi: Aula cambiata" },
      { title: "Pomodoro Completato", desc: "25 minuti di studio concentrato conclusi 👏" },
      { title: "iCal Sincronizzato", desc: "6 corsi e 14 orari lezioni aggiornati" }
    ],
    en: [
      { title: "Deadline Completed", desc: "Final Course Project submitted 🎉" },
      { title: "Outlook LATEST", desc: "New email from Prof. Rossi: Room updated" },
      { title: "Pomodoro Finished", desc: "25 minutes of deep focus completed 👏" },
      { title: "iCal Synchronized", desc: "6 courses and 14 lecture slots updated" }
    ]
  };

  let messageIdx = 0;

  function triggerDemo(e) {
    if (e) e.stopPropagation();
    playWebSound('notification');

    const list = demoMessages[currentLanguage] || demoMessages.it;
    messageIdx = (messageIdx + 1) % list.length;
    const nextItem = list[messageIdx];

    if (pillTitle) pillTitle.textContent = nextItem.title;
    if (pillDesc) pillDesc.textContent = nextItem.desc;

    // Pop bounce animation
    if (pill) {
      pill.style.transform = 'translateY(-10px) scale(1.06)';
      setTimeout(() => {
        pill.style.transform = 'translateY(0) scale(1)';
      }, 250);
    }
  }

  if (triggerBtn) {
    triggerBtn.addEventListener('click', triggerDemo);
  }
  if (pill) {
    pill.addEventListener('click', triggerDemo);
  }
}

// ===================================================================
// 6. Latest GitHub Release & Dynamic Download Synchronizer
// ===================================================================
const GITHUB_REPO = "zjncoo/uni";
const GITHUB_LATEST_RELEASE_API = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;
const CANONICAL_DMG_URL = `https://github.com/${GITHUB_REPO}/releases/latest/download/uni.dmg`;
const CANONICAL_ZIP_URL = `https://github.com/${GITHUB_REPO}/releases/latest/download/uni-macos.zip`;

async function fetchLatestGitHubRelease() {
  const heroBtn = document.getElementById('heroDownloadBtn');
  const mainBtn = document.getElementById('mainDownloadBtn');
  const zipBtn = document.getElementById('zipDownloadBtn');
  const heroMeta = document.getElementById('heroDmgMeta');
  const mainMeta = document.getElementById('mainDmgMeta');
  const zipMeta = document.getElementById('zipMeta');

  try {
    const res = await fetch(GITHUB_LATEST_RELEASE_API, {
      headers: { 'Accept': 'application/vnd.github.v3+json' }
    });

    if (res.ok) {
      const data = await res.json();
      const tagName = data.tag_name || 'v1.0.0';
      const assets = data.assets || [];

      // Find DMG asset
      const dmgAsset = assets.find(a => a.name.toLowerCase().endsWith('.dmg'));
      if (dmgAsset && dmgAsset.browser_download_url) {
        if (heroBtn) heroBtn.href = dmgAsset.browser_download_url;
        if (mainBtn) mainBtn.href = dmgAsset.browser_download_url;
        const mb = (dmgAsset.size / (1024 * 1024)).toFixed(1);
        const metaStr = `${tagName} • ${mb} MB • Apple Silicon & Intel`;
        if (heroMeta) heroMeta.textContent = metaStr;
        if (mainMeta) mainMeta.textContent = metaStr;
      }

      // Find ZIP asset
      const zipAsset = assets.find(a => a.name.toLowerCase().endsWith('.zip'));
      if (zipAsset && zipAsset.browser_download_url) {
        if (zipBtn) zipBtn.href = zipAsset.browser_download_url;
        const mb = (zipAsset.size / (1024 * 1024)).toFixed(1);
        if (zipMeta) zipMeta.textContent = `${tagName} • ${mb} MB`;
      }
    } else {
      // Fall back directly to the canonical GitHub Release download URL
      console.info("Using canonical GitHub Release URLs.");
      if (heroBtn) heroBtn.href = CANONICAL_DMG_URL;
      if (mainBtn) mainBtn.href = CANONICAL_DMG_URL;
      if (zipBtn) zipBtn.href = CANONICAL_ZIP_URL;
    }
  } catch (err) {
    console.warn("Unable to reach GitHub API; defaulting to canonical release URLs:", err);
    if (heroBtn) heroBtn.href = CANONICAL_DMG_URL;
    if (mainBtn) mainBtn.href = CANONICAL_DMG_URL;
    if (zipBtn) zipBtn.href = CANONICAL_ZIP_URL;
  }
}

function initDownloadButtons() {
  const heroBtn = document.getElementById('heroDownloadBtn');
  const mainBtn = document.getElementById('mainDownloadBtn');
  const zipBtn = document.getElementById('zipDownloadBtn');

  [heroBtn, mainBtn, zipBtn].forEach(btn => {
    if (btn) {
      btn.addEventListener('click', () => {
        playWebSound('success');
      });
    }
  });

  // Query GitHub for live release updates
  fetchLatestGitHubRelease();
}

// ===================================================================
// 7. Screenshot Lightbox Modal
// ===================================================================
function initScreenshotLightbox() {
  const lightbox = document.getElementById('screenshotLightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxCaption = document.getElementById('lightboxCaption');
  const closeBtn = document.getElementById('lightboxCloseBtn');
  const backdrop = document.getElementById('lightboxBackdrop');

  if (!lightbox || !lightboxImg) return;

  function openLightbox(src, caption) {
    lightboxImg.src = src;
    if (lightboxCaption) lightboxCaption.textContent = caption || '';
    lightbox.classList.add('active');
    lightbox.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
    playWebSound('pop');
  }

  function closeLightbox() {
    lightbox.classList.remove('active');
    lightbox.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
    playWebSound('remove');
  }

  document.querySelectorAll('.bento-screenshot-wrapper').forEach(wrapper => {
    wrapper.addEventListener('click', () => {
      const src = wrapper.getAttribute('data-screenshot');
      const caption = wrapper.getAttribute('data-caption');
      if (src) {
        openLightbox(src, caption);
      }
    });
  });

  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  if (backdrop) backdrop.addEventListener('click', closeLightbox);

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && lightbox.classList.contains('active')) {
      closeLightbox();
    }
  });
}

// ===================================================================
// 8. Initialize Application
// ===================================================================
document.addEventListener('DOMContentLoaded', () => {
  const initialLang = detectInitialLanguage();
  setLanguage(initialLang);
  initLanguageSwitcher();
  initPillHUDDemo();
  initDownloadButtons();
  initScreenshotLightbox();
});

