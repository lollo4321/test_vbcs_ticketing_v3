# Front-to-Back Review
**Scope:** All `eventListeners` declared in VBCS page-model.json files
**Date:** 2026-03-25
**Reviewer:** Claude Code (automated)

---

## 1. Chain Inventory

> Chains that delegate to another chain (e.g. `resetFilters` → `onFilterChange`) are shown with the effective ORDS call. Navigation-only chains have `N/A` for ORDS and DB columns.

| Page | Listener | JS File | ORDS Endpoint | DB Object | Status |
|------|----------|---------|---------------|-----------|--------|
| issue-list | `navigateToCreate` | `ac_issue-list_navigateCreate.js` ✓ | N/A (navigation) | N/A | OK |
| issue-list | `exportCsv` | `ac_issue-list_exportCsv.js` ✓ | N/A (reads DataProvider in memory) | N/A | OK |
| issue-list | `onFilterChange` | `ac_issue-list_filterChange.js` ✓ | GET `uat_api_v1/getIssues` → `/issues` | `uat_api_pkg.issue_search_json()` → `uat_issue` | OK |
| issue-list | `resetFilters` | `ac_issue-list_resetFilters.js` ✓ | (delegates → `onFilterChange`) same as above | same as above | OK |
| issue-list | `onTabChange` | `ac_issue-list_tabChange.js` ✓ | (delegates → `onFilterChange`) same as above | same as above | OK |
| issue-list | `onRowAction` | `ac_issue-list_rowAction.js` ✓ | N/A (navigation) | N/A | OK |
| issue-list | `onPageSizeChange` | `ac_issue-list_pageSizeChange.js` ✓ | (delegates → `onFilterChange`) same as above | same as above | OK |
| issue-create | `navigateToList` | `ac_issue-create_navigateList.js` ✓ | N/A (navigation) | N/A | OK |
| issue-create | `saveDraft` | `ac_issue-create_saveDraft.js` ✓ | POST `uat_api_v1/postIssues` → `/issues` | `uat_api_pkg.issue_create()` → `uat_issue` | PARTIAL |
| issue-create | `submitIssue` | `ac_issue-create_submit.js` ✓ | POST `uat_api_v1/postIssues` → `/issues` | `uat_api_pkg.issue_create()` → `uat_issue` | OK |
| issue-create | `submitIssue` (attach step) | `ac_issue-create_submit.js` ✓ | POST `uat_api_v1/postAttachments` → `/issues/:id/attachments` | `uat_api_pkg.attachment_add()` → `uat_issue_attachment` | BROKEN |
| issue-create | `onDomainStreamChange` | `ac_issue-create_domainStreamChange.js` ✓ | GET `uat_api_v1/getUsecases` → `/usecases` | `uat_use_case` (direct SQL) | OK |
| issue-create | `onFileSelect` | `ac_issue-create_fileSelect.js` ✓ | N/A (local state only) | N/A | OK |
| issue-detail | `vbEnter` (`loadIssueDetail`) | `ac_issue-detail_loadDetail.js` ✓ | GET `uat_api_v1/getIssueById` → `/issues/:id` | `uat_issue` (direct SQL) | OK |
| issue-detail | `navigateToList` | `ac_issue-detail_navigateList.js` ✓ | N/A (navigation) | N/A | OK |
| issue-detail | `proposeSolution` | `ac_issue-detail_proposeSolution.js` ✓ | POST `uat_api_v1/postTransition` → `/issues/:id/transition` | `uat_api_pkg.transition_json()` → `uat_issue`, `uat_issue_status_hist` | OK |
| issue-detail | `sendToRetest` | `ac_issue-detail_sendToRetest.js` ✓ | POST `uat_api_v1/postTransition` → `/issues/:id/transition` | `uat_api_pkg.transition_json()` → `uat_issue`, `uat_issue_status_hist` | OK |
| issue-detail | `confirmResolution` | `ac_issue-detail_confirmResolution.js` ✓ | POST `uat_api_v1/postTransition` → `/issues/:id/transition` | `uat_api_pkg.transition_json()` → `uat_issue`, `uat_issue_status_hist` | OK |
| issue-detail | `reopenFail` | `ac_issue-detail_reopenFail.js` ✓ | POST `uat_api_v1/postTransition` → `/issues/:id/transition` | `uat_api_pkg.transition_json()` → `uat_issue`, `uat_issue_status_hist` | OK |
| issue-detail | `closeIssue` | `ac_issue-detail_close.js` ✓ | POST `uat_api_v1/postTransition` → `/issues/:id/transition` | `uat_api_pkg.transition_json()` → `uat_issue`, `uat_issue_status_hist`, `uat_issue_comment` | OK |
| issue-detail | `uploadAttachment` | `ac_issue-detail_uploadAttachment.js` ✓ | POST `uat_api_v1/postAttachments` → `/issues/:id/attachments` | `uat_api_pkg.attachment_add()` → `uat_issue_attachment` | BROKEN |
| issue-detail | `addComment` | `ac_issue-detail_addComment.js` ✓ | POST `uat_api_v1/postComments` → `/issues/:id/comments` | `uat_api_pkg.comment_add()` → `uat_issue_comment` | OK |

