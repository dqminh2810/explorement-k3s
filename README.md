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

## LOAD BALANCER & K8S INGRESS

Client ---> LoadBalancer ---> (K8s cluster) IngressController ---> (K8s cluster) Service B
                                    |
                                    |
                         (K8s cluster) Service A

### K8S INGRESS CONTROLLER
*Install Nginx ingress controller having Node Port service*
`kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml`

*Create services*
`kubectl -n ingress-nginx apply -f fruit.yaml`

*Apply Ingress routing rules*
`kubectl -n ingress-nginx apply -f ingress-fruit.yaml`

*Test*
`curl -H "Host: fruit.com" http://<worker-IP>:<ingress-controller-NPservice-port>/apple`

`curl -H "Host: fruit.com" http://<worker-IP>:<ingress-controller-NPservice-port>/banana`

### LOAD BALANCER
*Install haproxy on master*

`. ./loadbalancer/install-haproxy.sh`

`cp loadbalancer/haproxy.cfg /etc/haproxy/haproxy.cfg` 

`haproxy -c -f /etc/haproxy/haproxy.cfg`

`sudo service haproxy restart`

*Browse <master-IP>:9000/haproxy?status  to check status*

*Modify hostname*
`/etc/hosts -> add <master-IP> fruit.test.com`

*Browse <master-IP>:8080/apple*

## CHECK CLUSTER STATUSES
`kubectl <-n namespace_name> get nodes -o wide`

`kubectl <-n namespace_name> get pods -o wide`

`kubectl <-n namespace_name> get services -o wide`