#!/bin/bash
if [[ $# == 3 ]]; then
	K3S_TOKEN=$1
	MASTER_IP=$2
	K3S_NODE_NAME=$3
	
	curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN K3S_URL=https://$MASTER_IP:6443 K3S_NODE_NAME=$K3S_NODE_NAME sh -
else
	echo "Please provide K3S_TOKEN - MASTER_IP - K3S_NODE_NAME"
fi
