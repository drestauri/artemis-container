

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

DEST_DIR=certs
CERT_DIR1=certs
CERT_DIR2=certs_gmsec
CLIENT_DIR=../AMQ_Client
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

# Copy client ks and ts to the client container's certs directory
# Copy client from dir1 (my generic certs)
cp $CERT_DIR1/artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/my-artemis-client.ks.pem
cp $CERT_DIR1/truststore.pem $CLIENT_DIR/$DEST_DIR/my-artemis-client.ts.pem

# Copy client from dir2 (gmsec script generated certs)
cp $CERT_DIR2/artemis-client.ks.pem $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ts.pem
cp $CERT_DIR2/artemis-client.ts.pem $CLIENT_DIR/$DEST_DIR/gmsec-artemis-client.ks.pem


#====== SERVER CERTS =========
# Copy server ks and ts from my cert process
cp $CERT_DIR1/artemis-server.ks.p12 ./my-artemis-server.ks
cp $CERT_DIR1/truststore.p12 ./my-artemis-server.ts

# Copy server ks and ts from GMSEC cert process
cp $CERT_DIR2/artemis-server.ks ./gmsec-artemis-server.ks 2> /dev/null
cp $CERT_DIR2/artemis-server.ts ./gmsec-artemis-server.ts 2> /dev/null


# Copy the files over (requires password entry)
if
	[ $SCP_CERTS = "True" ]
then
	echo "SCP'ing certs to $SCP_DEST"
	scp my-artemis-server.ks $SCP_DEST
	scp my-artemis-server.ts $SCP_DEST
	scp gmsec-artemis-server.ks $SCP_DEST
	scp gmsec-artemis-server.ts $SCP_DEST
fi

if
        [ $CP_CERTS = "True" ]
then
	echo "Copying certs to $CP_DEST"
	mkdir $CP_DEST 2> /dev/null
        cp my-artemis-server.ks $CP_DEST/
        cp my-artemis-server.ts $CP_DEST/
        cp gmsec-artemis-server.ks $CP_DEST/
        cp gmsec-artemis-server.ts $CP_DEST/
fi


