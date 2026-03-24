/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_sendToRetest
 * Description: Transizione SOLUTION_PROPOSED -> RETEST. Assegna owner use case automaticamente.
 * VBCS Binding: sendToRetest (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailSendToRetest extends ActionChain {

      async run(context) {
        const { $page } = context;
        const wp = $page.variables.workflowPayload;

        // Warning se istruzioni vuote
        if (!wp.retestInstructions) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Attenzione',
            message: 'Istruzioni re-test vuote. Continuare comunque?',
            type: 'warning'
          });
        }

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postTransition',
          uriParams: { id: $page.variables.issueId },
          body: {
            action: 'SEND_TO_RETEST',
            payload: {
              retestInstructions: wp.retestInstructions
            }
          }
        });

        if (response.ok) {
          var retestAssignedTo = response.body.data.retestAssignedTo || 'N/A';
          await Actions.fireNotificationEvent(context, {
            summary: 'Inviato in re-test',
            message: 'Issue #' + $page.variables.issueId + ' in RETEST. Assegnato a: ' + retestAssignedTo,
            type: 'confirmation'
          });
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailSendToRetest;
  }
);
