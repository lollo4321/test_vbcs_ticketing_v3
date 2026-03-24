-- =========================================================
-- 03 - PL/SQL Package Spec: UAT_API_PKG
-- Schema: staging_paas
-- =========================================================

CREATE OR REPLACE PACKAGE staging_paas.uat_api_pkg AS

  -- Utility: write JSON response via ORDS
  PROCEDURE write_json(p_clob CLOB);

  -- LOV
  FUNCTION lov_list(p_type VARCHAR2) RETURN SYS_REFCURSOR;

  -- Use cases
  FUNCTION usecase_list(p_domain_stream VARCHAR2 DEFAULT NULL,
                        p_enabled       CHAR     DEFAULT NULL) RETURN SYS_REFCURSOR;
  FUNCTION usecase_get(p_code VARCHAR2) RETURN SYS_REFCURSOR;

  -- Issues CRUD
  PROCEDURE issue_create(p_body      CLOB,
                         p_user_name VARCHAR2,
                         p_issue_id  OUT NUMBER);

  FUNCTION issue_get(p_issue_id NUMBER) RETURN SYS_REFCURSOR;

  PROCEDURE issue_update(p_issue_id  NUMBER,
                         p_body      CLOB,
                         p_user_name VARCHAR2);

  -- Search Issues (lista con meta) -> ritorna JSON CLOB
  FUNCTION issue_search_json(
    p_page               NUMBER,
    p_page_size          NUMBER,
    p_sort               VARCHAR2,
    p_status             VARCHAR2,
    p_severity           VARCHAR2,
    p_priority           VARCHAR2,
    p_record_type        VARCHAR2,
    p_domain_stream      VARCHAR2,
    p_environment        VARCHAR2,
    p_solution_type      VARCHAR2,
    p_assignee           VARCHAR2,
    p_created_by         VARCHAR2,
    p_retest_assigned_to VARCHAR2,
    p_use_case_code      VARCHAR2,
    p_q                  VARCHAR2,
    p_created_from       VARCHAR2,
    p_created_to         VARCHAR2,
    p_updated_from       VARCHAR2,
    p_updated_to         VARCHAR2,
    p_age_days_min       NUMBER
  ) RETURN CLOB;

  -- Comments
  FUNCTION comments_list(p_issue_id NUMBER) RETURN SYS_REFCURSOR;
  PROCEDURE comment_add(p_issue_id  NUMBER,
                        p_body      CLOB,
                        p_user_name VARCHAR2);

  -- Attachments
  FUNCTION attachments_list(p_issue_id NUMBER) RETURN SYS_REFCURSOR;
  PROCEDURE attachment_add(p_issue_id  NUMBER,
                           p_file_name VARCHAR2,
                           p_mime      VARCHAR2,
                           p_size      NUMBER,
                           p_blob      BLOB,
                           p_desc      VARCHAR2,
                           p_user_name VARCHAR2);
  PROCEDURE attachment_get_content(p_attachment_id NUMBER);

  -- Workflow transition
  FUNCTION transition_json(p_issue_id  NUMBER,
                           p_body      CLOB,
                           p_user_name VARCHAR2) RETURN CLOB;

END uat_api_pkg;
/
