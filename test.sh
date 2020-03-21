#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Tries after which the test fails.
MAX_TRIES=3

# Bootstrap requires time then the sleeping time between attemps should be long.
SLEEP_TIME=10s

TOR_LOG=/var/log/tor/log

check_for ()
{
		echo -n "[    ] ${1}"
		for i in $(seq 1 ${MAX_TRIES});
		do
				if grep -q "${1}" ${TOR_LOG}; then
						echo -e "\r[${GREEN} ok ${RESET}] ${1}"
						break
				fi

				if [[ $i == ${MAX_TRIES} ]]; then
						echo -e "\r[${RED} failed ${RESET}] ${1}"
						echo -e "\nTest of the bootstrap phase failed."
						exit 1
				fi

				sleep ${SLEEP_TIME}
		done
}

check_for "Bootstrapped 0%"
check_for "Bootstrapped 100%"

# Test get-bridge-line script
get-bridge-line | grep -qE "obfs4 ([0-9]{1,3}(\.|:)){4}[0-9]{1,5} [a-zA-Z0-9]{40} cert=[a-zA-Z0-9,\/]{70} iat-mode=0"

if [ ! $? ];
then
	echo "Test of the get-bridge-line script failed."
	exit 1
fi

echo -e "\nTests passed."
exit 0
