# explorement-k3s
Learn K8s components architecture and how to management

## MASTER NODE
`./setup-master.sh`

## WORKER NODES
**master node**
- K3S_TOKEN

`sudo cat /var/lib/rancher/k3s/server/node-token`

- MASTER_IP

`hostname -I`

**worker node**

`K3S_TOKEN=<K3S_TOKEN>`

`MASTER_IP=<MASTER_IP>`

`K3S_NODE_NAME=$(hostname)`

`./setup-worker.sh $K3S_TOKEN $MASTER_IP $K3S_NODE_NAME`

## RANCHER
`./setup-rancher.sh`

- Get Password
`docker logs <container-id> 2>&1 | grep "Bootstrap Password"`

- Reset Password
`docker exec -it <container-id> reset-password`

- Watch Logs
`docker logs -f <container-id>`

- Import K3s Cluster to Rancher
`Go to Rancher & Create new cluster & Go to master node then run CMD - curl --insecure -sfL <CONFIG_YAML_URL> | kubectl apply -f -`

## K8S MANIFEST FILES
`kubectl apply -f manifest-deployment.yaml`

`kubectl apply -f manifest-service-nodeport.yaml`

## CHECK CLUSTER STATUSES
`kubectl get nodes -o wide`

`kubectl get pods -o wide`

`kubectl get services -o wide`