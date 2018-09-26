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

## Create a random repo, create cert, add content, publish, and verify
```
stage
```

## Create a repo by name, create cert, add content, publish, and verify
```
stage docker.com/456
```

## Verfiy a published repo
```
verify.sh <repo>
```
