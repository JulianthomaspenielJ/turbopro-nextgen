if [ -z "$1" ]; then
  echo "Usage: $0 <dump-file>"
  exit 1
fi

mysql -u root -p <<!
drop database if exists nextgen;
CREATE DATABASE nextgen CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
SET GLOBAL log_bin_trust_function_creators = 1;
quit
!

sed -e 's/row varchar/`row` varchar/' -e 's/,row,/,`row`,/g' -e 's/@`%`/@`localhost`/' $1 > $1.out
mysql -u root -p nextgen < $1.out


