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
    docker build --pull --rm -t ${REPO}:${MINOR} -t ${REPO}:${MAJOR} .
  fi
done

docker tag ${REPO}:${LATEST} ${REPO}:latest
docker push ${REPO}

