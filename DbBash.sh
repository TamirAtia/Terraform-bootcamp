#!/bin/bash

apt-get update

apt install docker.io -y

docker pull postgres:latest

docker run --restart always -d --name measurements -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' postgres