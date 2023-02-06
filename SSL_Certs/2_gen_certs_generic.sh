
#/home/drestauri
#  |_ scripts for generating certs
#  |_ current certs
#  |_ certs/
#     |_ generated certs stored here

# Remove the certs from the previous build that were copied into the current directory
rm -r certs 2> /dev/null
rm *.p12 2> /dev/null
rm *.pem 2> /dev/null
rm *.ks 2> /dev/null
rm *.ts 2> /dev/null

# Inputs
CA_PASS=securepass
SERVER_PASS=securepass
CLIENT_PASS=securepass
# Only one truststore is generated since it's for the Root CA
TRUSTSTORE_PASS=securepass


applyCAPass() {
  echo $CA_PASS
  echo $CA_PASS
}

applyCASettings() {
# Country Name (2-Letter Code) 
    echo US
# State 
    echo CA
# City 
    echo Torrance
# Organization Name 
    echo home
# Organization Unit Name 
    echo self 
# Common Name 
    echo root-ca
# Email Address 
    echo don.restauri@gmail.com
}

applyClientSettings() {
# Country Name (2-Letter Code) 
    echo US
# State 
    echo CA
# City 
    echo Torrance
# Organization Name 
    echo home
# Organization Unit Name 
    echo self
# Common Name 
    echo artemis-client
# Email Address 
    echo don.restauri@gmail.com
# Optional challenge and other thing
    echo ""
    echo ""
}

applyServerSettings() {
# Country Name (2-Letter Code) 
    echo US
# State 
    echo CA
# City 
    echo Torrance
# Organization Name 
    echo home
# Organization Unit Name 
    echo self
# Common Name 
    echo artemis-server
# Email Address 
    echo don.restauri@gmail.com
# Optional challenge and other thing
    echo ""
    echo ""
}



mkdir certs

# Create Root CA
# Generate a Root CA private key:
openssl genrsa -aes-256-cbc -out certs/root-ca.key -passout pass:$CA_PASS 2048

# Extract the Root CA public key/certificate
applyCASettings | openssl req -x509 -new -days 3650 -key certs/root-ca.key -passin pass:$CA_PASS -out certs/root-ca.pem -passout pass:$CA_PASS


# Create Server Certs
openssl genrsa -out certs/artemis-server.key -passout pass:$SERVER_PASS 2048

# Create CSR
applyServerSettings | openssl req -new -key certs/artemis-server.key -passin pass:$SERVER_PASS -out certs/artemis-server.csr

# Create a x509 certificate extension config to define the Subject Alt Name
echo "authorityKeyIdentifier=keyid,issuer" > tmp.ext
echo "basicConstraints=CA:FALSE" >> tmp.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> tmp.ext
echo "subjectAltName = @alt_names" >> tmp.ext
echo "" >> tmp.ext	
echo "[alt_names]" >> tmp.ext
echo "" >> tmp.ext
echo "DNS.1 = artemis-server" >> tmp.ext

# Sign the cert & clean up the temp extension file
openssl x509 -req -in certs/artemis-server.csr -CA certs/root-ca.pem -passin pass:$CA_PASS -CAkey certs/root-ca.key -passin pass:$CA_PASS -CAcreateserial -out certs/artemis-server.crt -days 3650 -sha256 -extfile tmp.ext
rm tmp.ext


# Create Client Certs
openssl genrsa -out certs/artemis-client.key -passout pass:$CLIENT_PASS 2048

# Create CSR
applyClientSettings | openssl req -new -key certs/artemis-client.key -passin pass:$CLIENT_PASS -out certs/artemis-client.csr

# Create a x509 certificate extension config to define the Subject Alt Name
echo "authorityKeyIdentifier=keyid,issuer" > tmp.ext
echo "basicConstraints=CA:FALSE" >> tmp.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> tmp.ext
echo "subjectAltName = @alt_names" >> tmp.ext
echo "" >> tmp.ext
echo "[alt_names]" >> tmp.ext
echo "" >> tmp.ext
echo "DNS.1 = artemis-client" >> tmp.ext

# Sign the cert & clean up the temp extension file
openssl x509 -req -in certs/artemis-client.csr -CA certs/root-ca.pem -passin pass:$CA_PASS -CAkey certs/root-ca.key -passin pass:$CA_PASS -CAcreateserial -out certs/artemis-client.crt -days 3650 -sha256 -extfile tmp.ext
rm tmp.ext


# Create a truststore for the Root CA in P12 and also convert to PEM
openssl x509 -text -in certs/root-ca.pem > tmp_chain.crt
#openssl pkcs12 -export -in tmp_chain.crt -out certs/truststore.p12 -nokeys -caname root-ca -certpbe aes-256-cbc -passout pass:$TRUSTSTORE_PASS
echo yes | keytool -import -alias root-key -file tmp_chain.crt -keystore certs/truststore.p12 -storetype PKCS12 -storepass $TRUSTSTORE_PASS
openssl pkcs12 -in certs/truststore.p12 -passin pass:$TRUSTSTORE_PASS -out certs/truststore.pem -passout pass:$TRUSTSTORE_PASS -aes256
rm tmp_chain.crt


# Create Server Keystore (p12)
openssl pkcs12 -export -in certs/artemis-server.crt -inkey certs/artemis-server.key -name server-key -out certs/artemis-server.ks.p12 -certpbe aes-256-cbc -keypbe aes-256-cbc -passout pass:$SERVER_PASS

# Create Client Keystore and convert to PEM
openssl pkcs12 -export -in certs/artemis-client.crt -inkey certs/artemis-client.key -name client-key -out certs/artemis-client.ks.p12 -certpbe aes-256-cbc -keypbe aes-256-cbc -passout pass:$CLIENT_PASS
openssl pkcs12 -in certs/artemis-client.ks.p12 -passin pass:$CLIENT_PASS -out certs/artemis-client.ks.pem -passout pass:$CLIENT_PASS



