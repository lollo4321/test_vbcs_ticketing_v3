/**
 * Page:        issue-create
 * Chain:       ac_issue-create_saveDraft
 * Description: Salva la segnalazione come bozza (status=DRAFT) senza validazioni obbligatorie.
 * VBCS Binding: saveDraft (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueCreateSaveDraft extends ActionChain {

      async run(context) {
        const { $page } = context;
        const issue = $page.variables.issue;

        // Serve almeno il titolo per salvare bozza
        if (!issue.title) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Titolo obbligatorio',
            message: 'Inserire almeno il titolo per salvare la bozza.',
            type: 'error'
          });
          return;
        }

        var payload = Object.assign({}, issue);
        payload.reproducible = $page.variables.reproducibleBool ? 'Y' : 'N';
        payload.impactFlags = $page.variables.impactFlagsList.join(',');
        payload.status = 'DRAFT';

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postIssues',
          body: payload
        });

        if (response.ok) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Bozza salvata',
            message: 'Segnalazione #' + response.body.data.issueId + ' salvata come bozza.',
            type: 'confirmation'
          });
        }
      }
    }

    return AcIssueCreateSaveDraft;
  }
);
