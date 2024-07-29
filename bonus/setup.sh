#!/bin/bash

# Function to wait until all pods in a namespace are ready
wait_for_pods_ready() {
  local namespace=$1
  local completed_pods
  local ready_pods
  local total_pods

  while true; do
    completed_pods=$(kubectl get pods -n "$namespace" --field-selector=status.phase==Succeeded -o json | jq -r '.items | length')
    ready_pods=$(kubectl get pods -n "$namespace" -o json | jq -r '
  .items[] |
  select(
    (.status.containerStatuses | map(select(.ready == true)) | length) == (.status.containerStatuses | length)
  ) |
  .metadata.name
' | wc -l)
    total_pods=$(kubectl get pods -n "$namespace" -o json | jq -r '.items | length')

    if [ "$(($completed_pods + $ready_pods))" == "$total_pods" ]; then
      echo "All pods are both Completed and Ready."
      break
    else
      echo "$completed_pods pods have completed and $ready_pods are ready out of $total_pods. Waiting..."
      sleep 5
    fi
  done
}

# Create k3d cluster
k3d cluster create bonus -c k3d.yaml

# Create gitlab namespace
kubectl create namespace gitlab

# Add GitLab Helm repo
helm repo add gitlab https://charts.gitlab.io/

# Install GitLab using Helm
helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.hosts.gitlab.https=false \
  --set certmanager-issuer.email=me@example.com \
  --set gitlab-runner.install=false \
  --namespace gitlab

# Wait until all pods in the gitlab namespace are ready
wait_for_pods_ready "gitlab"

# Display GitLab's initial root password
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

# Setup port forwarding
kubectl port-forward service/gitlab-webservice-default --address 0.0.0.0 -n gitlab 8181:8181 2>&1 >/dev/null &

# Run setup_gitlab_repo.sh script
bash setup_gitlab_repo.sh

# Uncomment for installing ArgoCD and deploying an application
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
wait_for_pods_ready "argocd"
kubectl apply -f myapp.yaml
argocd admin initial-password -n argocd
kubectl port-forward service/argocd-server --address 0.0.0.0 -n argocd 8080:443 2>&1 >/dev/null &
