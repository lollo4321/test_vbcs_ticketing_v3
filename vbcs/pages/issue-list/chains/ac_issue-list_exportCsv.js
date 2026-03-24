/**
 * Page:        issue-list
 * Chain:       ac_issue-list_exportCsv
 * Description: Esporta i dati correnti della tabella in CSV client-side.
 * VBCS Binding: exportCsv (oj-button oj-action)
 */
define(['vb/action/actionChain', 'vb/action/actions'],
  function (ActionChain, Actions) {
    'use strict';

    class AcIssueListExportCsv extends ActionChain {

      async run(context) {
        const { $page } = context;

        const headers = ['ID', 'Titolo', 'Stream', 'Env', 'Type', 'Severity', 'Status', 'Assignee', 'Updated'];
        const fields = ['issueId', 'title', 'domainStream', 'environment', 'recordType', 'severity', 'status', 'assignee', 'updatedOn'];

        // Fetch current page data from the data provider
        const dp = $page.variables.issueListDataProvider;
        let csvContent = headers.join(';') + '\n';

        const result = await dp.fetchFirst({ size: -1 });
        if (result && result.value && result.value.data) {
          result.value.data.forEach(function (row) {
            const line = fields.map(function (f) {
              const val = row[f] != null ? String(row[f]) : '';
              return '"' + val.replace(/"/g, '""') + '"';
            });
            csvContent += line.join(';') + '\n';
          });
        }

        // Download
        const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'segnalazioni_uat_' + new Date().toISOString().slice(0, 10) + '.csv';
        a.click();
        URL.revokeObjectURL(url);
      }
    }

    return AcIssueListExportCsv;
  }
);
