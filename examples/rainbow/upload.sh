#!/bin/sh

#
# Upload new firmware to a target running nerves_firmware_ssh
#
# Usage:
#   upload.sh [destination IP] [Path to .fw file]
#
# If unspecifed, the destination is nerves.local and the .fw file
# is naively guessed
#
# You may want to add the following to your `~/.ssh/config` to avoid
# recording the IP addresses of the target:
#
# Host nerves.local
#   UserKnownHostsFile /dev/null
#   StrictHostKeyChecking no
#
# Feel free to copy this script whereever is convenient. The template
# is at
# https://github.com/nerves-project/nerves_firmware_ssh/blob/master/priv/templates/script.upload.eex
#

set -e

DESTINATION=$1
FILENAME="$2"

help() {
    echo
    echo "upload.sh [destination IP] [Path to .fw file]"
    echo
    echo "Default destination IP is 'nerves.local'"
    echo "Default firmware bundle is the first .fw file in '_build/\$MIX_TARGET/\$MIX_ENV/nerves/images'"
    exit 1
}

[ -n "$DESTINATION" ] || DESTINATION=nerves.local
[ -n "$MIX_TARGET" ] || MIX_TARGET=rpi0
[ -n "$MIX_ENV" ] || MIX_ENV=dev
[ -n "$FILENAME" ] || FILENAME=$(ls ./_build/$MIX_TARGET/$MIX_ENV/nerves/images/*.fw 2> /dev/null | head -n 1)

[ -n "$FILENAME" ] || (echo "Error: error determining firmware bundle."; help)
[ -f "$FILENAME" ] || (echo "Error: can't find '$FILENAME'"; help)

# Check the flavor of stat
if stat --version 2>/dev/null | grep GNU >/dev/null; then
    # The QNU way
    FILESIZE=$(stat -c%s "$FILENAME")
else
    # Else default to the BSD way
    FILESIZE=$(stat -f %z "$FILENAME")
fi

echo "Uploading $FILENAME to $DESTINATION..."

# Don't fall back to asking for passwords, since that won't work
# and it's easy to misread the message thinking that it's asking
# for the private key password
SSH_OPTIONS="-o PreferredAuthentications=publickey"

if [ "$(uname -s)" = "Darwin" ]; then
    DESTINATION_IP=$(arp -n $DESTINATION | sed 's/.* (\([0-9.]*\).*/\1/' || exit 0)
    if [ -z "$DESTINATION_IP" ]; then
        echo "Can't resolve $DESTINATION"
        exit 1
    fi
    TEST_DESTINATION_IP=$(printf "$DESTINATION_IP" | head -n 1)
    if [ "$DESTINATION_IP" != "$TEST_DESTINATION_IP" ]; then
        echo "Multiple destination IP addresses for $DESTINATION found:"
        echo "$DESTINATION_IP"
        echo "Guessing the first one..."
        DESTINATION_IP=$TEST_DESTINATION_IP
    fi

    IS_DEST_LL=$(echo $DESTINATION_IP | grep '^169\.254\.' || exit 0)
    if [ -n "$IS_DEST_LL" ]; then
        LINK_LOCAL_IP=$(ifconfig | grep 169.254 | sed 's/.*inet \([0-9.]*\) .*/\1/')
        if [ -z "$LINK_LOCAL_IP" ]; then
            echo "Can't find an interface with a link local address?"
            exit 1
        fi
        TEST_LINK_LOCAL_IP=$(printf "$LINK_LOCAL_IP" | tail -n 1)
        if [ "$LINK_LOCAL_IP" != "$TEST_LINK_LOCAL_IP" ]; then
            echo "Multiple interfaces with link local addresses:"
            echo "$LINK_LOCAL_IP"
            echo "Guessing the last one, but YMMV..."
            LINK_LOCAL_IP=$TEST_LINK_LOCAL_IP
        fi

        # If a link local address, then force ssh to bind to the link local IP
        # when connecting. This fixes an issue where the ssh connection is bound
        # to another Ethernet interface. The TCP SYN packet that goes out has no
        # chance of working when this happens.
        SSH_OPTIONS="$SSH_OPTIONS -b $LINK_LOCAL_IP"
    fi
fi

printf "fwup:$FILESIZE,reboot\n" | cat - $FILENAME | ssh -s -p 8989 $SSH_OPTIONS $DESTINATION nerves_firmware_ssh
