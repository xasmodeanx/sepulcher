#!/bin/bash
#Jason Barnett - xasmodeanx@gmail.com
#
#

BIN="ws_post.exe"

#Check that we got all necessary arguments to post a message
if [ -z "${1}" ]; then
        echo "Did not receive an argument specifying the message file to operate on!"
	echo "Call this script with an argument specifying the message file and host to send it to"
	echo "E.g. $0 /path/to/my/messagefile msgs.dspi.org"
        exit 4
#ensure that our argument is a file and exists
elif ! [ -e "${1}" ]; then
        echo "Received argument (${1}) did not exist!"
        exit 5
else
        MESSAGEFILE="${1}"
fi

#check if we got an argument specifying what host we should post the message to
if [ "${2}" ]; then
	HOSTFQDN="${2}"
else
	HOSTFQDN="msgs.dspi.org"
fi

PORT="443"
BINARGS="-c -v -s -H ${HOSTFQDN} -P ${PORT} -a 4"

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
echo "CMD: ${BINPATH} ${BINARGS} -f ${MESSAGEFILE}"
RESPONSE="`${BINPATH} ${BINARGS} -f ${MESSAGEFILE}`"
TOKEN="`echo \"${RESPONSE}\" | grep Token | awk '{print $2}'`"

#If we got a token, write it to our tokens directory
if [ "${TOKEN}" ]; then
	#echo "basename of messagefile was `basename ${MESSAGEFILE}` and token was ${TOKEN}"
	echo "${TOKEN}" >> tokens/"`basename ${MESSAGEFILE}`-POST.token"
	echo "Message file ${MESSAGEFILE} sent to ${HOSTFQDN} and received message token: ${TOKEN}"
else
	echo "Something went wrong while posting the message!"
	echo "${RESPONSE}"
	exit 6
fi

echo "Done. Message file ${MESSAGEFILE} sent to ${HOSTFQDN} and received message token: ${TOKEN}"
exit 0
