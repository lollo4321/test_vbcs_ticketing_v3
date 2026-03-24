# Installation Guide — Database (Oracle ATP)

## Prerequisites
- Oracle ATP instance provisioned
- Schema `staging_paas` created with appropriate privileges
- SQL client (SQL Developer, SQLcl, or Database Actions)

## Steps

### 1. Connect to ATP
Connect to the `staging_paas` schema using your preferred SQL client.

### 2. Run DDL script
Execute the table creation and indexes:
```
@db/01_ddl.sql
```
This creates 7 tables: `uat_lov`, `uat_use_case`, `uat_issue`, `uat_issue_attachment`, `uat_issue_comment`, `uat_issue_status_hist`, `uat_email_outbox`.

### 3. Seed LOV data
```
@db/02_seed_lov.sql
```
Populates all LOV entries (status, severity, priority, record types, etc.).

### 4. Create PL/SQL package
```
@db/03_pkg_uat_api_spec.sql
@db/04_pkg_uat_api_body.sql
```
Verify compilation:
```sql
SELECT object_name, status FROM user_objects WHERE object_name = 'UAT_API_PKG';
-- Expected: 2 rows (PACKAGE, PACKAGE BODY), both VALID
```

### 5. Enable ORDS on schema
```
@db/05_grants.sql
```

### 6. (Optional) Seed sample use cases
```sql
INSERT INTO staging_paas.uat_use_case (use_case_code, use_case_title, domain_stream, owner_user_name, owner_email, created_by)
VALUES ('UC_ACC_001', 'Registrazione prima nota', 'CONTABILITA', 'mario.rossi', 'mario.rossi@ente.it', 'admin');

INSERT INTO staging_paas.uat_use_case (use_case_code, use_case_title, domain_stream, owner_user_name, owner_email, created_by)
VALUES ('UC_PROC_001', 'Creazione ordine acquisto', 'PROCUREMENT', 'luigi.bianchi', 'luigi.bianchi@ente.it', 'admin');

COMMIT;
```

## Verification
```sql
SELECT table_name FROM user_tables WHERE table_name LIKE 'UAT_%' ORDER BY 1;
-- Expected: 7 tables

SELECT COUNT(*) FROM staging_paas.uat_lov;
-- Expected: ~55 rows
```

## Rollback
To remove all objects:
```sql
DROP PACKAGE staging_paas.uat_api_pkg;
DROP TABLE staging_paas.uat_email_outbox CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_issue_status_hist CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_issue_comment CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_issue_attachment CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_issue CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_use_case CASCADE CONSTRAINTS;
DROP TABLE staging_paas.uat_lov CASCADE CONSTRAINTS;
```
