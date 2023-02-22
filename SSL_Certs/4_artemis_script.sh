#!/bin/bash

export KEY_PASS=securepass STORE_PASS=securepass CA_VALIDITY=365000 VALIDITY=36500

#Create a key and self-signed certificate for the CA, to sign server certificate requests and use for trust:
#-----------------------------------------------------------------------------------------------------------

keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias server-ca -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Server Certification Authority, OU=Artemis, O=ActiveMQ" -validity $CA_VALIDITY -ext bc:c=ca:true 

keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -alias server-ca -exportcert -rfc > server-ca.crt

#Create trust store with the server CA cert:
#-------------------------------------------

keytool -keystore server-ca-truststore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server-ca -file server-ca.crt -noprompt

#Create a key pair for the server, and sign it with the CA:
#----------------------------------------------------------

keytool -keystore server-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -alias server -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Server, OU=Artemis, O=ActiveMQ, L=AMQ, S=AMQ, C=AMQ" -validity $VALIDITY -ext bc=ca:false -ext eku=sA -ext san=dns:localhost,ip:127.0.0.1

keytool -keystore server-keystore.jks -storepass $STORE_PASS -alias server -certreq -file server.csr 

keytool -keystore server-ca-keystore.p12 -storepass $STORE_PASS -alias server-ca -gencert -rfc -infile server.csr -outfile server.crt -validity $VALIDITY -ext bc=ca:false -ext san=dns:localhost,ip:127.0.0.1

keytool -keystore server-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server-ca -file server-ca.crt -noprompt 

keytool -keystore server-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server -file server.crt

#Create a key and self-signed certificate for the CA, to sign client certificate requests and use for trust:
#-----------------------------------------------------------------------------------------------------------

keytool -keystore client-ca-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -alias client-ca -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Client Certification Authority, OU=Artemis, O=ActiveMQ" -validity $CA_VALIDITY -ext bc:c=ca:true 

keytool -keystore client-ca-keystore.jks -storepass $STORE_PASS -alias client-ca -exportcert -rfc > client-ca.crt

#Create trust store with the client CA cert:
#-------------------------------------------

keytool -storetype pkcs12 -keystore client-ca-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias client-ca -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Client Certification Authority, OU=Artemis, O=ActiveMQ" -validity $CA_VALIDITY -ext bc:c=ca:true 

keytool -storetype pkcs12 -keystore client-ca-keystore.p12 -storepass $STORE_PASS -alias client-ca -exportcert -rfc > client-ca.crt

#Create a key pair for the client, and sign it with the CA:
#----------------------------------------------------------

keytool -keystore client-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -alias client -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Client, OU=Artemis, O=ActiveMQ, L=AMQ, S=AMQ, C=AMQ" -validity $VALIDITY -ext bc=ca:false -ext eku=cA -ext san=dns:localhost,ip:127.0.0.1

keytool -keystore client-keystore.jks -storepass $STORE_PASS -alias client -certreq -file client.csr 

keytool -keystore client-ca-keystore.p12 -storepass $STORE_PASS -alias client-ca -gencert -rfc -infile client.csr -outfile client.crt -validity $VALIDITY -ext bc=ca:false -ext eku=cA -ext san=dns:localhost,ip:127.0.0.1

keytool -keystore client-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias client-ca -file client-ca.crt -noprompt 

keytool -keystore client-keystore.jks -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias client -file client.crt


# Convert clients certs to PEM (my additions)
# Client Keystore
keytool -importkeystore -srckeystore client-keystore.jks -srcstoretype pkcs12 -srcstorepass securepass -destkeystore client-ks.p12 -deststoretype pkcs12 -deststorepass securepass

openssl pkcs12 -in client-ks.p12 -passin pass:securepass -out client-ks.pem -passout pass:securepass

# Client Truststore
openssl pkcs12 -in server-ca-truststore.p12 -passin pass:securepass -out client-ts.pem -passout pass:securepass
