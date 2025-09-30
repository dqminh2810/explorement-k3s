#!/bin/bash
set -e

# Log all output to a dedicated file
exec > >(tee -a /var/log/k3s-install.log) 2>&1

echo "Starting k3s agent installation..."

echo "K3S_URL='${k3s_url}'"
echo "K3S_TOKEN='${k3s_token}'"

curl -sfL https://get.k3s.io | K3S_URL="${k3s_url}" K3S_TOKEN="${k3s_token}" sh -

echo "K3s agent installation finished."