# Back-to-Front Review
**Scope:** All tables and PL/SQL objects in `/db/`, traced upward to ORDS and VBCS
**Date:** 2026-03-26
**Reviewer:** Claude Code (automated)

---

## 1. Chain Inventory

> One row per DB object → ORDS exposure → VBCS consumer.
> DataProvider declarations in page-model.json are noted as `(DataProvider)` in the Listener column since they are declarative REST consumers rather than action-chain calls.
> Internal-only objects (helpers with no direct ORDS exposure by design) are included for completeness with status `OK (internal)`.

| DB Object | ORDS Handler | VBCS Alias | Page | Listener / DataProvider | JS File | Status |
|-----------|-------------|------------|------|------------------------|---------|--------|
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-list | `lovDomainStream` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-list | `lovEnvironment` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-list | `lovSolutionType` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-list | `lovStatus` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-list | `lovSeverity` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovEnvironment` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovDomainStream` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovSolutionType` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovRecordType` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovSeverity` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovPriority` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-create | `lovFrequency` (DataProvider) | — | OK |
| `uat_lov` (SELECT) | GET `/lov/:type` | `uat_api_v1/getLov` | issue-detail | `lovClosureReason` (DataProvider) | — | OK |
| `uat_use_case` (SELECT all) | GET `/usecases` | `uat_api_v1/getUsecases` | issue-create | `lovUseCases` (DataProvider) | — | OK |
| `uat_use_case` (SELECT all) | GET `/usecases` | `uat_api_v1/getUsecases` | issue-create | `onDomainStreamChange` | `ac_issue-create_domainStreamChange.js` ✓ | OK |
| `uat_use_case` (SELECT by code) | GET `/usecases/:code` | *(no VBCS alias identified)* | — | — | — | PARTIAL |
| `uat_issue` (SELECT list) | GET `/issues` | `uat_api_v1/getIssues` | issue-list | `issueListDataProvider` (DataProvider) | — | OK |
| `uat_issue` (SELECT list) | GET `/issues` | `uat_api_v1/getIssues` | issue-list | `onFilterChange` | `ac_issue-list_filterChange.js` ✓ | OK |
| `uat_issue` (SELECT by id) | GET `/issues/:id` | `uat_api_v1/getIssueById` | issue-detail | `vbEnter` (`loadIssueDetail`) | `ac_issue-detail_loadDetail.js` ✓ | OK |
| `uat_issue` (INSERT) | POST `/issues` | `uat_api_v1/postIssues` | issue-create | `submitIssue` | `ac_issue-create_submit.js` ✓ | OK |
| `uat_issue` (INSERT) | POST `/issues` | `uat_api_v1/postIssues` | issue-create | `saveDraft` | `ac_issue-create_saveDraft.js` ✓ | OK |
| `uat_issue` (UPDATE) | PATCH `/issues/:id` | *(no VBCS alias identified)* | — | — | — | PARTIAL |
| `uat_issue` (UPDATE via transition) | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `proposeSolution` | `ac_issue-detail_proposeSolution.js` ✓ | OK |
| `uat_issue` (UPDATE via transition) | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `sendToRetest` | `ac_issue-detail_sendToRetest.js` ✓ | OK |
| `uat_issue` (UPDATE via transition) | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `confirmResolution` | `ac_issue-detail_confirmResolution.js` ✓ | OK |
| `uat_issue` (UPDATE via transition) | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `reopenFail` | `ac_issue-detail_reopenFail.js` ✓ | OK |
| `uat_issue` (UPDATE via transition) | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `closeIssue` | `ac_issue-detail_close.js` ✓ | OK |
| `uat_issue_attachment` (SELECT) | GET `/issues/:id/attachments` | `uat_api_v1/getAttachments` | issue-detail | `attachmentsDataProvider` (DataProvider) | — | OK |
| `uat_issue_attachment` (SELECT) | GET `/issues/:id/attachments` | `uat_api_v1/getAttachments` | issue-detail | `vbEnter` (`loadIssueDetail`) | `ac_issue-detail_loadDetail.js` ✓ | OK |
| `uat_issue_attachment` (SELECT blob) | GET `/attachments/:attId/content` | *(no VBCS alias identified)* | — | — | — | PARTIAL |
| `uat_issue_attachment` (INSERT) | **MISSING** POST `/issues/:id/attachments` | `uat_api_v1/postAttachments` | issue-detail | `uploadAttachment` | `ac_issue-detail_uploadAttachment.js` ✓ | BROKEN |
| `uat_issue_attachment` (INSERT) | **MISSING** POST `/issues/:id/attachments` | `uat_api_v1/postAttachments` | issue-create | `submitIssue` (attach step) | `ac_issue-create_submit.js` ✓ | BROKEN |
| `uat_issue_comment` (SELECT) | GET `/issues/:id/comments` | `uat_api_v1/getComments` | issue-detail | `commentsDataProvider` (DataProvider) | — | OK |
| `uat_issue_comment` (SELECT) | GET `/issues/:id/comments` | `uat_api_v1/getComments` | issue-detail | `vbEnter` (`loadIssueDetail`) | `ac_issue-detail_loadDetail.js` ✓ | OK |
| `uat_issue_comment` (INSERT) | POST `/issues/:id/comments` | `uat_api_v1/postComments` | issue-detail | `addComment` | `ac_issue-detail_addComment.js` ✓ | OK |
| `uat_issue_comment` (INSERT, system) | POST `/issues/:id/transition` (internal) | `uat_api_v1/postTransition` | issue-detail | workflow listeners (×5) | see transition chains | OK |
| `uat_issue_status_hist` (SELECT) | GET `/issues/:id/statusHistory` | `uat_api_v1/getStatusHistory` | issue-detail | `statusHistoryDataProvider` (DataProvider) | — | OK |
| `uat_issue_status_hist` (SELECT) | GET `/issues/:id/statusHistory` | `uat_api_v1/getStatusHistory` | issue-detail | `vbEnter` (`loadIssueDetail`) | `ac_issue-detail_loadDetail.js` ✓ | OK |
| `uat_issue_status_hist` (INSERT, via transition) | POST `/issues/:id/transition` (internal) | `uat_api_v1/postTransition` | issue-detail | workflow listeners (×5) | see transition chains | OK |
| `uat_email_outbox` (INSERT, via fallback) | *(no ORDS handler — internal fallback only)* | N/A | — | — | — | PARTIAL |

