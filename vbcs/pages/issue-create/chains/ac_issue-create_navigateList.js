/**
 * Page:        issue-create
 * Chain:       ac_issue-create_navigateList
 * Description: Naviga alla lista segnalazioni.
 * VBCS Binding: navigateToList (oj-button oj-action, breadcrumb)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueCreateNavigateList extends ActionChain {

      async run(context) {
        await Actions.navigateToPage(context, {
          page: 'issue-list'
        });
      }
    }

    return AcIssueCreateNavigateList;
  }
);
