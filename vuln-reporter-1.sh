#!/bin/bash

################################################

# Input file for parsing #
INPUT_FILE=$1

# Input the cluster name #
INPUT_CLUSTER=$2

# Out put file in text format #
OUTPUT_FILE=report.txt

# Output file name in html format #
OUTPUT_HTML_FILE=html

# text or html #
MODE=html

# Mail information #
MUA=mailx
FROM_ADDR=susgoswa@cisco.com
SUBJECT='security advisor'
SMTP_SERVER=localhost
SMTP_PORT=25
MAILSEND=combined  # Combined or independent for each project #

# job owner #
JOB_OWNER=susgoswa@cisco.com

################################################

>project_list.txt
while read line1
 do
  AVAIL=`echo $line1 | grep "$INPUT_CLUSTER" | wc -l`
   if [ $AVAIL != 0 ]; then
    echo $line1 >> project_list.txt
   fi
 done < $INPUT_FILE

while read line;
do
 OWNER_NAME=`echo $line | awk '{print $1}'`
 PROJECT_NAME=`echo $line | awk '{print $2}'`
 EMAIL_ID=`echo $line | awk '{print $3}'`
 oc describe vuln -n $PROJECT_NAME | grep 'Image:\|Critical Count:\|Fixable Count:\|High Count:\|Medium Count:\|Low Count:\|Affected Pods:\|'$PROJECT_NAME'' | grep -v 'Namespace:\|Labels:\|=' > $OWNER_NAME--$PROJECT_NAME--$EMAIL_ID--$OUTPUT_FILE
done < project_list.txt

for reports in `ls *$OUTPUT_FILE`
 do
  OWNER=`echo "$reports" | awk -F "--" '{print $1}'`
  PROJECT=`echo "$reports" | awk -F "--" '{print $2}'`
  echo "<html>" > $reports.$OUTPUT_HTML_FILE
  echo "<body>" >> $reports.$OUTPUT_HTML_FILE
  echo '<h1 style="background-color: red;">Follwing Vulenerabilities found in the project</h1>' >> $reports.$OUTPUT_HTML_FILE
  echo "<br>Project Name: $PROJECT</br>" >> $reports.$OUTPUT_HTML_FILE
  echo "<br>Owner Name: $OWNER</br>" >> $reports.$OUTPUT_HTML_FILE
  IFS=''
  while read line
   do
    IMG_NAME=`echo $line | grep "Image: " | wc -l`
    if [ $IMG_NAME == "1" ]; then
     echo '<h2 style="background-color: green;">Image Name</h2>' >> $reports.$OUTPUT_HTML_FILE
     echo "<br>$line</br>" >> $reports.$OUTPUT_HTML_FILE
    else
     echo "<br>$line</br>" >> $reports.$OUTPUT_HTML_FILE
    fi
   done < $reports
  echo "</body>" >> $reports.$OUTPUT_HTML_FILE
  echo "</html>" >> $reports.$OUTPUT_HTML_FILE
 done

if [ $MAILSEND == "combined" ]; then
 ls *$OUTPUT_FILE.$OUTPUT_HTML_FILE | awk -F "--" '{print $3}' | sort -u > get_mail_id.txt
 IFS=''
 while read line0
  do
   ls -l | awk '{print $NF}' | grep $line0 | grep html > email_to_output.file
   while read line
    do
     cat $line >> vuln-report-$line0.html
    done < email_to_output.file
   echo '#! /usr/bin/python' > pymailsend.py
   echo 'import smtplib' >> pymailsend.py
   echo 'from email.mime.multipart import MIMEMultipart' >> pymailsend.py
   echo 'from email.mime.text import MIMEText' >> pymailsend.py
   echo "me = '$FROM_ADDR'" >> pymailsend.py
   echo "you = '$line0'" >> pymailsend.py
   echo "msg = MIMEMultipart('alternative')" >> pymailsend.py
   echo "msg['Subject'] = '$SUBJECT'" >> pymailsend.py
   echo "msg['From'] = me" >> pymailsend.py
   echo "msg['To'] = you" >> pymailsend.py
   echo "text = 'Hello Teams'" >> pymailsend.py
   echo 'html = """\' >> pymailsend.py
   cat vuln-report-$line0.html >> pymailsend.py
   echo '"""' >> pymailsend.py
   echo "part1 = MIMEText(text, 'plain')" >> pymailsend.py
   echo "part2 = MIMEText(html, 'html')" >> pymailsend.py
   echo 'msg.attach(part1)' >> pymailsend.py
   echo 'msg.attach(part2)' >> pymailsend.py
   echo "s = smtplib.SMTP('localhost')" >> pymailsend.py
   echo 's.sendmail(me, you, msg.as_string())' >> pymailsend.py
   echo 's.quit()' >> pymailsend.py
   python3 pymailsend.py
done < get_mail_id.txt
fi