### Package Procedures

| DB Object | ORDS Handler | VBCS Alias | Page | Listener | JS File | Status |
|-----------|-------------|------------|------|----------|---------|--------|
| `uat_api_pkg.write_json()` | Called internally by all PL/SQL handlers | N/A | — | — | — | OK (internal) |
| `uat_api_pkg.lov_list()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.usecase_list()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.usecase_get()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.issue_create()` | POST `/issues` | `uat_api_v1/postIssues` | issue-create | `submitIssue`, `saveDraft` | `ac_issue-create_submit.js` ✓, `ac_issue-create_saveDraft.js` ✓ | OK |
| `uat_api_pkg.issue_get()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.issue_update()` | PATCH `/issues/:id` | *(no VBCS alias identified)* | — | — | — | PARTIAL |
| `uat_api_pkg.issue_search_json()` | GET `/issues` | `uat_api_v1/getIssues` | issue-list | `onFilterChange`, `issueListDataProvider` | `ac_issue-list_filterChange.js` ✓ | OK |
| `uat_api_pkg.comments_list()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.comment_add()` | POST `/issues/:id/comments` | `uat_api_v1/postComments` | issue-detail | `addComment` | `ac_issue-detail_addComment.js` ✓ | OK |
| `uat_api_pkg.attachments_list()` | *(not called — ORDS uses direct SQL)* | N/A | — | — | — | PARTIAL |
| `uat_api_pkg.attachment_add()` | *(no ORDS handler defined)* | `uat_api_v1/postAttachments` (broken) | issue-detail, issue-create | `uploadAttachment`, `submitIssue` | `ac_issue-detail_uploadAttachment.js` ✓, `ac_issue-create_submit.js` ✓ | BROKEN |
| `uat_api_pkg.attachment_get_content()` | GET `/attachments/:attId/content` | *(no VBCS alias identified)* | — | — | — | PARTIAL |
| `uat_api_pkg.transition_json()` | POST `/issues/:id/transition` | `uat_api_v1/postTransition` | issue-detail | `proposeSolution`, `sendToRetest`, `confirmResolution`, `reopenFail`, `closeIssue` | all 5 transition chain JS files ✓ | OK |

---

## 2. Link Matrix

### DB → ORDS

