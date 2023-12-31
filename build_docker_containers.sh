#!/bin/bash
set -e

CONTAINER_NAME=$1

docker pull $CI_REGISTRY_IMAGE/$CONTAINER_NAME:latest || true
docker build \
    --pull \
    --cache-from $CI_REGISTRY_IMAGE/$CONTAINER_NAME:latest \
    --label "org.opencontainers.image.title=$CI_PROJECT_TITLE" \
    --label "org.opencontainers.image.url=$CI_PROJECT_URL" \
    --label "org.opencontainers.image.created=$CI_JOB_STARTED_AT" \
    --label "org.opencontainers.image.revision=$CI_COMMIT_SHA" \
    --label "org.opencontainers.image.version=$CI_COMMIT_REF_NAME" \
    --tag $CI_REGISTRY_IMAGE/$CONTAINER_NAME:$CI_COMMIT_SHA \
    $CONTAINER_NAME/.
docker push $CI_REGISTRY_IMAGE/$CONTAINER_NAME:$CI_COMMIT_SHA

