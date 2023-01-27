#!/usr/bin/env bash 
 
# 
# GenCerts.sh 
# 
# This script sets up a bogus Certificate Authority, and then creates 
# Java Keystore and Truststore files that can be used to secure an 
# ActiveMQ broker using SSL/TLS. Lastly, PEM files are created so that 
# a client application connect and send data through the broker. 
# 

#/home/drestauri
#  |_ scripts for generating certs
#  |_ current certs
#  |_ certs/
#     |_ generated certs stored here

# Remove the certs from the previous build that were copied into the current directory
rm -r certs_gmsec 2> /dev/null
rm *.p12 2> /dev/null
rm *.pem 2> /dev/null
rm *.ks 2> /dev/null
rm *.ts 2> /dev/null


CA_PASSPHRASE=securepass
BROKER_PASSPHRASE=securepass 
CLIENT_PASSPHRASE=securepass
 
ROOT_CN=root-ca
BROKER_CN=artemis-server
CLIENT_CN=artemis-client
 
VALIDDAYS=3650
KEYSIZE=2048 
CERTS_DIR=certs_gmsec 


baseAnswers() { 
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
    echo $1
# Email Address 
    echo don.restauri@gmail.com
} 
 
 
# 
# DO NOT EDIT ANYTHING BELOW THIS LINE 
# 
 
answers() { 
    baseAnswers $1 
    echo '' 
    echo '' 
} 
 
createderfiles() { 
    echo Creating .der files for $1 
 
    openssl pkcs8 -topk8 -nocrypt -in $1.key -inform PEM -out $1.key.der -outform DER 
    openssl x509 -in $1.crt -inform PEM -out $1.crt.der -outform DER 
} 
 
 
# find keytool in our path 
KEYTOOL=$( which keytool ) 
if [ -z "$KEYTOOL" ]; then 
    echo "keytool command not found. Update your path if you want this" 
    echo "tool to create JKS files as well as PEM format files" 
       exit 1 
fi 
 
# find openssl in our path 
OPENSSL=$( which openssl ) 
if [ -z "$OPENSSL" ]; then 
    echo "openssl command not found. Update your path if you want this" 
    echo "tool to create JKS files as well as PEM format files" 
       exit 1 
fi 
 
rm -rf $CERTS_DIR && mkdir $CERTS_DIR && cd $CERTS_DIR 
 
if [ $? -ne 0 ]; then 
       echo "Aborting due to previous error(s)" 
       exit 1 
fi 
 
# 
# SET UP (BOGUS) CERTIFICATE AUTHORITY 
# 
echo "Create Cert-Authority key and certificate" 
baseAnswers $ROOT_CN | openssl req -newkey rsa:$KEYSIZE -keyout ca.key -nodes -x509 -sha256 -days $VALIDDAYS -out ca.crt 2> /dev/null 
 
echo "Creat Cert-Authority DER file" 
createderfiles ca 
 
echo "Create Cert-Authority JKS (Java Keystore) from DER file" 
keytool -import -noprompt -trustcacerts -alias ca -file ca.crt.der -keystoreca.jks -storetype JKS -storepass $CA_PASSPHRASE 2> /dev/null 
 
 
# 
# SET UP BROKER 
# 
KEY=$BROKER_CN.key 
CRT=$BROKER_CN.crt 
REQ=$BROKER_CN.req 
P12=$BROKER_CN.p12 
KS=$BROKER_CN.ks 
TS=$BROKER_CN.ts 
KEYDER=$KEY.der 
CRTDER=$CRT.der 
 
echo "Create Broker key and certificate" 
answers $BROKER_CN | openssl req -newkey rsa:$KEYSIZE -keyout $KEY -nodes -days $VALIDDAYS -out $REQ  2> /dev/null 
 
echo "Sign the Broker certificate" 
openssl x509 -req -in $REQ -out $CRT -CA ca.crt -CAkey ca.key -CAcreateserial -CAserial ca.serial -sha256 -days $VALIDDAYS 2> /dev/null 
 
