#! /bin/bash

DIR=~/.docker/trust/private/
FILES=`tree -i --noreport $DIR | tail -n +2`
for file in $FILES; do
   ROLE=`grep role $DIR$file`
   GUN=`grep gun $DIR$file`
   echo "$file $ROLE $GUN"
done
