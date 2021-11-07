# ######################################################################
# Sample Cassandra backup script # # NOTE: This MUST be adapted for and validated in your environment before use!
# ######################################################################

set -e

trap '[ "$?" -eq 0 ] || echo \*\*\* FATAL ERROR \*\*\*' EXIT $?

CASHOST=localhost
CASPORT=7199
CASSANDRA_DATA_DIR=/data/cassandra/data
BACKUP_DIR=/backup/cassandra
BACKUP_DATE=`date +"%Y%m%d_%H%M"`
BACKUP_DATE_WEEK_AGO=`date --date="-7 day" +"%Y%m%d_%H%M"`
BPBACKUP_CMD=/usr/openv/netbackup/bin/bpbackup
DAYS_KEEP=8

nodetool -h $CASHOST -p $CASPORT clearsnapshot
nodetool -h $CASHOST -p $CASPORT snapshot -t $BACKUP_DATE

for line in $(find "${CASSANDRA_DATA_DIR}" -type d -name "${BACKUP_DATE}"); do

  keyspace_name="$(basename "$(dirname "$(dirname "$(dirname "${line}")")")")"

  table_name="$(basename "$(dirname "$(dirname "${line}")")")"

  current_backup_dir=${BACKUP_DIR}/${BACKUP_DATE}/${keyspace_name}/${table_name}

  mkdir -p "${current_backup_dir}"

  cp -a "${line}"/* "${current_backup_dir}"

done

  tar cvfz ${BACKUP_DIR}/${BACKUP_DATE}.tar.gz ${BACKUP_DIR}/${BACKUP_DATE}
  ${BPBACKUP_CMD} ${BACKUP_DIR}/${BACKUP_DATE}.tar.gz
  rm ${BACKUP_DIR}/${BACKUP_DATE_WEEK_AGO}.tar.gz
  rm -rf ${BACKUP_DIR}/${BACKUP_DATE_WEEK_AGO}
  find /backup/cassandra/ -maxdepth 1 -ctime +${DAYS_KEEP} -exec rm -rf {} \;
