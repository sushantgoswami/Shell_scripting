#!/bin/bash

# example ./userfinder_from_sysrpt.sh actual-linux-servers.txt ps_gid_uid.txt userid

SERVERDB=$1
LASTFILE=$2
USERNAME=$3
USERID=`adquery user $USERNAME | cut -d ":" -f 3 2>/dev/null`
FINDING=0

for i in `cat $SERVERDB`
 do
  if [ -f /opt/config_data/$i/$LASTFILE ]; then
   FINDING=`cat /opt/config_data/$i/$LASTFILE | awk '{print " "$2" "}' | grep " $USERID " | grep -v grep | wc -l`
   if [ $FINDING -ne 0 ]; then
    echo "Alert:(MSG001): User $USERNAME found on server $i" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> userfinder_from_config_data.log.txt
    echo "Alert:(MSG001): User $USERNAME found on server $i"
   fi
  else
   echo "Information:(MSG002): Last ps_gid_uid.txt $LASTFILE not found for server $i" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> userfinder_from_config_data.log.txt
  fi
 done

echo "=============== script completed - end of line ===============" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> userfinder_from_config_data.log.txt
