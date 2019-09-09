#!/usr/bin/env bash
#
# This script launches an obfs4proxy docker container.  Don't start the docker
# container directly with docker.  We need this wrapper script because it
# automatically determines a random OR port and obfs4 port.
#
# Note that we link to this script from:
# <https://trac.torproject.org/projects/tor/wiki/doc/PluggableTransports/obfs4proxy>
# If we change the path to this script, we must update the above instructions.

# Get the bridge operator's email address.
if [ $# -ne 1 ]
then
    >&2 echo -e "Usage: $0 EMAIL_ADDR\n"
    >&2 echo "Please provide your email address so we're able to reach you in" \
             "case of problems with your bridge."
    exit 1
fi
EMAIL="$1"

function get_port {
    # Here's where the following code snippet comes from:
    # <https://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port>
    read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
    while :
    do
            port="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
            ss -lpn | grep -q ":$port" || break
    done
    echo "$port"
}

# Determine random ports.
OR_PORT=$(get_port)
PT_PORT=$(get_port)

# Keep getting a new PT port until it's different from our OR port.  This loop
# will only run if we happened to choose the same port for both variables, which
# is unlikely.
while [ "$PT_PORT" -eq "$OR_PORT" ]
do
    PT_PORT=$(get_port)
done

# Pass our two ports and email address to the container using environment
# variables.
docker run -d \
    -e "OR_PORT=$OR_PORT" -e "PT_PORT=$PT_PORT" -e "EMAIL=$EMAIL" \
    -p "$OR_PORT":"$OR_PORT" -p "$PT_PORT":"$PT_PORT" \
    phwinter/obfs4-bridge:0.2
