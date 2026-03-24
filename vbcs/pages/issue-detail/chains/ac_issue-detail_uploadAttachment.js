/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_uploadAttachment
 * Description: Upload allegato alla issue corrente.
 * VBCS Binding: uploadAttachment (oj-file-picker oj-select)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailUploadAttachment extends ActionChain {

      async run(context, params) {
        const { $page } = context;
        const files = params.detail.files;

        if (!files || files.length === 0) return;

        for (var i = 0; i < files.length; i++) {
          await Actions.callRestEndpoint(context, {
            endpoint: 'uat_api_v1/postAttachments',
            uriParams: { id: $page.variables.issueId },
            body: files[i],
            contentType: 'multipart/form-data'
          });
        }

        await Actions.fireNotificationEvent(context, {
          summary: 'Upload completato',
          message: files.length + ' file caricati.',
          type: 'confirmation'
        });

        // Refresh attachments
        await Actions.fireAction(context, { action: 'loadIssueDetail' });
      }
    }

    return AcIssueDetailUploadAttachment;
  }
);
