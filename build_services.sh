#!/bin/bash

( cd data-model ; bal pack && bal push --repository local )
( cd entity_model ; bal persist generate && bal pack && bal push --repository local )
( cd user_service ; bal build --cloud=docker)
( cd upload-service ; bal build --cloud=docker)
( cd score_service ; bal build --cloud=docker)
( cd executor-service ; bal build --cloud=docker)
( cd entity_model ; bal build --cloud=docker)
( cd data-model ; bal build --cloud=docker)
( cd contest-service ; bal build --cloud=docker)
( cd challenge-service ; bal build --cloud=docker)
( cd bff ; bal build --cloud=docker)
