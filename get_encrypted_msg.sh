#!/bin/bash
#Jason Barnett - xasmodeanx@gmail.com
#
#

BIN="get_msg.sh"

#Make sure we got an argument specifying the token string
if [ -z "${1}" ]; then
        echo "Did not receive a token as an argument, call this script like:"
        echo "$0 mytokenstring myhost.example.com"
        exit 1
else
        TOKEN="${1}"
fi

#Make sure we have all the right dependencies installed
if [ -z "`which gpg2`" ]; then
	echo "gpg2 utility not found!"
	echo "Please install before proceeding. E.g. apt install gpg2"
	exit 1
fi

#Make sure we have access to file named by BIN 
BINPATH="`find . -type f -iname ${BIN}`"
if [ -z "${BINPATH}" ]; then
	echo "${BIN} was not found on this system within this directory or subdirectories.  Please obtain ${BIN} before proceeding."
	exit 2
fi

#Make sure we have a keys, messages and tokens directory before proceeding.
#These directories should have already been set up by the setup_gpg_identity.sh script
if ! [ -d "keys" -a -d "msgs" -a -d "tokens" ]; then
	echo "You must run setup_gpg_identity.sh first!"
	exit 3
fi

#Perform the operation
#Get the encrypted message file
${BINPATH} ${TOKEN}
#Decrypt the message file
gpg2 -o msgs/${TOKEN}.txt -d msgs/${TOKEN}.msg
echo "Done.  Message was:"
echo
echo
cat msgs/${TOKEN}.txt

exit 0
