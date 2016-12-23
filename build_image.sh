#!/bin/bash

set -e

rvm get head
rvm reload

LATEST=2.3
REPO=gh2k/minimal-ruby

for RUBY in `rvm list known_strings | grep '^ruby-2\.'` 
do
  MINOR=${RUBY#*-}
  MAJOR=${MINOR%.*}

  if [ "$MAJOR" != "2.0" ]; then
    docker build --pull --rm -t ${REPO}:${MINOR} -t ${REPO}:${MAJOR} --build-arg ruby=${MINOR} .
  fi
done

docker tag ${REPO}:${LATEST} ${REPO}:latest
