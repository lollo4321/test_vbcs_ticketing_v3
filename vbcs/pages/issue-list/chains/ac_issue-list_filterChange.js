/**
 * Page:        issue-list
 * Chain:       ac_issue-list_filterChange
 * Description: Ricarica DataProvider issues applicando i filtri correnti come query params.
 * VBCS Binding: onFilterChange (oj-select-single/many value-changed, oj-input-text value-changed)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListFilterChange extends ActionChain {

      async run(context) {
        const { $page } = context;

        const params = {};
        if ($page.variables.filterDomainStream) {
          params.domainStream = $page.variables.filterDomainStream;
        }
        if ($page.variables.filterEnvironment) {
          params.environment = $page.variables.filterEnvironment;
        }
        if ($page.variables.filterSolutionType) {
          params.solutionType = $page.variables.filterSolutionType;
        }
        if ($page.variables.filterStatus && $page.variables.filterStatus.length > 0) {
          params.status = $page.variables.filterStatus.join(',');
        }
        if ($page.variables.filterSeverity && $page.variables.filterSeverity.length > 0) {
          params.severity = $page.variables.filterSeverity.join(',');
        }
        if ($page.variables.filterQ && $page.variables.filterQ.length >= 3) {
          params.q = $page.variables.filterQ;
        }

        params.page = 1;
        params.pageSize = $page.variables.pageSize;
        params.sort = $page.variables.sortField;

        await Actions.resetVariables(context, {
          variables: { page: 1 }
        });

        await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/getIssues',
          uriParams: params
        });
      }
    }

    return AcIssueListFilterChange;
  }
);
