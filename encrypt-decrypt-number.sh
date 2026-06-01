#!/bin/bash

encrypt()
{
codelock=0
read -p "Enter the number to encrypt: " mynumber
while IFS= read -r -n1 char;
 do
  if [ ! -z $char ]; then
  if [ "$char" == "5" ] || [ "$char" == "6" ] || [ "$char" == "7" ] || [ "$char" == "8" ] || [ "$char" == "9" ]; then
   if [ $codelock == "0" ]; then
   codelock=1
   printf "%d" "5"
   fi
  fi

  if [ "$char" == "0" ] || [ "$char" == "1" ] || [ "$char" == "2" ] || [ "$char" == "3" ] || [ "$char" == "4" ]; then
   if [ $codelock == "1" ]; then
   codelock=0
   printf "%d" "5"
   fi
  fi

  if [ $codelock == "0" ]; then
   printf "%d" "$char"
  else
   char=$((char - 5))
   printf "%d" "$char"
  fi
  fi
 done <<< "$mynumber"
echo "  ..done"
}

decrypt()
{
codelock=0
read -p "Enter the number to decrypt: " mynumber
while IFS= read -r -n1 char;
 do
  if [ ! -z $char ]; then
  if [ "$char" == "5" ]; then
   if [ "$char" == "5" ] && [ $codelock == "1" ]; then
   codelock=0
   else
   codelock=1
   fi
  fi

  if [ $codelock == "0" ] && [ $char != "5" ]; then
   printf "%d" "$char"
  fi
  if [ $codelock == "1" ] && [ $char != "5" ]; then
   char=$((char + 5))
   printf "%d" "$char"
  fi
  fi
 done <<< "$mynumber"
echo "  ..done"
}

echo "[[ Encrypt or Decrypt the number ]]"
echo "(1) Encrypt the number."
echo "(2) Decrypt the number."
echo "Any other to Exit."

read -p "Enter the choice: " choice
if [ $choice == "1" ]; then
 encrypt
fi
if [ $choice == "2" ]; then
 decrypt
fi
