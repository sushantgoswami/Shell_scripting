#!/bin/bash
###
# rsync-script_PROD-glpdvlapp788 to DR-glsdvlapp780
##################################################################
############# Name : rsync-script_PROD-to-DR_v2.sh ###############
############# Version_Number 1.0 #################################
#################### Revision ####################################
# version 1.0 Dated 26-Nov-2024
# Revision
# Revision
# Revision
# Revision
######################## Scope ######################
# The script is intended to copy the data from /OTRS_Attachment/ to another server /OTRS_Attachment/
# The script can be setup in the cron
# Set the SERVER_TYPE variable to copy the data from prd-to-dr or dr-to-prd

##################### User Defined Variables #########################
PRD_SERVER=glpdvlapp788
DR_SERVER=glsdvlapp780
SERVER_TYPE=PRD
RSYNC_FOLDER=OTRS_Attachment
RSYNC_USER=root
LOGFILE_PATH=/var/log
LOGFILE=$0
SERVER_NAME=`hostname`
CURRENTDATE=`date | awk '{print $3"-"$2"-"$6}'`
LOG_RETENTION=15

################## Main Script - Do not edit below, use above variables ##################

if [ $SERVER_TYPE == "PRD" ]; then
 SCRIPT_COUNT=$(ps -ef | grep "/usr/bin/rsync -avrp --delete" | grep $RSYNC_FOLDER | wc -l)
 if [ $SCRIPT_COUNT -gt 0 ] ; then
  echo "Rsync is running for /$RSYNC_FOLDER..." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
 else
  echo "Starting rsync PRD to DR" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
  /usr/bin/rsync -avrp --delete /$RSYNC_FOLDER/* $RSYNC_USER@$DR_SERVER:/$RSYNC_FOLDER/ >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
  echo "=== Finished ===" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
 fi
fi

if [ $SERVER_TYPE == "DR" ]; then
 SCRIPT_COUNT=$(ps -ef | grep "/usr/bin/rsync -avrp --delete" | grep $RSYNC_FOLDER | wc -l)
 if [ $SCRIPT_COUNT -gt 0 ] ; then
  echo "Rsync is running for /$RSYNC_FOLDER..." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
 else
  echo "Starting rsync DR to PRD" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
  /usr/bin/rsync -avrp --delete /$RSYNC_FOLDER/* $RSYNC_USER@$PRD_SERVER:/$RSYNC_FOLDER/ >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
  echo "=== Finished ===" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt
 fi
fi

find $LOGFILE_PATH -name "*-$LOGFILE.txt" -mtime +$LOG_RETENTION -exec ls -l {} \; >> $LOGFILE_PATH/$CURRENTDATE-$LOGFILE.txt

################## End Main Script  ##################
