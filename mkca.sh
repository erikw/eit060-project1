#1/bin/sh
# Creage a new Root self signed CA.
# References:
# http://wwwneu.secit.at/web/documentation/openssl/openssl_cnf.html#S_usr_cert_Section
# http://www.openssl.org/docs/apps/openssl.html
# http://www.openssl.org/docs/apps/req.html#CONFIGURATION_FILE_FORMAT
# http://www.eclectica.ca/howto/ssl-cert-howto.php
# http://www.g-loaded.eu/2005/11/10/be-your-own-ca/

#set -e				# Exit if any command fails.
. ./lib.sh			# Import common functions.

# Name of the CA.
if [ -n "$1" ]; then
	ca_name="$1"
else
	ca_name=ewca
fi

# Days the certificate will be valid for.
if [ -n "$2" ]; then
	valid_days=$2
else
	valid_days=1826		# 5 years.
fi

init_ca $ca_name
cd $ca_name
ca $ca_name $valid_days
