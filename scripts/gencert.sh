#! /bin/bash

if [ "$1" == "" ]; then
   org="docker.com"
else
   org=$1
fi

if [ "$2" == "" ]; then
   repopath="notary/test"
else
   repopath=$2
fi

if [ "$3" != "" ]; then
   keyfile=$3
fi

PASS="weakpass"

OPENSSLCNF=
for path in /etc/openssl/openssl.cnf /etc/ssl/openssl.cnf /usr/local/etc/openssl/openssl.cnf; do
    if [[ -e ${path} ]]; then
        OPENSSLCNF=${path}
    fi
done
if [[ -z ${OPENSSLCNF} ]]; then
    printf "Could not find openssl.cnf"
    exit 1
fi

selfsigned="docker.com"

cat > "${selfsigned}.cnf" <<EOL
[selfsigned]
basicConstraints = critical,CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage=codeSigning
subjectKeyIdentifier=hash
EOL

orgname="O=$org"
commonname="CN=$org/$repopath"

#NOTE:  Leaving out O= orgname for now
subj="/${commonname//\//\\/}"


# set to true for debugging openssl logging
if false; then 
  REDIRECT=/dev/tty
else 
  REDIRECT=/dev/null
fi

if [ "$keyfile" == "" ]; then
   echo "Building key ${selfsigned}.key"
   openssl req -x509 -newkey rsa:2048 -keyout "${selfsigned}.key" -out "${selfsigned}.tmp" -subj "${subj}" -sha256 -batch -passout pass:$PASS &> $REDIRECT
   openssl x509 -x509toreq -days 365 -in ${selfsigned}.tmp -signkey ${selfsigned}.key -out ${selfsigned}.csr -passin pass:$PASS &> $REDIRECT
   keyfile=${selfsigned}.key
fi
echo "Building certificate for $subj"
openssl x509 -req -days 750 -in "${selfsigned}.csr" -signkey "${keyfile}" -out "${selfsigned}.crt" -sha256 -extfile "${selfsigned}.cnf" -extensions selfsigned -passin pass:$PASS &> $REDIRECT

#openssl req -new -newkey rsa:2048 -days 750 -x509 -subj "${subj}" -keyout ${selfsigned}.key -out ${selfsigned}.crt -passout pass:$PASS -config "${selfsigned}.cnf" -extensions selfsigned

rm -f ${selfsigned}.csr ${selfsigned}.cnf ${selfsigned}.tmp
