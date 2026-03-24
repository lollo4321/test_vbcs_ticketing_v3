-- =========================================================
-- ORDS Module: uat_api_v1
-- Base path: /uat/api/v1/
-- Schema: staging_paas
-- =========================================================

BEGIN

  ORDS.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => 'STAGING_PAAS',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'uat',
    p_auto_rest_auth      => FALSE
  );

  ORDS.DEFINE_MODULE(
    p_module_name    => 'uat_api_v1',
    p_base_path      => '/api/v1/',
    p_items_per_page => 25
  );

  -- ---------------------------------------------------------
  -- LOV: GET /uat/api/v1/lov/{type}
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'lov/:type');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'lov/:type',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT lov_code AS code, lov_label AS label, sort_order AS "sortOrder"
        FROM staging_paas.uat_lov
       WHERE lov_type = UPPER(:type) AND enabled_yn = 'Y'
       ORDER BY sort_order, lov_label
    ]'
  );

  -- ---------------------------------------------------------
  -- Use Cases: GET /usecases
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'usecases');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'usecases',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT use_case_code   AS "useCaseCode",
             use_case_title  AS "useCaseTitle",
             domain_stream   AS "domainStream",
             owner_user_name AS "ownerUserName",
             owner_email     AS "ownerEmail",
             enabled_yn      AS "enabled"
        FROM staging_paas.uat_use_case
       WHERE (:domainStream IS NULL OR domain_stream = UPPER(:domainStream))
         AND (:enabled IS NULL OR enabled_yn = UPPER(:enabled))
       ORDER BY domain_stream, use_case_code
    ]'
  );

  -- ---------------------------------------------------------
  -- Use Cases: GET /usecases/{code}
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'usecases/:code');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'usecases/:code',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT use_case_code   AS "useCaseCode",
             use_case_title  AS "useCaseTitle",
             domain_stream   AS "domainStream",
             owner_user_name AS "ownerUserName",
             owner_email     AS "ownerEmail",
             enabled_yn      AS "enabled"
        FROM staging_paas.uat_use_case
       WHERE use_case_code = :code
    ]'
  );

  -- ---------------------------------------------------------
  -- Issues list: GET /issues (custom JSON with meta)
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      DECLARE
        v_json CLOB;
      BEGIN
        v_json := staging_paas.uat_api_pkg.issue_search_json(
          :page, :pageSize, :sort,
          :status, :severity, :priority, :recordType,
          :domainStream, :environment, :solutionType,
          :assignee, :createdBy, :retestAssignedTo, :useCaseCode,
          :q, :createdFrom, :createdTo, :updatedFrom, :updatedTo,
          :ageDaysMin
        );
        staging_paas.uat_api_pkg.write_json(v_json);
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Issues: POST /issues (creazione)
  -- ---------------------------------------------------------
  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues',
    p_method      => 'POST',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      DECLARE
        v_issue_id NUMBER;
      BEGIN
        staging_paas.uat_api_pkg.issue_create(:body, NVL(:userName, 'anonymous'), v_issue_id);
        staging_paas.uat_api_pkg.write_json(
          JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE v_issue_id, 'status' VALUE 'NEW')).to_clob()
        );
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Issue detail: GET /issues/{id}
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues/:id');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT * FROM staging_paas.uat_issue WHERE issue_id = TO_NUMBER(:id)
    ]'
  );

  -- ---------------------------------------------------------
  -- Issue update: PATCH /issues/{id}
  -- ---------------------------------------------------------
  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id',
    p_method      => 'PATCH',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      BEGIN
        staging_paas.uat_api_pkg.issue_update(TO_NUMBER(:id), :body, NVL(:userName, 'anonymous'));
        staging_paas.uat_api_pkg.write_json(
          JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE TO_NUMBER(:id))).to_clob()
        );
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Workflow: POST /issues/{id}/transition
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues/:id/transition');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/transition',
    p_method      => 'POST',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      DECLARE
        v_json CLOB;
      BEGIN
        v_json := staging_paas.uat_api_pkg.transition_json(TO_NUMBER(:id), :body, NVL(:userName, 'anonymous'));
        staging_paas.uat_api_pkg.write_json(v_json);
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Comments: GET /issues/{id}/comments
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues/:id/comments');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/comments',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT comment_id   AS "commentId",
             issue_id     AS "issueId",
             comment_text AS "commentText",
             visibility,
             comment_on   AS "commentOn",
             comment_by   AS "commentBy"
        FROM staging_paas.uat_issue_comment
       WHERE issue_id = TO_NUMBER(:id)
       ORDER BY comment_on DESC
    ]'
  );

  -- ---------------------------------------------------------
  -- Comments: POST /issues/{id}/comments
  -- ---------------------------------------------------------
  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/comments',
    p_method      => 'POST',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      BEGIN
        staging_paas.uat_api_pkg.comment_add(TO_NUMBER(:id), :body, NVL(:userName, 'anonymous'));
        staging_paas.uat_api_pkg.write_json(
          JSON_OBJECT('data' VALUE JSON_OBJECT('issueId' VALUE TO_NUMBER(:id))).to_clob()
        );
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Attachments: GET /issues/{id}/attachments
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues/:id/attachments');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/attachments',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT attachment_id AS "attachmentId",
             issue_id      AS "issueId",
             file_name     AS "fileName",
             mime_type     AS "mimeType",
             file_size     AS "fileSize",
             description,
             uploaded_on   AS "uploadedOn",
             uploaded_by   AS "uploadedBy"
        FROM staging_paas.uat_issue_attachment
       WHERE issue_id = TO_NUMBER(:id)
       ORDER BY uploaded_on DESC
    ]'
  );

  -- ---------------------------------------------------------
  -- Attachment content: GET /attachments/{attId}/content
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'attachments/:attId/content');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'attachments/:attId/content',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_PLSQL,
    p_source      => q'[
      BEGIN
        staging_paas.uat_api_pkg.attachment_get_content(TO_NUMBER(:attId));
      END;
    ]'
  );

  -- ---------------------------------------------------------
  -- Status History: GET /issues/{id}/statusHistory
  -- ---------------------------------------------------------
  ORDS.DEFINE_TEMPLATE('uat_api_v1', 'issues/:id/statusHistory');

  ORDS.DEFINE_HANDLER(
    p_module_name => 'uat_api_v1',
    p_pattern     => 'issues/:id/statusHistory',
    p_method      => 'GET',
    p_source_type => ORDS.SOURCE_TYPE_QUERY,
    p_source      => q'[
      SELECT hist_id     AS "histId",
             issue_id    AS "issueId",
             old_status  AS "oldStatus",
             new_status  AS "newStatus",
             changed_on  AS "changedOn",
             changed_by  AS "changedBy",
             change_note AS "changeNote"
        FROM staging_paas.uat_issue_status_hist
       WHERE issue_id = TO_NUMBER(:id)
       ORDER BY changed_on DESC
    ]'
  );

  COMMIT;
END;
/
