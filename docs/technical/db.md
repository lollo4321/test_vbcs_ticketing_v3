# Technical Documentation — Database Layer

## Schema
`staging_paas` on Oracle ATP (Autonomous Transaction Processing).

## Tables

| Table | Purpose | PK |
|---|---|---|
| `uat_lov` | Generic LOV configuration (status, severity, etc.) | `(lov_type, lov_code)` |
| `uat_use_case` | Use case registry with owner for re-test assignment | `use_case_code` |
| `uat_issue` | Main issue/ticket table | `issue_id` (IDENTITY) |
| `uat_issue_attachment` | File attachments (BLOB) | `attachment_id` (IDENTITY) |
| `uat_issue_comment` | Comments timeline (public/internal) | `comment_id` (IDENTITY) |
| `uat_issue_status_hist` | Status change audit log | `hist_id` (IDENTITY) |
| `uat_email_outbox` | Email queue (fallback when APEX_MAIL unavailable) | `email_id` (IDENTITY) |

## Key Relationships
- `uat_issue.use_case_code` → FK to `uat_use_case.use_case_code`
- `uat_issue.duplicate_of` → self-referencing FK to `uat_issue.issue_id`
- `uat_issue_attachment.issue_id` → FK to `uat_issue` (ON DELETE CASCADE)
- `uat_issue_comment.issue_id` → FK to `uat_issue` (ON DELETE CASCADE)
- `uat_issue_status_hist.issue_id` → FK to `uat_issue` (ON DELETE CASCADE)

## Indexes
Performance indexes on: `status`, `severity`, `domain_stream`, `environment`, `assignee`, `created_on`, `use_case_code`, plus attachment/comment/history by `issue_id`.

## PL/SQL Package: `uat_api_pkg`

### Spec (`03_pkg_uat_api_spec.sql`)
Exposes all business logic as a single API surface for ORDS handlers.

### Body (`04_pkg_uat_api_body.sql`)
Key procedures/functions:

| Procedure/Function | Purpose |
|---|---|
| `write_json(p_clob)` | Writes CLOB as JSON response via ORDS |
| `lov_list(p_type)` | Returns LOV entries by type |
| `usecase_list(...)` / `usecase_get(...)` | Use case CRUD |
| `issue_create(p_body, p_user, p_id OUT)` | Create issue with validation |
| `issue_get(p_id)` | Get full issue detail |
| `issue_update(p_id, p_body, p_user)` | Partial update (non-status fields) |
| `issue_search_json(...)` | Full search with 18+ filters, sorting, paging, returns JSON with meta |
| `comments_list(p_id)` / `comment_add(...)` | Comments CRUD |
| `attachments_list(p_id)` / `attachment_add(...)` / `attachment_get_content(...)` | Attachments CRUD + download |
| `transition_json(p_id, p_body, p_user)` | Workflow state machine (5 actions) |

### Workflow State Machine (in `transition_json`)
| Action | From | To | Required Fields |
|---|---|---|---|
| `PROPOSE_SOLUTION` | IN_PROGRESS | SOLUTION_PROPOSED | resolutionNotes; fixVersion (if PaaS) |
| `SEND_TO_RETEST` | SOLUTION_PROPOSED | RETEST | auto-assigns owner from use_case |
| `CONFIRM_RESOLUTION` | RETEST | RESOLVED | retestOutcome=PASS |
| `REOPEN_FAIL` | RETEST | IN_PROGRESS | retestOutcome=FAIL, retestNotes |
| `CLOSE` | RESOLVED | CLOSED | closureReason |

### Email Strategy
- Tries `APEX_MAIL.SEND` first (if SMTP configured)
- Falls back to `uat_email_outbox` table for deferred processing

## LOV Types
`DOMAIN_STREAM`, `ENVIRONMENT`, `STATUS` (12 values), `RECORD_TYPE` (6), `SEVERITY` (4), `PRIORITY` (3), `FREQUENCY` (4), `COMPONENT` (6), `CLOSURE_REASON` (5), `SOLUTION_TYPE` (2), `IMPACT` (5).

## Scripts Execution Order
1. `01_ddl.sql` — Tables + indexes
2. `02_seed_lov.sql` — LOV seed data
3. `03_pkg_uat_api_spec.sql` — Package specification
4. `04_pkg_uat_api_body.sql` — Package body
5. `05_grants.sql` — ORDS schema enablement
