#!/bin/sh
# Create a user keypair with keytool that is stored in a local keystore.
# References:
# http://docs.oracle.com/javase/6/docs/technotes/tools/solaris/keytool.html
set -e				# Exit if any command fails.
. ./lib.sh			# Import common functions.

# Name of the CA.
if [ -n "$1" ]; then
	ca_name="$1"
else
	ca_name=ewca
fi

# The common name for the cert.
if [ -n "$2" ]; then
	co_name="$2"
else
	co_name=ada09ewe
fi

cd $ca_name
keytool_key $co_name
keytool_imp $ca_name
keytool_exp $co_name
sign $ca_name $co_name
keytool_imp $co_name

#keytool -keystore .keystore -delete -alias $co_name
