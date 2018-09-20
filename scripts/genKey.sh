#! /bin/bash

if [ "$1" == "" ]; then
   filename="priv.key"
else
   filename=$1
fi

openssl ecparam -genkey -name prime256v1 | openssl ec -aes256 -out $filename -passout pass:"weakpass"
