# Common functions.

# Print execution log.
log() {
	echo "----> $1"
}

# Initialize a new CA file structure.
init_ca() {
	ca_name=$1
	mkdir -p $ca_name
	cd $ca_name
	cp ../openssl.cnf .				# Use a modified default configuration.

	read -d '' patchcontent << EOF
50c50
< certificate	= \$dir/cacert.pem 	# The CA certificate
---
> certificate	= \$dir/certs/${ca_name}.crt 	# The CA certificate
55c55
< private_key	= \$dir/private/cakey.pem# The private key
---
> private_key	= \$dir/private/${ca_name}.key# The private key
EOF
	log "Patching openssl.cnf"
	echo -e "$patchcontent" > openssl.cnf.patch
	patch openssl.cnf openssl.cnf.patch
	rm openssl.cnf.patch

	log "Creating directories"
	mkdir certs crl newcerts private csr 		# Directories used.
	chmod 700 private				# Must be protected so only we can make certs.
	chmod 0600 openssl.cnf				# Not neccessaty to tell the world about how we configure.
	touch index.txt 				# Its database.
	touch crlnumber					# Stor the current crl number
	echo '01' > serial				# The number of the first certificate to be generated.
	echo '01' > crlnumber				# The number of the first revokation to be done.
}

# Issue an self signed root certificate.
ca() {
	ca=$1
	days=$2
	log "Now generating CA."
	# -config    = Use values from the configuration file.
	# -new       = Create a new certificate.
	# -x509      = Let it be an c.509 cert.
	# -extension = Load extra options.
	# -out       = Filename for the cert.
	# -keyout    = Filname for the private key.
	# -days      = Number of valid days.
	openssl req -config ./openssl.cnf -new -x509 -extensions v3_ca -out "certs/${ca}.crt" -keyout "private/${ca}.key" -days $days
	chmod 0400 private/${ca}.pem		# Protect the private key.
	log "CA generated is displayed below:"
	openssl x509 -in certs/${ca}.crt -noout -text
	log "Its capabilities are:"
	openssl x509 -in certs/${ca}.crt -noout -purpose
}

# Make an  Certificate Signing Request.
csr() {
	cert=$1
	days=$2
	log "Now generating CSR."
	# -config    = Use values from the configuration file.
	# -new       = Create a new certificate.
	# -nodes     = Skip passphrase when using private key. Protect in filesystem.
	# -out       = Filename for the crs.
	# -keyout    = Filname for the private key.
	openssl req  -config ./openssl.cnf -new -nodes -out "csr/${cert}.req.csr" -keyout "private/${cert}.req.key" -days $days
	chmod 0400 "private/${cert}.req.key"
	log "CSR generated:"
	openssl req -in "csr/${cert}.req.csr" -noout -text
}
#export -f csr		# Give the function "linkage"

# Sign a certificate.
sign() {
	ca=$1
	cert=$2
	log "Now signing the CSR"
	# -config    = Use values from the configuration file.
	# -policy    = Policy gorup in config for required fields. Don't require match with $ca_name.
	# -out       = Filename for the cert.
	# -infiles   = The CSR to sign.
	openssl ca -config ./openssl.cnf -policy policy_anything -out "certs/${cert}.crt" -infiles "csr/${cert}.req.csr"

	log "Information and purpose:"
	openssl x509 -in "certs/${cert}.crt" -noout -text -purpose
	log "Test if it works for SSL"
	openssl verify -purpose sslserver -CAfile "certs/${ca}.crt" "certs/${cert}.crt"
	openssl verify -purpose sslclient -CAfile "certs/${ca}.crt" "certs/${cert}.crt"

	# Strip of human readable from cert (copy of original is in newcerts)
	openssl x509 -in "certs/${cert}.crt" -out "certs/${cert}.crt" 
}

# Revoke an Cert with supplied ID.
revoke_cer() {
	ca=$1
	cert=$2
	log "Revoking certID ${cert}"
	# -config    = Use values from the configuration file.
	# -revoke    = Cert to revoke.
	#openssl ca -config ./openssl.cnf -revoke "newcerts/${cert}.pem" 

	log "Generating a new CRL (Certificate Revokation List)"
	openssl ca -config ./openssl.cnf -gencrl -out "crl/${ca}.crl"
}

# Generate keypair with keytool.
keytool_key() {
	co=$1
	log "Now generating keypair"
	keytool -keystore .keystore -genkey -alias $co -keyalg RSA -keysize 1024 -validity 365

	log "Listing keys"
	keytool -keystore .keystore -list -v

	#keytool -keystore .keystore -export -alias $co -file "${co}.crt"
}

# Export CSR from keytool.
keytool_exp() {
	kalias=$1
	log "Exporting CSR"
	keytool -keystore .keystore -certreq -alias $kalias -file "csr/${kalias}.req.csr"
}

# Import an issued certificate.
keytool_imp() {
	kalias=$1
	log "Importing certificate crt to keystore."
	keytool -keystore .keystore -importcert -alias "${kalias}" -file "certs/${kalias}.crt"

	#log "Converting to PKCS#7 format"
	#openssl crl2pkcs7 -nocrl -certfile "certs/${co_name}.crt" -out "certs/${co_name}.p7b" -certfile "certs/${ca_name}.crt"
	#log "Importing certificate p7b to keystore."
	#keytool -keystore .keystore -importcert -alias "${co_name}.signed" -file "certs/${co_name}.p7b"

	log "Listing keys"
	keytool -keystore .keystore -list -v
}
