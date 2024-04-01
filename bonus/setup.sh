#!/bin/bash

# Argo CD web interface URL
ARGOCD_URL="https://localhost:8080"

# check_argocd_status() {
#     response=$(curl -k -s -o /dev/null -w "%{http_code}" $ARGOCD_URL)

#     if [ $response -eq 200 ]; then
#         return 0
#     else
#         return 1
#     fi
# }

# check_web_status(url) {
#     response=$(curl -k -s -o /dev/null -w "%{http_code}" $url)

#     if [ $response -eq 200 ]; then
#         return 0
#     else
#         return 1
#     fi
# }

# wait_web_status(url) {
#     while true; do
#         if check_web_status($url); then
#             echo "$url is ready"
#             break
#         else
#             echo "$url is not up yet, waiting..."
#             sleep 10
#         fi
#     done
# }

k3d cluster create bonus -c k3d.yaml

kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=example.com \
  --set certmanager-issuer.email=me@example.com \
  --set gitlab-runner.runners.privileged=true \
  --namespace gitlab

while true; do
  completed_pods=$(kubectl get pods -n gitlab --field-selector=status.phase==Succeeded -o json | jq -r '.items | length')
  ready_pods=$(kubectl get pods -n gitlab --field-selector=status.phase==Running -o json | jq -r '.items | length')
  total_pods=$(kubectl get pods -n gitlab -o json | jq -r '.items | length')
  
  if [ "$(($completed_pods + $ready_pods))" == "$total_pods" ]; then
    echo "Tous les pods sont à la fois Completed et Ready."
    break
  else
    echo "$completed_pods pods ont terminé et $ready_pods sont prêts sur un total de $total_pods. Attente..."
    sleep 5
  fi
done
#kubectl wait --for=condition=Ready pod -n gitlab --all --timeout=600s
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo


# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# kubectl wait --for=condition=Ready pod -n argocd --all
# kubectl apply -f myapp.yaml
# argocd admin initial-password -n argocd



