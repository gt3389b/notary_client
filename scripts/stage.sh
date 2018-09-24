#! /bin/bash

set -x

if [ "$1" != "" ]; then
   id=$1
else
   id=$RANDOM
fi

gen_repo.sh $id

echo Generating $id repo

notary init --rootcert certificates_repo/$id.crt --rootkey certificates_repo/$id.key docker.com/$id
notary add docker.com/$id v1 ~/bin/setup.sh

#~/data/getcert.sh docker.com/notary/$id

notary publish docker.com/$id

rm -rf ~/.notary/tuf/docker.com/$id

#test the trust_pinning
notary list docker.com/$id
