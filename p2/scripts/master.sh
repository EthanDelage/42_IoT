#!/bin/bash

apt-get update -y
apt-get install curl -y

export INSTALL_K3S_VERSION="v1.28.7+k3s1"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -

# app1
kubectl apply -f configs/app1/deployment.yaml
kubectl apply -f configs/app1/service.yaml
kubectl apply -f configs/app1/ingress.yaml

# app2
kubectl apply -f configs/app2/deployment.yaml
kubectl apply -f configs/app2/service.yaml
kubectl apply -f configs/app2/ingress.yaml

# app3
kubectl apply -f configs/app3/deployment.yaml
kubectl apply -f configs/app3/service.yaml
kubectl apply -f configs/app3/ingress.yaml


