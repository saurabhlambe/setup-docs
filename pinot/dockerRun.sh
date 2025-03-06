#!/bin/bash
echo "Acquiring the latest Pinot image from https://github.com/apache/pinot"
docker pull apachepinot/pinot:latest-arm64 >> /dev/null 2>&1
sleep 2
echo "Pulling the latest Zookeeper image from https://hub.docker.com/_/zookeeper"
docker pull --platform linux/arm64 zookeeper >> /dev/null 2>&1
echo "***************************************************"
sleep 2
echo "Deploying Zookeeper to run on port 2181"
docker run --network=pinot-demo --name pinot-zookeeper --restart always -p 2181:2181 --platform linux/arm64 -d zookeeper:3.5.9 >> /dev/null 2>&1
sleep 2
echo "Deploying Apache Pinot docker image to run on port 9000"
docker run -p 9000:9000 --name apache-pinot apachepinot/pinot:latest-arm64 QuickStart -type batch >> /dev/null 2>&1
echo "***************************************************"
echo "Pinot is deployed successfully. Browse to http://localhost:9000 to play around in the query console"
