#!/usr/bin/env bash
set -e

REPO_URL_GOLANG="https://dl.bintray.com/epam/reportportal"
REPO_URL_JAR="https://dl.bintray.com/epam/reportportal/com/epam/reportportal"

# Versions of the services
SERVICE_API_VERSION="5.0.0-RC-2"
SERVICE_UAT_VERSION="5.0.0-RC-2"
SERVICE_UI_VERSION="5.0.0-RC-3"
SERVICE_ANALYZER_VERSION="5.0.0-RC-2"
SERVICE_INDEX_VERSION="5.0.4"
SERVICE_MIGRATIONS_VERSION="5.0.0-RC-2"

# Downloading

wget -c -N -O service-api.jar $REPO_URL_JAR/service-api/$SERVICE_API_VERSION/service-api-$SERVICE_API_VERSION.jar
wget -c -N -O service-uat.zip https://dl.bintray.com/epam/reportportal/com/epam/reportportal/service-authorization/$SERVICE_UAT_VERSION/service-authorization-$SERVICE_UAT_VERSION.zip && unzip service-uat.zip && mv service-authorization-$SERVICE_UAT_VERSION.jar service-uat.jar && rm -f service-uat.zip
wget -c -N -O service-analyzer $REPO_URL_GOLANG/$SERVICE_ANALYZER_VERSION/service-analyzer_linux_amd64
wget -c -N -O service-index $REPO_URL_GOLANG/$SERVICE_INDEX_VERSION/service-index_linux_amd64
wget -c -N -O migrations.zip https://github.com/reportportal/migrations/archive/$SERVICE_MIGRATIONS_VERSION.zip && unzip migrations.zip && mv migrations-$SERVICE_MIGRATIONS_VERSION migrations && rm -f migrations.zip

#UI
#https://github.com/reportportal/service-ui/blob/master/Dockerfile

mkdir ui
wget -c -N -O service-ui $REPO_URL_GOLANG/$SERVICE_UI_VERSION/service-ui_linux_amd64 && mv service-ui ui
chmod -R +x ui/*
wget -c -N -O ui.tar.gz $REPO_URL_GOLANG/$SERVICE_UI_VERSION/ui.tar.gz 
mkdir public
tar -zxvf ui.tar.gz -C public && rm -f ui.tar.gz

# GATEWAY

wget -c -N -O traefik https://github.com/containous/traefik/releases/download/v1.7.19/traefik_linux-amd64

# Traefik configuration file

wget -c -N -O traefik.toml https://raw.githubusercontent.com/reportportal/shell-installation/master/reportportal/traefik.toml


