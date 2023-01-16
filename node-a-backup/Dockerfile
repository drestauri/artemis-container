FROM rhel7

MAINTAINER Red Hat, Inc.

# Configurable Arguments
ARG username=artemis
ARG default_pw=artemis
ARG artemis_tarball=artemis-2.27.1-bin.tar.gz
ARG artemis_install_dir=apache-artemis-2.27.1
ARG broker_user=artemis
ARG broker_pw=artemis
ARG broker_port=61617
ARG web_port=8162
# Need ENV as well for anything interpreted from inside the container (e.g. echo'ed to a shell)
ENV env_username $username
ENV env_artemis_install_dir $artemis_install_dir

#labels for container catalog
LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
LABEL io.openshift.tags="base rhel7"

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#====== ROOT USER =======
# Install apps while still root user
#RUN yum update -y;
#RUN yum install sudo -y
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


# Create a new user, add them to sudoers (disabled), give a defualt pw,  and switch to it
RUN useradd $username
#RUN usermod -aG wheel $username
RUN echo $username:$default_pw | chpasswd
USER $username


#====== ARTEMIS USER =====
# Copy over Artemis and unpack it
WORKDIR /home/$username/
COPY $artemis_tarball .
RUN tar -xvf $artemis_tarball

# Setup permanent environment variables
RUN echo "export ARTEMIS_HOME=/home/$env_username/$env_artemis_install_dir" >> /home/$username/.bashrc
RUN source /home/$username/.bashrc

# Build broker:./artemis create ~/mybroker --user artemis --password artemis --allow-anonymous
RUN $artemis_install_dir/bin/artemis create ~/mybroker --user $broker_user --password $broker_pw --allow-anonymous

# Create a file for launching the app & an entry app
RUN echo "/home/$env_username/mybroker/bin/artemis-service start" > start_service.sh
# These are not needed if using entry.sh as they are included in that script
# > stdout.log 2> stderr.log" > start_service.sh
COPY entry.sh ./entry.sh.backup
# Copy sets the owner as root so need to make an "artemis" owned copy
RUN cp entry.sh.backup entry.sh

RUN chmod +x start_service.sh
RUN chmod +x entry.sh

# Copy over the Artemis files:
COPY artemis-users.properties ./mybroker/etc/
COPY broker.xml ./mybroker/etc/
COPY login.config ./mybroker/etc/
COPY artemis-roles.properties ./mybroker/etc/
COPY bootstrap.xml ./mybroker/etc/


# Expose the ports needed for the servers
EXPOSE $broker_port
EXPOSE $web_port


# ==== ENTRY POINT =====
#CMD /home/$env_username/mybroker/bin/artemis-service start > live-log.txt && tail -f live-log.txt

# Keeps the container alive by streaming the log file. You would think SIGINT would work OK
# to shut this down since CTRL + C stops tail -f but didn't appear to work well. Maybe because
# that doesn't actually stop the Artemis service? I doubt it...
#CMD /home/$env_username/./start_service.sh && tail -f stdout.log

# This is used with entry.sh to enable more graceful handling of podman stop live-server (SIGINT).
# exec is necessary to get an interactive terminal so that signals are not ignored
CMD exec /home/$env_username/./entry.sh /home/$env_username/mybroker/bin/artemis-service start
# These don't need to be appended since they are already in entry.sh
# >>/app/my_log.txt 2>>/app/stderr.log

# Works to keep the terminal open so the container keeps running. Also podman stop live-server will
# close the container, but I think it just does CTRL + C on the terminal window.
#CMD /home/$env_username/mybroker/bin/artemis run

# ==== For d
#USER root

