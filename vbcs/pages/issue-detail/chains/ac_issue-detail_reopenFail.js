/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_reopenFail
 * Description: Transizione RETEST -> IN_PROGRESS (outcome=FAIL). Richiede retestNotes.
 * VBCS Binding: reopenFail (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailReopenFail extends ActionChain {

      async run(context) {
        const { $page } = context;
        const wp = $page.variables.workflowPayload;

        if (!wp.retestNotes) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Validazione',
            message: 'Note esito obbligatorie in caso FAIL.',
            type: 'error'
          });
          return;
        }

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postTransition',
          uriParams: { id: $page.variables.issueId },
          body: {
            action: 'REOPEN_FAIL',
            payload: {
              retestOutcome: 'FAIL',
              retestNotes: wp.retestNotes
            }
          }
        });

        if (response.ok) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Riaperto',
            message: 'Issue #' + $page.variables.issueId + ' riaperta (FAIL) -> IN_PROGRESS.',
            type: 'confirmation'
          });
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailReopenFail;
  }
);
