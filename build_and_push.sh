#!/bin/bash

# IRIS_PROJECT_FOLDER_NAME=irisdemodb-atelier-project
GIT_REPO_NAME=irisdemo-base-irisdb-community
TAG=version-$(cat ./VERSION)

IMG_TGT=docker.iscinternal.com/sds-docker-dev/sds/$GIT_REPO_NAME:$TAG
IMG_X86=docker.iscinternal.com/sds-docker-dev/sds/$GIT_REPO_NAME:$TAG-amd64
IMG_ARM=docker.iscinternal.com/sds-docker-dev/sds/$GIT_REPO_NAME:$TAG-arm64

# docker build --build-arg IRIS_PROJECT_FOLDER_NAME=$IRIS_PROJECT_FOLDER_NAME --force-rm -t $IMAGE_NAME . 

docker buildx build --builder desktop-linux --load --force-rm \
  --progress plain \
  --platform linux/amd64 \
  -t $IMG_X86 .
docker push $IMG_X86

docker buildx build --builder desktop-linux --load --force-rm \
  --progress plain \
  --platform linux/arm64 \
  -t $IMG_ARM .
docker push $IMG_ARM

docker manifest create $IMG_TGT \
  --amend $IMG_X86 \
  --amend $IMG_ARM
docker manifest inspect $IMG_TGT

docker manifest push $IMG_TGT
