/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_navigateList
 * Description: Naviga alla lista segnalazioni.
 * VBCS Binding: navigateToList (breadcrumb, back button)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailNavigateList extends ActionChain {

      async run(context) {
        await Actions.navigateToPage(context, {
          page: 'issue-list'
        });
      }
    }

    return AcIssueDetailNavigateList;
  }
);
