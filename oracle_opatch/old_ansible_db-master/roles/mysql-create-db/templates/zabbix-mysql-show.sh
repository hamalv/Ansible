#!/bin/sh
# Script to generate file and parse output for mysql SHOW GLOBAL STATUS ; SHOW GLOBAL VARIABLES ; SHOW SLAVE STATUS
# Usage: zabbix_mysql_show {STATUS|VARIABLE|SLAVE} item [dbname]
 
SOURCE=$1
CHECK=$2
DB=${3:-"mysql"}
TMPFILE="/tmp/zabbix_mysql_showglobal_"$SOURCE"_"$DB".txt"
DELIMITER=""
 
MYSQL="sudo -u zabbix /usr/bin/mysql --login-path=zabbix_mon --connect-timeout 10"
EGREP="/bin/egrep -w"
AWK="/usr/bin/awk"
RM="/bin/rm -f"
 
if [ ! -f  $TMPFILE ]
then
    touch $TMPFILE
fi
 
AGE=$(($(date +%s)-$(date -r $TMPFILE +%s)))
 
if [ $AGE -gt 100 ]
then
  if [ $SOURCE == SLAVE ]
  then
        RET=$($MYSQL -e "SHOW SLAVE STATUS\G" $DB &> $TMPFILE.tmp)
        DELIMITER=" -F: "
  else
        RET=$($MYSQL -e "SHOW GLOBAL $SOURCE;" $DB &> $TMPFILE.tmp)
  fi
  mv $TMPFILE.tmp $TMPFILE
fi
 
CHECK_ITEM=`$EGREP $CHECK $TMPFILE | $AWK $DELIMITER '{ print $2 }'`   
 
#Convert Yes/No values to numeric 1/0
if [ "$CHECK_ITEM" == "Yes" ]; then CHECK_ITEM=1
elif [ "$CHECK_ITEM" == " Yes" ]; then CHECK_ITEM=1
elif [ "$CHECK_ITEM" == "No" ]; then CHECK_ITEM=0
elif [ "$CHECK_ITEM" == " No" ]; then CHECK_ITEM=0
fi
 
echo "$CHECK_ITEM"
