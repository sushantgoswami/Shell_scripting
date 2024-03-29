#!/bin/bash
############# Name : system_status.sh ###############
############# Version_Number 0.01 #############
#################### Revision ######################
# version 0.01 written by Sushant Goswami Dated 25-apr-2018
# Revision
# Revision
# Revision
# Revision
######################## Scope ######################
# The script is intended to check top 5 cpu and memory process, it also monitors the ram utilisation, it is needed to be set by cron
# example */5 * * * * /opt/system_status.sh
# SERVER_TYPE can be DMZ or NORMAL
##################### User Defined Variables #########################
ZONE=ALL_ZONE
EMAIL_SEND=1
PRIMARY_EMAIL=goswami_sushant@network.lilly.com
SECONDARY_EMAIL=karthick_manivannan@network.lilly.com
PRIMARY_MAIL_ENABLE=1
SECONDARY_MAIL_ENABLE=0
NAS_SEND=1
NASSERVER=uxwebprd.am.lilly.com
NASDIR=/opt/status_report
TARGETDIR=/opt/status_report
WORKDIR=/tmp
LOGDIR=log
LOGFILE=system_status.log
REPORT_HOUR=2354
SERVER_TYPE=NORMAL
LOCAL_STATUS_REPO=/opt/status_report
############## Pre Fixed Variables ##############################
SERVER_NAME=`hostname`
CURRENTDATE=`date | awk '{print $3"-"$2"-"$6}'`
CURRENTTIMESTAMP=`date | awk '{print $4}' | sed '$ s/:/./g'`
CURRENT_HOUR=`date | awk '{print $4}' | awk -F ":" '{print $1$2}'`
###################### Help Menu ##########################################
if [ -z $1 ]; then
 echo "(MSG 000): No arguments passed, continuing to regular task" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
else
 if [ $1 == "-help" ]; then
  echo "(MSG HELP): The script is intended to check top 5 cpu and memory process, it also monitors the ram utilisation, it is needed to be set by cron"
  exit 0;
 fi
fi
######################## Duplicate instance check ######################################
DUPLICATE_INSTANCE=2
DUPLICATE_INSTANCE=`ps -ef | grep system_status.sh | grep -v grep | wc -l`
if [ $DUPLICATE_INSTANCE -ge 3 ]; then
 echo "(MSG 000): Duplicate instance found, .. exiting." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
 exit 0;
fi
#################### Do not edit below this line, use variables above ###########################################
if [ ! -d /$WORKDIR/$LOGDIR ]; then
 mkdir -p /$WORKDIR/$LOGDIR
fi
#################### Local Repo check ############################
if [ ! -d $LOCAL_STATUS_REPO ] && [ $SERVER_TYPE == DMZ ]; then
 echo "(MSG 000): Local repo is not available. However, Server seems DMZ, .. exiting." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
 if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
  echo "System_status script on $SERVER_NAME, Local repo is not available. Please check" | mailx -s "Error: Performance report on $SERVER_NAME" -r reporter@$SERVER_NAME.am.lilly.com $PRIMARY_EMAIL
 fi
 exit 0;
fi
if [ -d $LOCAL_STATUS_REPO ] && [ $SERVER_TYPE == DMZ ]; then
 DEVICE=`df -Phl $LOCAL_STATUS_REPO | tail -1 | awk '{print $1}'`
 if [ $DEVICE == /dev/mapper/rootvg-status_report_lv ]; then
  echo "Local device for reports is prperly mounted" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
 else
  echo "Local device for reports is not prperly mounted" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
  exit 0;
 fi
fi
####################
echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt
echo "(MSG 001): Below top 10 CPU process" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt
ps aux | sort -k 3 -rn | head -10 | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt
echo "(MSG 002): Below top 10 MEMORY process" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt
ps aux | sort -k 4 -rn | head -10 | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt
echo "(MSG 003): Below is free command output" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt
free | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt
echo "(MSG 003): Below is the Fetched D state processes" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt
ps aux | grep " D " | grep -v grep | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt
echo "(MSG 004): Below is the Fetched vmstat status" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt
vmstat 1 5 | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt
echo "(MSG 005): Below is the io status" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt
KERNEL=`uname -r | cut -d "." -f 1,2`
if [ $KERNEL == "2.6" ]; then
iostat -n 1 2 | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt
fi
if [ $KERNEL == "3.10" ]; then
nfsiostat 1 2 | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt
fi

