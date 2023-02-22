FROM rhel7-min

MAINTAINER Red Hat, Inc.

# User Arguments
ARG username=artemis-client
ARG default_pw=password
ARG root_pw=securepass
ARG apr_ver=apr-1.7.0
ARG amq_lib_ver=activemq-cpp-library-3.9.5
ARG gmsec_ver=5.0
ARG gmsec_platform=RH7_x86_64
ARG gmsec_support_os=RHEL7

# Need ENV as well for anything interpreted from inside the container (e.g. echo'ed to a shell)
ENV env_username $username
ENV env_artemis_install_dir $artemis_install_dir

# Create a new user, add them to sudoers (disabled), give a defualt pw,  and switch to it
RUN useradd $username
RUN echo $username:$default_pw | chpasswd

#=== ActiveMQ Client Library Install ===
#WORKDIR /home/$username/
USER root
RUN yum install openssl openssl-devel -y

# Copy over SSL Cert files
USER $username
WORKDIR /home/$username/
# NOTE: These certs need to be generated outside the container due to the versions of
# OpenSSL not matching where the scripts were created
#COPY move_certs.sh ./temp_move_certs.sh
#RUN cp temp_move_certs.sh move_certs.sh
#RUN rm temp*.sh

# Copy the certs and then copy to the home directory so test scripts can
# be run without changing anything
COPY certs certs
USER root
RUN chown $username certs/*
RUN cp certs/*.ts.pem /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust extract

USER $username
RUN cp certs/* /home/$username/


# Download and Unpack GMSEC API
USER $username
WORKDIR /home/$username/
RUN wget -c "https://github.com/nasa/GMSEC_API/releases/download/API-$gmsec_ver-release/GMSEC_API-$gmsec_ver-$gmsec_platform.tar.gz"
RUN tar -xvf GMSEC_API-$gmsec_ver-$gmsec_platform.tar.gz
RUN rm GMSEC_API-$gmsec_ver-$gmsec_platform.tar.gz


# Download and Unpack the GMSEC Support files (APR and ActiveMQ Client)
USER $username
WORKDIR /home/$username/
RUN wget -c "https://github.com/nasa/GMSEC_API/releases/download/API-$gmsec_ver-release/SUPPORT.zip"
RUN unzip -q SUPPORT.zip
RUN rm SUPPORT.zip
WORKDIR /home/$username/SUPPORT
RUN tar -xvf $gmsec_support_os.tar.gz
RUN rm *.tar.gz
RUN rm *.zip


# Add environment variables to .bashrc and reload
RUN echo "export GMSEC_HOME=\$HOME/GMSEC_API" >> ~/.bashrc
RUN echo "export PYTHONPATH=\$GMSEC_HOME/bin:\$GMSEC_HOME/bin/lib/GMSECAPI4:\$PYTHONPATH" >> ~/.bashrc
RUN echo "export LIB_AMQ_PATH=\$HOME/SUPPORT/$gmsec_support_os/activemq395/lib" >> ~/.bashrc
RUN echo "export PATH=\$GMSEC_HOME/bin:/usr/local/lib:/usr/:/usr/include:\$PATH" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$GMSEC_HOME/bin:/usr/:/usr/lib:/usr/include:\$LIB_AMQ_PATH:\$LD_LIBRARY_PATH" >> ~/.bashrc


# Add GMSEC Test Scripts
WORKDIR /home/$username/
# TCP Test Script
RUN echo "\$GMSEC_HOME/bin/gmpub mw-id=artemis mw-server=\"tcp://ssl-container:61619\"" > pub_test.sh
# SSL Test Script for my generic certs
RUN echo "\$GMSEC_HOME/bin/gmpub mw-id=artemis mw-server=\"ssl://ssl-container:61616\" mw-keystore=./my-artemis-client.ks.pem mw-keystore-password=securepass mw-truststore=./my-artemis-client.ts.pem mw-truststore-password=securepass" > my_pub_test_ssl.sh
# SSL Test Script for gmsec certs
RUN echo "\$GMSEC_HOME/bin/gmpub mw-id=artemis mw-server=\"ssl://ssl-container:61617\" mw-keystore=./gmsec-artemis-client.ks.pem mw-keystore-password=securepass mw-truststore=./gmsec-artemis-client.ts.pem mw-truststore-password=securepass" > gmsec_pub_test_ssl.sh
# SSL Test Script for Artemis example certs
RUN echo "\$GMSEC_HOME/bin/gmpub mw-id=artemis mw-server=\"ssl://ssl-container:61618\" mw-keystore=./ex-artemis-client.ks.pem mw-keystore-password=securepass mw-truststore=./ex-artemis-client.ts.pem mw-truststore-password=securepass" > ex_pub_test_ssl.sh
RUN chmod +x pub_test.sh
RUN chmod +x my_pub_test_ssl.sh
RUN chmod +x gmsec_pub_test_ssl.sh
RUN chmod +x ex_pub_test_ssl.sh



WORKDIR /home/$username/

# ==== ENTRY POINT =====
# Keep the container alive
CMD echo "test"  > tmp.txt && tail -f tmp.txt

