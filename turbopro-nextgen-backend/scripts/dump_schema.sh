mysqldump -h 8.26.21.206 -u root -p --routines -d $1 > $1.sql
