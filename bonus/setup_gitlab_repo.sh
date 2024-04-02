#!/bin/bash

GITLAB_TOOLBOX_POD_NAME=$(kubectl get pods -lapp=toolbox -n gitlab -ojsonpath='{.items[0].metadata.name}')

kubectl cp   gitlab_create_user.rb gitlab/$GITLAB_TOOLBOX_POD_NAME:/tmp/test.rb
kubectl exec -i -n gitlab $GITLAB_TOOLBOX_POD_NAME -- /srv/gitlab/bin/rails runner /tmp/test.rb

JSON_RESPONSE=$(curl -k --request POST \
        --header "PRIVATE-TOKEN: abcd1234" \
        --header "Content-Type: application/json" \
        --data '{"name": "webapp","description": "webapp","path": "webapp","namespace": "webapp","initialize_with_readme": "true"}' \
        --url "https://gitlab.example.com:1080/api/v4/projects/")

HTTP_URL=$(echo $JSON_RESPONSE | jq -r '.http_url_to_repo')
SSH_URL=$(echo $JSON_RESPONSE | jq -r '.ssh_url_to_repo')
