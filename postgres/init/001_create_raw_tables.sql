CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS meta;

-- Track ingestion runs
CREATE TABLE IF NOT EXISTS meta.ingestion_run (
    run_id BIGSERIAL PRIMARY KEY,
    pipeline_name TEXT NOT NULL,
    source_file TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'started',
    rows_loaded INTEGER NOT NULL DEFAULT 0,
    error_message TEXT
);

-- Raw table for patient data
CREATE TABLE IF NOT EXISTS raw.raw_patient (
    patient_id TEXT PRIMARY KEY,
    birth_date DATE,
    gender TEXT,
    deceased_boolean BOOLEAN,
    source_file TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    payload JSONB NOT NULL
);

-- Raw table for encounter data
CREATE TABLE IF NOT EXISTS raw.raw_encounter (
    encounter_id TEXT PRIMARY KEY,
    patient_id TEXT,
    encounter_start TIMESTAMPTZ,
    encounter_end TIMESTAMPTZ,
    encounter_class TEXT,
    status TEXT,
    source_file TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    payload JSONB NOT NULL
);

-- Raw table for condition data
CREATE TABLE IF NOT EXISTS raw.raw_condition (
    condition_id TEXT PRIMARY KEY,
    patient_id TEXT,
    encounter_id TEXT,
    code TEXT,
    display TEXT,
    recorded_date TIMESTAMPTZ,
    clinical_status TEXT,
    verification_status TEXT,
    source_file TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    payload JSONB NOT NULL
);

-- Raw table for observation data
CREATE TABLE IF NOT EXISTS raw.raw_observation (
    observation_id TEXT PRIMARY KEY,
    patient_id TEXT,
    encounter_id TEXT,
    code TEXT,
    display TEXT,
    value_numeric DOUBLE PRECISION,
    value_text TEXT,
    unit TEXT,
    reference_low DOUBLE PRECISION,
    reference_high DOUBLE PRECISION,
    effective_datetime TIMESTAMPTZ,
    status TEXT,
    source_file TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    payload JSONB NOT NULL
);

-- Indexes for downstream joins and filtering
CREATE INDEX IF NOT EXISTS idx_raw_encounter_patient_id
    ON raw.raw_encounter(patient_id);

CREATE INDEX IF NOT EXISTS idx_raw_condition_patient_id
    ON raw.raw_condition(patient_id);

CREATE INDEX IF NOT EXISTS idx_raw_condition_encounter_id
    ON raw.raw_condition(encounter_id);

CREATE INDEX IF NOT EXISTS idx_raw_observation_patient_id
    ON raw.raw_observation(patient_id);

CREATE INDEX IF NOT EXISTS idx_raw_observation_encounter_id
    ON raw.raw_observation(encounter_id);

CREATE INDEX IF NOT EXISTS idx_raw_observation_code
    ON raw.raw_observation(code);
