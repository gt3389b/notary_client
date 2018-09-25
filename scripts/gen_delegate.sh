#!/usr/bin/env bash

if [ "$1" != "" ]; then
   dele=$1
else
   echo "Need delegate name"
   exit
fi

# set to true for debugging openssl logging
if false; then 
  REDIRECT=/dev/tty
else 
  REDIRECT=/dev/null
fi

org="docker.com"
commonname="CN=$org/$dele"

#NOTE:  Leaving out O= orgname for now
subj="/${commonname//\//\\/}"

#openssl req -newkey rsa:2048 -passout pass:"weakpass" -keyout "$dele.key" -x509 -days 365 -subj "$subj" -out "$dele.crt"
openssl req -newkey rsa:2048 -nodes -keyout "$dele.key" -x509 -days 365 -subj "$subj" -out "$dele.crt"

mkdir -p certificates_repo
mv $dele.key $dele.crt certificates_repo/

