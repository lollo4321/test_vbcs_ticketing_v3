/**
 * Page:        issue-list
 * Chain:       ac_issue-list_tabChange
 * Description: Applica preset filtri in base al tab selezionato (quick views).
 * VBCS Binding: onTabChange (oj-tab-bar selection-changed)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListTabChange extends ActionChain {

      async run(context) {
        const { $page } = context;
        const tab = $page.variables.activeTab;

        // Reset filtri
        await Actions.assignVariables(context, {
          filterDomainStream: '',
          filterEnvironment: '',
          filterSolutionType: '',
          filterStatus: [],
          filterSeverity: [],
          filterQ: ''
        });

        switch (tab) {
          case 'tabMine':
            // "Le mie" -> createdBy=currentUser
            // currentUser resolved at runtime via $application.user.userId
            break;

          case 'tabRetest':
            await Actions.assignVariables(context, {
              filterStatus: ['RETEST']
            });
            break;

          case 'tabHighPriority':
            await Actions.assignVariables(context, {
              filterSeverity: ['BLOCKER', 'HIGH'],
              filterStatus: ['NEW', 'TRIAGE', 'IN_PROGRESS', 'SOLUTION_PROPOSED', 'RETEST']
            });
            break;

          default: // tabAll
            break;
        }

        await Actions.fireAction(context, {
          action: 'onFilterChange'
        });
      }
    }

    return AcIssueListTabChange;
  }
);
