#!/bin/bash
#Jason Barnett - xasmodeanx@gmail.com
#
#

BIN="ws_get.exe"
#Make sure we got an argument specifying the token string
if [ -z "${1}" ]; then
	echo "Did not receive a token as an argument, call this script like:"
	echo "$0 mytokenstring myhost.example.com"
	exit 1
else
	TOKEN="${1}"
fi
#check if we got an argument specifying what host we should post the message to
if [ "${2}" ]; then
	HOSTFQDN="${2}"
else
	HOSTFQDN="msgs.dspi.org"
fi

PORT="443"

#if our HOSTFQDN was from the keys.dspi.org domain, it's a good bet we
#are retrieving a pubkey and should store it in the keys folder
if [ "`echo ${HOSTFQDN} | grep key`" ]; then
	BINARGS="-s -H ${HOSTFQDN} -P ${PORT} -t ${TOKEN} -f keys/${TOKEN}.asc"
	MSGWASKEY="1"
else
	BINARGS="-s -H ${HOSTFQDN} -P ${PORT} -t ${TOKEN} -f msgs/${TOKEN}.msg"
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
echo "CMD: ${BINPATH} ${BINARGS}"
RESULT="`${BINPATH} ${BINARGS}`"

if [ "${MSGWASKEY}" ]; then
	#import the gpg key from the message we just received
	gpg2 --import "keys/${TOKEN}.asc"
	if [ "$?" ]; then	
		echo "Failed to import GPG key from keys/${TOKEN}.asc"
		echo "Maybe this wasn't a public key or it is already known to us?"
		exit 4
	else
		echo "Done. Wrote key to keys/${TOKEN}.asc"
		exit 0
	fi
fi

echo "Done. Wrote message to msgs/${TOKEN}.msg"
exit 0
