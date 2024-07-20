#!/bin/bash

apt-get update -y
apt-get install curl -y

export INSTALL_K3S_VERSION="v1.28.7+k3s1"
export K3S_KUBECONFIG_MODE="644"
export K3S_URL="https://$MASTER_IP:6443"
export K3S_TOKEN_FILE=$NODE_TOKEN_PATH
export INSTALL_K3S_EXEC="--flannel-iface=eth1"

curl -sfL https://get.k3s.io | sh -
