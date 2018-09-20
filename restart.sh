#! /bin/bash

ID=`docker ps | grep "notary-client" | cut -d " " -f 1`

if [ "$ID" != "" ]; then 
   echo Stopping $ID
   docker stop $ID
fi

docker build -t notary-client .

ID=`docker run -v ${PWD}/data:/home/notary/data --network=notary_sig --disable-content-trust -itd notary-client`

docker exec -it $ID /bin/bash

