
# NOTE: rhel-min is a self build image on top of the base "rhel7" image from RedHat
# You need to make sure this is already on the system with: podman images
# If not, build it from your drestauri/amq-builds-scripts git project
FROM localhost/rhel7-min 

MAINTAINER Red Hat, Inc.

# User Arguments
ARG username=artemis-broker
ARG artemis_ver=2.28.0
ARG broker_user=artemis
ARG broker_pw=artemis
ARG broker_tcp_port=61616
ARG broker_ssl_port=51617
ARG web_port=8161

# Create the user account
RUN useradd $username
RUN echo $username:$default_pw | chpasswd

#====== Install Artemis Dependencies ======
# Download OpenSSL 3.0
USER root
RUN yum install openssl openssl-devel -y

# Download Artemis
USER $username
WORKDIR /home/$username/
RUN wget -c "https://www.apache.org/dyn/closer.cgi?filename=activemq/activemq-artemis/$artemis_ver/apache-artemis-$artemis_ver-bin.tar.gz&action=download"
RUN mv *apache-artemis-$artemis_ver* apache-artemis-$artemis_ver-bin.tar.gz
RUN tar -xvf apache-artemis-$artemis_ver-bin.tar.gz
RUN rm *.tar.gz

RUN echo "export ARTEMIS_HOME=\$HOME/apache-artemis-$artemis_ver" >> ~/.bashrc
RUN source ~/.bashrc

RUN /home/$username/apache-artemis-$artemis_ver/bin/artemis create ~/mybroker --user $broker_user --password $broker_pw --allow-anonymous

# Copy over the certs
COPY certs certs
USER root
RUN cp certs/*ca.pem /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust extract

RUN chown $username certs/*
USER $username
RUN cp certs/* /home/$username/mybroker/etc/


# Create a file for launching the app
RUN echo "\$HOME/mybroker/bin/artemis-service start" > start_service.sh
RUN chmod +x start_service.sh

# Copy over the entry point script for kicking off the service
COPY entry.sh ./entry.sh
USER root
RUN chown $username entry.sh
USER $username


# Copy over the Artemis files:
COPY artemis-users.properties ./mybroker/etc/
COPY artemis-roles.properties ./mybroker/etc/
COPY broker.xml ./mybroker/etc/
COPY login.config ./mybroker/etc/
COPY bootstrap.xml ./mybroker/etc/

# Expose the ports needed for the servers
EXPOSE $broker_tcp_port
EXPOSE $broker_ssl_port
EXPOSE $web_port

USER $username
WORKDIR /home/$username/

# ==== ENTRY POINT =====
# Keep the container alive
CMD echo "test"  > tmp.txt && tail -f tmp.txt
















