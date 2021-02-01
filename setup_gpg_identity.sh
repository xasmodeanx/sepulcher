#!/bin/bash 
#Jason Barnett - xasmodeanx@gmail.com
#
#

BIN="post_msg.sh"
SERVER="keys.dspi.org"

#Make sure we have all the right dependencies installed
if [ -z "`which gpg2`" ]; then
        echo "gpg2 utility not found!"
        echo "Please install before proceeding. E.g. apt install gpg2"
        exit 1
fi

#Make sure we have the ws_post.exe utility ready to go
BINPATH="`find . -type f -iname ${BIN}`"
if [ -z "${BINPATH}" ]; then
        echo "${BIN} was not found on this system within this directory or subdirectories.  Please obtain ${BIN} before proceeding."
        exit 2
fi

#Check to see if we already have a private key known to gpg2, if not, generate one
if [ -z "gpg2 --list-secret-keys | grep ultimate" ]; then
	gpg2 --full-gen-key
	#Make sure our gpg2 setup returned success, bail out otherwise
	if ! [ -z "$?" ]; then
		echo "gpg2 command failed to complete successfully."
		exit 2
	fi
fi

#Grab the serial number of our private key from GPG so that we can do operations with it
MYSERIAL="`gpg2 --list-secret-keys | grep -B1 ultimate | awk '{print $1}' | head -n1`"
#we now have enough information to set up the directory structure and prep for message GETS and POSTS
mkdir -p keys msgs tokens
#export our public key
gpg2 -a -o keys/mypubkey.asc --export ${MYSERIAL}

#Post our public key to the server
echo "${BINPATH} keys/mypubkey.asc ${SERVER}"
${BINPATH} keys/mypubkey.asc ${SERVER}

echo "Done. Share this identity with others by sending them your token!"
exit 0
