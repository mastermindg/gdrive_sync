#!/usr/bin/env bash

# Check architecture
uname -a | grep -q armv
if [ $? -eq 0 ]; then
	echo "We're running on ARM"
	docker build -f Dockerfile.arm -t gdrive_sync .
else
	echo "We're running on x86"
	docker build -f Dockerfile.x86 -t gdrive_sync .
fi

docker stop gdrive_sync
docker rm gdrive_sync
docker run -d --name gdrive_sync -v $PWD/files:/files gdrive_sync
#docker exec -it gdrive_sync bash
