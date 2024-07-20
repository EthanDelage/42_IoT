#!/bin/bash

apt-get update -y
apt-get install curl -y

export INSTALL_K3S_VERSION="v1.28.7+k3s1"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -

cp /var/lib/rancher/k3s/server/node-token $NODE_TOKEN_PATH
