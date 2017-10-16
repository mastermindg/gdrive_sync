#!/usr/bin/env bash

# Direct user to issues
function issues {
	echo "Something went wrong...create an issue here: https://github.com/mastermindg/gdrive_sync/issues"
	exit 1
}

# Check if subfolder is in the config for uploading to a specific folder
function checkforfolder {
	if [ ! -f nosubfolder ]; then
		grep -q subfolder config.json
		if [ $? -ne 0 ]; then
			echo "Do you want to upload to a specific folder in your Google Drive? ( Y for Yes, N for No):"
			read answer
			if [ "$answer" == "N" ] || [ "$answer" == "n" ]; then
				echo "OK...we won't ask you again"
				touch nosubfolder
			else
				echo "Which folder would you like to upload to?:"
				read subfolder
				sed -i '$ d' config.json
				echo -e "  \x22subfolder\x22: \x22$subfolder\x22\n}" >> config.json
				sed -i '/.*refresh_token/ s/$/,/' config.json
				echo "Make sure to add the folder in your Google Drive if it's not already there."
				echo "Files will be dropped in the root of your drive if the folder isn't there!"
			fi
		fi
	fi
}

function startit {
	echo "Let's get ready to start it!"
	echo "Which folder do you want to sync to Google Drive?: i.e. /myshare/files"
	read mymount
	# Docker will create the path if it's not there
	docker run -d --name gdrive_sync --restart always -v "$mymount":/files gdrive_sync #> /dev/null 2>&1
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
	echo "Your config is all set! Let's continue..."
	checkforfolder
	buildit
	startit
else
	echo "You need to authenticate to get started..."
	buildit
	docker run -it --rm -v $PWD/config.json:/root/config.json gdrive_sync ruby firstrun.rb
	if [ $? -eq 0 ]; then
		echo "Great...let's check the config again jic"
		grep -q "refresh_token" config.json
		if [ $? -eq 0 ]; then
			checkforfolder
			buildit
			startit
		else
			issues
		fi
	else
		echo "Something went wrong with firstrun"
		exit 1
	fi
fi

