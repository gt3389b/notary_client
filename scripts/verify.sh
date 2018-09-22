#! /bin/bash

set -x

id=$1

rm -rf ~/.notary/tuf/docker.com

#test the trust_pinning
notary list docker.com/$id
