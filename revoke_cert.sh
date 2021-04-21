#!/bin/sh
# Revoke an certificate by ID (see index.txt).
set -e				# Exit if any command fails.
. ./lib.sh			# Import common functions.

# Name of the CA.
if [ -n "$1" ]; then
	ca_name="$1"
else
	ca_name=ewca
fi

# Name of the cert.
if [ -n "$2" ]; then
	cert_id="$2"
else
	cert_id="01"
fi

cd $ca_name
revoke_cer $ca_name $cert_id
