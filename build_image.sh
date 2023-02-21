#!/bin/bash

rvm get head
rvm reload

#LATEST=2.6
REPO=symbols/minimal-ruby

rvm list known_strings | egrep '^ruby-(3\.|2\.7)'
TAGLIST="${REPO}:latest"
LATEST_TAG=z

for RUBY in `rvm list known_strings | egrep '^ruby-(3\.|2.7\.)'`
do
  MINOR=${RUBY#*-}
  MAJOR=${MINOR%.*}
  POINT=${RUBY##*.}

  ALPINES="3.17 3.16 3.15 3.14"
  LATEST_ALPINE="3.17"
  LAST_ALPINE=$LATEST_ALPINE
  LAST_MAJOR=""

#  while [ "x$POINT" != "x-1" ]
#  do
  
    for ALPINE in $ALPINES
    do
      cp Dockerfile.template Dockerfile
      sed -i "s/%RUBY%/${MINOR}/" Dockerfile

      echo -e "\033[0;33m\033[1mBuilding Ruby $MINOR for Alpine $ALPINE\033[21m\033[34m"
      sed -i "s/alpine:ALPINE_VERSION/alpine:$ALPINE/" Dockerfile
      docker build --pull --rm -t ${REPO}:${MINOR}_${ALPINE} . >> log/build_${MINOR}_${ALPINE}.log 2>&1
      if [ "x$?" == "x0" ]; then
        if [ "$ALPINE" == "$LATEST_ALPINE" ]; then
          echo "- tagging ${REPO}:${MINOR}_${ALPINE} as ${REPO}:${MINOR}"
          docker tag ${REPO}:${MINOR}_${ALPINE} ${REPO}:${MINOR}
          TAGLIST="${TAGLIST} ${REPO}:${MINOR}_${ALPINE} ${REPO}:${MINOR}"
        fi
        if [ "$LAST_MAJOR" != "$MAJOR" ]; then
          echo "- tagging ${REPO}:${MINOR}_${ALPINE} as ${REPO}:${MAJOR}_${ALPINE}"
          docker tag ${REPO}:${MINOR}_${ALPINE} ${REPO}:${MAJOR}_${ALPINE}
          TAGLIST="${TAGLIST} ${REPO}:${MAJOR}_${ALPINE}"
          if [ "$ALPINE" == "$LATEST_ALPINE" ]; then
            echo "- tagging ${REPO}:${MAJOR}_${ALPINE} as ${REPO}:${MAJOR}"
            docker tag ${REPO}:${MAJOR}_${ALPINE} ${REPO}:${MAJOR}
            TAGLIST="${TAGLIST} ${REPO}:${MAJOR}"
          fi
        fi
        echo -e "\033[0;32m- Building Ruby $MINOR for Alpine $ALPINE: \033[1mSUCCESS\033[21m"
        if [ "$LATEST_TAG" == "z" ]; then
          LATEST_TAG="${REPO}:${MINOR}_${ALPINE}"
          echo "- Will set :latest tag to ${LATEST_TAG}"
        fi
      else
        echo -e "\033[0;31m- Building Ruby $MINOR for Alpine $ALPINE: \033[1mFAILED\033[21m"
      fi
      LAST_ALPINE=$ALPINE
    done
#    LAST_MAJOR=$MAJOR
#    let POINT=$POINT-1
#    MINOR="${MAJOR}.${POINT}"
#  done
done
  
if [ "x$DOCKERHUB_USERNAME" != "x" ]; then
  echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
fi

docker tag ${LATEST_TAG} ${REPO}:latest
docker image ls -a
echo -e "\033[0;34mAll done. Pushing changes."
echo ${TAGLIST}
for i in ${TAGLIST} ; do docker push ${i} ; done

echo -e "\033[1m\033[0;32m- Finished."
echo -e "\033[0m"
