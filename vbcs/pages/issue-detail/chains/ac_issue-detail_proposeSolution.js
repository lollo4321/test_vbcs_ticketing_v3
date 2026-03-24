/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_proposeSolution
 * Description: Transizione IN_PROGRESS -> SOLUTION_PROPOSED. Richiede resolutionNotes e fixVersion (PaaS).
 * VBCS Binding: proposeSolution (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailProposeSolution extends ActionChain {

      async run(context) {
        const { $page } = context;
        const wp = $page.variables.workflowPayload;

        if (!wp.resolutionNotes) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Validazione',
            message: 'Resolution Notes obbligatorio.',
            type: 'error'
          });
          return;
        }

        if ($page.variables.issue.solutionType === 'PaaS' && !wp.fixVersion) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Validazione',
            message: 'Fix Version obbligatorio per PaaS.',
            type: 'error'
          });
          return;
        }

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postTransition',
          uriParams: { id: $page.variables.issueId },
          body: {
            action: 'PROPOSE_SOLUTION',
            payload: {
              resolutionNotes: wp.resolutionNotes,
              fixVersion: wp.fixVersion,
              fixEnvironment: wp.fixEnvironment
            }
          }
        });

        if (response.ok) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Soluzione proposta',
            message: 'Issue #' + $page.variables.issueId + ' aggiornata a SOLUTION_PROPOSED.',
            type: 'confirmation'
          });
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailProposeSolution;
  }
);