---

## 2. Link Matrix

> "Consistent" means the target's schema/response shape is compatible with how the caller uses it.

### VBCS → ORDS

| Source (VBCS endpoint alias) | Target (ORDS pattern + method) | Type | Exists | Consistent |
|------------------------------|-------------------------------|------|--------|------------|
| `uat_api_v1/getIssues` | GET `/issues` | REST call | YES | YES — `itemsPath: "data"` matches PL/SQL custom JSON |
| `uat_api_v1/postIssues` | POST `/issues` | REST call | YES | YES |
| `uat_api_v1/getIssueById` | GET `/issues/:id` | REST call | YES | YES — response `items[0]` matches ORDS QUERY wrapper |
| `uat_api_v1/getLov` | GET `/lov/:type` | REST call | YES | YES |
| `uat_api_v1/getUsecases` | GET `/usecases` | REST call | YES | YES |
| `uat_api_v1/postTransition` | POST `/issues/:id/transition` | REST call | YES | YES |
| `uat_api_v1/getComments` | GET `/issues/:id/comments` | REST call | YES | YES |
| `uat_api_v1/postComments` | POST `/issues/:id/comments` | REST call | YES | YES |
| `uat_api_v1/getAttachments` | GET `/issues/:id/attachments` | REST call | YES | YES |
| `uat_api_v1/postAttachments` | POST `/issues/:id/attachments` | REST call | **NO** | N/A — handler not defined |
| `uat_api_v1/getStatusHistory` | GET `/issues/:id/statusHistory` | REST call | YES | YES |

### ORDS → DB

| Source (ORDS handler) | Target (DB object) | Type | Exists | Consistent |
|-----------------------|--------------------|------|--------|------------|
| GET `/lov/:type` | `staging_paas.uat_lov` (direct SQL) | Table | YES | YES |
| GET `/usecases` | `staging_paas.uat_use_case` (direct SQL) | Table | YES | YES |
| GET `/usecases/:code` | `staging_paas.uat_use_case` (direct SQL) | Table | YES | YES |
| GET `/issues` | `staging_paas.uat_api_pkg.issue_search_json()` | Package procedure | YES | YES |
| POST `/issues` | `staging_paas.uat_api_pkg.issue_create()` | Package procedure | YES | YES |
| GET `/issues/:id` | `staging_paas.uat_issue` (direct SQL `SELECT *`) | Table | YES | YES |
| PATCH `/issues/:id` | `staging_paas.uat_api_pkg.issue_update()` | Package procedure | YES | YES |
| POST `/issues/:id/transition` | `staging_paas.uat_api_pkg.transition_json()` | Package procedure | YES | YES |
| GET `/issues/:id/comments` | `staging_paas.uat_issue_comment` (direct SQL) | Table | YES | YES |
| POST `/issues/:id/comments` | `staging_paas.uat_api_pkg.comment_add()` | Package procedure | YES | YES |
| GET `/issues/:id/attachments` | `staging_paas.uat_issue_attachment` (direct SQL) | Table | YES | YES |
| *(missing POST handler)* | `staging_paas.uat_api_pkg.attachment_add()` | Package procedure | YES | **NO** — procedure exists but no ORDS handler calls it |
| GET `/attachments/:attId/content` | `staging_paas.uat_api_pkg.attachment_get_content()` | Package procedure | YES | YES |
| GET `/issues/:id/statusHistory` | `staging_paas.uat_issue_status_hist` (direct SQL) | Table | YES | YES |

### DB package procedures with no ORDS coverage

