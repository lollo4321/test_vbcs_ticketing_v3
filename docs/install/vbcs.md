# Installation Guide — VBCS (Visual Builder Cloud Service)

## Prerequisites
- Oracle VBCS instance provisioned
- ORDS endpoints deployed and accessible (see `docs/install/ords.md`)
- Base URL of ORDS API: `https://<HOST>/ords/uat/api/v1/`

## Steps

### 1. Create Service Connection
1. In VBCS, go to **Services** > **+ Service Connection**
2. Select **Define by Endpoint**
3. Base URL: `https://<HOST>/ords/uat/api/v1/`
4. Name: `uat_api_v1`
5. Authentication: **None** (for UAT) or **OAuth2** (for production)
6. Test the connection with a GET to `/lov/STATUS`

### 2. Create Application and Pages
Create a new Web Application and add 3 pages:

#### Page 1: issue-list
- Copy content from `vbcs/pages/issue-list/`
- HTML: `page.html`
- CSS: `page.css`
- Page Model: `page-model.json`
- Page Chains: `page-chains.json`
- Action Chains: copy all files from `chains/` folder

#### Page 2: issue-create
- Copy content from `vbcs/pages/issue-create/`
- Same structure as above

#### Page 3: issue-detail
- Copy content from `vbcs/pages/issue-detail/`
- Same structure as above
- Configure `issueId` as URL input parameter

### 3. Configure Navigation
- Set `issue-list` as the default/home page
- Configure navigation flow:
  - issue-list → issue-create (via "Nuova segnalazione" button)
  - issue-list → issue-detail (via table row click, passing `issueId`)
  - issue-create → issue-detail (on successful submit)
  - issue-detail → issue-list (via breadcrumb/back)

### 4. Configure Service Endpoints
Map the following endpoints in the Service Connection:

| Endpoint ID | Method | Path |
|---|---|---|
| `getLov` | GET | `/lov/{type}` |
| `getUsecases` | GET | `/usecases` |
| `getIssues` | GET | `/issues` |
| `postIssues` | POST | `/issues` |
| `getIssueById` | GET | `/issues/{id}` |
| `patchIssue` | PATCH | `/issues/{id}` |
| `postTransition` | POST | `/issues/{id}/transition` |
| `getComments` | GET | `/issues/{id}/comments` |
| `postComments` | POST | `/issues/{id}/comments` |
| `getAttachments` | GET | `/issues/{id}/attachments` |
| `postAttachments` | POST | `/issues/{id}/attachments` |
| `getAttachmentContent` | GET | `/attachments/{attId}/content` |
| `getStatusHistory` | GET | `/issues/{id}/statusHistory` |

### 5. Configure Security (Optional)
1. Go to **Security** > **Roles**
2. Create roles: `UAT_Tester`, `UAT_Triage`, `UAT_Lead`, `UAT_Admin`
3. Add role-based conditions to workflow buttons (see `docs/technical/vbcs.md`)

### 6. Preview and Test
1. Click **Preview** in VBCS
2. Test the complete flow:
   - Create a new issue (Contabilità, SVI, SaaS)
   - Verify it appears in the list
   - Open the detail page
   - Walk through the workflow: NEW → TRIAGE → IN_PROGRESS → SOLUTION_PROPOSED → RETEST → RESOLVED → CLOSED

### 7. Deploy
1. Stage the application
2. Publish to the target VBCS instance
3. Configure authentication (SSO/IDCS) for production access

## Troubleshooting
- **CORS errors**: Ensure ORDS is configured to allow cross-origin requests from the VBCS domain
- **401/403 on API calls**: Check Service Connection authentication settings
- **Empty LOV dropdowns**: Verify ORDS endpoints return data (test with curl/Postman first)
- **Workflow buttons not visible**: Check that issue status matches the expected state for each button
