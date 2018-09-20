./restart.sh

or 

docker build -t notary-client .
docker run --network=notary_sig --disable-content-trust -itd notary-client
docker exec -it <container-id> /bin/bash
