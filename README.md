# docker-obfs4-bridge

This repository contains the docker files for an obfs4 Tor bridge.

## Deploying the container

Do you want to deploy this docker container to run a Tor bridge?  Keep reading.
First, pull the image:

    docker pull phwinter/obfs4-bridge:0.1

Next, run the container.  The following script automatically finds an OR and
obfs4 port for you.  All you need to provide is your email address, so we can
get in touch with you if there are problems with your bridge:

    ./deploy-container.sh admin@example.com

If you would rather provide your own ports, run the following command:

    OR_PORT=XXX PT_PORT=YYY EMAIL=admin@example.com; \
    docker run -d \
      -e "OR_PORT=$OR_PORT" -e "PT_PORT=$PT_PORT" -e "EMAIL=$EMAIL" \
      -p "$OR_PORT":"$OR_PORT" -p "$PT_PORT":"$PT_PORT" \
      phwinter/obfs4-bridge:0.1

Replace `XXX` with your OR port, `YYY` with your obfs4 port, and
`admin@example.com` with your email address.  Don't forget the semicolon after
the enrivonment variables.  That's it!  Your container should now be
bootstrapping your new obfs4 Tor bridge.
