#!/bin/sh
if [[ $1 == '-d' || $1 == '--docker' ]]; then
    if docker info &> /dev/null; then
        echo "Docker daemon is running and responsive."
        curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - --docker
    else
        echo "Docker daemon is not running or not responsive."
    fi
else
    echo 'containerd'
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s
fi

sudo cat /var/lib/rancher/k3s/server/node-token