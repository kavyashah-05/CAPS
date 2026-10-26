# C.A.P.S. — Database Schema

## 1. Overview

C.A.P.S. uses PostgreSQL as its relational database. The schema supports user accounts, student profiles, company information, placement drives, applications, recruitment rounds, and student document verification.

The database is designed to maintain data integrity through primary keys, foreign keys, unique constraints, and appropriate status fields.

## 2. Core Tables

### 2.1 users

Stores application user identities and roles.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| email | VARCHAR(255) | Unique, not null |
| password_hash | TEXT | Not null for local authentication |
| role | VARCHAR(20) | Not null; student or admin |
| is_active | BOOLEAN | Not null, default true |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |
| updated_at | TIMESTAMPTZ | Not null, default current timestamp |

Passwords must be stored as secure password hashes, never as plain text. If Supabase Auth is adopted, authentication credentials should be managed by Supabase Auth instead of maintaining a separate password store.

### 2.2 student_profiles

Stores academic and placement-related student information.

| Column | Type | Constraints |
|---|---|---|
| user_id | UUID | Primary key; foreign key to users.id |
| enrollment_number | VARCHAR(50) | Unique, not null |
| full_name | VARCHAR(150) | Not null |
| department | VARCHAR(100) | Not null |
| graduation_year | SMALLINT | Not null |
| cgpa | NUMERIC(4,2) | Nullable |
| active_backlogs | INTEGER | Not null, default 0 |
| phone | VARCHAR(20) | Nullable |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |
| updated_at | TIMESTAMPTZ | Not null, default current timestamp |

### 2.3 companies

Stores employer information.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(200) | Not null |
| website | TEXT | Nullable |
| logo_path | TEXT | Nullable |
| description | TEXT | Nullable |
| is_archived | BOOLEAN | Not null, default false |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |
| updated_at | TIMESTAMPTZ | Not null, default current timestamp |

Company logos should be stored as files in object storage, with their storage paths recorded in the database.

### 2.4 placement_drives

Stores individual recruitment opportunities offered by companies.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| company_id | UUID | Foreign key to companies.id |
| job_title | VARCHAR(200) | Not null |
| job_description | TEXT | Nullable |
| eligibility_criteria | JSONB | Not null, default empty object |
| minimum_cgpa | NUMERIC(4,2) | Nullable |
| maximum_backlogs | INTEGER | Nullable |
| package_min_lpa | NUMERIC(8,2) | Nullable |
| package_max_lpa | NUMERIC(8,2) | Nullable |
| registration_deadline | TIMESTAMPTZ | Not null |
| visit_date | TIMESTAMPTZ | Nullable |
| venue | TEXT | Nullable |
| status | VARCHAR(20) | Not null; draft, published, closed, or cancelled |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |
| updated_at | TIMESTAMPTZ | Not null, default current timestamp |

One company can have multiple placement drives. Eligibility criteria can be expanded as the project develops.

### 2.5 applications

Stores each student's application to a placement drive.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| drive_id | UUID | Foreign key to placement_drives.id |
| student_id | UUID | Foreign key to student_profiles.user_id |
| status | VARCHAR(30) | Not null |
| applied_at | TIMESTAMPTZ | Not null, default current timestamp |
| updated_at | TIMESTAMPTZ | Not null, default current timestamp |

A unique constraint on `(drive_id, student_id)` prevents duplicate applications.

Suggested application statuses: `applied`, `shortlisted`, `in_progress`, `selected`, `rejected`, and `withdrawn`.

### 2.6 recruitment_rounds

Defines the rounds associated with a placement drive.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| drive_id | UUID | Foreign key to placement_drives.id |
| name | VARCHAR(150) | Not null |
| round_number | INTEGER | Not null |
| scheduled_at | TIMESTAMPTZ | Nullable |
| description | TEXT | Nullable |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |

A unique constraint on `(drive_id, round_number)` ensures that each drive has a distinct round sequence.

### 2.7 round_results

Records an applicant's outcome in each recruitment round.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| application_id | UUID | Foreign key to applications.id |
| round_id | UUID | Foreign key to recruitment_rounds.id |
| status | VARCHAR(20) | Not null |
| remarks | TEXT | Nullable |
| evaluated_by | UUID | Nullable; foreign key to users.id |
| evaluated_at | TIMESTAMPTZ | Nullable |
| created_at | TIMESTAMPTZ | Not null, default current timestamp |

Suggested statuses: `pending`, `passed`, `failed`, and `absent`.

A unique constraint on `(application_id, round_id)` prevents duplicate results for the same application and round.

### 2.8 student_documents

Stores document metadata, verification status, and private storage paths.

| Column | Type | Constraints |
|---|---|---|
| id | UUID | Primary key |
| student_id | UUID | Foreign key to student_profiles.user_id |
| document_type | VARCHAR(50) | Not null |
| storage_path | TEXT | Not null |
| original_filename | VARCHAR(255) | Not null |
| mime_type | VARCHAR(100) | Not null |
| file_size_bytes | BIGINT | Not null |
| verification_status | VARCHAR(20) | Not null, default pending |
| verified_by | UUID | Nullable; foreign key to users.id |
| verified_at | TIMESTAMPTZ | Nullable |
| uploaded_at | TIMESTAMPTZ | Not null, default current timestamp |

Suggested verification statuses: `pending`, `verified`, and `rejected`.

Files must be stored in private object storage, not directly in PostgreSQL or the Git repository. File type, size, access permissions, and ownership must be validated by the backend.

## 3. Relationships

- One user can have one student profile.
- One company can have multiple placement drives.
- One placement drive can have multiple applications.
- One student can apply to multiple placement drives.
- One placement drive can have multiple recruitment rounds.
- One application can have multiple round results.
- One student can upload multiple documents.
- Administrators can evaluate recruitment results and verify documents.

## 4. Data Integrity and Security

- Use UUID primary keys for application entities.
- Enforce foreign keys and appropriate unique constraints.
- Validate package ranges, CGPA values, backlog counts, file sizes, and status values.
- Use transactions for multi-step recruitment result updates where appropriate.
- Restrict student data and private documents to authorized users.
- Use server-side authorization checks for every sensitive operation.
- Never store plaintext passwords, secret keys, or actual student records in source control.
- If Supabase Auth is used, map application profiles to authenticated user IDs and enforce suitable Row Level Security policies.

## 5. Implementation Notes

This document defines the initial logical schema. The actual SQL migration will specify UUID generation, check constraints, indexes, deletion behavior, and database-specific defaults.

The schema may evolve as authentication, eligibility filtering, import workflows, and reporting are implemented.

## 6. Database Deployment Status

- PostgreSQL database provisioned through Supabase.
- Initial schema migration executed successfully.
- All eight application tables verified in the `public` schema.
- Row Level Security (RLS) enabled on all eight application tables.
- Application-level access policies still need to be designed, implemented, and tested before client access is enabled.

### Deployment Notes

The migration file is maintained in `database/migrations/001_initial_schema.sql`.

The GitHub repository stores the schema and migration scripts, not database credentials or private student records.

Supabase manages the hosted PostgreSQL instance. Database credentials and service secrets must remain outside version control.

RLS policies will be implemented alongside the authentication and authorization features.