| Source (DB Object / Procedure) | Target (ORDS Handler) | Access Type | Exposed by ORDS | Consistent |
|-------------------------------|----------------------|-------------|----------------|------------|
| `staging_paas.uat_lov` | GET `/lov/:type` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_use_case` | GET `/usecases` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_use_case` | GET `/usecases/:code` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_issue` | GET `/issues` (via `issue_search_json`) | Package function | YES | YES |
| `staging_paas.uat_issue` | POST `/issues` (via `issue_create`) | Package procedure | YES | YES |
| `staging_paas.uat_issue` | GET `/issues/:id` | Direct SQL SELECT * | YES | YES |
| `staging_paas.uat_issue` | PATCH `/issues/:id` (via `issue_update`) | Package procedure | YES | YES |
| `staging_paas.uat_issue` | POST `/issues/:id/transition` (via `transition_json`) | Package function | YES | YES |
| `staging_paas.uat_issue_attachment` | GET `/issues/:id/attachments` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_issue_attachment` | GET `/attachments/:attId/content` (via `attachment_get_content`) | Package procedure | YES | YES |
| `staging_paas.uat_issue_attachment` | POST `/issues/:id/attachments` (via `attachment_add`) | Package procedure | **NO** | N/A — ORDS handler missing |
| `staging_paas.uat_issue_comment` | GET `/issues/:id/comments` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_issue_comment` | POST `/issues/:id/comments` (via `comment_add`) | Package procedure | YES | YES |
| `staging_paas.uat_issue_status_hist` | GET `/issues/:id/statusHistory` | Direct SQL SELECT | YES | YES |
| `staging_paas.uat_email_outbox` | *(no ORDS handler)* | — | **NO** | N/A — table unreachable via ORDS |
| `uat_api_pkg.lov_list` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |
| `uat_api_pkg.usecase_list` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |
| `uat_api_pkg.usecase_get` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |
| `uat_api_pkg.issue_get` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |
| `uat_api_pkg.attachments_list` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |
| `uat_api_pkg.comments_list` | *(no ORDS handler references it)* | — | **NO** (bypassed) | N/A — dead code |

### ORDS → VBCS

| Source (ORDS Handler) | Target (VBCS Alias) | Caller | Exists in VBCS | Consistent |
|----------------------|---------------------|--------|----------------|------------|
| GET `/lov/:type` | `uat_api_v1/getLov` | DataProvider declarations (13 instances across 3 pages) | YES | YES |
| GET `/usecases` | `uat_api_v1/getUsecases` | DataProvider + `ac_issue-create_domainStreamChange.js` | YES | YES |
| GET `/usecases/:code` | *(no alias defined in VBCS)* | — | **NO caller found** | N/A |
| GET `/issues` | `uat_api_v1/getIssues` | DataProvider + `ac_issue-list_filterChange.js` | YES | YES |
| POST `/issues` | `uat_api_v1/postIssues` | `ac_issue-create_submit.js`, `ac_issue-create_saveDraft.js` | YES | YES |
| GET `/issues/:id` | `uat_api_v1/getIssueById` | `ac_issue-detail_loadDetail.js` | YES | YES |
| PATCH `/issues/:id` | *(no alias defined in VBCS)* | — | **NO caller found** | N/A |
| POST `/issues/:id/transition` | `uat_api_v1/postTransition` | 5 transition chain JS files | YES | YES |
| GET `/issues/:id/comments` | `uat_api_v1/getComments` | DataProvider + `ac_issue-detail_loadDetail.js` | YES | YES |
| POST `/issues/:id/comments` | `uat_api_v1/postComments` | `ac_issue-detail_addComment.js` | YES | YES |
| GET `/issues/:id/attachments` | `uat_api_v1/getAttachments` | DataProvider + `ac_issue-detail_loadDetail.js` | YES | YES |
| *(missing)* POST `/issues/:id/attachments` | `uat_api_v1/postAttachments` | `ac_issue-detail_uploadAttachment.js`, `ac_issue-create_submit.js` | YES (callers exist) | **NO — ORDS handler missing** |
| GET `/attachments/:attId/content` | *(no alias defined in VBCS)* | — | **NO caller found in chains** | N/A |
| GET `/issues/:id/statusHistory` | `uat_api_v1/getStatusHistory` | DataProvider + `ac_issue-detail_loadDetail.js` | YES | YES |

---

## 3. Findings

---

**[F-001] Missing ORDS POST handler for `/issues/:id/attachments`**
- Layer: Cross-layer (ORDS missing; DB procedure `attachment_add` exists and is complete)
- Description: `uat_api_pkg.attachment_add()` is fully declared in the package spec and body. Two VBCS chains call `uat_api_v1/postAttachments` (inferred POST `/issues/:id/attachments`), but no such handler is defined in `uat_api_v1_module.sql`. Only a GET handler is defined for this template.
- Impact: All attachment uploads fail with a 404/405 HTTP error at runtime. The `uploadAttachment` listener on issue-detail is entirely non-functional. On issue-create, the submit flow creates the issue record but silently fails all attachment uploads (the loop in `ac_issue-create_submit.js` does not abort on attachment error).

---

**[F-002] PATCH `/issues/:id` exposes `issue_update()` but has no VBCS caller**
- Layer: Cross-layer (ORDS and DB complete; VBCS layer missing)
- Description: `uat_api_v1_module.sql` defines a PATCH handler for `issues/:id` backed by `uat_api_pkg.issue_update()`. No VBCS action chain or DataProvider calls this endpoint. There is no listener in any page-model.json that triggers issue editing after creation.
- Impact: Issue field editing is dead functionality. Users can create issues and advance their workflow status but cannot correct any field (title, description, severity, assignee, etc.) after submission. The `issue_update` package procedure and the PATCH ORDS handler are unreachable from the UI.

---

**[F-003] GET `/usecases/:code` endpoint has no VBCS caller**
- Layer: Cross-layer (ORDS and DB complete; VBCS layer missing)
- Description: `uat_api_v1_module.sql` defines a GET handler for `usecases/:code` backed by a direct SQL query on `uat_use_case`. No VBCS action chain or DataProvider references this endpoint. The `getUsecases` (list) endpoint is used, but the single-record variant is not.
- Impact: Not a runtime break. The endpoint is inaccessible from the UI. If use-case detail lookup (e.g., to auto-populate retest assignee before displaying a confirmation) is a future requirement, it cannot be triggered through any existing VBCS path.

---

**[F-004] GET `/attachments/:attId/content` has no identified VBCS action-chain caller**
- Layer: Cross-layer (ORDS and DB complete; VBCS caller not verifiable from chains)
- Description: `uat_api_v1_module.sql` defines a GET handler for `attachments/:attId/content` backed by `uat_api_pkg.attachment_get_content()`. No VBCS action chain JS file and no DataProvider calls this endpoint. Attachment download presumably relies on a direct `href` link in the HTML templates, which is outside the scope of action-chain review.
- Impact: Cannot be confirmed as broken without reading `page.html` files. If attachment download is implemented as a raw URL in HTML (rather than through a VBCS service connection), it bypasses any VBCS authentication token injection, which may cause 401 errors on ORDS endpoints that require authentication. Risk level depends on `p_auto_rest_auth` configuration (currently `FALSE`).

---

**[F-005] `uat_email_outbox` table has no ORDS read or management endpoint**
- Layer: Cross-layer (DB complete; ORDS and VBCS layers missing)
- Description: `uat_email_outbox` is written to by `uat_api_pkg.queue_email()`, called as a fallback from `send_email_best_effort()` when `apex_mail.send` fails. `transition_json()` internally calls `send_email_best_effort()` for workflow notifications. There is no ORDS endpoint to read, retry, or clear rows in this table.
- Impact: If APEX_MAIL is not configured, all workflow notification emails are silently queued in `uat_email_outbox` with no delivery. There is no UI or API to monitor queue depth, view failures, or trigger retries. Failed notifications accumulate invisibly.

---

**[F-006] Six package functions declared in spec but bypassed by all ORDS handlers**
- Layer: Cross-layer (DB / ORDS)
- Description: `uat_api_pkg` declares six public functions that are never called by any ORDS handler: `lov_list`, `usecase_list`, `usecase_get`, `issue_get`, `attachments_list`, `comments_list`. The corresponding ORDS handlers use identical inline SQL queries instead. The package API is partially a dead public interface.
- Impact: Not a runtime break. Future maintainers modifying query logic inside these package functions will not affect ORDS behaviour. Query logic is duplicated between the package body and the ORDS module SQL, creating a maintenance divergence risk.

---

## 4. Suggested Actions

> Ordered by priority: BROKEN first, then PARTIAL, then inconsistencies.

---

**[A-001] → [F-001] Add POST `/issues/:id/attachments` ORDS handler**
- File to modify: `ords/uat_api_v1_module.sql`
- Action: On the existing `issues/:id/attachments` template, add a POST handler using `ORDS.SOURCE_TYPE_PLSQL`. The handler must call `staging_paas.uat_api_pkg.attachment_add(TO_NUMBER(:id), :filename, :content_type, TO_NUMBER(:content_length), :body, :description, NVL(:userName, 'anonymous'))` where `:filename`, `:content_type`, `:content_length`, and `:body` (BLOB) are multipart bind parameters provided by ORDS. Return a JSON confirmation: `JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE TO_NUMBER(:id)))`. Example block:
  ```sql
  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/attachments',
    p_method      => 'POST',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      BEGIN
        staging_paas.uat_api_pkg.attachment_add(
          TO_NUMBER(:id), :filename, :content_type,
          TO_NUMBER(:content_length), :body, :description,
          NVL(:userName, 'anonymous')
        );
        staging_paas.uat_api_pkg.write_json(
          JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE TO_NUMBER(:id))).to_clob()
        );
      END;
    ]'
  );
  ```

---

**[A-002] → [F-002] Wire PATCH `/issues/:id` to a VBCS edit action chain**
- File to modify: `vbcs/pages/issue-detail/page-model.json`, new file `vbcs/pages/issue-detail/chains/ac_issue-detail_editIssue.js`, `vbcs/pages/issue-detail/page-chains.json`
- Action:
  1. Add a new listener `editIssue` in `page-model.json` eventListeners pointing to chain `editIssue`.
  2. Add an `editIssue` entry in `page-chains.json` with root `ac_issue-detail_editIssue`.
  3. Create `ac_issue-detail_editIssue.js` that calls `Actions.callRestEndpoint` with `endpoint: 'uat_api_v1/patchIssue'`, `uriParams: { id: $page.variables.issueId }`, and `body` containing the editable fields from `$page.variables.issue`. On success, fire `loadIssueDetail` to refresh the page.
  4. Add the `uat_api_v1/patchIssue` service endpoint to the VBCS service connection catalog, mapping to PATCH `/issues/:id`.
  5. Add the corresponding edit button and form controls to `vbcs/pages/issue-detail/page.html`.

---

**[A-003] → [F-004] Verify and secure attachment download in HTML**
- File to read (not modify during this session): `vbcs/pages/issue-detail/page.html`
- Action: Confirm whether attachment download links are rendered as direct `href` URLs to `/attachments/:attId/content`. If so, evaluate whether `p_auto_rest_auth=FALSE` is intentional for this endpoint. If authentication is required, replace direct URL links with a VBCS action chain that calls `uat_api_v1/getAttachmentContent` (a new service connection alias for GET `/attachments/:attId/content`) using `Actions.callRestEndpoint` with the VBCS auth token injected automatically by the runtime.

---

**[A-004] → [F-005] Add ORDS endpoint to manage `uat_email_outbox`**
- File to modify: `ords/uat_api_v1_module.sql`
- Action: Define a new template and handler (admin-only, consider adding ORDS privilege): GET `/email-outbox` to list pending/failed rows from `uat_email_outbox` (filter by `status IN ('PENDING','ERROR')`), and optionally a POST `/email-outbox/:emailId/retry` handler to reset `status='PENDING'` for manual reprocessing. Without this, failed notifications are invisible. Alternatively, document that email monitoring requires direct DB access and is out of scope for this application.

---

**[A-005] → [F-006] Align ORDS handlers to use package functions or remove dead declarations**
- File to modify: `ords/uat_api_v1_module.sql` and/or `db/03_pkg_uat_api_spec.sql` + `db/04_pkg_uat_api_body.sql`
- Action: Choose one:
  - **Option A (adopt package functions):** Replace direct SQL in GET `/lov/:type`, GET `/usecases`, GET `/usecases/:code`, GET `/issues/:id`, GET `/issues/:id/comments`, GET `/issues/:id/attachments` handlers with `ORDS.SOURCE_TYPE_PLSQL` calls to the corresponding package functions. Centralises query logic.
  - **Option B (remove dead spec entries):** Remove `lov_list`, `usecase_list`, `usecase_get`, `issue_get`, `comments_list`, `attachments_list` from the package spec and body. Keep `attachment_add` (needed for A-001). Documents that direct SQL in ORDS is the intentional pattern.

---

**[A-006] → [F-003] Remove or document GET `/usecases/:code`**
- File to modify: `ords/uat_api_v1_module.sql` (if removing) or `docs/technical/ords.md` (if documenting)
- Action: If the endpoint has no planned VBCS consumer, either remove the `ORDS.DEFINE_TEMPLATE` + `ORDS.DEFINE_HANDLER` block for `usecases/:code`, or add a comment in the ORDS module and a note in `docs/technical/ords.md` explaining that it is a utility endpoint for direct API consumers (e.g., integration scripts). This prevents future confusion about whether the endpoint is incomplete.
