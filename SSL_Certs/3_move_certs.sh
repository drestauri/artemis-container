

#/home/drestauri/dev/artemis-cluster
#  |_ AMQ_Client/certs/
#     |_ my-artemis-client.ks.pem
#     |_ my-artemis-client.ts.pem
#     |_ gmsec-artemiss-client.ks.pem
#     |_ gmsec-artemiss-client.ts.pem
#     |_ ex-artemis-client.ks.pem  # From the examples, not this script
#     |_ ex-artemis-client.ts.pem  # From the examples, not this script
#  |_ SSL_Certs
#     |_ certs/  # temp storage for certs generated per online examples
#     |_ certs_gmsec  # temp storage for certs generated per GMSEC instructions
#     |_ scripts for generating certs
#     |_ my-artemis-server.ks  # The server certs stored here to SCP/CP'ed to dest
#     |_ my-artemis-server.ts
#     |_ gmsec-artemis-server.ks
#     |_ gmsec-artemis-server.ts

CERT_DIR1=certs
CERT_DIR2=certs_gmsec
CERT_DIR3=certs_example

CLIENT_DIR=../AMQ_Client
DEST_DIR=certs

SCP_CERTS=False  # If you are running the broker on another VM
SCP_DEST=drestauri@192.168.1.10:  # This is that VM's IP

CP_CERTS=True
CP_DEST=../Artemis_Servers/ssl-node-a-live/certs


rm *.pem 2> /dev/null
rm *.ts 2> /dev/null
rm *.ks 2> /dev/null


#====== CLIENT CERTS =======
rm -r $CLIENT_DIR/$DEST_DIR 2> /dev/null
mkdir $CLIENT_DIR/$DEST_DIR 2> /dev/null

echo "Copying client certs to $CLIENT_DIR/$DEST_DIR"

# Copy client ks and ts to the client container's certs directory as plain text
# Copy client from dir1 (my generic certs)
cp $CERT_DIR1/artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/my-artemis-client.ks.pem
cp $CERT_DIR1/truststore.pem $CLIENT_DIR/$DEST_DIR/my-artemis-client.ts.pem
#openssl x509 -text -in $CERT_DIR1/artemis-client.ks.pem > $CLIENT_DIR/$DEST_DIR/my-artemis-client.ks.pem
#openssl x509 -text -in $CERT_DIR1/truststore.pem > $CLIENT_DIR/$DEST_DIR/my-artemis-client.ts.pem

# Copy client from dir2 (gmsec script generated certs)
cp $CERT_DIR2/artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ks.pem
cp $CERT_DIR2/artemis-client.ts.pem $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ts.pem
#openssl x509 -text -in $CERT_DIR2/artemis-client.ks.pem > $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ks.pem
#openssl x509 -text -in $CERT_DIR2/artemis-client.ts.pem > $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ts.pem

# Copy client certs from dir3 (Artemis example certs)
cp $CERT_DIR3/ex-artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/ex-artemis-client.ks.pem
cp $CERT_DIR3/ex-artemis-client.ts.pem $CLIENT_DIR/$DEST_DIR/ex-artemis-client.ts.pem
#openssl x509 -text -in $CERT_DIR3/ex-artemis-client.ks.pem > $CLIENT_DIR/$DEST_DIR/ex-artemis-client.ks.pem
#openssl x509 -text -in $CERT_DIR3/ex-artemis-client.ts.pem > $CLIENT_DIR/$DEST_DIR/ex-artemis-client.ts.pem
cp $CERT_DIR3/ex-artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/ex-original-artemis-client.ks.pem
cp $CERT_DIR3/ex-artemis-client.ts.pem $CLIENT_DIR/$DEST_DIR/ex-original-artemis-client.ts.pem
cp $CERT_DIR3/ex-artemis-client-conv.ks.pem $CLIENT_DIR/$DEST_DIR/ex-artemis-client-conv.ks.pem
cp $CERT_DIR3/ex-artemis-client-conv.ts.pem $CLIENT_DIR/$DEST_DIR/ex-artemis-client-conv.ts.pem


#====== SERVER CERTS =========
# Copy server ks and ts from my cert process
cp $CERT_DIR1/artemis-server.ks.p12 ./my-artemis-server.ks
cp $CERT_DIR1/truststore.p12 ./my-artemis-server.ts
cp $CERT_DIR1/root-ca.pem ./my-ca.pem
#openssl x509 -text -in truststore.pem ./my-artemis-server.ts`

# Copy server ks and ts from GMSEC cert process
cp $CERT_DIR2/artemis-server.ks ./gmsec-artemis-server.ks 2> /dev/null
cp $CERT_DIR2/artemis-server.ts ./gmsec-artemis-server.ts 2> /dev/null
cp $CERT_DIR2/ca.crt ./gmsec-ca.pem

# Copy server ks and ts from Artemis example
cp $CERT_DIR3/server-keystore.jks ./ex-artemis-server-keystore.jks 2> /dev/null
cp $CERT_DIR3/client-ca-truststore.jks ./ex-artemis-server-truststore.jks 2> /dev/null
cp $CERT_DIR3/ex-artemis-client.ts.pem ./ex-ca.pem

# Copy the files over (requires password entry)
if
	[ $SCP_CERTS = "True" ]
then
	echo "SCP'ing server certs to $SCP_DEST"
	scp my-artemis-server.ks $SCP_DEST
	scp my-artemis-server.ts $SCP_DEST
	scp gmsec-artemis-server.ks $SCP_DEST
	scp gmsec-artemis-server.ts $SCP_DEST
	scp my-ca.pem $SCP_DEST
	scp ex-ca.pem $SCP_DEST
	scp gmsec-ca.pem $SCP_DEST
fi

if
        [ $CP_CERTS = "True" ]
then
	echo "Copying server certs to $CP_DEST"
	mkdir $CP_DEST 2> /dev/null
        cp my-artemis-server.ks $CP_DEST/
        cp my-artemis-server.ts $CP_DEST/
        cp gmsec-artemis-server.ks $CP_DEST/
        cp gmsec-artemis-server.ts $CP_DEST/
	cp my-ca.pem $CP_DEST/
	cp gmsec-ca.pem $CP_DEST/
fi


