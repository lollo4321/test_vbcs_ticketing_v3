/**
 * Page:        issue-list
 * Chain:       ac_issue-list_resetFilters
 * Description: Reset tutti i filtri ai valori di default e ricarica la tabella.
 * VBCS Binding: resetFilters (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListResetFilters extends ActionChain {

      async run(context) {
        await Actions.assignVariables(context, {
          filterDomainStream: '',
          filterEnvironment: '',
          filterSolutionType: '',
          filterStatus: [],
          filterSeverity: [],
          filterQ: '',
          activeTab: 'tabAll',
          page: 1
        });

        await Actions.fireAction(context, {
          action: 'onFilterChange'
        });
      }
    }

    return AcIssueListResetFilters;
  }
);
