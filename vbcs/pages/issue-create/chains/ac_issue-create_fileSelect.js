/**
 * Page:        issue-create
 * Chain:       ac_issue-create_fileSelect
 * Description: Gestisce la selezione di file dal file picker e li aggiunge alla lista selectedFiles.
 * VBCS Binding: onFileSelect (oj-file-picker oj-select)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueCreateFileSelect extends ActionChain {

      async run(context, params) {
        const { $page } = context;
        const files = params.detail.files;

        if (files && files.length > 0) {
          var current = $page.variables.selectedFiles.slice();
          for (var i = 0; i < files.length; i++) {
            current.push(files[i]);
          }
          $page.variables.selectedFiles = current;
        }
      }
    }

    return AcIssueCreateFileSelect;
  }
);
