# Data Preservation & User State Integrity

## Strict Database & State Safety Rules

1. **Never Overwrite or Stale-Restore User Databases:**
   - Under no circumstances should real user data (e.g. `uni_database.json` in sandbox container or Application Support) be swapped, altered, or replaced with demo/mock data without creating an **immediate, fresh, timestamped backup** of the current real database first.
   - **Never** rely on an existing/pre-existing backup file (e.g. `real_database_backup.json` from earlier sessions or dates). Always inspect the active database, verify the current student name and records, and snapshot it immediately before any modifications.

2. **Verify Integrity of All User Entities:**
   - Always preserve and verify all attached data fields when restoring or synchronizing:
     - Deadlines & Assignments: titles, priorities, due dates, custom notes, link URLs (`linkURL`, `linkURLs`), and local attachment paths (`localFilePath`, `localFileName`).
     - Courses: CFU, schedule, professors, external links (`links`), and linked files/folders (`linkedFiles`).
     - Exams: status, grades, exam dates, notes.
     - Calendar feeds and user settings/preferences.

3. **Safe Demo Data Automation:**
   - If demo data must be loaded (e.g. for generating website screenshots or automated tests), the automation script must:
     1. Gracefully terminate running instances of the app.
     2. Create a timestamped backup of the user's active database if it contains user data.
     3. Load demo data and perform the capture/test.
     4. Immediately restore the exact user database.
     5. Relaunch the app and confirm that all items, links, and linked files match the pre-demo state.
