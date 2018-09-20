#! /bin/bash
rm -rf ~/.notary/private/*
rm -rf ~/.notary/tuf/*

cd ../notary-server/notary
docker-compose down; docker volume prune --force; docker-compose up -d
cd -
