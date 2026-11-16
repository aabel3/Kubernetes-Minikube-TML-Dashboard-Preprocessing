#!/bin/bash
#
# install-kubernetes-tools.bash
# Kubernetes and TML dashboard lab
#
# Installs minikube and kubectl on the Ubuntu VM:
#   1. Download and install minikube
#   2. Download and install kubectl
#   3. Show the installed versions
#
# Docker must already be installed (sudo apt-get install docker.io).
#
# Usage:  ./install-kubernetes-tools.bash
#
# Written and tested by: Avraham Abel

WORKDIR="${1:-$HOME/kubernetes}"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Kubernetes Lab - Install minikube and kubectl\n'
printf '#%.0s' {1..50}; printf '\n\n'

if ! command -v docker >/dev/null 2>&1; then
    printf 'Docker is not installed. Run: sudo apt-get install docker.io\n' >&2
    exit 1
fi

mkdir -p "$WORKDIR" && cd "$WORKDIR" || exit 1

printf '== Installing minikube ==\n'
wget -q --show-progress https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 || exit 1
sudo install minikube-linux-amd64 /usr/local/bin/minikube || exit 1

printf '\n== Installing kubectl ==\n'
KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl" || exit 1
sudo chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl || exit 1

printf '\n== Installed versions ==\n'
minikube version
kubectl version --client
