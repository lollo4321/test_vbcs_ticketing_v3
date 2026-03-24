-- =========================================================
-- 05 - ORDS Grants & Schema Privileges
-- Schema: staging_paas
-- =========================================================

-- Grant ORDS access to schema objects
-- (Run as DBA or schema owner with appropriate privileges)

-- ORDS REST-enable the schema
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled          => TRUE,
    p_schema           => 'STAGING_PAAS',
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'uat',
    p_auto_rest_auth   => FALSE
  );
  COMMIT;
END;
/

-- Grant execute on the package to ORDS runtime (if needed)
-- GRANT EXECUTE ON staging_paas.uat_api_pkg TO ORDS_PUBLIC_USER;

-- Synonyms for convenience (optional)
-- CREATE OR REPLACE PUBLIC SYNONYM uat_api_pkg FOR staging_paas.uat_api_pkg;