| DB Object | Declared in Spec | Called by ORDS Handler |
|-----------|-----------------|----------------------|
| `uat_api_pkg.lov_list()` | YES | NO — ORDS uses direct SQL instead |
| `uat_api_pkg.usecase_list()` | YES | NO — ORDS uses direct SQL instead |
| `uat_api_pkg.usecase_get()` | YES | NO — ORDS uses direct SQL instead |
| `uat_api_pkg.issue_get()` | YES | NO — ORDS uses direct SQL instead |
| `uat_api_pkg.attachment_add()` | YES | **NO — and no ORDS handler exists at all** |
| `uat_api_pkg.attachments_list()` | YES | NO — ORDS uses direct SQL instead |
| `uat_api_pkg.comments_list()` | YES | NO — ORDS uses direct SQL instead |

---

## 3. Findings

---

**[F-001] Missing ORDS POST handler for `/issues/:id/attachments`**
- Layer: Cross-layer (ORDS missing; DB handler exists but is unreachable)
- Description: `uat_api_v1_module.sql` defines a GET handler for `issues/:id/attachments` but **no POST handler**. Two chains call the non-existent POST endpoint via `uat_api_v1/postAttachments`:
  1. `ac_issue-detail_uploadAttachment.js` — triggered by `uploadAttachment` listener on issue-detail
  2. `ac_issue-create_submit.js` — triggered inline after issue creation when files are selected

  The DB package has `uat_api_pkg.attachment_add()` fully declared in spec, meaning the DB side is ready but ORDS never calls it.
- Impact: Any attempt to upload a file attachment will result in a 404/405 HTTP error. The `uploadAttachment` feature on issue-detail is entirely non-functional. On issue-create, submitting a form with files selected will create the issue record successfully but silently fail on all attachment uploads (the loop in `ac_issue-create_submit.js` does not abort on attachment failure, so the user is shown "Segnalazione creata con successo" even though no files were attached).

---

**[F-002] `saveDraft` chain silently discards selected files**
- Layer: VBCS
- Description: `ac_issue-create_saveDraft.js` calls only `uat_api_v1/postIssues` (POST `/issues`) without subsequently uploading `$page.variables.selectedFiles`, unlike `ac_issue-create_submit.js` which loops through selected files and calls `postAttachments`. A user who selects files and then clicks "Salva bozza" receives a success notification ("Bozza salvata") but no files are attached to the newly created draft record.
- Impact: Data loss — selected files are not attached to draft issues. Since `selectedFiles` is a page variable (lost on navigation), files cannot be recovered in a subsequent session.

---

**[F-003] Package spec functions unreferenced by ORDS (dead code divergence risk)**
- Layer: Cross-layer (DB / ORDS)
- Description: Seven functions/procedures declared in `uat_api_pkg` spec are bypassed by ORDS, which instead uses direct inline SQL queries for: `lov_list`, `usecase_list`, `usecase_get`, `issue_get`, `attachments_list`, `comments_list`. The only ORDS handlers that use the package are `issue_search_json`, `issue_create`, `issue_update`, `transition_json`, `comment_add`, and `attachment_get_content`. The package spec declares a public API that is partially dead code.
- Impact: Not a runtime break today. Risk: if query logic is updated in package body functions (e.g. adding a filter to `attachments_list`), the corresponding ORDS endpoint behaviour will not change. Maintenance divergence could cause subtle bugs in future changes.

---

**[F-004] `loadIssueDetail` directly assigns objects to `vb/ServiceDataProvider` variables**
- Layer: VBCS
- Description: `ac_issue-detail_loadDetail.js` (lines 34–50) directly assigns plain JavaScript objects to the `attachmentsDataProvider`, `commentsDataProvider`, and `statusHistoryDataProvider` page variables (declared as `vb/ServiceDataProvider` type in page-model.json) using `$page.variables.xxx = { endpoint: ..., uriParameters: ... }`. The standard VBCS pattern for reinitialising a ServiceDataProvider is `Actions.resetVariables`. Direct assignment may not trigger the reactive refresh that causes the bound `oj-list-view` / `oj-table` components to re-fetch data.
- Impact: Attachments, comments, and status history tabs may render empty on initial load. This depends on VBCS runtime version behaviour. Under some runtimes the assignment works; under others only `Actions.resetVariables` triggers the data refresh. Bug may be intermittent or version-dependent.

---

