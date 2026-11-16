#!/bin/bash
#
# build-container.bash
# Kubernetes and TML dashboard lab
#
# Builds the modified TML container (name ends in _modification) from the
# Dockerfile in the current directory and optionally pushes it to Docker Hub.
#
# Usage:  ./build-container.bash <dockerhub_user> [push]
# Example: ./build-container.bash myuser push
#
# The build runs from scratch with --no-cache and takes about 20 minutes.
# Commit the preprocesslogic change to your raspberrypi repository first.
# Log in before pushing:  docker login
#
# Written and tested by: Avraham Abel

USER_ID="${1:-}"
PUSH="${2:-}"

if [ -z "$USER_ID" ]; then
    printf 'Usage: %s <dockerhub_user> [push]\n' "$0" >&2
    exit 1
fi

IMAGE="$USER_ID/seneca-iot-tml-kafka-amd64_modification"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Kubernetes Lab - Build the Modified Container\n'
printf '#%.0s' {1..50}; printf '\n\n'

if [ ! -f Dockerfile ]; then
    printf 'No Dockerfile in %s.\n' "$PWD" >&2
    printf 'Copy it from https://github.com/smaurice101/raspberrypi/blob/main/docker/Dockerfile\n' >&2
    exit 1
fi

printf '== Building %s ==\n' "$IMAGE"
docker build -t "$IMAGE" --build-arg CHIP=AMD64 --no-cache --network=host . || exit 1

if [ "$PUSH" = "push" ]; then
    printf '\n== Pushing %s ==\n' "$IMAGE"
    docker push "$IMAGE" || exit 1
fi

printf '\nDone. Test it with: docker run -p 9005:9005 %s\n' "$IMAGE"
