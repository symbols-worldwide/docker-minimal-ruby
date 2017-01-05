#!/bin/bash

set -e

rvm get head
rvm reload

LATEST=2.4
REPO=gh2k/minimal-ruby

for RUBY in `rvm list known_strings | grep '^ruby-2\.'` 
do
  MINOR=${RUBY#*-}
  MAJOR=${MINOR%.*}

  if [ "$MAJOR" != "2.0" ]; then
    cp Dockerfile.template Dockerfile
    sed -i "s/%RUBY%/${MINOR}/" Dockerfile
    docker build --pull --rm -t ${REPO}:${MINOR} -t ${REPO}:${MAJOR} -t ${REPO}:${MINOR}_3.5 -t ${REPO}:${MAJOR}_3.5 .
    sed -i "s/alpine:3.5/alpine:3.4/" Dockerfile
    docker build --pull --rm -t ${REPO}:${MINOR}_3.4 -t ${REPO}:${MAJOR}_3.4 .
  fi
done

docker tag ${REPO}:${LATEST} ${REPO}:latest
docker push ${REPO}

