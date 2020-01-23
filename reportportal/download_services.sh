#!/usr/bin/env bash
set -e

REPO_URL_BASE="https://dl.bintray.com/epam/reportportal"
REPO_URL_JAR="$REPO_URL_BASE/com/epam/reportportal"

# Versions of the services
VERSION="5.0.0"
SERVICE_INDEX_VERSION="5.0.5"

# Downloading

wget -c -N -O service-api.jar ${REPO_URL_JAR}/service-api/${VERSION}/service-api-${VERSION}-exec.jar
wget -c -N -O service-uat.jar ${REPO_URL_JAR}/service-authorization/${VERSION}/service-authorization-${VERSION}-exec.jar
wget -c -N -O service-analyzer ${REPO_URL_BASE}/${VERSION}/service-analyzer_linux_amd64
wget -c -N -O service-index ${REPO_URL_BASE}/${SERVICE_INDEX_VERSION}/service-index_linux_amd64
wget -c -N -O migrations.zip https://github.com/reportportal/migrations/archive/${VERSION}.zip && unzip migrations.zip && mv migrations-${VERSION} migrations && rm -f migrations.zip

#UI
#https://github.com/reportportal/service-ui/blob/master/Dockerfile

mkdir ui
wget -c -N -O service-ui ${REPO_URL_BASE}/${VERSION}/service-ui_linux_amd64 && mv service-ui ui
chmod -R +x ui/*
wget -c -N -O ui.tar.gz ${REPO_URL_BASE}/${VERSION}/ui.tar.gz
mkdir public
tar -zxvf ui.tar.gz -C public && rm -f ui.tar.gz

# GATEWAY

wget -c -N -O traefik https://github.com/containous/traefik/releases/download/v1.7.19/traefik_linux-amd64

# Traefik configuration file

wget -c -N -O traefik.toml https://raw.githubusercontent.com/reportportal/shell-installation/master/reportportal/traefik.toml


