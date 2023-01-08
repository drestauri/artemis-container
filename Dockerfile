FROM rhel7

MAINTAINER Red Hat, Inc.

#labels for container catalog
LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
LABEL io.openshift.tags="base rhel7"

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#====== ROOT USER =======
# Install apps while still root user
RUN yum install sudo -y
RUN yum install java-11-openjdk -y

# Create a new user, add them to sudoers, and switch to it
RUN useradd artemis
RUN usermod -aG wheel artemis
RUN echo artemis:password | chpasswd
USER artemis


#====== ARTEMIS USER =====
# Copy over Artemis and unpack it
COPY artemis-2.27.1-bin.tar.gz /home/artemis/
WORKDIR /home/artemis/
RUN tar -xvf artemis-2.27.1-bin.tar.gz

# Setup permanent environment variable
RUN echo "export ARTEMIS_HOME=/home/artemis/apache-artemis-2.27.1" >> /home/artemis/.bashrc
RUN source /home/artemis/.bashrc

# Build broker:./artemis create ~/mybroker --user artemis --password artemis --allow-anonymous
RUN /home/artemis/apache-artemis-2.27.1/bin/artemis create ~/mybroker --user artemis --password artemis --allow-anonymous

RUN echo "/home/artemis/mybroker/bin/artemis run" > runit.sh
RUN chmod +x runit.sh

# Expose the ports needed for the servers
EXPOSE 61616
EXPOSE 8161
EXPOSE 61617
EXPOSE 8162


CMD ["/bin/bash"]
