#!/bin/bash

# Argo CD web interface URL
ARGOCD_URL="https://localhost:8080"

check_argocd_status() {
    response=$(curl -k -s -o /dev/null -w "%{http_code}" $ARGOCD_URL)

    if [ $response -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

k3d cluster create part3 -c k3d.yaml
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

while true; do
    if check_argocd_status; then
        echo "Argo CD is up"
        break
    else
        echo "Argo CD is not up yet, waiting..."
        sleep 10
    fi
done

kubectl wait --for=condition=Ready pod -n argocd --all
kubectl apply -f myapp.yaml
argocd admin initial-password -n argocd
