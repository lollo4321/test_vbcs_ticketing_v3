/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_close
 * Description: Transizione RESOLVED -> CLOSED. Richiede closureReason.
 * VBCS Binding: closeIssue (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailClose extends ActionChain {

      async run(context) {
        const { $page } = context;
        const wp = $page.variables.workflowPayload;

        if (!wp.closureReason) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Validazione',
            message: 'Closure Reason obbligatorio.',
            type: 'error'
          });
          return;
        }

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postTransition',
          uriParams: { id: $page.variables.issueId },
          body: {
            action: 'CLOSE',
            payload: {
              closureReason: wp.closureReason,
              closureEvidenceLink: wp.closureEvidenceLink || ''
            }
          }
        });

        if (response.ok) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Chiuso',
            message: 'Issue #' + $page.variables.issueId + ' chiusa.',
            type: 'confirmation'
          });
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailClose;
  }
);
