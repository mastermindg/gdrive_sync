#!/usr/bin/env bash

uname -a | grep -q armv
if [ $? -eq 0 ]; then
	image="mastermindg/gdrive_sync:arm"
else
	image="mastermindg/gdrive_sync:x86"
fi

# Direct user to issues
function issues {
	echo "Something went wrong...create an issue here: https://github.com/mastermindg/gdrive_sync/issues"
	exit 1
}

# Google Drive and Local Folder are stored locally in csv
# so we don't have to ask everytime and so the container
# can start on boot
# Check to see if they are set and add them if necessary
function checkforfolders {
	if [ ! -f folders.csv ]; then
		echo "folder,name" > folders.csv
	fi

	grep -q googlefolder folders.csv
	if [ $? -ne 0 ]; then
		echo "Which folder would you like to upload to?:"
		read googlefolder
		echo "googlefolder,$googlefolder" >> folders.csv
	fi

	grep -q localfolder folders.csv
	if [ $? -ne 0 ]; then
		echo "Which local folder do you want to sync to Google Drive? i.e. /myshare/files"
		read localfolder
		echo "localfolder,$localfolder" >> folders.csv
	fi
	echo -e "\tYour folders are set now! Let's start..."
}


function startit {
	echo "Pulling the most recent Docker image, this may take a bit..."
	docker pull $image > /dev/null 2>&1
	# Get the localfolder for mounting from the config
	mymount=$(grep localfolder folders.csv | awk -F "," '{print $2}' | xargs echo -n)
	# Docker will create the path if it's not there
	echo "Starting up the container now..."
	docker run -d --name gdrive_sync --restart always -v $PWD/config.json:/root/config.json:ro -v "$mymount":/files $image > /dev/null 2>&1
}

function buildit {
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
}


# Check for config.json
if [ ! -f config.json ]; then
	echo "config.json doesn't exist...We need this to get moving"
	echo "Follow the README and create the config.json from the credentials page"
	exit 1
fi

# Cleanup jic
echo "Cleaning up any running containers"
docker stop gdrive_sync > /dev/null 2>&1
docker rm gdrive_sync > /dev/null 2>&1

# Check if config.json has been updated by first run
grep -q "refresh_token" config.json
if [ $? -eq 0 ]; then
	echo "Your config is all set for syncing! Let's see what you want to sync..."
	checkforfolders
	startit
else
	echo "You need to authenticate to get started..."
	docker run -it --rm -v $PWD/config.json:/root/config.json $image ruby firstrun.rb
	if [ $? -eq 0 ]; then
		echo "Great...let's check the config again jic"
		grep -q "refresh_token" config.json
		if [ $? -eq 0 ]; then
			checkforfolders
			startit
		else
			issues
		fi
	else
		echo "Something went wrong with firstrun"
		exit 1
	fi
fi

