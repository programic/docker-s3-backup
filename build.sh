#!/usr/bin/env bash

docker login
docker build -t programic/s3-backup:latest .
docker push programic/s3-backup:latest