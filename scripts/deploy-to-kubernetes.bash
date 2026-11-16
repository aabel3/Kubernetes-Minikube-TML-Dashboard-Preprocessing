#!/bin/bash
#
# deploy-to-kubernetes.bash
# Kubernetes and TML dashboard lab
#
# Starts minikube, deploys the TML container from senecaiot.yml, waits for the
# pod to run and forwards host port 9005 to container port 9005.
#
# Usage:  ./deploy-to-kubernetes.bash [yaml_file] [port]
# Example: ./deploy-to-kubernetes.bash senecaiot.yml 9005
#
# The port-forward runs in the foreground. Press Ctrl+C to stop it.
#
# Written and tested by: Avraham Abel

YAML="${1:-senecaiot.yml}"
PORT="${2:-9005}"
DEPLOYMENT="seneca-iot-deployment"
URL="http://localhost:$PORT/iot-failure-seneca.html?topic=iot-preprocess2,iot-preprocess&offset=-1&groupid=&rollbackoffset=500&topictype=prediction&append=0&secure=1"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Kubernetes Lab - Deploy the TML Container\n'
printf '#%.0s' {1..50}; printf '\n\n'

for tool in docker minikube kubectl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf '%s is not installed. Run ./install-kubernetes-tools.bash first.\n' "$tool" >&2
        exit 1
    fi
done

if [ ! -f "$YAML" ]; then
    printf 'Cannot find %s. Copy configs/senecaiot.yml and set your image.\n' "$YAML" >&2
    exit 1
fi

printf '== Starting minikube ==\n'
minikube start --driver=docker || exit 1

printf '\n== Applying %s ==\n' "$YAML"
kubectl apply -f "$YAML" || exit 1

printf '\n== Waiting for the pod (up to 5 minutes) ==\n'
kubectl rollout status "deployment/$DEPLOYMENT" --timeout=300s || exit 1
kubectl get pods

POD="$(kubectl get pods -o name | grep "$DEPLOYMENT" | head -n 1 | cut -d/ -f2)"
if [ -z "$POD" ]; then
    printf 'No pod found for %s\n' "$DEPLOYMENT" >&2
    exit 1
fi

printf '\n== Dashboard URL (press START STREAMING in the browser) ==\n'
printf '%s\n\n' "$URL"

printf '== Port-forwarding %s (Ctrl+C stops it) ==\n' "$POD"
kubectl port-forward "$POD" "$PORT:9005"
