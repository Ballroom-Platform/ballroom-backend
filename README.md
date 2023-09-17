# Ballroom Backend

## Setup

Make sure you are in linux based operating system (or using WSL) when implementing the backend.
After cloning the repository, switch to "m2" branch and follow the steps provided below to setup the project.

1.) Replace place holders of `user_service/docker/Config.toml`, `user_service/k8s/Config.toml` with the asgardeo credentials.

2.) Run `./build_services` to build all ballerina packages and container images.

3.) Push the container images to docker hub if the docker deamon is not shared with kubernetes cluster.

## Run the services

### Docker Compose

1.) Run `docker compose up`in the repository root directory. 

2.) Once all services are up and running, launch the frontend application by running `npm start` in the frontend repo.

### Kubernetes

1.) Run `kubectl apply -k .`in the repository root directory. 

2.) Run `kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80` to expose the ingress to the host machine.

3.) Once all services are up and running, launch the frontend application by running `npm start` in the frontend repo.

## Setup Asgardeo account

You can follow the steps below to create an [Asgardeo](https://wso2.com/asgardeo/) account and obtain the necessary credentials:

1.) Create a ['Single Page Application'](https://wso2.com/asgardeo/docs/guides/applications/register-single-page-app/#get-the-client-id) in the Asgardeo Console. Use its client ID for the frontend. Use the refresh token grant type.

2.) Create a ['Standard Based Application'](https://wso2.com/asgardeo/docs/guides/applications/register-standard-based-app/#register-an-application) in the Asgardeo Console. Use its client ID and client secret for the backend.  Use the client credential grant type.

3.) Create [two Groups](https://wso2.com/asgardeo/docs/guides/users/manage-groups/#onboard-a-group) named 'Admin' and 'Contestant' in the Asgardeo Console. Use their IDs for the backend.