-- =========================================================
-- 02 - SEED LOV (codici stabili + label UI)
-- Schema: staging_paas
-- =========================================================

-- DOMAIN_STREAM
INSERT INTO staging_paas.uat_lov VALUES ('DOMAIN_STREAM','CONTABILITA','Contabilità',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('DOMAIN_STREAM','PROCUREMENT','Procurement',20,'Y');

-- ENVIRONMENT
INSERT INTO staging_paas.uat_lov VALUES ('ENVIRONMENT','SVI','SVI',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('ENVIRONMENT','CALL','CALL',20,'Y');

-- STATUS
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','DRAFT','Bozza',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','NEW','Nuovo',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','TRIAGE','In triage',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','IN_PROGRESS','In lavorazione',40,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','SOLUTION_PROPOSED','Soluzione proposta',50,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','RETEST','In re-test',60,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','RESOLVED','Risolto',70,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','CLOSED','Chiuso',80,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','WAITING_INFO','In attesa info',90,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','NOT_REPRODUCIBLE','Non riproducibile',100,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','DUPLICATE','Duplicato',110,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('STATUS','REJECTED','Scartato',120,'Y');

-- RECORD_TYPE
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','BUG','Bug',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','INCIDENT','Incident',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','IMPROVEMENT','Miglioria',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','QUESTION','Chiarimento',40,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','DATA','Dato',50,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('RECORD_TYPE','ACCESS','Accesso',60,'Y');

-- SEVERITY
INSERT INTO staging_paas.uat_lov VALUES ('SEVERITY','BLOCKER','Blocker',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('SEVERITY','HIGH','High',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('SEVERITY','MEDIUM','Medium',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('SEVERITY','LOW','Low',40,'Y');

-- PRIORITY
INSERT INTO staging_paas.uat_lov VALUES ('PRIORITY','P1','P1',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('PRIORITY','P2','P2',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('PRIORITY','P3','P3',30,'Y');

-- FREQUENCY
INSERT INTO staging_paas.uat_lov VALUES ('FREQUENCY','ALWAYS','Sempre',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('FREQUENCY','OFTEN','Spesso',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('FREQUENCY','RARELY','Raramente',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('FREQUENCY','ONCE','Prima volta',40,'Y');

-- COMPONENT
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','UI','UI',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','INTEGRATION','Integration',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','DATA','Data',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','SECURITY','Security',40,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','WORKFLOW','Workflow',50,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('COMPONENT','REPORTING','Reporting',60,'Y');

-- CLOSURE_REASON
INSERT INTO staging_paas.uat_lov VALUES ('CLOSURE_REASON','FIX_VERIFIED','Fix verificato',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('CLOSURE_REASON','WORKAROUND_ACCEPTED','Workaround accettato',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('CLOSURE_REASON','DUPLICATE','Duplicato',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('CLOSURE_REASON','NOT_REPRODUCIBLE','Non riproducibile',40,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('CLOSURE_REASON','OUT_OF_SCOPE','Fuori ambito UAT',50,'Y');

-- SOLUTION_TYPE
INSERT INTO staging_paas.uat_lov VALUES ('SOLUTION_TYPE','SaaS','SaaS',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('SOLUTION_TYPE','PaaS','PaaS',20,'Y');

-- IMPACT
INSERT INTO staging_paas.uat_lov VALUES ('IMPACT','PROCESS_BLOCKED','Processo bloccato',10,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('IMPACT','DATA_ERROR','Dati',20,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('IMPACT','PERFORMANCE','Performance',30,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('IMPACT','UX','UX',40,'Y');
INSERT INTO staging_paas.uat_lov VALUES ('IMPACT','COMPLIANCE','Compliance',50,'Y');

COMMIT;
