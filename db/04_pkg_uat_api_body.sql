-- =========================================================
-- 04 - PL/SQL Package Body: UAT_API_PKG
-- Schema: staging_paas
-- =========================================================

CREATE OR REPLACE PACKAGE BODY staging_paas.uat_api_pkg AS

  -- -------------------------------------------------------
  -- Helpers
  -- -------------------------------------------------------

  PROCEDURE write_json(p_clob CLOB) IS
  BEGIN
    owa_util.mime_header('application/json; charset=utf-8', FALSE);
    htp.p('Cache-Control: no-store');
    owa_util.http_header_close;
    htp.prn(p_clob);
  END;

  PROCEDURE raise_bad_request(p_code VARCHAR2, p_msg VARCHAR2) IS
  BEGIN
    raise_application_error(-20000, p_code || ': ' || p_msg);
  END;

  FUNCTION lov_exists(p_type VARCHAR2, p_code VARCHAR2) RETURN BOOLEAN IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
      FROM staging_paas.uat_lov
     WHERE lov_type = p_type AND lov_code = p_code AND enabled_yn = 'Y';
    RETURN v_cnt > 0;
  END;

  FUNCTION is_null_or_empty(p_str VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN p_str IS NULL OR TRIM(p_str) IS NULL;
  END;

  FUNCTION get_json_string(p_obj JSON_OBJECT_T, p_key VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_obj.has(p_key) THEN
      RETURN p_obj.get_string(p_key);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;

  FUNCTION get_json_clob(p_obj JSON_OBJECT_T, p_key VARCHAR2) RETURN CLOB IS
  BEGIN
    IF p_obj.has(p_key) THEN
      RETURN p_obj.get_clob(p_key);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;

  PROCEDURE add_status_hist(p_issue_id NUMBER, p_old VARCHAR2,
                            p_new VARCHAR2, p_user VARCHAR2, p_note VARCHAR2) IS
  BEGIN
    INSERT INTO staging_paas.uat_issue_status_hist
      (issue_id, old_status, new_status, changed_by, change_note)
    VALUES (p_issue_id, p_old, p_new, p_user, p_note);
  END;

  PROCEDURE add_system_comment(p_issue_id NUMBER, p_text VARCHAR2, p_user VARCHAR2) IS
  BEGIN
    INSERT INTO staging_paas.uat_issue_comment
      (issue_id, comment_text, visibility, comment_by)
    VALUES (p_issue_id, p_text, 'INTERNAL', p_user);
  END;

  PROCEDURE queue_email(p_to VARCHAR2, p_subject VARCHAR2,
                        p_body_html CLOB, p_body_text CLOB DEFAULT NULL,
                        p_cc VARCHAR2 DEFAULT NULL) IS
  BEGIN
    INSERT INTO staging_paas.uat_email_outbox
      (to_email, cc_email, subject, body_html, body_text)
    VALUES (p_to, p_cc, p_subject, p_body_html, p_body_text);
  END;

  PROCEDURE send_email_best_effort(p_to VARCHAR2, p_subject VARCHAR2,
                                   p_body_html CLOB, p_body_text CLOB DEFAULT NULL,
                                   p_cc VARCHAR2 DEFAULT NULL) IS
    v_mail_id NUMBER;
  BEGIN
    BEGIN
      v_mail_id := apex_mail.send(
        p_to        => p_to,
        p_cc        => p_cc,
        p_from      => 'noreply@uat.local',
        p_subj      => p_subject,
        p_body      => NVL(p_body_text, ' '),
        p_body_html => p_body_html
      );
      apex_mail.push_queue;
    EXCEPTION
      WHEN OTHERS THEN
        queue_email(p_to, p_subject, p_body_html, p_body_text, p_cc);
    END;
  END;

  -- -------------------------------------------------------
  -- LOV / Use Case
  -- -------------------------------------------------------

  FUNCTION lov_list(p_type VARCHAR2) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT lov_code AS code, lov_label AS label, sort_order AS "sortOrder"
        FROM staging_paas.uat_lov
       WHERE lov_type = UPPER(p_type) AND enabled_yn = 'Y'
       ORDER BY sort_order, lov_label;
    RETURN rc;
  END;

  FUNCTION usecase_list(p_domain_stream VARCHAR2 DEFAULT NULL,
                        p_enabled       CHAR     DEFAULT NULL) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT use_case_code   AS "useCaseCode",
             use_case_title  AS "useCaseTitle",
             domain_stream   AS "domainStream",
             owner_user_name AS "ownerUserName",
             owner_email     AS "ownerEmail",
             enabled_yn      AS "enabled"
        FROM staging_paas.uat_use_case
       WHERE (p_domain_stream IS NULL OR domain_stream = UPPER(p_domain_stream))
         AND (p_enabled IS NULL OR enabled_yn = UPPER(p_enabled))
       ORDER BY domain_stream, use_case_code;
    RETURN rc;
  END;

  FUNCTION usecase_get(p_code VARCHAR2) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT use_case_code   AS "useCaseCode",
             use_case_title  AS "useCaseTitle",
             domain_stream   AS "domainStream",
             owner_user_name AS "ownerUserName",
             owner_email     AS "ownerEmail",
             enabled_yn      AS "enabled"
        FROM staging_paas.uat_use_case
       WHERE use_case_code = p_code;
    RETURN rc;
  END;

  -- -------------------------------------------------------
  -- Issue Create / Get / Update
  -- -------------------------------------------------------

  PROCEDURE issue_create(p_body CLOB, p_user_name VARCHAR2, p_issue_id OUT NUMBER) IS
    obj               JSON_OBJECT_T;
    v_solution_type   VARCHAR2(10);
    v_app_module      VARCHAR2(100);
    v_environment     VARCHAR2(50);
    v_domain_stream   VARCHAR2(100);
    v_use_case_code   VARCHAR2(50);
    v_record_type     VARCHAR2(20);
    v_severity        VARCHAR2(10);
    v_title           VARCHAR2(120);
    v_expected        CLOB;
    v_actual          CLOB;
    v_steps           CLOB;
    v_repro           CHAR(1);
  BEGIN
    obj             := JSON_OBJECT_T.parse(p_body);
    v_solution_type := get_json_string(obj, 'solutionType');
    v_app_module    := get_json_string(obj, 'applicationModule');
    v_environment   := get_json_string(obj, 'environment');
    v_domain_stream := get_json_string(obj, 'domainStream');
    v_use_case_code := get_json_string(obj, 'useCaseCode');
    v_record_type   := get_json_string(obj, 'recordType');
    v_severity      := get_json_string(obj, 'severity');
    v_title         := get_json_string(obj, 'title');
    v_expected      := get_json_clob(obj, 'expectedBehavior');
    v_actual        := get_json_clob(obj, 'actualBehavior');
    v_steps         := get_json_clob(obj, 'stepsToReproduce');
    v_repro         := NVL(UPPER(get_json_string(obj, 'reproducible')), 'Y');

    -- Validazioni obbligatorie
    IF is_null_or_empty(v_solution_type) OR is_null_or_empty(v_app_module)
       OR is_null_or_empty(v_environment) OR is_null_or_empty(v_domain_stream)
       OR is_null_or_empty(v_record_type) OR is_null_or_empty(v_severity)
       OR is_null_or_empty(v_title)
       OR v_expected IS NULL OR v_actual IS NULL OR v_steps IS NULL
    THEN
      raise_bad_request('VALIDATION_ERROR', 'Campi obbligatori mancanti per creazione issue');
    END IF;

    IF NOT lov_exists('ENVIRONMENT', UPPER(v_environment)) THEN
      raise_bad_request('INVALID_LOV', 'Environment non valido: ' || v_environment);
    END IF;
    IF NOT lov_exists('DOMAIN_STREAM', UPPER(v_domain_stream)) THEN
      raise_bad_request('INVALID_LOV', 'Domain stream non valido: ' || v_domain_stream);
    END IF;
    IF NOT lov_exists('RECORD_TYPE', UPPER(v_record_type)) THEN
      raise_bad_request('INVALID_LOV', 'Record type non valido: ' || v_record_type);
    END IF;
    IF NOT lov_exists('SEVERITY', UPPER(v_severity)) THEN
      raise_bad_request('INVALID_LOV', 'Severity non valida: ' || v_severity);
    END IF;

    INSERT INTO staging_paas.uat_issue (
      created_by, solution_type, application_module, environment, domain_stream,
      use_case_code, page_url, tenant_pod, app_version, test_case_id, uat_step_ref,
      record_type, severity, priority, frequency, impact_flags,
      title, expected_behavior, actual_behavior, error_message,
      prerequisites, steps_to_reproduce, reproducible_yn, notes,
      status, component, assignee, target_release, context_payload
    ) VALUES (
      p_user_name, v_solution_type, v_app_module,
      UPPER(v_environment), UPPER(v_domain_stream),
      v_use_case_code,
      get_json_string(obj, 'pageUrl'),
      get_json_string(obj, 'tenantPod'),
      get_json_string(obj, 'appVersion'),
      get_json_string(obj, 'testCaseId'),
      get_json_string(obj, 'uatStepRef'),
      UPPER(v_record_type), UPPER(v_severity),
      get_json_string(obj, 'priority'),
      get_json_string(obj, 'frequency'),
      get_json_string(obj, 'impactFlags'),
      v_title, v_expected, v_actual, get_json_clob(obj, 'errorMessage'),
      get_json_clob(obj, 'prerequisites'), v_steps,
      CASE WHEN v_repro = 'N' THEN 'N' ELSE 'Y' END,
      get_json_clob(obj, 'notes'),
      'NEW',
      get_json_string(obj, 'component'),
      get_json_string(obj, 'assignee'),
      get_json_string(obj, 'targetRelease'),
      get_json_clob(obj, 'contextPayload')
    )
    RETURNING issue_id INTO p_issue_id;

    add_status_hist(p_issue_id, NULL, 'NEW', p_user_name, 'Issue creata');
  END;

  FUNCTION issue_get(p_issue_id NUMBER) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT * FROM staging_paas.uat_issue WHERE issue_id = p_issue_id;
    RETURN rc;
  END;

  PROCEDURE issue_update(p_issue_id NUMBER, p_body CLOB, p_user_name VARCHAR2) IS
    obj JSON_OBJECT_T;
  BEGIN
    obj := JSON_OBJECT_T.parse(p_body);
    UPDATE staging_paas.uat_issue
       SET updated_on       = SYSTIMESTAMP,
           updated_by       = p_user_name,
           title            = COALESCE(get_json_string(obj, 'title'), title),
           expected_behavior = COALESCE(get_json_clob(obj, 'expectedBehavior'), expected_behavior),
           actual_behavior  = COALESCE(get_json_clob(obj, 'actualBehavior'), actual_behavior),
           error_message    = COALESCE(get_json_clob(obj, 'errorMessage'), error_message),
           prerequisites    = COALESCE(get_json_clob(obj, 'prerequisites'), prerequisites),
           steps_to_reproduce = COALESCE(get_json_clob(obj, 'stepsToReproduce'), steps_to_reproduce),
           notes            = COALESCE(get_json_clob(obj, 'notes'), notes),
           page_url         = COALESCE(get_json_string(obj, 'pageUrl'), page_url),
           app_version      = COALESCE(get_json_string(obj, 'appVersion'), app_version),
           tenant_pod       = COALESCE(get_json_string(obj, 'tenantPod'), tenant_pod),
           component        = COALESCE(get_json_string(obj, 'component'), component),
           assignee         = COALESCE(get_json_string(obj, 'assignee'), assignee),
           target_release   = COALESCE(get_json_string(obj, 'targetRelease'), target_release)
     WHERE issue_id = p_issue_id;

    IF SQL%ROWCOUNT = 0 THEN
      raise_bad_request('NOT_FOUND', 'Issue non trovata: ' || p_issue_id);
    END IF;
  END;

  -- -------------------------------------------------------
  -- Search Issues
  -- -------------------------------------------------------

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
  ) RETURN CLOB IS
    v_page   NUMBER := NVL(p_page, 1);
    v_ps     NUMBER := NVL(p_page_size, 20);
    v_offset NUMBER;
    v_sort   VARCHAR2(200) := NVL(p_sort, 'createdOn:desc');
    v_where  VARCHAR2(4000) := ' WHERE 1=1 ';
    v_order  VARCHAR2(4000) := '';
    v_sql_count VARCHAR2(4000);
    v_sql_data  VARCHAR2(4000);
    v_total  NUMBER;
    v_json   CLOB;

    FUNCTION map_sort_field(p_field VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      CASE LOWER(p_field)
        WHEN 'createdon'    THEN RETURN 'created_on';
        WHEN 'updatedon'    THEN RETURN 'updated_on';
        WHEN 'severity'     THEN
          RETURN 'CASE severity WHEN ''BLOCKER'' THEN 4 WHEN ''HIGH'' THEN 3 WHEN ''MEDIUM'' THEN 2 WHEN ''LOW'' THEN 1 ELSE 0 END';
        WHEN 'priority'     THEN
          RETURN 'CASE priority WHEN ''P1'' THEN 3 WHEN ''P2'' THEN 2 WHEN ''P3'' THEN 1 ELSE 0 END';
        WHEN 'status'       THEN RETURN 'status';
        WHEN 'domainstream' THEN RETURN 'domain_stream';
        WHEN 'environment'  THEN RETURN 'environment';
        WHEN 'assignee'     THEN RETURN 'assignee';
        ELSE RETURN NULL;
      END CASE;
    END;

  BEGIN
    IF v_page < 1 THEN raise_bad_request('INVALID_PAGINATION', 'page min 1'); END IF;
    IF v_ps < 1 OR v_ps > 100 THEN raise_bad_request('INVALID_PAGINATION', 'pageSize 1..100'); END IF;
    v_offset := (v_page - 1) * v_ps;

    -- Filtri IN-list via REGEXP_SUBSTR + CONNECT BY
    IF NOT is_null_or_empty(p_status) THEN
      v_where := v_where || ' AND status IN (SELECT REGEXP_SUBSTR(:status, ''[^,]+'', 1, LEVEL) FROM dual CONNECT BY REGEXP_SUBSTR(:status, ''[^,]+'', 1, LEVEL) IS NOT NULL) ';
    END IF;
    IF NOT is_null_or_empty(p_severity) THEN
      v_where := v_where || ' AND severity IN (SELECT REGEXP_SUBSTR(:severity, ''[^,]+'', 1, LEVEL) FROM dual CONNECT BY REGEXP_SUBSTR(:severity, ''[^,]+'', 1, LEVEL) IS NOT NULL) ';
    END IF;
    IF NOT is_null_or_empty(p_priority) THEN
      v_where := v_where || ' AND priority IN (SELECT REGEXP_SUBSTR(:priority, ''[^,]+'', 1, LEVEL) FROM dual CONNECT BY REGEXP_SUBSTR(:priority, ''[^,]+'', 1, LEVEL) IS NOT NULL) ';
    END IF;
    IF NOT is_null_or_empty(p_record_type) THEN
      v_where := v_where || ' AND record_type IN (SELECT REGEXP_SUBSTR(:record_type, ''[^,]+'', 1, LEVEL) FROM dual CONNECT BY REGEXP_SUBSTR(:record_type, ''[^,]+'', 1, LEVEL) IS NOT NULL) ';
    END IF;
    IF NOT is_null_or_empty(p_domain_stream) THEN
      v_where := v_where || ' AND domain_stream = UPPER(:domain_stream) ';
    END IF;
    IF NOT is_null_or_empty(p_environment) THEN
      v_where := v_where || ' AND environment = UPPER(:environment) ';
    END IF;
    IF NOT is_null_or_empty(p_solution_type) THEN
      v_where := v_where || ' AND solution_type = :solution_type ';
    END IF;
    IF NOT is_null_or_empty(p_assignee) THEN
      v_where := v_where || ' AND assignee = :assignee ';
    END IF;
    IF NOT is_null_or_empty(p_created_by) THEN
      v_where := v_where || ' AND created_by = :created_by ';
    END IF;
    IF NOT is_null_or_empty(p_retest_assigned_to) THEN
      v_where := v_where || ' AND retest_assigned_to = :retest_assigned_to ';
    END IF;
    IF NOT is_null_or_empty(p_use_case_code) THEN
      v_where := v_where || ' AND use_case_code = :use_case_code ';
    END IF;
    IF NOT is_null_or_empty(p_q) THEN
      v_where := v_where || ' AND (UPPER(title) LIKE ''%''||UPPER(:q)||''%'' ) ';
    END IF;
    IF NOT is_null_or_empty(p_created_from) THEN
      v_where := v_where || ' AND created_on >= TO_TIMESTAMP(:created_from) ';
    END IF;
    IF NOT is_null_or_empty(p_created_to) THEN
      v_where := v_where || ' AND created_on <= TO_TIMESTAMP(:created_to) ';
    END IF;
    IF NOT is_null_or_empty(p_updated_from) THEN
      v_where := v_where || ' AND updated_on >= TO_TIMESTAMP(:updated_from) ';
    END IF;
    IF NOT is_null_or_empty(p_updated_to) THEN
      v_where := v_where || ' AND updated_on <= TO_TIMESTAMP(:updated_to) ';
    END IF;
    IF p_age_days_min IS NOT NULL THEN
      v_where := v_where || ' AND (SYSTIMESTAMP - created_on) >= NUMTODSINTERVAL(:age_days_min,''DAY'') ';
    END IF;

    -- Sorting
    DECLARE
      v_part  VARCHAR2(200);
      v_field VARCHAR2(100);
      v_dir   VARCHAR2(10);
      v_col   VARCHAR2(400);
      v_idx   NUMBER := 1;
      v_first BOOLEAN := TRUE;
    BEGIN
      LOOP
        v_part := REGEXP_SUBSTR(v_sort, '[^,]+', 1, v_idx);
        EXIT WHEN v_part IS NULL;
        v_field := REGEXP_SUBSTR(v_part, '^[^:]+');
        v_dir   := LOWER(NVL(REGEXP_SUBSTR(v_part, ':(asc|desc)', 1, 1, NULL, 1), 'desc'));
        v_col   := map_sort_field(v_field);
        IF v_col IS NULL THEN
          raise_bad_request('INVALID_SORT_FIELD', 'Sort non consentito: ' || v_field);
        END IF;
        IF v_first THEN
          v_order := ' ORDER BY ';
          v_first := FALSE;
        ELSE
          v_order := v_order || ', ';
        END IF;
        v_order := v_order || v_col || ' ' || CASE WHEN v_dir = 'asc' THEN 'ASC' ELSE 'DESC' END;
        v_idx := v_idx + 1;
      END LOOP;
      IF v_order IS NULL OR v_order = '' THEN
        v_order := ' ORDER BY created_on DESC ';
      END IF;
    END;

    v_sql_count := 'SELECT COUNT(*) FROM staging_paas.uat_issue ' || v_where;
    v_sql_data  := 'SELECT issue_id, title, domain_stream, environment, solution_type, '
                || 'record_type, severity, priority, status, assignee, retest_assigned_to, '
                || 'use_case_code, created_on, updated_on '
                || 'FROM staging_paas.uat_issue ' || v_where || v_order
                || ' OFFSET :offset ROWS FETCH NEXT :fetch ROWS ONLY';

    -- COUNT
    EXECUTE IMMEDIATE v_sql_count INTO v_total
      USING p_status, p_severity, p_priority, p_record_type,
            p_domain_stream, p_environment, p_solution_type, p_assignee, p_created_by,
            p_retest_assigned_to, p_use_case_code, p_q,
            p_created_from, p_created_to, p_updated_from, p_updated_to, p_age_days_min;

    -- DATA -> JSON
    DECLARE
      c         SYS_REFCURSOR;
      v_arr     JSON_ARRAY_T  := JSON_ARRAY_T();
      v_obj     JSON_OBJECT_T;
      v_issue_id NUMBER; v_title VARCHAR2(120);
      v_ds VARCHAR2(100); v_env VARCHAR2(50); v_sol VARCHAR2(10);
      v_rt VARCHAR2(20); v_sev VARCHAR2(10); v_pri VARCHAR2(5);
      v_st VARCHAR2(30); v_ass VARCHAR2(128); v_retest VARCHAR2(128);
      v_uc VARCHAR2(50); v_co TIMESTAMP; v_uo TIMESTAMP;
      v_meta JSON_OBJECT_T := JSON_OBJECT_T();
      v_root JSON_OBJECT_T := JSON_OBJECT_T();
      v_total_pages NUMBER;
    BEGIN
      OPEN c FOR v_sql_data
        USING p_status, p_severity, p_priority, p_record_type,
              p_domain_stream, p_environment, p_solution_type, p_assignee, p_created_by,
              p_retest_assigned_to, p_use_case_code, p_q,
              p_created_from, p_created_to, p_updated_from, p_updated_to, p_age_days_min,
              v_offset, v_ps;

      LOOP
        FETCH c INTO v_issue_id, v_title, v_ds, v_env, v_sol, v_rt, v_sev,
                     v_pri, v_st, v_ass, v_retest, v_uc, v_co, v_uo;
        EXIT WHEN c%NOTFOUND;
        v_obj := JSON_OBJECT_T();
        v_obj.put('issueId',       v_issue_id);
        v_obj.put('title',         v_title);
        v_obj.put('domainStream',  v_ds);
        v_obj.put('environment',   v_env);
        v_obj.put('solutionType',  v_sol);
        v_obj.put('recordType',    v_rt);
        v_obj.put('severity',      v_sev);
        IF v_pri IS NOT NULL THEN v_obj.put('priority', v_pri); END IF;
        v_obj.put('status',        v_st);
        IF v_ass IS NOT NULL THEN v_obj.put('assignee', v_ass); END IF;
        IF v_retest IS NOT NULL THEN v_obj.put('retestAssignedTo', v_retest); END IF;
        IF v_uc IS NOT NULL THEN v_obj.put('useCaseCode', v_uc); END IF;
        v_obj.put('createdOn', TO_CHAR(v_co, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'));
        IF v_uo IS NOT NULL THEN
          v_obj.put('updatedOn', TO_CHAR(v_uo, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'));
        END IF;
        v_arr.append(v_obj);
      END LOOP;
      CLOSE c;

      v_total_pages := CEIL(v_total / v_ps);
      v_meta.put('page',       v_page);
      v_meta.put('pageSize',   v_ps);
      v_meta.put('total',      v_total);
      v_meta.put('totalPages', v_total_pages);
      v_meta.put('sort',       v_sort);
      v_root.put('data', v_arr);
      v_root.put('meta', v_meta);
      v_json := v_root.to_clob();
    END;

    RETURN v_json;
  END;

  -- -------------------------------------------------------
  -- Comments
  -- -------------------------------------------------------

  FUNCTION comments_list(p_issue_id NUMBER) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT comment_id   AS "commentId",
             issue_id     AS "issueId",
             comment_text AS "commentText",
             visibility,
             comment_on   AS "commentOn",
             comment_by   AS "commentBy"
        FROM staging_paas.uat_issue_comment
       WHERE issue_id = p_issue_id
       ORDER BY comment_on DESC;
    RETURN rc;
  END;

  PROCEDURE comment_add(p_issue_id NUMBER, p_body CLOB, p_user_name VARCHAR2) IS
    obj    JSON_OBJECT_T;
    v_text CLOB;
    v_vis  VARCHAR2(10);
  BEGIN
    obj    := JSON_OBJECT_T.parse(p_body);
    v_text := get_json_clob(obj, 'commentText');
    v_vis  := NVL(UPPER(get_json_string(obj, 'visibility')), 'PUBLIC');

    IF v_text IS NULL THEN
      raise_bad_request('VALIDATION_ERROR', 'commentText obbligatorio');
    END IF;
    IF v_vis NOT IN ('PUBLIC', 'INTERNAL') THEN
      raise_bad_request('VALIDATION_ERROR', 'visibility non valida');
    END IF;

    INSERT INTO staging_paas.uat_issue_comment
      (issue_id, comment_text, visibility, comment_by)
    VALUES (p_issue_id, v_text, v_vis, p_user_name);
  END;

  -- -------------------------------------------------------
  -- Attachments
  -- -------------------------------------------------------

  FUNCTION attachments_list(p_issue_id NUMBER) RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT attachment_id AS "attachmentId",
             issue_id      AS "issueId",
             file_name     AS "fileName",
             mime_type     AS "mimeType",
             file_size     AS "fileSize",
             description,
             uploaded_on   AS "uploadedOn",
             uploaded_by   AS "uploadedBy"
        FROM staging_paas.uat_issue_attachment
       WHERE issue_id = p_issue_id
       ORDER BY uploaded_on DESC;
    RETURN rc;
  END;

  PROCEDURE attachment_add(p_issue_id NUMBER, p_file_name VARCHAR2, p_mime VARCHAR2,
                           p_size NUMBER, p_blob BLOB, p_desc VARCHAR2,
                           p_user_name VARCHAR2) IS
  BEGIN
    INSERT INTO staging_paas.uat_issue_attachment
      (issue_id, file_name, mime_type, file_size, file_content, description, uploaded_by)
    VALUES (p_issue_id, p_file_name, p_mime, p_size, p_blob, p_desc, p_user_name);
  END;

  PROCEDURE attachment_get_content(p_attachment_id NUMBER) IS
    v_blob BLOB;
    v_mime VARCHAR2(100);
    v_name VARCHAR2(255);
  BEGIN
    SELECT file_content, mime_type, file_name
      INTO v_blob, v_mime, v_name
      FROM staging_paas.uat_issue_attachment
     WHERE attachment_id = p_attachment_id;

    owa_util.mime_header(NVL(v_mime, 'application/octet-stream'), FALSE);
    htp.p('Content-Disposition: inline; filename="' || REPLACE(v_name, '"', '') || '"');
    owa_util.http_header_close;
    wpg_docload.download_file(v_blob);
  END;

  -- -------------------------------------------------------
  -- Transition (workflow)
  -- -------------------------------------------------------

  FUNCTION transition_json(p_issue_id NUMBER, p_body CLOB, p_user_name VARCHAR2) RETURN CLOB IS
    obj            JSON_OBJECT_T;
    v_action       VARCHAR2(50);
    payload        JSON_OBJECT_T;
    v_old_status   VARCHAR2(30);
    v_new_status   VARCHAR2(30);
    v_solution_type VARCHAR2(10);
    v_use_case_code VARCHAR2(50);
    v_owner_user   VARCHAR2(128);
    v_owner_email  VARCHAR2(256);
    v_subject      VARCHAR2(300);
    v_html         CLOB;
  BEGIN
    obj      := JSON_OBJECT_T.parse(p_body);
    v_action := UPPER(get_json_string(obj, 'action'));

    IF v_action IS NULL THEN
      raise_bad_request('VALIDATION_ERROR', 'action obbligatoria');
    END IF;

    IF obj.has('payload') THEN
      payload := obj.get_object('payload');
    ELSE
      payload := JSON_OBJECT_T();
    END IF;

    SELECT status, solution_type, use_case_code
      INTO v_old_status, v_solution_type, v_use_case_code
      FROM staging_paas.uat_issue
     WHERE issue_id = p_issue_id
       FOR UPDATE;

    -- ---- PROPOSE_SOLUTION ----
    IF v_action = 'PROPOSE_SOLUTION' THEN
      IF v_old_status <> 'IN_PROGRESS' THEN
        raise_bad_request('INVALID_TRANSITION', 'Da ' || v_old_status || ' non puoi PROPOSE_SOLUTION');
      END IF;
      IF get_json_clob(payload, 'resolutionNotes') IS NULL THEN
        raise_bad_request('VALIDATION_ERROR', 'resolutionNotes obbligatorio');
      END IF;
      IF v_solution_type = 'PaaS' AND is_null_or_empty(get_json_string(payload, 'fixVersion')) THEN
        raise_bad_request('VALIDATION_ERROR', 'fixVersion obbligatorio per PaaS');
      END IF;

      v_new_status := 'SOLUTION_PROPOSED';
      UPDATE staging_paas.uat_issue
         SET status           = v_new_status,
             resolution_notes = get_json_clob(payload, 'resolutionNotes'),
             fix_version      = COALESCE(get_json_string(payload, 'fixVersion'), fix_version),
             fix_environment  = COALESCE(get_json_string(payload, 'fixEnvironment'), fix_environment),
             updated_on       = SYSTIMESTAMP,
             updated_by       = p_user_name
       WHERE issue_id = p_issue_id;

      add_status_hist(p_issue_id, v_old_status, v_new_status, p_user_name, 'Soluzione proposta');
      add_system_comment(p_issue_id,
        'System: soluzione proposta. FixVersion=' || COALESCE(get_json_string(payload, 'fixVersion'), 'n/a'),
        p_user_name);

    -- ---- SEND_TO_RETEST ----
    ELSIF v_action = 'SEND_TO_RETEST' THEN
      IF v_old_status <> 'SOLUTION_PROPOSED' THEN
        raise_bad_request('INVALID_TRANSITION', 'Da ' || v_old_status || ' non puoi SEND_TO_RETEST');
      END IF;

      -- lookup Owner Use Case
      IF v_use_case_code IS NOT NULL THEN
        BEGIN
          SELECT owner_user_name, owner_email
            INTO v_owner_user, v_owner_email
            FROM staging_paas.uat_use_case
           WHERE use_case_code = v_use_case_code AND enabled_yn = 'Y';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_owner_user  := NULL;
            v_owner_email := NULL;
        END;
      END IF;

      v_new_status := 'RETEST';
      UPDATE staging_paas.uat_issue
         SET status              = v_new_status,
             retest_assigned_to  = COALESCE(v_owner_user, created_by),
             retest_instructions = COALESCE(get_json_clob(payload, 'retestInstructions'), retest_instructions),
             updated_on          = SYSTIMESTAMP,
             updated_by          = p_user_name
       WHERE issue_id = p_issue_id;

      add_status_hist(p_issue_id, v_old_status, v_new_status, p_user_name, 'Inviato in re-test');

      IF v_owner_email IS NOT NULL THEN
        v_subject := '[UAT] Issue #' || p_issue_id || ' - In re-test';
        v_html    := '<p>Issue <b>#' || p_issue_id || '</b> inviata in <b>re-test</b>.</p>';
        send_email_best_effort(v_owner_email, v_subject, v_html);
      END IF;

    -- ---- CONFIRM_RESOLUTION ----
    ELSIF v_action = 'CONFIRM_RESOLUTION' THEN
      IF v_old_status <> 'RETEST' THEN
        raise_bad_request('INVALID_TRANSITION', 'Da ' || v_old_status || ' non puoi CONFIRM_RESOLUTION');
      END IF;
      IF UPPER(get_json_string(payload, 'retestOutcome')) <> 'PASS' THEN
        raise_bad_request('VALIDATION_ERROR', 'retestOutcome deve essere PASS');
      END IF;

      v_new_status := 'RESOLVED';
      UPDATE staging_paas.uat_issue
         SET status         = v_new_status,
             retest_outcome = 'PASS',
             retest_notes   = COALESCE(get_json_clob(payload, 'retestNotes'), retest_notes),
             resolved_on    = SYSTIMESTAMP,
             resolved_by    = p_user_name,
             updated_on     = SYSTIMESTAMP,
             updated_by     = p_user_name
       WHERE issue_id = p_issue_id;

      add_status_hist(p_issue_id, v_old_status, v_new_status, p_user_name, 'Risolto (PASS)');
      add_system_comment(p_issue_id,
        'System: re-test PASS. ' || SUBSTR(COALESCE(get_json_string(payload, 'retestNotes'), ''), 1, 300),
        p_user_name);

    -- ---- REOPEN_FAIL ----
    ELSIF v_action = 'REOPEN_FAIL' THEN
      IF v_old_status <> 'RETEST' THEN
        raise_bad_request('INVALID_TRANSITION', 'Da ' || v_old_status || ' non puoi REOPEN_FAIL');
      END IF;
      IF UPPER(get_json_string(payload, 'retestOutcome')) <> 'FAIL' THEN
        raise_bad_request('VALIDATION_ERROR', 'retestOutcome deve essere FAIL');
      END IF;
      IF get_json_clob(payload, 'retestNotes') IS NULL THEN
        raise_bad_request('VALIDATION_ERROR', 'retestNotes obbligatorio in caso FAIL');
      END IF;

      v_new_status := 'IN_PROGRESS';
      UPDATE staging_paas.uat_issue
         SET status         = v_new_status,
             retest_outcome = 'FAIL',
             retest_notes   = get_json_clob(payload, 'retestNotes'),
             updated_on     = SYSTIMESTAMP,
             updated_by     = p_user_name
       WHERE issue_id = p_issue_id;

      add_status_hist(p_issue_id, v_old_status, v_new_status, p_user_name, 'Riaperto (FAIL)');
      add_system_comment(p_issue_id,
        'System: re-test FAIL. ' || SUBSTR(get_json_string(payload, 'retestNotes'), 1, 300),
        p_user_name);

    -- ---- CLOSE ----
    ELSIF v_action = 'CLOSE' THEN
      IF v_old_status <> 'RESOLVED' THEN
        raise_bad_request('INVALID_TRANSITION', 'Da ' || v_old_status || ' non puoi CLOSE');
      END IF;
      IF is_null_or_empty(get_json_string(payload, 'closureReason')) THEN
        raise_bad_request('VALIDATION_ERROR', 'closureReason obbligatorio');
      END IF;

      v_new_status := 'CLOSED';
      UPDATE staging_paas.uat_issue
         SET status                = v_new_status,
             closure_reason        = get_json_string(payload, 'closureReason'),
             closure_evidence_link = COALESCE(get_json_string(payload, 'closureEvidenceLink'), closure_evidence_link),
             closed_on             = SYSTIMESTAMP,
             closed_by             = p_user_name,
             updated_on            = SYSTIMESTAMP,
             updated_by            = p_user_name
       WHERE issue_id = p_issue_id;

      add_status_hist(p_issue_id, v_old_status, v_new_status, p_user_name, 'Chiuso');

    ELSE
      raise_bad_request('INVALID_ACTION', 'Azione non supportata: ' || v_action);
    END IF;

    RETURN JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE p_issue_id, 'status' VALUE v_new_status)).to_clob();
  END;

END uat_api_pkg;
/
