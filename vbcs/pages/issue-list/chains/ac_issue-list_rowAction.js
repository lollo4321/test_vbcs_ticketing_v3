/**
 * Page:        issue-list
 * Chain:       ac_issue-list_rowAction
 * Description: Naviga al dettaglio della issue selezionata nella tabella.
 * VBCS Binding: onRowAction (oj-table oj-row-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListRowAction extends ActionChain {

      async run(context, params) {
        const issueId = params.item.data.issueId;

        await Actions.navigateToPage(context, {
          page: 'issue-detail',
          params: { issueId: issueId }
        });
      }
    }

    return AcIssueListRowAction;
  }
);
