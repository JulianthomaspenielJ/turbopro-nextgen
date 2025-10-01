mysqldump -h 8.26.21.206 -u root -p --skip-triggers --no-create-info \
--ignore-table=dbbackup_13_09_2023.tpInventoryLogMaster \
--ignore-table=dbbackup_13_09_2023.SEARCH_engine \
--ignore-table=dbbackup_13_09_2023.tpCuInvoiceLogMaster \
--ignore-table=dbbackup_13_09_2023.TPUsage \
dbbackup_13_09_2023 > dumpall.data
