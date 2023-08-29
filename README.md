# Ballroom Backend

## Setup

Make sure you are in linux based operating system (or using WSL) when implementing the backend.
After cloning the repository, switch to "m2" branch and follow the steps provided below to setup the project.

1.) Replace place holders of `user_service/docker/Config.toml` with the asgardeo credentials.

2.) Run `./build_services` to build all ballerina packages and container images.

## Run the services

1.) Run `docker compose up`in the repository root directory. 

2.) Once all services are up and running, launch the frontend application by running `npm start` in the frontend repo.

