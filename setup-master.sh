#!/bin/sh
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s
sudo cat /var/lib/rancher/k3s/server/node-token