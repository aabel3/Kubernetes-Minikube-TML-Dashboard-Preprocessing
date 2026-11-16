#!/bin/bash
#
# verify-kubernetes.bash
# Kubernetes and TML dashboard lab
#
# Runs the checks for the lab on the VM:
#   1. minikube and kubectl are installed and the cluster is running
#   2. The seneca-iot-deployment pod is Running
#   3. The dashboard answers on the forwarded port
#   4. The expected tmux sessions exist inside the pod
#
# Start the port-forward in another terminal first:
#   kubectl port-forward <pod name> 9005:9005
#
# Usage:  ./verify-kubernetes.bash [port]
# Example: ./verify-kubernetes.bash 9005
#
# Written and tested by: Avraham Abel

PORT="${1:-9005}"
SESSIONS="kafka zookeeper preprocess-data-python-8001 preprocess-data-viper-8001 preprocess2-data-python-8002 preprocess2-data-viper-8002 produce-iot-data-python-8000 produce-iot-data-viper-8000 visualization-viperviz-9005"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Kubernetes Lab - Cluster Check\n'
printf '#%.0s' {1..50}; printf '\n\n'

PASS=0
FAIL=0

check() {
    # check "description" command...
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf '[ OK ]   %s\n' "$desc"
        PASS=$((PASS + 1))
    else
        printf '[FAIL]   %s\n' "$desc" >&2
        FAIL=$((FAIL + 1))
    fi
}

check "minikube is installed" command -v minikube
check "kubectl is installed" command -v kubectl
check "minikube cluster is running" minikube status

POD="$(kubectl get pods --no-headers 2>/dev/null | awk '/seneca-iot-deployment/ && /Running/ {print $1; exit}')"

printf '\n== Pods ==\n'
kubectl get pods 2>&1
printf '\n'

printf '== Checks ==\n'
check "Pod seneca-iot-deployment is Running" test -n "$POD"

if command -v curl >/dev/null 2>&1; then
    check "HTTP 200 from the dashboard page on port $PORT" \
        bash -c "[ \"\$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://localhost:$PORT/iot-failure-seneca.html)\" = 200 ]"
else
    printf '[SKIP]   curl not installed, dashboard check skipped\n'
fi

if [ -n "$POD" ]; then
    TMUX_LIST="$(kubectl exec "$POD" -- tmux ls 2>/dev/null)"
    for s in $SESSIONS; do
        check "tmux session $s" bash -c "printf '%s' \"\$1\" | grep -q \"^$s:\"" _ "$TMUX_LIST"
    done
fi

printf '\nResult: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
