#! /bin/bash

PASS='testtest'
DIR=~/.docker/trust/private/
FILES=`tree -i --noreport $DIR | tail -n +2`

echo $FILES
for file in $FILES; do
   echo "***************************************************************"
   ROLE=`grep role $DIR$file`
   GUN=`grep gun $DIR$file`
   echo "$file $ROLE $GUN"
   cat $DIR$file | sed '/role/d' | sed '/gun/d' | sed '/^$/d' | openssl ec -passin pass:testtest -pubout | openssl ec -pubin -noout -text
   echo "***************************************************************"
   echo 
done
