# Commands to use

## Cleanup

Cleanup:
kubectl config unset contexts
kubectl config unset users
kubectl config unset clusters
kubectl config unset current-context
Remove-Item Alias:k
Remove-Item -Path "C:\dockerk8sworkshop" -Recurse -Force 
Copy-Item -Path "C:\Users\BaptistePA\OneDrive - Skyline Communications NV\DockerWs\dockerk8sworkshop" -Destination c:\ -Recurse
cd "C:\dockerk8sworkshop"

## Connect to cluster

kubectl get ns
kubectl config view
az aks get-credentials –g cca-develop-weu –n cca-develop
kubectl config view 
kubectl get ns
kubectl config view
Set-Alias –Name k –Value kubectl
k get ns
k get pods –n test1
k get all -A

## Create namespace

k get pods –n dev
k create ns workshop 
k get all –n workshop
k config view
k config set-context --current --namespace=workshop
k get pods
k get pods -n dev
k get all

## Pods

k run nginx --image=nginx --restart=Never --labels=“app=poddemo”
k get pods -o wide
k get pods --show-labels
k exec --stdin --tty nginx -- /bin/sh
ls
ifconfig
apt update
apt install net-tools
apt install wget
wget 127.0.0.1
ifconfig

k logs –f nginx

wget 127.0.0.1
wget 127.0.0.1/admin
touch /usr/share/nginx/html/admin 

k run nginx2 --image=nginx --restart=Never --labels="app=poddemo"

k get pods --show-labels
k get all –l app=poddemo
k delete pod --all
k get pods

## Nodes

k get nodes
k get node aks-agentpool-23858973-vmss000000 -o wide
k describe node aks-agentpool-23858973-vmss000000
k cordon aks-agentpool-23858973-vmss000000
k get pods --all-namespaces -o wide --field-selector spec.nodeName=aks-agentpool-23858973-vmss000000s –w
k drain aks-agentpool-23858973-vmss000000 --delete-emptydir-data --ignore-daemonsets --force

k get pods --all-namespaces -o wide --field-selector spec.nodeName=aks-agentpool-23858973-vmss000000 –w
k drain aks-agentpool-23858973-vmss000001 --delete-emptydir-data --ignore-daemonsets --force
k uncordon aks-agentpool-23858973-vmss000000
k uncordon aks-agentpool-23858973-vmss000001

k top node

## Replicasets

k apply -f ./k8s/nginx.yaml
k get pods
k get rs
k scale --replicas=5 rs nginx
k get pods -w
k get rs
k scale --replicas=1 rs nginx
k get pods
k get rs

k apply -f ./k8s/nginxv2.yaml
k get rs
k scale --replicas=0 rs nginx
k scale --replicas=3 rs nginxv2

k apply -f ./k8s/redis.yaml
k get all --show-labels
k get pods -l tier=frontend,version=v1
k get pods -l tier=frontend
k get pods -l tier=backend

## Deployments

k apply –f ./k8s/depl.yaml
k get pods,rs,deployments
k describe deployment nginx-deployment
k get pods –w

k set image deployment/nginx-deployment nginx=nginx:1.23.1
k get rs -w
k describe deployment nginx-deployment 

k set image deployment/nginx-deployment nginx=nginx:1.22.13
k get rs -w
k set image deployment/nginx-deployment nginx=nginx:1.22.1
k get rs –w
k get rs

## Jobs

k apply -f .\k8s\job.yaml
k get jobs
k get pods
k logs <pod id>
k get jobs
k get pods

## Liveness Probe

k apply -f .\k8s\liveness.yaml
k get pods –w
k get event --field-selector involvedObject.name=liveness-exec3 -w
k apply -f .\k8s\livenessv2.yaml
k get event --field-selector involvedObject.name=liveness-exec1 -w
k get pods -w