#!/bin/bash
set -e

# Log all output to a dedicated file
exec > >(tee -a /var/log/k3s-install.log) 2>&1

echo "Starting k3s server installation..."

curl -sfL https://get.k3s.io | sh -

sudo cat /var/lib/rancher/k3s/server/node-token

echo "K3s server installation finished."