/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_confirmResolution
 * Description: Transizione RETEST -> RESOLVED (outcome=PASS).
 * VBCS Binding: confirmResolution (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailConfirmResolution extends ActionChain {

      async run(context) {
        const { $page } = context;
        const wp = $page.variables.workflowPayload;

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postTransition',
          uriParams: { id: $page.variables.issueId },
          body: {
            action: 'CONFIRM_RESOLUTION',
            payload: {
              retestOutcome: 'PASS',
              retestNotes: wp.retestNotes || ''
            }
          }
        });

        if (response.ok) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Risolto',
            message: 'Issue #' + $page.variables.issueId + ' confermata RESOLVED.',
            type: 'confirmation'
          });
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailConfirmResolution;
  }
);
