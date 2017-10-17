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

# Google Drive and Local Folder are stored in the config
# Check the config and if they're not there then prompt 
# and add them
function checkforfolders {
	grep -q subfolder config.json
	if [ $? -ne 0 ]; then
		echo "Which folder would you like to upload to?:"
		read subfolder
		sed -i '$ d' config.json
		echo -e "  \x22subfolder\x22: \x22$subfolder\x22," >> config.json
		sed -i '/.*refresh_token/ s/$/,/' config.json
	fi

	grep -q localfolder config.json
	if [ $? -ne 0 ]; then
		echo "Which local folder do you want to sync to Google Drive? i.e. /myshare/files"
		read localfolder
		echo -e "  \x22localfolder\x22: \x22$localfolder\x22\n}" >> config.json
	fi
}


function startit {
	echo "Let's get ready to start it!"
	#echo "Which folder do you want to sync to Google Drive?: i.e. /myshare/files"
	#read mymount
	docker pull $image > /dev/null 2>&1
	# Docker will create the path if it's not there
	docker run -d --name gdrive_sync --restart always -v $PWD/config.json:/root/config.json -v "$mymount":/files $image > /dev/null 2>&1
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
	#startit
else
	echo "You need to authenticate to get started..."
	#buildit
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

