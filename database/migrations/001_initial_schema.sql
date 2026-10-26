
-- C.A.P.S. - Initial PostgreSQL Schema
-- Migration: 001_initial_schema.sql

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Application users and roles
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'student'
        CHECK (role IN ('student', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Student academic profiles
CREATE TABLE student_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE RESTRICT,
    enrollment_number VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    department VARCHAR(100) NOT NULL,
    graduation_year SMALLINT NOT NULL
        CHECK (graduation_year BETWEEN 2000 AND 2100),
    cgpa NUMERIC(4,2)
        CHECK (cgpa BETWEEN 0 AND 10),
    active_backlogs INTEGER NOT NULL DEFAULT 0
        CHECK (active_backlogs >= 0),
    phone VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Companies
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    website TEXT,
    logo_path TEXT,
    description TEXT,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Placement drives
CREATE TABLE placement_drives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL
        REFERENCES companies(id) ON DELETE RESTRICT,
    job_title VARCHAR(200) NOT NULL,
    job_description TEXT,
    eligibility_criteria JSONB NOT NULL DEFAULT '{}'::JSONB,
    minimum_cgpa NUMERIC(4,2)
        CHECK (minimum_cgpa BETWEEN 0 AND 10),
    maximum_backlogs INTEGER
        CHECK (maximum_backlogs >= 0),
    package_min_lpa NUMERIC(8,2)
        CHECK (package_min_lpa >= 0),
    package_max_lpa NUMERIC(8,2)
        CHECK (package_max_lpa >= 0),
    registration_deadline TIMESTAMPTZ NOT NULL,
    visit_date TIMESTAMPTZ,
    venue TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published', 'closed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CHECK (
        package_min_lpa IS NULL
        OR package_max_lpa IS NULL
        OR package_min_lpa <= package_max_lpa
    )
);

-- 5. Student applications
CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drive_id UUID NOT NULL
        REFERENCES placement_drives(id) ON DELETE RESTRICT,
    student_id UUID NOT NULL
        REFERENCES student_profiles(user_id) ON DELETE RESTRICT,
    status VARCHAR(30) NOT NULL DEFAULT 'applied'
        CHECK (status IN (
            'applied', 'shortlisted', 'in_progress',
            'selected', 'rejected', 'withdrawn'
        )),
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_drive_application
        UNIQUE (drive_id, student_id)
);

-- 6. Recruitment rounds for each placement drive
CREATE TABLE recruitment_rounds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drive_id UUID NOT NULL
        REFERENCES placement_drives(id) ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,
    round_number INTEGER NOT NULL CHECK (round_number > 0),
    scheduled_at TIMESTAMPTZ,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_drive_round_number
        UNIQUE (drive_id, round_number)
);

-- 7. Results for each application in each round
CREATE TABLE round_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL
        REFERENCES applications(id) ON DELETE RESTRICT,
    round_id UUID NOT NULL
        REFERENCES recruitment_rounds(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'passed', 'failed', 'absent')),
    remarks TEXT,
    evaluated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    evaluated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_application_round
        UNIQUE (application_id, round_id)
);

-- 8. Student document metadata
-- Actual files are stored separately in private object storage.
CREATE TABLE student_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL
        REFERENCES student_profiles(user_id) ON DELETE RESTRICT,
    document_type VARCHAR(50) NOT NULL,
    storage_path TEXT NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries and foreign-key lookups
CREATE INDEX idx_student_profiles_department
    ON student_profiles(department);

CREATE INDEX idx_companies_name
    ON companies(name);

CREATE INDEX idx_drives_company
    ON placement_drives(company_id);

CREATE INDEX idx_drives_status_deadline
    ON placement_drives(status, registration_deadline);

CREATE INDEX idx_applications_student
    ON applications(student_id);

CREATE INDEX idx_applications_drive_status
    ON applications(drive_id, status);

CREATE INDEX idx_rounds_drive
    ON recruitment_rounds(drive_id, round_number);

CREATE INDEX idx_round_results_application
    ON round_results(application_id);

CREATE INDEX idx_documents_student_status
    ON student_documents(student_id, verification_status);

COMMIT;