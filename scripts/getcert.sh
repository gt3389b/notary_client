#! /bin/sh
filepath=~/.notary/tuf/$1/metadata/root.json 

keyid=`cat $filepath | jq .signed.roles.root.keyids[0]`
b64cert=`cat $filepath | jq -r ".signed.keys.${keyid}.keyval.public"`
#echo $b64cert | base64 --decode | openssl x509 -noout -text

certId=`echo $b64cert | base64 --decode | genCertId`
echo $b64cert | base64 --decode > $certId.crt
echo "Wrote data to" $certId.crt
