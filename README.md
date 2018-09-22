# Container setup
```
./restart.sh
```

or 

```
docker build -t notary-client .
docker run --network=notary_sig --disable-content-trust -itd notary-client
docker exec -it <container-id> /bin/bash
```

# Stage repo

## Create a random repo, create cert/key, add content, publish, and verify
```
stage.sh
```

## Verfiy a published repo
```
verify.sh <repo>
```
