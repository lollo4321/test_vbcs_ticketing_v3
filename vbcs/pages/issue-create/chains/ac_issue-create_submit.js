/**
 * Page:        issue-create
 * Chain:       ac_issue-create_submit
 * Description: Valida il form e invia la segnalazione (POST /issues). On success naviga a Detail.
 * VBCS Binding: submitIssue (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueCreateSubmit extends ActionChain {

      async run(context) {
        const { $page } = context;
        const issue = $page.variables.issue;

        // Client-side validazioni obbligatorie
        const required = ['solutionType', 'applicationModule', 'environment', 'domainStream',
                          'recordType', 'severity', 'title', 'expectedBehavior',
                          'actualBehavior', 'stepsToReproduce'];
        const missing = required.filter(function (f) { return !issue[f]; });

        if (missing.length > 0) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Campi obbligatori mancanti',
            message: 'Compilare: ' + missing.join(', '),
            type: 'error'
          });
          return;
        }

        // Validazione: se non riproducibile, notes obbligatorio
        if (!$page.variables.reproducibleBool && !issue.notes) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Note aggiuntive obbligatorie',
            message: 'Se il bug non è riproducibile, compilare le note aggiuntive.',
            type: 'error'
          });
          return;
        }

        // Validazione: recordType=DATA -> transactionRef consigliato
        if (issue.recordType === 'DATA' && !issue.transactionRef) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Riferimento transazione consigliato',
            message: 'Per record di tipo "Dato", compilare il riferimento transazione.',
            type: 'warning'
          });
        }

        // Warning severity alta senza allegati
        if ((issue.severity === 'BLOCKER' || issue.severity === 'HIGH') &&
            $page.variables.selectedFiles.length === 0) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Allegato consigliato',
            message: 'Per severity Blocker/High, allegare screenshot o log.',
            type: 'warning'
          });
        }

        // Prepara payload
        var payload = Object.assign({}, issue);
        payload.reproducible = $page.variables.reproducibleBool ? 'Y' : 'N';
        payload.impactFlags = $page.variables.impactFlagsList.join(',');

        // POST /issues
        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postIssues',
          body: payload
        });

        if (response.ok) {
          var issueId = response.body.data.issueId;

          // Upload allegati
          for (var i = 0; i < $page.variables.selectedFiles.length; i++) {
            var file = $page.variables.selectedFiles[i];
            var formData = new FormData();
            formData.append('file', file, file.name);
            await Actions.callRestEndpoint(context, {
              endpoint: 'uat_api_v1/postAttachments',
              uriParams: { id: issueId },
              body: formData,
              contentType: 'multipart/form-data'
            });
          }

          await Actions.fireNotificationEvent(context, {
            summary: 'Segnalazione inviata',
            message: 'Segnalazione #' + issueId + ' creata con successo.',
            type: 'confirmation'
          });

          await Actions.navigateToPage(context, {
            page: 'issue-detail',
            params: { issueId: issueId }
          });
        }
      }
    }

    return AcIssueCreateSubmit;
  }
);