echo "=================================================================================================================" >> $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt
echo "(MSG 006): Below is the process count for users" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt
ps -elfT | awk '{print $3}'  | sort | uniq -c | awk '{print $2, " ", $1}'  | column -t  | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt

#################### Mailing report ####################
if [ $CURRENT_HOUR -gt $REPORT_HOUR ] && [ $EMAIL_SEND == 1 ] && [ $CURRENT_HOUR -lt `expr $REPORT_HOUR + 5` ]; then
 if [ $PRIMARY_MAIL_ENABLE == 1 ]; then
  echo "Performance report on $SERVER_NAME" | mailx -s "Performance report on $SERVER_NAME" -r reporter@$SERVER_NAME.am.lilly.com -a $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt $PRIMARY_EMAIL
 fi
 if [ $SECONDARY_MAIL_ENABLE == 1 ]; then
  echo "Performance report on $SERVER_NAME" | mailx -s "Performance report on $SERVER_NAME" -r reporter@$SERVER_NAME.am.lilly.com -a $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt -a $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt  $SECONDARY_EMAIL
 fi
fi
################# copy report to NAS ###################
if [ $CURRENT_HOUR -gt $REPORT_HOUR ] && [ $EMAIL_SEND == 1 ] && [ $CURRENT_HOUR -lt `expr $REPORT_HOUR + 5` ] && [ $SERVER_TYPE != DMZ ]; then
 if [ -d $TARGETDIR ]; then
  echo "(MSG 007): $TARGETDIR directory exist on server" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
 else
  mkdir -p $TARGETDIR
 fi
 /usr/bin/timeout 2s mount $NASSERVER:$NASDIR $TARGETDIR
 MOUNTPOINT=`df -Ph $TARGETDIR | grep $NASSERVER | awk '{print $1}'`
 if [ -z $MOUNTPOINT ]; then
  echo "(MSG 008): NAS filesystem is unable to mount" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
  echo "The NASserver is not mounting in $SERVER_NAME" | mailx -s "The NASserver is not mounting in $SERVER_NAME" -r reporter@$SERVER_NAME.am.lilly.com $PRIMARY_EMAIL
  echo "The NASserver is not mounting in $SERVER_NAME" | mailx -s "The NASserver is not mounting in $SERVER_NAME" -r reporter@$SERVER_NAME.am.lilly.com $SECONDARY_EMAIL
 else
  if [ ! -d $TARGETDIR/$SERVER_NAME ]; then
   mkdir -p $TARGETDIR/$SERVER_NAME
  fi
  if [ ! -d $TARGETDIR/$SERVER_NAME/$CURRENTDATE ]; then
   mkdir -p $TARGETDIR/$SERVER_NAME/$CURRENTDATE
  fi
  if [ -d $TARGETDIR/$SERVER_NAME/$CURRENTDATE ]; then
   cp $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt $TARGETDIR/$SERVER_NAME/$CURRENTDATE
   if [ -d $TARGETDIR/$SERVER_NAME ]; then
    find $TARGETDIR/$SERVER_NAME -mtime +120 -exec ls -l {} \; | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
   fi
   umount $TARGETDIR
  fi
 fi
fi
################# copy report to Local #################
if [ $CURRENT_HOUR -gt $REPORT_HOUR ] && [ $CURRENT_HOUR -lt `expr $REPORT_HOUR + 5` ] && [ $SERVER_TYPE == DMZ ] && [ -d $LOCAL_STATUS_REPO ]; then
 if [ ! -d $LOCAL_STATUS_REPO/$CURRENTDATE ]; then
  mkdir -p $LOCAL_STATUS_REPO/$CURRENTDATE
 fi
 cp $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 cp $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt $LOCAL_STATUS_REPO/$CURRENTDATE
 if [ -d $LOCAL_STATUS_REPO ]; then
  find $LOCAL_STATUS_REPO -mtime +120 -exec ls -l {} \; | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
 fi
fi
################### Cleanup log files ##################
if [ $CURRENT_HOUR -gt $REPORT_HOUR ] && [ $CURRENT_HOUR -lt `expr $REPORT_HOUR + 5` ]; then
rm -rf $WORKDIR/$LOGDIR/$LOGFILE-top10cpu-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-top10mem-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-memstat-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-dstate-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-vmstat-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-process-count-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-io-$CURRENTDATE.txt $WORKDIR/$LOGDIR/$LOGFILE-$CURRENTDATE.txt
fi
#################### Do not edit above this line, use variables above in User Defined Variables ###########################################
