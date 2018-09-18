
docker build -t notary-client .
docker run --network=notary_sig --disable-content-trust -itd notary-client
docker exec -it <container-id> /bin/bash


su notary
export PATH=$PATH:/go/bin
