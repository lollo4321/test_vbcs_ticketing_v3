# Installation Guide — ORDS

## Prerequisites
- Oracle ORDS installed and connected to the ATP instance
- Schema `staging_paas` REST-enabled (done in `db/05_grants.sql`)
- DB scripts (01-05) already executed

## Steps

### 1. Run ORDS module definition
Connect to the `staging_paas` schema and execute:
```
@ords/uat_api_v1_module.sql
```

### 2. Verify module registration
```sql
SELECT id, name, uri_prefix FROM user_ords_modules WHERE name = 'uat_api_v1';
```
Expected: 1 row with `uri_prefix = /api/v1/`.

### 3. Verify templates
```sql
SELECT uri_template FROM user_ords_templates WHERE module_name = 'uat_api_v1' ORDER BY 1;
```
Expected templates:
- `attachments/:attId/content`
- `issues`
- `issues/:id`
- `issues/:id/attachments`
- `issues/:id/comments`
- `issues/:id/statusHistory`
- `issues/:id/transition`
- `lov/:type`
- `usecases`
- `usecases/:code`

### 4. Test endpoints
Replace `<HOST>` with your ORDS hostname:

**LOV**:
```
GET https://<HOST>/ords/uat/api/v1/lov/STATUS
```

**Issues list**:
```
GET https://<HOST>/ords/uat/api/v1/issues?page=1&pageSize=5
```

**Create issue** (sample):
```bash
curl -X POST "https://<HOST>/ords/uat/api/v1/issues?userName=test.user" \
  -H "Content-Type: application/json" \
  -d '{
    "solutionType": "SaaS",
    "applicationModule": "Fusion Payables",
    "environment": "SVI",
    "domainStream": "CONTABILITA",
    "recordType": "INCIDENT",
    "severity": "HIGH",
    "title": "Test issue",
    "expectedBehavior": "Should work",
    "actualBehavior": "Does not work",
    "stepsToReproduce": "1) Open page 2) Click button"
  }'
```

## Security (Optional — Production)
For OAuth2 protection, run the appropriate ORDS security script based on your ORDS version:
- **ORDS 24.3+**: Use `ORDS_SECURITY` package
- **ORDS <= 24.2**: Use `ORDS_METADATA.OAUTH_ADMIN` package

See functional spec section on ORDS security for detailed scripts.

## Base URL for VBCS
The base URL to configure in VBCS Service Connection:
```
https://<HOST>/ords/uat/api/v1/
```
