/**
 * Page:        issue-list
 * Chain:       ac_issue-list_navigateCreate
 * Description: Naviga alla pagina di creazione nuova segnalazione.
 * VBCS Binding: navigateToCreate (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListNavigateCreate extends ActionChain {

      async run(context) {
        await Actions.navigateToPage(context, {
          page: 'issue-create'
        });
      }
    }

    return AcIssueListNavigateCreate;
  }
);