## 4. Suggested Actions

> Ordered by priority: BROKEN first, then PARTIAL, then inconsistencies.

---

**[A-001] → [F-001] Add POST `/issues/:id/attachments` ORDS handler**
- File to modify: `ords/uat_api_v1_module.sql`
- Action: After the existing GET handler block for `issues/:id/attachments`, add a POST handler on the same template (`issues/:id/attachments`) using `ORDS.SOURCE_TYPE_PLSQL`. The handler must:
  1. Extract from the multipart body: `file_name` (`:filename` bind), `mime_type` (`:content_type` bind), `file_size` (`:content_length` bind), binary content (`:body` BLOB bind), and optionally `:description`.
  2. Call `staging_paas.uat_api_pkg.attachment_add(TO_NUMBER(:id), :filename, :content_type, TO_NUMBER(:content_length), :body, :description, NVL(:userName,'anonymous'))`.
  3. Return a JSON body confirming the upload (e.g. `JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE TO_NUMBER(:id)))`).

  Note: ORDS multipart form handling requires the handler pattern to support `BLOB` input. Verify that `attachment_add` body correctly reads from the BLOB parameter before deploying.

---

**[A-002] → [F-001 (create path)] Guard attachment upload failure in `ac_issue-create_submit.js`**
- File to modify: `vbcs/pages/issue-create/chains/ac_issue-create_submit.js`
- Action: In the file upload loop (lines 76–86), check `response.ok` after each `callRestEndpoint` for `postAttachments`. If any upload fails, either (a) abort and show an error message listing the failed files, or (b) collect failures and show a warning after all uploads complete. Currently the loop silently ignores HTTP errors on attachment calls. This action is secondary to A-001 (which fixes the root cause) but provides resilience if the endpoint is temporarily unavailable.

---

**[A-003] → [F-002] Upload `selectedFiles` in `saveDraft` or inform the user**
- File to modify: `vbcs/pages/issue-create/chains/ac_issue-create_saveDraft.js`
- Action: Two options (choose one based on product intent):
  - **Option A (upload on draft):** After a successful `postIssues` call, add the same attachment upload loop present in `ac_issue-create_submit.js` (lines 76–86), using the returned `response.body.data.issueId`. Requires A-001 to be implemented first.
  - **Option B (inform user):** If `$page.variables.selectedFiles.length > 0`, show a warning notification before or after saving the draft: *"I file selezionati non vengono allegati alle bozze. Inviare la segnalazione per allegare i file."* This prevents silent data loss without changing the upload behavior.

---

**[A-004] → [F-004] Replace direct DataProvider assignment with `Actions.resetVariables` in `loadDetail`**
- File to modify: `vbcs/pages/issue-detail/chains/ac_issue-detail_loadDetail.js`
- Action: Replace the three direct assignment statements (lines 34–50) with `Actions.resetVariables` calls, one per DataProvider. Example for attachments:
  ```js
  await Actions.resetVariables(context, {
    variables: {
      attachmentsDataProvider: {
        endpoint: 'uat_api_v1/getAttachments',
        keyAttributes: 'attachmentId',
        uriParameters: { id: issueId }
      }
    }
  });
  ```
  Apply the same pattern for `commentsDataProvider` and `statusHistoryDataProvider`. This ensures VBCS reactive bindings are notified and bound components refresh their data.

---

**[A-005] → [F-003] Align ORDS handlers to use package functions or remove dead package API**
- File to modify: `ords/uat_api_v1_module.sql` and/or `db/03_pkg_uat_api_spec.sql` + `db/04_pkg_uat_api_body.sql`
- Action: Choose one of:
  - **Option A (adopt package functions):** Replace the inline SQL in ORDS handlers for `lov/:type`, `usecases`, `usecases/:code`, `issues/:id` (GET) with `ORDS.SOURCE_TYPE_PLSQL` calls to the corresponding package functions (`lov_list`, `usecase_list`, `usecase_get`, `issue_get`). This centralises query logic in the package body.
  - **Option B (remove dead spec entries):** If the direct SQL approach is intentional, remove the unused function declarations (`lov_list`, `usecase_list`, `usecase_get`, `issue_get`, `attachments_list`, `comments_list`) from the package spec and body to eliminate maintenance divergence. Keep `attachment_add` (needed for A-001).

  Priority: low. Implement after BROKEN and PARTIAL items are resolved.
