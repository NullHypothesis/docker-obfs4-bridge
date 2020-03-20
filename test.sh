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
						echo -e "\nTest failed."
						exit 1
				fi

				sleep ${SLEEP_TIME}
		done
}

check_for "Bootstrapped 0%"
check_for "Bootstrapped 100%"

echo -e "\nTest passed."
exit 0
