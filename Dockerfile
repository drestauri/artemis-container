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
#RUN yum update -y;
RUN yum install sudo -y
RUN yum install java-11-openjdk -y

# Steps to get systemd working
#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;
#VOLUME ["/sys/fs/cgroup"]


# Create a new user, add them to sudoers, and switch to it
RUN useradd artemis
RUN usermod -aG wheel artemis
RUN echo artemis:password | chpasswd
USER artemis


#====== ARTEMIS USER =====
# Copy over Artemis and unpack it
WORKDIR /home/artemis/
COPY artemis-2.27.1-bin.tar.gz /home/artemis/
RUN tar -xvf artemis-2.27.1-bin.tar.gz

# Setup permanent environment variable
RUN echo "export ARTEMIS_HOME=/home/artemis/apache-artemis-2.27.1" >> /home/artemis/.bashrc
RUN source /home/artemis/.bashrc

# Build broker:./artemis create ~/mybroker --user artemis --password artemis --allow-anonymous
RUN /home/artemis/apache-artemis-2.27.1/bin/artemis create ~/mybroker --user artemis --password artemis --allow-anonymous

# Create a file for testing from within the container
RUN echo "/home/artemis/mybroker/bin/artemis run" > runit.sh
RUN chmod +x runit.sh
RUN echo "/home/artemis/mybroker/bin/artemis-service start" > start_service.sh
RUN chmod +x start_service.sh

# Copy over the Artemis files:
COPY artemis-users.properties ./mybroker/etc/
COPY broker.xml ./mybroker/etc/
COPY login.config ./mybroker/etc/
COPY artemis-roles.properties ./mybroker/etc/
COPY bootstrap.xml ./mybroker/etc/


# Expose the ports needed for the servers
EXPOSE 61616
EXPOSE 8161

#CMD ["/home/artemis/./start-service.sh"]
CMD /home/artemis/mybroker/bin/artemis-service start > log.txt && tail -f log.txt

#USER root

