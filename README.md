# explorement-k3s
Learn K8s components architecture and how to management

## INFRASTRUCTURE
**VMware** `https://cloudviet.com.vn/download-vmware-workstation-pro-16-full-key-phan-mem-ao-hoa-quyen-nang-nhat/`

**OS - DEBIAN** `https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/mini.iso`
- MASTER NODE

`2 cores, 2GB RAM, 30GB DISK `

- WORKER NODES

`2 cores, 2GB RAM, 30GB DISK `

- RANCHER

`2 cores, 4GB RAM, 30GB DISK `

**Disable GUI**

`sudo systemctl set-default multi-user.target`

`sudo reboot`

## INSTALL DOCKER
K3s includes and defaults to containerd, an industry-standard container runtime. As of Kubernetes 1.24, the Kubelet no longer includes dockershim, the component that allows the kubelet to communicate with dockerd. K3s 1.24 and higher include cri-dockerd, which allows seamless upgrade from prior releases of K3s while continuing to use the Docker container runtime.

`./install-docker`

## MASTER NODE
`./setup-master.sh` || `./setup-docker.sh --docker`

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

## SETUP CREDENTIAL FOR DOCKER REPOSITORY
`
k3s kubectl create secret docker-registry docker-reg-creds \
      --docker-server=<your-registry-server> \
      --docker-username=<your-username> \
      --docker-password=<your-password> \
      --docker-email=<your-email>
`

## K8S MANIFEST FILES
`kubectl apply -f manifest-deployment-nginx.yaml`

`kubectl apply -f manifest-deployment-alpine.yaml`

`kubectl apply -f manifest-service-nodeport.yaml`

## CHECK CLUSTER STATUSES
`kubectl get nodes -o wide`

`kubectl get pods -o wide`

`kubectl get services -o wide`