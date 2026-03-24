# Technical Documentation — VBCS Layer

## Pages

### 1. Issue List (`vbcs/pages/issue-list/`)
**Purpose**: Main table view with filters, search, sorting, paging, and quick views.

**Components**:
- `oj-select-single` / `oj-select-many` for filters (Domain/Stream, Environment, SolutionType, Status, Severity)
- `oj-input-text` for text search (q)
- `oj-tab-bar` for quick views (Tutte, Le mie, Da re-testare, Alte priorità)
- `oj-table` with server-side paging via ServiceDataProvider
- `oj-paging-control` for pagination
- Cell templates for severity chips, status pills, stream badges

**Action Chains** (7):
| Chain | Trigger | Description |
|---|---|---|
| `ac_issue-list_filterChange` | Filter value changes | Rebuilds query params and refreshes DataProvider |
| `ac_issue-list_tabChange` | Tab selection | Applies preset filter combinations |
| `ac_issue-list_navigateCreate` | "Nuova segnalazione" button | Navigates to issue-create |
| `ac_issue-list_exportCsv` | "Export CSV" button | Client-side CSV generation from current data |
| `ac_issue-list_rowAction` | Table row click | Navigates to issue-detail with issueId |
| `ac_issue-list_resetFilters` | "Reset" button | Clears all filters |
| `ac_issue-list_pageSizeChange` | Page size dropdown | Updates pageSize and refreshes |

### 2. Issue Create (`vbcs/pages/issue-create/`)
**Purpose**: Structured form for creating UAT reports with 4 cards.

**Cards**:
- **A. Contesto**: solutionType (radio), applicationModule, environment, domainStream, useCaseCode, pageUrl, tenantPod/appVersion (conditional)
- **B. Descrizione**: title, recordType, severity, priority, frequency, impactFlags (checkboxes), expectedBehavior, actualBehavior, errorMessage
- **C. Riproducibilità**: prerequisites, stepsToReproduce, reproducible (switch), notes (conditional)
- **D. Evidenze**: file picker (multi), transactionRef

**Validations**:
- Required fields enforced client-side before POST
- `reproducible=No` → notes required
- `severity=BLOCKER|HIGH` without attachments → warning
- `recordType=DATA` without transactionRef → warning

**Action Chains** (5):
| Chain | Trigger | Description |
|---|---|---|
| `ac_issue-create_submit` | "Invia" button | Validates + POST /issues + upload attachments + navigate to detail |
| `ac_issue-create_saveDraft` | "Salva bozza" button | Saves with status=DRAFT |
| `ac_issue-create_navigateList` | "Annulla" / breadcrumb | Back to list |
| `ac_issue-create_domainStreamChange` | Domain/Stream change | Reloads use cases LOV filtered by stream |
| `ac_issue-create_fileSelect` | File picker selection | Adds files to selectedFiles array |

### 3. Issue Detail (`vbcs/pages/issue-detail/`)
**Purpose**: Full issue view with tabs and workflow actions.

**Tabs**:
1. **Dettaglio** — Read-only form with all issue fields
2. **Allegati** — Table + upload
3. **Commenti** — Timeline with add new (public/internal)
4. **Workflow & Audit** — Cards for solution/retest/closure + status history table

**Workflow Buttons** (conditional on status):
| Button | Visible When | Action |
|---|---|---|
| Proponi soluzione | IN_PROGRESS | PROPOSE_SOLUTION transition |
| Invia in re-test | SOLUTION_PROPOSED | SEND_TO_RETEST transition |
| Conferma risoluzione (PASS) | RETEST | CONFIRM_RESOLUTION transition |
| Esito negativo (FAIL) | RETEST | REOPEN_FAIL transition |
| Chiudi | RESOLVED | CLOSE transition |

**Action Chains** (9):
| Chain | Trigger | Description |
|---|---|---|
| `ac_issue-detail_loadDetail` | vbEnter | Loads issue + configures sub-DataProviders |
| `ac_issue-detail_proposeSolution` | Button | Validates + POST transition PROPOSE_SOLUTION |
| `ac_issue-detail_sendToRetest` | Button | POST transition SEND_TO_RETEST |
| `ac_issue-detail_confirmResolution` | Button | POST transition CONFIRM_RESOLUTION |
| `ac_issue-detail_reopenFail` | Button | Validates retestNotes + POST transition REOPEN_FAIL |
| `ac_issue-detail_close` | Button | Validates closureReason + POST transition CLOSE |
| `ac_issue-detail_addComment` | Button | POST /issues/{id}/comments |
| `ac_issue-detail_uploadAttachment` | File picker | POST multipart attachment |
| `ac_issue-detail_navigateList` | Breadcrumb | Back to list |

## Design System
- Oracle JET (`oj-*` components) with Knockout.js bindings
- Oracle Redwood design tokens for colors and typography
- Custom CSS classes: `uat-severity-*`, `uat-status-*` for colored chips/pills
- Responsive layout via `oj-flex` grid

## Service Connection
- Base URL: `https://<ords-host>/ords/uat/api/v1/`
- Auth: OAuth2 (production) or simplified userName param (UAT)
