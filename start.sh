#!/usr/bin/env bash

# Direct user to issues
function issues {
	echo "Something went wrong...create an issue here: https://github.com/mastermindg/gdrive_sync/issues"
	exit 1
}

# Check if subfolder is in the config for uploading to a specific folder
function checkforfolder {
	grep -q subfolder config.json
	echo "Do you want to upload to a specific folder in your Google Drive? ( Y for Yes, N for No):"
	read answer
	if [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
		echo "OK...we won't ask you again"
	else
		echo "Which folder would you like to upload to?:"
		read subfolder
		echo $subfolder
		sed -i '$ d' config.json
		echo e "\t$subfolder\n}" >> config.json
	fi
}

# Check for config.json
if [ ! -f config.json ]; then
	echo "config.json doesn't exist...We need this to get moving"
	echo "Follow the README and create the config.json from the credentials page"
	exit 1
fi

# Build - check architecture
uname -a | grep -q armv
if [ $? -eq 0 ]; then
	echo "You're running on ARM. Let's build an image for you..."
	docker build -f Dockerfile.arm -t gdrive_sync . > /dev/null 2>&1
else
	echo "You're running on x86. Let's build an image for you..."
	docker build -f Dockerfile.x86 -t gdrive_sync . > /dev/null 2>&1
fi

if [ $? -eq 0 ]; then
	echo -e "\tDocker image has been built"
else
	echo -e "\tSomthing went wrong with the build"
	issues
fi

# Cleanup jic
echo "Cleaning up any running containers"
docker stop gdrive_sync > /dev/null 2>&1
docker rm gdrive_sync > /dev/null 2>&1

# Check if config.json has been updated by first run
grep -q "refresh_token" config.json
if [ $? -eq 0 ]; then
	echo "You're config is all set! Starting the container..."
	checkforfolder
	exit
	docker run -d --name gdrive_sync -v $PWD/files:/files gdrive_sync > /dev/null 2>&1
else
	echo "You need to authenticate to get started..."
	docker run -it --rm -v $PWD/config.json:/root/config.json gdrive_sync ruby firstrun.rb
	echo "Great...let's check the config again jic"
	grep -q "refresh_token" config.json
	if [ $? -eq 0 ]; then
		echo "You're config is all set!"
		echo "Type the year that you want to check (4 digits), followed by [ENTER]:"
		read year

		docker run -d --name gdrive_sync -v $PWD/files:/files gdrive_sync > /dev/null 2>&1
	else
		issues
	fi
fi

