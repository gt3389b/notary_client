#!/usr/bin/env bash

if [ "$1" != "" ]; then
   repo=$1
else
   echo "Need repo name"
   exit
fi

# set to true for debugging openssl logging
if false; then 
  REDIRECT=/dev/tty
else 
  REDIRECT=/dev/null
fi

cat > "$repo.cnf" <<EOL
[repo_ext]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
extendedKeyUsage=serverAuth,clientAuth
keyUsage = critical, digitalSignature, keyEncipherment
subjectAltName = DNS:notary-signer, DNS:notarysigner, DNS:localhost, IP:127.0.0.1
subjectKeyIdentifier=hash
EOL

org="docker.com"
commonname="CN=$org/$repo"

#NOTE:  Leaving out O= orgname for now
subj="/${commonname//\//\\/}"

openssl ecparam -genkey -name prime256v1 | openssl ec -aes256 -passout pass:"weakpass" -out "$repo.key" &>$REDIRECT
openssl req -new -key "$repo.key" \
	-out "$repo.csr" \
	-sha256 \
	-passin pass:"weakpass" \
        -subj "$subj"

openssl x509 -req -days 750 -in "$repo.csr" -sha256 \
        -CA "certificates_ca/intermediate-ca.crt" \
	-CAkey "certificates_ca/intermediate-ca.key"  \
	-CAcreateserial \
        -out "$repo.crt" \
	-extfile "$repo.cnf" \
	-extensions repo_ext

rm "$repo.cnf" "$repo.csr"

# append the intermediate cert to this one to make it a proper bundle
cat "certificates_ca/intermediate-ca.crt" >> "$repo.crt"

openssl verify -CAfile certificates_ca/cacerts.crt $repo.crt

mkdir -p certificates_repo
mv $repo.key $repo.crt certificates_repo/

