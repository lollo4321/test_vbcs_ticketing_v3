/**
 * Page:        issue-create
 * Chain:       ac_issue-create_domainStreamChange
 * Description: Ricarica la LOV use cases filtrata per il domainStream selezionato.
 * VBCS Binding: onDomainStreamChange (oj-select-single value-changed)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueCreateDomainStreamChange extends ActionChain {

      async run(context) {
        const { $page } = context;
        const domainStream = $page.variables.issue.domainStream;

        // Reset use case selection
        $page.variables.issue.useCaseCode = '';

        // Reload use cases data provider with filter
        await Actions.resetVariables(context, {
          variables: {
            lovUseCases: {
              endpoint: 'uat_api_v1/getUsecases',
              keyAttributes: 'useCaseCode',
              uriParameters: domainStream ? { domainStream: domainStream, enabled: 'Y' } : {}
            }
          }
        });
      }
    }

    return AcIssueCreateDomainStreamChange;
  }
);
