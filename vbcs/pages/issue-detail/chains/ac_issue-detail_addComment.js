/**
 * Page:        issue-detail
 * Chain:       ac_issue-detail_addComment
 * Description: Aggiunge un commento (public/internal) alla issue corrente.
 * VBCS Binding: addComment (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueDetailAddComment extends ActionChain {

      async run(context) {
        const { $page } = context;

        if (!$page.variables.newCommentText) {
          await Actions.fireNotificationEvent(context, {
            summary: 'Validazione',
            message: 'Inserire il testo del commento.',
            type: 'error'
          });
          return;
        }

        var response = await Actions.callRestEndpoint(context, {
          endpoint: 'uat_api_v1/postComments',
          uriParams: { id: $page.variables.issueId },
          body: {
            commentText: $page.variables.newCommentText,
            visibility: $page.variables.newCommentVisibility
          }
        });

        if (response.ok) {
          $page.variables.newCommentText = '';
          await Actions.fireNotificationEvent(context, {
            summary: 'Commento aggiunto',
            message: 'Commento salvato.',
            type: 'confirmation'
          });
          // Refresh comments
          await Actions.fireAction(context, { action: 'loadIssueDetail' });
        }
      }
    }

    return AcIssueDetailAddComment;
  }
);
