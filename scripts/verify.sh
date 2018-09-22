#! /bin/bash

set -x

id=$1

rm -rf ~/.notary/tuf/docker.com/

#test the trust_pinning
notary -D -v list docker.com/notary/$id
