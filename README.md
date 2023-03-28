# Ballroom Backend

## Setup

After cloning the repository, switch to "m2" branch and follow the steps provided below to setup the project.

1.) First push the data model to the local repository by executing the pushtorepo.sh file in data model package directory using the following command, 
`./pushtorepo`

> Note: Set necessary permissions if needed using the following command and retry step 1.
`chmod +x pushtorepo.sh`

2.) Download and install the latest version of Docker and run the rabbitmq message broker using docker. Use the following command to do that,
`docker run --name rabbitmq -p 5672:5672 rabbitmq`

3.) Download and install mysql in your local environment.

4.) Create a database called "Ballroom" and add the necessary tables using the sql queries provided in the "queries.sql" file located in the data-model package directory.

> Note: You will have to manually copy paste the queries to create the required tables. 

5.) Create Config.toml files in every service and provided the details mentioned in Config-template.txt files provided within each service.

6.) Create a folder called "certificates" within the sts-service. Then create a subfolder called "jwt" within the "certificates" folder. Add your certificate and key file needed for JWT validation within this subfolder.

> Tip : Refer [this](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_key_and_cert.htm) to create a private Key and Self-Signed Digital Certificate.

> Note: Name the certificate "server.crt" and the key file as "server.key"

## Start the services

1.) Run `bal run` from within the rabbitmq package directory in order to declare the necessary queues.

2.) Go to each service (except the rabbitmq package) and start each service individually by running `bal run`.
