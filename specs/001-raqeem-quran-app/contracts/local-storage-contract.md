# Contract: Local Storage

**Purpose**: Define the app-owned SQLite schema. quran_library-owned storage is outside this schema.

## Database

- File: `raqeem.db`.
- Engine: sqflite.
- Version: `1`.
- All writes that create or recalculate khatma/daily wird data must be transactional.

## Table: settings

```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

**Keys**:

- `user_preferences`
- `reciter_preference`

## Table: last_reading_entries

```sql
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
);

CREATE INDEX idx_last_reading_saved_at
ON last_reading_entries(saved_at DESC);
```

**Invariant**: Repository keeps at most five rows after each insert/update.

## Table: bookmark_annotations

```sql
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
);

CREATE INDEX idx_bookmark_position
ON bookmark_annotations(surah_number, ayah_number, page);

CREATE INDEX idx_bookmark_updated_at
ON bookmark_annotations(updated_at DESC);
```

## Table: khatma_plans

```sql
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
);

CREATE UNIQUE INDEX idx_one_home_active_khatma
ON khatma_plans(is_home_active)
WHERE is_home_active = 1;

CREATE INDEX idx_khatma_state
ON khatma_plans(state);
```

## Table: daily_wirds

```sql
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
);

CREATE INDEX idx_daily_wirds_plan_date
ON daily_wirds(khatma_plan_id, date);

CREATE INDEX idx_daily_wirds_state
ON daily_wirds(state);
```

## Table: reminder_settings

```sql
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
);
```

## Table: ayah_share_drafts

```sql
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
);
```

## Repository Acceptance Rules

- Repositories return domain entities, not SQL maps.
- Unknown enum values from older/newer app versions map to a recoverable data error.
- Date comparisons for khatma scheduling use local dates, not UTC instants.
- Transaction boundaries are required for:
  - creating a khatma plan and its daily wird rows;
  - editing a khatma plan with recalculation;
  - applying missed-day redistribution;
  - changing active khatma.
- Deleting a khatma cascades daily wird and reminder rows.
