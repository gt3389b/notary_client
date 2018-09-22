#!/usr/bin/env bash

#set -x 
typeset -r keystore_pw='weakpass'

# set to true for debugging openssl logging
if false; then 
  REDIRECT=/dev/tty
else 
  REDIRECT=/dev/null
fi

#
#   Generate ROOT CA
#
# First generates root-ca
openssl ecparam -genkey -name prime256v1 | openssl ec -out "root-ca.key" &>$REDIRECT
openssl req -new -key "root-ca.key" \
	-out "root-ca.csr" \
	-sha256            \
	-subj '/C=US/ST=CA/L=San Francisco/O=Docker/CN=Notary Testing CA' \
	&>$REDIRECT

cat > "root-ca.cnf" <<EOL
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOL

openssl x509 -req -days 3650 \
	-in "root-ca.csr" \
	-signkey "root-ca.key" \
	-sha256 \
        -out "root-ca.crt" \
	-extfile "root-ca.cnf" \
	-extensions root_ca \
	&>$REDIRECT
#cp "root-ca.crt" "../cmd/notary/root-ca.crt"

rm "root-ca.cnf" "root-ca.csr"

#
#   Generate Intermediate CA
#
# Then generate intermediate-ca
openssl ecparam -genkey -name prime256v1 | openssl ec -out "intermediate-ca.key" &>$REDIRECT
openssl req -new \
	-key "intermediate-ca.key" \
	-out "intermediate-ca.csr" \
	-sha256 \
        -subj '/C=US/ST=CA/L=San Francisco/O=Docker/CN=Notary Intermediate Testing CA' \
	&>$REDIRECT

cat > "intermediate-ca.cnf" <<EOL
[intermediate_ca]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:TRUE,pathlen:0
extendedKeyUsage=serverAuth,clientAuth
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOL

openssl x509 -req -days 3650 \
	-in "intermediate-ca.csr" \
	-sha256 \
        -CA "root-ca.crt" \
	-CAkey "root-ca.key"  \
	-CAcreateserial \
        -out "intermediate-ca.crt" \
	-extfile "intermediate-ca.cnf" \
	-extensions intermediate_ca \
	&>$REDIRECT

rm "intermediate-ca.cnf" "intermediate-ca.csr"
rm "root-ca.srl" 
#rm "root-ca.key" 

# simulate key import
openssl verify -CAfile root-ca.crt root-ca.crt

openssl verify -CAfile root-ca.crt intermediate-ca.crt

mkdir -p certificates_ca
cat root-ca.crt intermediate-ca.crt > cacerts.crt
mv root-ca.key root-ca.crt intermediate-ca.key intermediate-ca.crt cacerts.crt certificates_ca/

echo
echo "********************************************************************"
echo "*"
echo "*  Copy certificates_ca/cacerts.crt to ~/.notary/trusted_certificates"
echo "*"
echo "********************************************************************"
echo