echo "Create Broker PKCS12 file" 
openssl pkcs12 -export -in $CRT -inkey $KEY -certfile ca.crt -name $BROKER_CN -out $P12 -password pass:$BROKER_PASSPHRASE -nodes 
 
echo "Create Broker DER file" 
createderfiles $BROKER_CN 
 
echo "Create Broker JKS (Java Keystore) from DER file" 
echo '' | keytool -genkey -keyalg RSA -alias foo -keystore $KS -storepass $BROKER_PASSPHRASE -dname "CN=CN, OU=OU, O=O, L=L, S=S, C=C" 
keytool -delete -alias foo -keystore $KS -storepass $BROKER_PASSPHRASE 
 
echo "Import Broker PKCS12 file into JKS" 
keytool -importkeystore -deststorepass $BROKER_PASSPHRASE -destkeypass $BROKER_PASSPHRASE -destkeystore $KS -srckeystore $P12 -srcstoretype PKCS12 -srcstorepass $BROKER_PASSPHRASE -alias $BROKER_CN 
 
echo "Create Broker Truststore" 
echo 'yes' | keytool -import -file ca.crt -alias ca -keystore $TS -storepass $BROKER_PASSPHRASE 

 
# 
# SET UP CLIENT 
# 
KEY=$CLIENT_CN.key 
CRT=$CLIENT_CN.crt 
REQ=$CLIENT_CN.req 
P12=$CLIENT_CN.p12 
KS=$CLIENT_CN.ks 
KSPEM=$CLIENT_CN.ks.pem 
TS=$CLIENT_CN.ts 

TSPEM=$CLIENT_CN.ts.pem 
KEYDER=$KEY.der 
CRTDER=$CRT.der 
 
echo "Create Client key and certificate" 
answers $CLIENT_CN | openssl req -newkey rsa:$KEYSIZE -keyout $KEY -nodes -days $VALIDDAYS -out $REQ  2> /dev/null 
 
echo "Sign the Client certificate" 
openssl x509 -req -in $REQ -out $CRT -CA ca.crt -CAkey ca.key -CAcreateserial -CAserial ca.serial -sha256 -days $VALIDDAYS 2> /dev/null 
 
echo "Create Client PKCS12 file" 
openssl pkcs12 -export -in $CRT -inkey $KEY -certfile ca.crt -name $CLIENT_CN -out $P12 -password pass:$CLIENT_PASSPHRASE -nodes 
 
echo "Create Client DER file" 
createderfiles $CLIENT_CN 
 
echo "Create Client JKS (Java Keystore) from DER file" 
echo '' | keytool -genkey -keyalg RSA -alias foo -keystore $KS -storepass $CLIENT_PASSPHRASE -dname "CN=CN, OU=OU, O=O, L=L, S=S, C=C" 
keytool -delete -alias foo -keystore $KS -storepass $CLIENT_PASSPHRASE 
 
echo "Import Client PKCS12 file into JKS" 
keytool -importkeystore -deststorepass $CLIENT_PASSPHRASE -destkeypass $CLIENT_PASSPHRASE -destkeystore $KS -srckeystore $P12 -srcstoretype PKCS12 -srcstorepass $CLIENT_PASSPHRASE -alias $CLIENT_CN 
 
echo "Create Client Truststore" 
echo 'yes' | keytool -import -file ca.crt -alias ca -keystore $TS -storepass $CLIENT_PASSPHRASE 
 
echo "Convert Client PKCS11 to PEM format" 
keytool -importkeystore -srckeystore $KS -srcstoretype jks -srcstorepass $CLIENT_PASSPHRASE -destkeystore $KS.p12 -deststoretype pkcs12 -deststorepass $CLIENT_PASSPHRASE 2> /dev/null 
openssl pkcs12 -in $KS.p12 -passin pass:$CLIENT_PASSPHRASE -out $KSPEM -passout pass:$CLIENT_PASSPHRASE > /dev/null 2>&1 
 
echo "Create Client PEM formatted Truststore" 
cat ca.crt >> $TSPEM 
 
 
echo "Done!" 
exit 0 
