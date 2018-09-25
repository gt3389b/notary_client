#! /bin/bash

set -x

if [ "$1" != "" ]; then
   id=$1
else
   echo "Need repoe name"
   exit
fi

if [ "$2" != "" ]; then
   targ=$2
else
   echo "Need target name for delegate"
   exit
fi

echo Ensuring snapshot key is on server
notary key rotate docker.com/$id snapshot -r

echo Generating delegate keys and cert
gen_delegate.sh $targ

echo Creating target delegate $targ and adding file
notary delegation add docker.com/$id "targets/$targ" certificates_repo/$targ.crt --paths="secure/secret"

notary add docker.com/$id secure/secret ~/bin/setup.sh --roles "targets/$targ"

echo Publishing but this will fail
notary publish docker.com/$id

echo Now adding key
notary key import certificates_repo/$targ.key --role user

echo 2nd publish which should be successful
notary publish docker.com/$id


