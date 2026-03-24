/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_loadDetail
 * Description: Carica i dati della issue, allegati, commenti e storico stati.
 * VBCS Binding: vbEnter (page lifecycle event)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailLoadDetail extends ActionChain {

      async run(context) {
        const { $page } = context;
        const issueId = $page.variables.issueId;

        // Load issue detail
        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/getIssueById',
          uriParams: { id: issueId }
        });

        if (response.ok && response.body.items && response.body.items.length > 0) {
          $page.variables.issue = response.body.items[0];

          // Pre-populate workflow payload from existing data
          var issue = $page.variables.issue;
          $page.variables.workflowPayload.resolutionNotes = issue.resolutionNotes || '';
          $page.variables.workflowPayload.fixVersion = issue.fixVersion || '';
          $page.variables.workflowPayload.fixEnvironment = issue.fixEnvironment || '';
        }

        // Configure data providers with issueId
        $page.variables.attachmentsDataProvider = {
          endpoint: 'uat_api_v1/getAttachments',
          keyAttributes: 'attachmentId',
          uriParameters: { id: issueId }
        };

        $page.variables.commentsDataProvider = {
          endpoint: 'uat_api_v1/getComments',
          keyAttributes: 'commentId',
          uriParameters: { id: issueId }
        };

        $page.variables.statusHistoryDataProvider = {
          endpoint: 'uat_api_v1/getStatusHistory',
          keyAttributes: 'histId',
          uriParameters: { id: issueId }
        };
      }
    }

    return AcIssueDetailLoadDetail;
  }
);
