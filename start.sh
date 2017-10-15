#!/usr/bin/env bash

# Check for config.json
if [ -f config.json ]; then
	echo "It exists"
else
	echo "config.json doesn't exist...We need this to get moving"
	echo "Follow the README and create the config.json from the credentials page"
	exit 1
fi

# Build - check architecture
uname -a | grep -q armv
if [ $? -eq 0 ]; then
	echo "We're running on ARM"
	docker build -f Dockerfile.arm -t gdrive_sync .
else
	echo "We're running on x86"
	docker build -f Dockerfile.x86 -t gdrive_sync .
fi

# Check if config.json has been updated by first run
grep -q "refresh_token" config.json
if [ $? -eq 0 ]; then
	echo "You're config is all set!"
	docker run -d --name gdrive_sync -v $PWD/files:/files gdrive_sync
else
	echo "You need to authenticate to get started..."
	docker stop gdrive_sync && docker rm gdrive_sync
	docker run -it --rm -v $PWD/config.json:/root/config.json gdrive_sync
fi

