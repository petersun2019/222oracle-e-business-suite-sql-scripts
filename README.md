# Oracle E-Business Suite SQL Scripts Library
## Intro

This is a collection of SQL scripts I've built up since starting to work with Oracle in 2003.

## Download

You can download the scripts via [this link](https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts/archive/refs/heads/main.zip)

## ⚠️Disclaimer

Please treat the scripts with caution!

I work supporting Cloud these days, so while I was tidying them up, as I no longer spend a lot of time supporting EBS systems, I can't confirm for certain that all of the scripts work perfectly and without error.

They should work as a starting point, and might help people out which is why I'm putting them on Github.

However - if they break your systems or do other strange and mysterious things, I want to put an official line here such as the [disclaimer on oracle-base](https://oracle-base.com/misc/site-info#copyright):

> All information is offered in good faith and in the hope that it may be of use, but is not guaranteed to be correct, up to date or suitable for any particular purpose. I accept no liability in respect of these scripts or their use.

I've put these scripts online in case they are of use to others, but please use them with caution, and test them thoroughly.

They are mostly SELECT scripts, but there are a few APIs used for user account admin so there is scope for making updates, hence the need to make sure you test them and are comfortable with using them.

If you find any errors with joins etc. please let me know as per the `Issues` heading below.

## Issues

If you have any problems with the scripts, [please log an issue](https://github.com/owlowe/oracle-e-business-suite-sql-scripts/issues) or get in touch using [this contact form](https://jimpix.co.uk/contact/).

## Contents


    +---ap (Accounts Payable)
    |
    |       ap-checks-all.sql
    |       ap-expenses.sql
    |       ap-invoices-holds.sql
    |       ap-invoices-interface-table.sql
    |       ap-invoices-link-to-journal-and-sla.sql
    |       ap-invoices-locked.sql
    |       ap-invoices-scheduled-payments.sql
    |       ap-invoices-tax-info.sql
    |       ap-invoices-tax-withholding.sql
    |       ap-invoices.sql
    |       ap-payment-groups.sql
    |       ap-payment-methods.sql
    |       ap-payment-terms.sql
    |       ap-payments.sql
    |       ap-suppliers-bank-accounts.sql
    |       ap-suppliers-xml-gateway-trading-partners.sql
    |       ap-suppliers.sql
    |       ap-trial-balance.sql
    |       ap_accounting_entries_11i.sql
    |       
    +---ar (Accounts Receivable)
    |
    |       ar-applications.sql
    |       ar-bank-account-owners.sql
    |       ar-batch-sources.sql
    |       ar-customers-bank-accounts.sql
    |       ar-customers-contacts.sql
    |       ar-customers.sql
    |       ar-interface-lines.sql
    |       ar-locations.sql
    |       ar-memo-lines.sql
    |       ar-payment-terms.sql
    |       ar-receipt-methods.sql
    |       ar-receipts.sql
    |       ar-receivables-activities.sql
    |       ar-salespersons.sql
    |       ar-statement-cycles.sql
    |       ar-system-settings.sql
    |       ar-transaction-types.sql
    |       ar-transactions-tax-value.sql
    |       ar-transactions.sql
    |       ar-trx-bal-summary.sql
    |       
    +---ce (Cash Management)
    |
    |       ce-internal-bank-accounts.sql
    |       ce-reversed-transactions-matched-to-bank-accounts.sql
    |       ce-statements.sql
    |       
    +---dba (DBA)
    |
    |       db-details.sql
    |       dba-check-ota-running.sql
    |       dba-file-versions.sql
    |       dba-invalid-objects.sql
    |       dba-locks-and-blocks.sql
    |       dba-module-patchset-levels-and-database-version.sql
    |       dba-nodes.sql
    |       dba-notification-mailer.sql
    |       dba-patch-installs.sql
    |       dba-performance-checking.sql
    |       dba-schema-browser.sql
    |       dba-session-monitor.sql
    |       dba-source.sql
    |       dba-sql-bind-capture.sql
    |       dba-sqlarea.sql
    |       dba-stats-table.sql
    |       dba-tablespace.sql
    |       dba.sql
    |       
    +---fa (Fixed Assets)
    |
    |       fa-assets.sql
    |       fa-mass-additions.sql
    |       
    +---gl (General Ledger)
    |
    |       gl-application-accounting-definitions.sql
    |       gl-balances.sql
    |       gl-chart-of-accounts.sql
    |       gl-code-combinations.sql
    |       gl-cross-validation-rules.sql
    |       gl-daily-rates.sql
    |       gl-data-access-sets.sql
    |       gl-fsg-reports.sql
    |       gl-hierarchy.sql
    |       gl-interface.sql
    |       gl-journal-approvals.sql
    |       gl-journal-categories-and-sources.sql
    |       gl-journals.sql
    |       gl-periods.sql
    |       gl-security-rules.sql
    |       gl-segment-values.sql
    |       gl-sla-sum-and-gl-sum.sql
    |       gl-trial-balance.sql
    |       gl-web-adi.sql
    |       gl-xla-accounting-data.sql
    |       
    +---hr (HR)
    |
    |       hr-addresses.sql
    |       hr-business-groups.sql
    |       hr-hr-records.sql
    |       hr-legislations.sql
    |       hr-operating-units.sql
    |       hr-organizations.sql
    |       hr-position-hierarchy.sql
    |       
    +---iex (Advanced Collections)
    |
    |       iex-admin.sql
    |       iex-collectors.sql
    |       iex-customers.sql
    |       iex-delinquencies.sql
    |       iex-notes.sql
    |       iex-promises.sql
    |       iex-strategies.sql
    |       iex-tasks.sql
    |       iex-work-items-strategies.sql
    |       
    +---inv (Inventory)
    |
    |       inv-accounting-periods.sql
    |       inv-assignment-sets.sql
    |       inv-errored-transactions.sql
    |       inv-items-locators.sql
    |       inv-items.sql
    |       inv-orgs.sql
    |       inv-requisitions.sql
    |       inv-resps-linked-to-inv-orgs.sql
    |       inv-sub-inventories.sql
    |       inv-transactions.sql
    |       inv-units-of-measure.sql
    |       
    +---pa (Projects)
    |
    |       pa-agreements.sql
    |       pa-asset-info.sql
    |       pa-auto-accounting-lookups.sql
    |       pa-auto-accounting-rules.sql
    |       pa-bc-balances.sql
    |       pa-bc-packets.sql
    |       pa-budget-entry-methods.sql
    |       pa-budgets.sql
    |       pa-burden-shedules.sql
    |       pa-classifications.sql
    |       pa-commitments.sql
    |       pa-customers.sql
    |       pa-deliveravbles.sql
    |       pa-events.sql
    |       pa-expenditure-types.sql
    |       pa-expenditures.sql
    |       pa-finances-against-revenues-and-invoices.sql
    |       pa-hierarchy.sql
    |       pa-invoices.sql
    |       pa-key-members.sql
    |       pa-lookups.sql
    |       pa-organizations.sql
    |       pa-periods.sql
    |       pa-project-templates.sql
    |       pa-project-types.sql
    |       pa-projects-and-tasks.sql
    |       pa-revenue.sql
    |       pa-service-types.sql
    |       pa-transaction-controls.sql
    |       pa-transaction-sources.sql
    |       pa-transactions-interface.sql
    |       
    +---po (Purchasing)
    |
    |       po-approval-groups.sql
    |       po-approval-history.sql
    |       po-approval-workflow-errors.sql
    |       po-autocreate-report.sql
    |       po-basic-housekeeping-report.sql
    |       po-blanket-purchase-agreements.sql
    |       po-buyers.sql
    |       po-categories.sql
    |       po-change-requests.sql
    |       po-commodities.sql
    |       po-contract-purchase-agreements.sql
    |       po-counts.sql
    |       po-e-commerce-gateway-mappings.sql
    |       po-get-active-encumbrance.sql
    |       po-locations.sql
    |       po-purchase-orders-call-off-orders.sql
    |       po-purchase-orders-no-workflow.sql
    |       po-purchase-orders-sqls-for-sr.sql
    |       po-purchase-orders.sql
    |       po-receipts.sql
    |       po-requisitions-created-by-requisition-import.sql
    |       po-requisitions-interface.sql
    |       po-requisitions-links-to-inv-items.sql
    |       po-requisitions-preparer-vs-requester.sql
    |       po-requisitions-purchase-orders-join.sql
    |       po-requisitions-sqls-for-service-request.sql
    |       po-requisitions-system-saved-requisitions.sql
    |       po-requisitions-to-po-timings.sql
    |       po-requisitions.sql
    |       po-summary-details-ordered-receipted-billed.sql
    |       po-xml-po-errors.sql
    |       pos-supplier-registrations.sql
    |       
    +---sa (SysAdmin)
    |
    |       sa-alerts.sql
    |       sa-ame.sql
    |       sa-api-resp-add-end-date.sql
    |       sa-api-resp-add.sql
    |       sa-api-resp-remove-end-date.sql
    |       sa-api-user-add-end-date.sql
    |       sa-api-user-remove-end-date.sql
    |       sa-api-user-reset-pwd.sql
    |       sa-attachments.sql
    |       sa-audits.sql
    |       sa-bank-account-ownership-checking.sql
    |       sa-business-events.sql
    |       sa-concurrent-manager-queries.sql
    |       sa-concurrent-program-incompatibilities.sql
    |       sa-concurrent-requests-diag-sql.sql
    |       sa-concurrent-requests-inc-queue-and-actions.sql
    |       sa-concurrent-requests-params.sql
    |       sa-concurrent-requests-scheduled.sql
    |       sa-concurrent-requests.sql
    |       sa-connect-by-example.sql
    |       sa-core-apps-top-ten-linked-to-resps.sql
    |       sa-flexfields-descriptive.sql
    |       sa-flexfields-key.sql
    |       sa-flexfields-validation.sql
    |       sa-fnd-debug.sql
    |       sa-folders.sql
    |       sa-forms.sql
    |       sa-functional-administrator-grants.sql
    |       sa-invalid-characters.sql
    |       sa-iproc-favourite-charge-accounts.sql
    |       sa-locations.sql
    |       sa-logins-and-sessions.sql
    |       sa-lookups.sql
    |       sa-menu-function-exclusions.sql
    |       sa-menus-and-functions.sql
    |       sa-notifications.sql
    |       sa-operating-units.sql
    |       sa-personalizations-forms.sql
    |       sa-personalizations-oaf.sql
    |       sa-profiles.sql
    |       sa-r12-navigator-favourites.sql
    |       sa-report-repository-tables.sql
    |       sa-request-groups.sql
    |       sa-request-set-attempt.sql
    |       sa-responsibilities-with-particular-function.sql
    |       sa-responsibilities-with-particular-menu.sql
    |       sa-responsibilities.sql
    |       sa-spool-example.sql
    |       sa-staff-approval-limits.sql
    |       sa-user-accounts-hr-records.sql
    |       sa-vacation-rules.sql
    |       sa-value-sets.sql
    |       sa-workflows-errors.sql
    |       sa-workflows.sql
    |       
    +---xdo (XML Publisher)
    |
    |       xdo-templates.sql
    |       
    +---xla (Subledger Accounting)
    |
    |       01-xla-transaction-entities.sql
    |       02-xla-ae-headers.sql
    |       03-xla-events.sql
    |       04-xla-ae-lines.sql
    |       05-xla-accounting-errors.sql
    |       06-xla-all-joined.sql
    |       xla-entity-id-mappings.sql
    |       xla-linked-to-sub-ledger-transactions.sql
    |       
    +---zx (Tax)
    |
    |       zx-customer-and-supplier-tax-registrations.sq.sql
    |       zx.sql
    |       
    \---_misc (Miscellaneous)
    |
            misc-count-volumes-group-by-rollup.sql
            misc-volumes.sql
