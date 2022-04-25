#!/bin/bash

>/tmp/parsed.xml

IFS=''
while read line;

 do
  echo "$line" >> /tmp/parsed.xml
 done < /tmp/product-feed_uk.xml
