#!/bin/bash
set -e

K3S_URL=$1
K3S_TOKEN=$2

# Log all output to a dedicated file
exec > >(tee -a /var/log/k3s-install.log) 2>&1

echo "Starting k3s agent installation..."

# echo "K3S_URL='${k3s_url}'"
# echo "K3S_TOKEN='${k3s_token}'"
# curl -sfL https://get.k3s.io | K3S_URL="${k3s_url}" K3S_TOKEN="${k3s_token}" sh -

if [ -z "$K3S_URL" ] || [ -z "$K3S_TOKEN" ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <K3S_URL> <K3S_TOKEN>"
    exit 1
fi

echo "K3S_URL=$K3S_URL"
echo "K3S_TOKEN=$K3S_TOKEN"

curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -

echo "K3s agent installation finished."