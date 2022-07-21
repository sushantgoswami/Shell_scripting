#!/bin/bash

LANGUAGE_CODE=$2
INFILE=$3
OUTFILE=$4
s10=`od -vAn -N2 -tu2 < /dev/urandom`
s11=`echo $s10`

cp -rf $INFILE /tmp/infile_process6a55-$s11.xml

cat /tmp/infile_process6a55-$s11.xml | awk '{print "### "$0}' > /tmp/infile_process6a55_hashed-$s11.xml

touch /tmp/infile_process6a55_processed-$s11.xml
>/tmp/infile_process6a55_processed-$s11.xml
TMP_OUTFILE=/tmp/infile_process6a55_processed-$s11.xml

if [ $1 == "process" ]; then

DICT_PATH=/usr/local/share/dictionary
GOOGLE_PRODUCT_CATEGORY="<g:google_product_category>"
TITLE="<g:title>"
DESCRIPTION="<g:description>"
DESCRIPTION_END="</g:description>"
COLOR="<color>"

SET_LOCK=0

>$OUTFILE

IFS=''
while read line;

 do

  PARSE1=`echo "$line" | grep $GOOGLE_PRODUCT_CATEGORY | wc -l`
  PARSE2=`echo "$line" | grep $TITLE | wc -l`
  PARSE3=`echo "$line" | grep $DESCRIPTION | wc -l`
  PARSE3_END=`echo "$line" | grep $DESCRIPTION_END | wc -l`
  PARSE4=`echo "$line" | grep $COLOR | wc -l`

  if [ $SET_LOCK = 0 ]; then

  if [ $PARSE1 = 1 ]; then
   #################################
   f_google_product_category=`echo "$line" | cut -d ">" -f 2 | cut -d "<" -f 1`
   DICT_FIND=`cat $DICT_PATH/dict_en_$LANGUAGE_CODE.txt | grep "#$f_google_product_category#" | wc -l`
   if [ $DICT_FIND == 1 ]; then
    f_google_product_category_tr=`cat $DICT_PATH/dict_en_$LANGUAGE_CODE.txt | grep "#$f_google_product_category#" | cut -d "#" -f 4`
   else
    f_google_product_category_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_google_product_category"`
   fi
   echo "###       <g:google_product_category>$f_google_product_category_tr</g:google_product_category>" >> $TMP_OUTFILE
   #################################
  fi

  if [ $PARSE2 = 1 ]; then
   #################################
   f_title=`echo "$line" | cut -d ">" -f 2 | cut -d "<" -f 1`
   f_title_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_title"`
   echo "###       <g:title>$f_title_tr</g:title>" >> $TMP_OUTFILE
   #################################
  fi

  if [ $PARSE3 = 1 ] && [ $PARSE3_END = 1 ]; then
   #################################
   f_description=`echo "$line" | cut -d ">" -f 2 | cut -d "<" -f 1`
   f_description_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_description"`
   echo "###       <g:description>$f_description_tr</g:description>" >> $TMP_OUTFILE
   #################################
  fi

  if [ $PARSE4 = 1 ]; then
   #################################
   f_color=`echo "$line" | cut -d ">" -f 2 | cut -d "<" -f 1`
   DICT_FIND=`cat $DICT_PATH/dict_en_$LANGUAGE_CODE.txt | grep "#$f_color#" | wc -l`
   if [ $DICT_FIND == 1 ]; then
    f_color_tr=`cat $DICT_PATH/dict_en_$LANGUAGE_CODE.txt | grep "#$f_color#" | cut -d "#" -f 4`
   else
    f_color_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_color"`
   fi
   echo "###       <color>$f_color_tr</color>" >> $TMP_OUTFILE
   #################################
  fi

  fi

  if [ $SET_LOCK = 1 ] && [ $PARSE3_END = 0 ]; then
   #################################
   # f_description=`echo "$line"`
   # f_description_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_description"`
   # echo "$f_description_tr" >> $TMP_OUTFILE
   echo "$line" >> /tmp/tmp_parse_desc-$s11.txt
   #################################
  fi

  if [ $PARSE3 = 1 ] && [ $PARSE3_END = 0 ]; then
   #################################
   f_description=`echo "$line" | cut -d ">" -f 2`
   f_description_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_description"`
   echo "###       <g:description>$f_description_tr" >> $TMP_OUTFILE
   SET_LOCK=1
   #################################
  fi

  if [ $SET_LOCK = 1 ] && [ $PARSE3_END = 1 ]; then
   #################################
   f_description=`echo "$line" | cut -d "<" -f 1`
   f_description_tr=`/usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE "$f_description"`
   if [ $f_description_tr != "###" ]; then
    /usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE -i /tmp/tmp_parse_desc-$s11.txt >> $TMP_OUTFILE
    echo "$f_description_tr</g:description>" >> $TMP_OUTFILE
   else
    /usr/local/bin/trans -brief -no-auto :$LANGUAGE_CODE -i /tmp/tmp_parse_desc-$s11.txt >> $TMP_OUTFILE
    echo "### </g:description>" >> $TMP_OUTFILE
   fi
   >/tmp/tmp_parse_desc-$s11.txt
   SET_LOCK=0
   #################################
  fi

  if [ $PARSE1 = 0 ] && [ $PARSE2 = 0 ] && [ $PARSE3 = 0 ] && [ $PARSE4 = 0 ] && [ $PARSE3_END = 0 ] && [ $SET_LOCK = 0 ]; then
   echo "$line" >> $TMP_OUTFILE
  fi
 done < /tmp/infile_process6a55_hashed-$s11.xml

cat $TMP_OUTFILE | cut -c 5- > $OUTFILE

fi
