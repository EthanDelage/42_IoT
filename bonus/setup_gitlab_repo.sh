#!/bin/bash

source .env.example

GITLAB_TOOLBOX_POD_NAME=$(kubectl get pods -lapp=toolbox -n gitlab -ojsonpath='{.items[0].metadata.name}')

kubectl cp gitlab_create_user.rb gitlab/$GITLAB_TOOLBOX_POD_NAME:/tmp/gitlab_create_user.rb
kubectl exec -i -n gitlab $GITLAB_TOOLBOX_POD_NAME -- /bin/bash -c "\
        export GITLAB_USERNAME=$GITLAB_USERNAME &&\
        export GITLAB_EMAIL=$GITLAB_EMAIL &&\
        export GITLAB_NAME=$GITLAB_NAME &&\
        export GITLAB_PASSWORD=$GITLAB_PASSWORD &&\
        export GITLAB_PERSONAL_ACCESS_TOKEN=$GITLAB_PERSONAL_ACCESS_TOKEN &&\
        /srv/gitlab/bin/rails runner /tmp/gitlab_create_user.rb"

JSON_RESPONSE=$(curl -k --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_PERSONAL_ACCESS_TOKEN" \
        --header "Content-Type: application/json" \
        --data '{"name": "webapp","description": "webapp","path": "webapp","namespace": "webapp","initialize_with_readme": "false", "visibility": "public"}' \
        --url "http://localhost:8181/api/v4/projects/")

PROJECT_HTTP_URL=$(echo $JSON_RESPONSE | jq -r '.http_url_to_repo')
SSH_URL=$(echo $JSON_RESPONSE | jq -r '.ssh_url_to_repo')

git config --global user.name $GITLAB_USERNAME
git config --global user.email $GITLAB_EMAIL
git config --global init.defaultBranch main
git config --global http.sslVerify false # Allow self signed certificate

git init --initial-branch=main
git add .
git commit -m "feat: Initial commit"
git push http://$GITLAB_USERNAME:$GITLAB_PERSONAL_ACCESS_TOKEN@localhost:8181/$GITLAB_USERNAME/webapp.git

