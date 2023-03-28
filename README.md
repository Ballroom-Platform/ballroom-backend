# ballerina-hackathon

First push the data model to the local repository

execute the pushtorepo.py file in data model package directory 
`./pushtorepo`

if permissions are not given then give permissions by 
`chmod +x pushtorepo.py` and retrying the above command

then run the rabbitmq message broker using docker
`docker run --name rabbitmq -p 5672:5672 rabbitmq`

then start each individual service by going to each package directory and execute `bal run`
