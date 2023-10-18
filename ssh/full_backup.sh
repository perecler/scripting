#!/bin/bash
# full_backup.sh
# Full Data Backup
#
# Directories to copy, excluding the initial /
DIRS="etc home var"
# Destination directory for the backup
BACKUPDIR="/backups"
# Backup file name
TODAY=$(date +"%Y-%m-%d")
FILE="full_$TODAY.tar.gz"
# Number of days to keep old backups
OLD_BACKUPS=14
#
# Start message
echo "$(date +%X) Start of the backup procedure."
#
# Check if the 'tar' tool is available
TAR=$(which tar)
if [ -z "$TAR" ]; then
echo "Error: 'tar' was not found."
exit 1
fi
# Check if the backup directory exists
if [ ! -d $BACKUPDIR ] ; then
echo "Error: $BACKUPDIR was not found."
exit 1
fi
# Perform the backup
$TAR -zcPf $BACKUPDIR/$FILE -C / $DIRS
if [ $? -ne 0 ]
then
# Tar operation has failed
echo "Error: An error occurred while creating the backup."
exit 1
fi
# Delete backups older than $OLD_BACKUPS days
find $BACKUPDIR/ -name "*.gz" -type f -mtime +$OLD_BACKUPS -delete
if [ $? -ne 0 ]
then
echo "Error: Deleting old backups."
exit 1
fi
# Completion message
echo "$(date +%X) Successful completion of the backup."
exit 0

# Don't forget to create a cron job for this event, for example daily at 2:00 AM
# with log file:
# 0 2 * * * /usr/local/bin/completa.sh >>logfile 2>>logfile
#
# withous log file:
#0 2 * * * /usr/local/bin/completa.sh
