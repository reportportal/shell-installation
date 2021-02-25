#!/bin/bash
# redirect stdout/stderr to a file
exec &> reportportal.log

# JAVA OPTS

# API
SERVICE_API_JAVA_OPTS="-Xms1024m -Xmx2048m"
# UAT
SERVICE_UAT_JAVA_OPTS="-Xms512m -Xmx512m"

# Requirements

RP_POSTGRES_USER=<your_rpdbuser>
RP_POSTGRES_PASSWORD=<your_rpdbuser_password>
RP_RABBITMQ_USER=<your_rpmquser>
RP_RABBITMQ_PASSWORD=<your_rpmquser_password>

# Deploy the services

# Traefik
./traefik --configFile=traefik.toml 2>&1 &

# service-migrations
PGPASSWORD=$RP_POSTGRES_PASSWORD psql -U $RP_POSTGRES_USER -d reportportal -a -f migrations/migrations/0_extensions.up.sql -f migrations/migrations/1_initialize_schema.up.sql -f migrations/migrations/2_initialize_quartz_schema.up.sql -f migrations/migrations/3_default_data.up.sql 2>&1 &

# service-index
RP_SERVER_PORT=9000 LB_URL=http://localhost:8081 ./service-index 2>&1 &

# service-api
RP_AMQP_HOST=localhost RP_AMQP_USER=$RP_RABBITMQ_USER RP_AMQP_PASS=$RP_RABBITMQ_PASSWORD RP_DB_USER=$RP_POSTGRES_USER RP_DB_PASS=$RP_POSTGRES_PASSWORD RP_DB_HOST=localhost java $SERVICE_API_JAVA_OPTS -jar service-api.jar 2>&1 &
​
# service-uat
RP_DB_HOST=localhost RP_DB_USER=$RP_POSTGRES_USER RP_DB_PASS=$RP_POSTGRES_PASSWORD java $SERVICE_UAT_JAVA_OPTS -jar service-uat.jar 2>&1 &

# service-ui
cd ui/ && RP_STATICS_PATH=../public RP_SERVER_PORT=3000 ./service-ui 2>&1 &

# service-analyzer
AMQP_URL="amqp://$RP_RABBITMQ_USER:$RP_RABBITMQ_PASSWORD@localhost:5672" ./service-analyzer 2>&1 &
