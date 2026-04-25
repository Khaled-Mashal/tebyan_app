import 'package:sqflite/sqflite.dart';

class RaqeemV1Schema {
  const RaqeemV1Schema._();

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE last_reading_entries (
  id TEXT PRIMARY KEY,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  ayah_unique_number INTEGER,
  page INTEGER NOT NULL,
  juz INTEGER,
  hizb INTEGER,
  rub INTEGER,
  display_surah_name TEXT NOT NULL,
  display_ayah_label TEXT NOT NULL,
  source TEXT NOT NULL,
  saved_at TEXT NOT NULL
)
''');
    await db.execute('''
CREATE INDEX idx_last_reading_saved_at
ON last_reading_entries(saved_at DESC)
''');

    await db.execute('''
CREATE TABLE bookmark_annotations (
  id TEXT PRIMARY KEY,
  quran_library_bookmark_id INTEGER,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  ayah_unique_number INTEGER,
  page INTEGER NOT NULL,
  juz INTEGER,
  hizb INTEGER,
  rub INTEGER,
  display_surah_name TEXT NOT NULL,
  display_ayah_label TEXT NOT NULL,
  type TEXT NOT NULL,
  note TEXT,
  color TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  last_opened_at TEXT
)
''');
    await db.execute('''
CREATE INDEX idx_bookmark_position
ON bookmark_annotations(surah_number, ayah_number, page)
''');
    await db.execute('''
CREATE INDEX idx_bookmark_updated_at
ON bookmark_annotations(updated_at DESC)
''');

    await db.execute('''
CREATE TABLE khatma_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  start_surah_number INTEGER NOT NULL,
  start_ayah_number INTEGER NOT NULL,
  start_ayah_unique_number INTEGER,
  start_page INTEGER NOT NULL,
  end_surah_number INTEGER NOT NULL,
  end_ayah_number INTEGER NOT NULL,
  end_ayah_unique_number INTEGER,
  end_page INTEGER NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  active_weekdays_json TEXT NOT NULL,
  distribution_mode TEXT NOT NULL,
  reminder_time TEXT,
  state TEXT NOT NULL,
  is_home_active INTEGER NOT NULL DEFAULT 0,
  total_assigned_pages INTEGER NOT NULL DEFAULT 0,
  completed_assigned_pages INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
    await db.execute('''
CREATE UNIQUE INDEX idx_one_home_active_khatma
ON khatma_plans(is_home_active)
WHERE is_home_active = 1
''');
    await db.execute('''
CREATE INDEX idx_khatma_state
ON khatma_plans(state)
''');

    await db.execute('''
CREATE TABLE daily_wirds (
  id TEXT PRIMARY KEY,
  khatma_plan_id TEXT NOT NULL,
  date TEXT NOT NULL,
  start_surah_number INTEGER NOT NULL,
  start_ayah_number INTEGER NOT NULL,
  start_ayah_unique_number INTEGER,
  start_page INTEGER NOT NULL,
  end_surah_number INTEGER NOT NULL,
  end_ayah_number INTEGER NOT NULL,
  end_ayah_unique_number INTEGER,
  end_page INTEGER NOT NULL,
  assigned_page_count INTEGER NOT NULL,
  boundary_adjustment TEXT NOT NULL,
  state TEXT NOT NULL,
  completed_at TEXT,
  missed_decision TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY(khatma_plan_id) REFERENCES khatma_plans(id) ON DELETE CASCADE
)
''');
    await db.execute('''
CREATE INDEX idx_daily_wirds_plan_date
ON daily_wirds(khatma_plan_id, date)
''');
    await db.execute('''
CREATE INDEX idx_daily_wirds_state
ON daily_wirds(state)
''');

    await db.execute('''
CREATE TABLE reminder_settings (
  id TEXT PRIMARY KEY,
  khatma_plan_id TEXT,
  time TEXT NOT NULL,
  weekdays_json TEXT NOT NULL,
  enabled INTEGER NOT NULL,
  permission_state TEXT NOT NULL,
  platform_schedule_ids_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY(khatma_plan_id) REFERENCES khatma_plans(id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE ayah_share_drafts (
  id TEXT PRIMARY KEY,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  ayah_unique_number INTEGER,
  page INTEGER NOT NULL,
  range_json TEXT,
  format TEXT NOT NULL,
  include_translation INTEGER NOT NULL,
  include_tafsir INTEGER NOT NULL,
  theme TEXT NOT NULL,
  brand_placement TEXT NOT NULL,
  last_generated_path_or_uri TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
  }
}
