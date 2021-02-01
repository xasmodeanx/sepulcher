#!/bin/bash
#Jason Barnett - xasmodeanx@gmail.com
#
#

BIN="post_msg.sh"

#Check that we got all necessary arguments to post a message
if [ -z "${1}" ]; then
        echo "Did not receive an argument specifying the message file to operate on!"
	echo "Call this script with an argument specifying the message file and host to send it to"
	echo "E.g. $0 /path/to/my/messagefile recipientname"
        exit 4
#ensure that our argument is a file and exists
elif ! [ -e "${1}" ]; then
        echo "Received argument (${1}) did not exist!"
        exit 5
else
        MESSAGEFILE="${1}"
fi
#check if we got an argument specifying how we should encrypt the message for the recipient
if [ -z "${2}" ]; then
        echo "Did not receive an argument specifying a recipient so we couldn't encrypt the message for them."
	exit 2
else
	RECIPIENT="${2}"
fi

#Make sure we have all the right dependencies installed
if [ -z "`which gpg2`" ]; then
	echo "gpg2 utility not found!"
	echo "Please install before proceeding. E.g. apt install gpg2"
	exit 1
fi

#check to make sure the recipient named was valid
VALIDRECIPIENTS="`gpg2 --list-public-keys | grep '\[  full  \]' | awk '{print $5}'`"
for name in $VALIDRECIPIENTS; do
	if [ "${name}" == "${RECIPIENT}" ]; then
		echo "Found ${RECIPIENT} in gpg2 --list-public-keys"
		VALIDRECIPIENT="true"
	fi
done
if [ -z "${VALIDRECIPIENT}" ]; then
	echo "The recipient ${RECIPIENT} was not known to GPG.  Did you import their public key using their token with get_msg.sh?"
	echo "E.g. ./get_msg.sh recipientpublickeytoken"
	echo "Valid recipients are:"
	echo "$VALIDRECIPIENTS"
	exit 3
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
#Encrypt the message file
gpg2 -o ${MESSAGEFILE}.gpg -r ${RECIPIENT} -s -e ${MESSAGEFILE}
#Send the message
${BINPATH} ${MESSAGEFILE}.gpg

exit 0
