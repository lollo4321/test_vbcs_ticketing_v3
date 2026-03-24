# Assumptions

Documented assumptions made during generation where the functional spec was ambiguous or incomplete.

## Database

1. **Schema name**: Used `staging_paas` as specified in CLAUDE.md. The functional doc mentions `UAT_BUGS` as example — ignored in favor of project standard.

2. **Application Module LOV**: The functional doc does not provide a definitive list of application/modules. Hardcoded a sample list in VBCS page-model (Fusion Payables, Fusion Receivables, Fusion GL, Procurement Cloud, Custom PaaS App). This should be replaced with a DB-backed LOV (`uat_lov` type `APPLICATION_MODULE`) or a VBCS-managed list.

3. **Email sender address**: Set to `noreply@uat.local` as placeholder. Must be configured per environment.

4. **APEX_MAIL availability**: The package body tries `APEX_MAIL.SEND` first. If APEX is not installed or SMTP not configured, it silently falls back to the `uat_email_outbox` table. A separate job/process must be created to flush the outbox.

5. **reporter_email**: Not stored in `uat_issue`. The functional doc mentions the option but doesn't mandate it. For CLOSED notifications to the reporter, the system relies on identity provider lookup or the outbox pattern.

6. **`closure_evidence_link`**: Added as `VARCHAR2(1000)` on `uat_issue` per the workflow spec (Card: Chiusura). The initial DDL in the functional doc doesn't list it — added for completeness.

7. **`retest_instructions`**: Added as `CLOB` on `uat_issue`. Referenced in SEND_TO_RETEST transition but not in the initial DDL — added for completeness.

## ORDS

8. **User identity**: Simplified via `userName` query parameter. Production should use OAuth2 token introspection or ORDS security modules.

9. **Attachment upload**: The POST endpoint for attachments references `multipart/form-data` but the ORDS handler uses PL/SQL `attachment_add`. In practice, ORDS auto-REST or a custom multipart handler may be needed.

10. **`GET /issues/:id` response format**: Uses standard ORDS query output (items array). The VBCS loadDetail chain expects `response.body.items[0]`.

## VBCS

11. **SOLUTION_TYPE LOV**: Added as a DB-backed LOV (`SOLUTION_TYPE` with SaaS/PaaS) to keep consistency, even though the form uses a radioset.

12. **IMPACT LOV**: Added `IMPACT` LOV type to the seed data for the impactFlags checkboxes. The functional doc lists them inline.

13. **Role-based visibility**: The functional doc specifies role-based button visibility (Tester, Triage, Lead, Admin). The generated VBCS only implements status-based visibility. Role checks should be added via `$application.user.roles` conditions.

14. **"Invia e nuova" button**: Mentioned in section 2.3 for intensive testers. Not implemented in this generation — can be added as a variant of the submit chain.

15. **REQUEST_INFO transition**: Listed as optional in the functional doc. Not implemented in the workflow state machine. Can be added as an additional action.

16. **Quick view "Aging > X giorni"**: Listed as optional. Not implemented as a tab preset.

17. **Oracle Text full-text search**: The search uses simple `LIKE` on title. Oracle Text integration is an evolution.
