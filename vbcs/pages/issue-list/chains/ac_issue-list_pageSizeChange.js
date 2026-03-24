/**
 * Page:        issue-list
 * Chain:       ac_issue-list_pageSizeChange
 * Description: Aggiorna pageSize, resetta a page 1 e ricarica la tabella.
 * VBCS Binding: onPageSizeChange (oj-select-single value-changed)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListPageSizeChange extends ActionChain {

      async run(context) {
        await Actions.assignVariables(context, {
          page: 1
        });

        await Actions.fireAction(context, {
          action: 'onFilterChange'
        });
      }
    }

    return AcIssueListPageSizeChange;
  }
);
