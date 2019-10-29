# docker-obfs4-bridge

This repository contains the docker files for an obfs4 Tor bridge.

## Deploying the container

Do you want to deploy this docker container to run a Tor bridge?  Keep reading.
First, pull the image:

    docker pull phwinter/obfs4-bridge:latest

Next, run the container.  The following script automatically finds an OR and
obfs4 port for you.  All you need to provide is your email address, so we can
get in touch with you if there are problems with your bridge:

    ./deploy-container.sh admin@example.com

If you would rather provide your own ports, run the following command:

    OR_PORT=XXX PT_PORT=YYY EMAIL=admin@example.com; \
    docker run -d \
      -e "OR_PORT=$OR_PORT" -e "PT_PORT=$PT_PORT" -e "EMAIL=$EMAIL" \
      -p "$OR_PORT":"$OR_PORT" -p "$PT_PORT":"$PT_PORT" \
      phwinter/obfs4-bridge:latest

Replace `XXX` with your OR port, `YYY` with your obfs4 port, and
`admin@example.com` with your email address.  Don't forget the semicolon after
the enrivonment variables.  That's it!  Your container should now be
bootstrapping your new obfs4 Tor bridge.

## Getting the bridge's bridge line

To use your bridge in Tor Browser, you need its "bridge line".  Here's how you
can get your bridge line:

    docker exec CONTAINER get-bridge-line

This will return a string similar to the following:

    obfs4 1.2.3.4:1234 B0E566C9031657EA7ED3FC9D248E8AC4F37635A4 cert=OYWq67L7MDApdJCctUAF7rX8LHvMxvIBPHOoAp0+YXzlQdsxhw6EapaMNwbbGICkpY8CPQ iat-mode=0
