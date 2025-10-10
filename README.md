# explorement-k3s
Learn K8s components architecture and how to management

[INFRASTRUCTURE](#INFRASTRUCTURE)  
[DOCKER REPOSITORY](#SETUP-CREDENTIAL-FOR-DOCKER-REPOSITORY)  
[LOAD BALANCER & K8S INGRESS](#LOAD-BALANCER-&-K8S-INGRESS)  
[ROLLING UPDATE](#ROLLING-UPDATE)  
[HORIZONTAL POD AUTOSCALING](#HORIZONTAL-POD-AUTOSCALING)


<a name="INFRASTRUCTURE"/>

## INFRASTRUCTURE
### REQUIREMENTS
- OS `Debian arm64`

- MASTER NODE `2 cores, 4GB RAM, 30GB DISK `

- WORKER NODES `2 cores, 2GB RAM, 30GB DISK `

- RANCHER `2 cores, 4GB RAM, 30GB DISK `

### LOCAL (VMware) - MANUALLY SETUP
**VMware** `https://cloudviet.com.vn/download-vmware-workstation-pro-16-full-key-phan-mem-ao-hoa-quyen-nang-nhat/`

**OS - DEBIAN** `https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/mini.iso`

**Disable GUI**

`sudo systemctl set-default multi-user.target`

`sudo reboot`

**INSTALL DOCKER**
K3s includes and defaults to containerd, an industry-standard container runtime. As of Kubernetes 1.24, the Kubelet no longer includes dockershim, the component that allows the kubelet to communicate with dockerd. K3s 1.24 and higher include cri-dockerd, which allows seamless upgrade from prior releases of K3s while continuing to use the Docker container runtime.

`./install-docker`

**MASTER NODE**
`./setup-master.sh` || `./setup-docker.sh --docker`

**WORKER NODES**
***master node***
- K3S_TOKEN

`sudo cat /var/lib/rancher/k3s/server/node-token`

- MASTER_IP

`hostname -I`

***worker node***

`K3S_TOKEN=<K3S_TOKEN>`

`MASTER_IP=<MASTER_IP>`

`K3S_NODE_NAME=$(hostname)`

`./setup-worker.sh $K3S_TOKEN $MASTER_IP $K3S_NODE_NAME`

**RANCHER**
`./setup-rancher.sh`

- Get Password
`docker logs <container-id> 2>&1 | grep "Bootstrap Password"`

- Reset Password
`docker exec -it <container-id> reset-password`

- Watch Logs
`docker logs -f <container-id>`

- Import K3s Cluster to Rancher
`Go to Rancher & Create new cluster & Go to master node then run CMD - curl --insecure -sfL <CONFIG_YAML_URL> | kubectl apply -f -`

### AWS (EC2) - SETUP K3S CLUSTER BY TERRAFORM
`cd terraform`

`ssh-keygen -t ed25519 -f ./ssh/k3s-cluster-key`

`terraform init`

`terraform plan`

`terraform apply --without-approve`

`terraform destroy --without-approve`

<a name="SETUP-CREDENTIAL-FOR-DOCKER-REPOSITORY"/>

## SETUP CREDENTIAL FOR DOCKER REPOSITORY
`
k3s kubectl create secret docker-registry docker-reg-creds \
      --docker-server=<your-registry-server> \
      --docker-username=<your-username> \
      --docker-password=<your-password> \
      --docker-email=<your-email>
`

<a name="LOAD-BALANCER-&-K8S-INGRESS"/>

## LOAD BALANCER & K8S INGRESS

Client ---> LoadBalancer (HAProxy) ---> (K8s cluster) IngressController ---> (K8s cluster) Service B
                                                            |
                                                            |
                                                (K8s cluster) Service A
                                                
### K8S INGRESS CONTROLLER
*Install Nginx ingress controller having Node Port service*

`kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml`

*Create deployment + apply ingress rules*

`kubectl apply -f test.yaml`

*Test*

`curl -H "Host: myapp.example.com" http://<worker-IP>:<ingress-controller-NPservice-port>/`

### LOAD BALANCER
**Master node**

`. ./loadbalancer/install-haproxy.sh`

`cp loadbalancer/haproxy.cfg /etc/haproxy/haproxy.cfg` 

`haproxy -c -f /etc/haproxy/haproxy.cfg`

`sudo service haproxy restart`

`Browse <master-IP>:9000/haproxy?stats  to check status`

**Client Machine**

`C:\Windows\System32\drivers\etc\hosts || /etc/hosts  --->  <master-IP> myapp.example.com`

`Browse myapp.example.com:8080`

<a name="ROLLING-UPDATE"/>

## ROLLING UPDATE

*Update the image*

`kubectl -n <namespace_name> set image deployment/my-app my-app=nginx:1.26-alpine`

*Monitor the rollout status*

`kubectl -n <namespace_name> rollout status deployment/my-app`

<a name="HORIZONTAL-POD-AUTOSCALING"/>

## HORIZONTAL POD AUTOSCALING

*Simulate high CPU load with new terminals*

`while true; do wget -q -O- http://myapp.example.com; done`

*Watch HPA stastus*

`kubectl -n <namespace_name> get hpa -w`

*Watch Pod stastus*

`kubectl -n <namespace_name> get pod -w`