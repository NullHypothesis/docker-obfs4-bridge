#!/usr/bin/env bash

if [ ! "${GITHUB_TOKEN}" ];
then
	echo "GITHUB_TOKEN variable needs to be defined before run the script"
	exit 1
fi

RELEASE_FILE=/tmp/InRelease

# This variables can be put all into .env file maybe changin their name.
OWNER=$(grep "IMAGE=" .env | sed "s/IMAGE=//" | sed "s/\/.*//")
REPO=docker-obfs4-bridge

# Verifying the signature of the message
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import 2> /dev/null
wget -qP /tmp https://deb.torproject.org/torproject.org/dists/stable/InRelease
gpg --verify ${RELEASE_FILE} 2> /dev/null

if [ ! $? ];
then
	echo "Signature verification failed."
	exit 1
fi;

RELEASE_DATE=$(grep "Date:" ${RELEASE_FILE} | sed "s/Date: //")
RELEASE_DATE_SECS=$(date -d "${RELEASE_DATE}" "+%s")

if [ -f "release_date.txt" ];
then
    LAST_RELEASE_DATE=$(date -d "$(cat release_date.txt)" "+%s")
else
    LAST_RELEASE_DATE=0
fi

if [ ${RELEASE_DATE_SECS} -le ${LAST_RELEASE_DATE} ];
then
	echo "The last version was already built and deployed."
	exit 0
fi

VERSION=$( \
	wget -qO- https://deb.torproject.org/torproject.org/dists/stable/main/binary-amd64/Packages | \
	grep -A1 "^Package: tor$" | \
	grep "^Version:" | \
	sed "s/Version: //" | sed "s/~.*//")

# Trigger github in order to test and build the new docker image.
curl \
	-H "Accept: application/vnd.github.everest-preview+json" \
	-H "Authorization: token ${GITHUB_TOKEN}" \
	--request POST \
	--data '{"event_type": "new-release", "client_payload": {"version": "'"${VERSION}"'"}}' \
	https://api.github.com/repos/${OWNER}/${REPO}/dispatches

echo "Writing new release date to file."
echo ${RELEASE_DATE} > release_date.txt