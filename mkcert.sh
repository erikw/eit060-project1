#!/bin/sh
# Create CSR (Certificate Signing Request)
# References:
# http://wwwneu.secit.at/web/documentation/openssl/openssl_cnf.html#S_usr_cert_Section
# http://www.openssl.org/docs/apps/req.html#CONFIGURATION_FILE_FORMAT
# http://www.openssl.org/docs/apps/x509.html#
# http://www.eclectica.ca/howto/ssl-cert-howto.php
# http://www.g-loaded.eu/2005/11/10/be-your-own-ca/
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
	cert_name="$2"
else
	cert_name=ew_service
fi

# Days the certificate will be valid for.
if [ -n "$3" ]; then
	valid_days=$3
else
	valid_days=356
fi

cd $ca_name
csr $cert_name $valid_days
sign $ca_name $cert_name
