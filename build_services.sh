#!/bin/bash

export DOCKER_DEFAULT_PLATFORM=linux/amd64
( cd data-model ; bal pack && bal push --repository local )
( cd entity_model ; bal persist generate && bal pack && bal push --repository local )
( cd user_service ; bal build --cloud=k8s)
( cd upload-service ; bal build --cloud=k8s)
( cd score_service ; bal build --cloud=k8s)
( cd executor-service ; bal build --cloud=k8s)
( cd contest-service ; bal build --cloud=k8s)
( cd challenge-service ; bal build --cloud=k8s)
( cd bff ; bal build --cloud=k8s)
