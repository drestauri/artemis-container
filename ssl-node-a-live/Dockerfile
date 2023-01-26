
# NOTE: rhel-min is a self build image on top of the base "rhel7" image from RedHat
# You need to make sure this is already on the system with: podman images
# If not, build it from your drestauri/amq-builds-scripts git project
FROM localhost/rhel7-min 

MAINTAINER Red Hat, Inc.

# User Arguments
ARG username=drestauri
#ARG default_pw=password
#ARG root_pw=securepass
ARG artemis_ver=2.27.1

# Need ENV as well for anything interpreted from inside the container (e.g. echo'ed to a shell)
#ENV env_username $username
#ENV env_artemis_install_dir $artemis_install_dir

#labels for container catalog
#LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
#LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
#LABEL io.openshift.tags="base rhel7"

#ENV container oci
#ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#====== ROOT USER =======
# Install apps while still root user
#RUN yum update -y;
#RUN yum groupinstall "Development Tools" -y

#RUN yum install java-11-openjdk -y
#RUN yum install wget -y
#RUN yum install less -y
#RUN yum install python3 -y
#RUN yum install openssl openssl-devel -y

# Set the root pw
#RUN echo root:$root_pw | chpasswd

# Create a new user, add them to sudoers (disabled), give a defualt pw,  and switch to it
#RUN useradd $username
#RUN echo $username:$default_pw | chpasswd



#====== Install Artemis Dependencies ======
# Download OpenSSL 3.0
USER $username
WORKDIR /home/$username/
RUN git clone git://git.openssl.org/openssl.git
# Prereqs:
# make
# Perl 5 (see NOTES-PERL.md)
USER root
RUN yum install perl-core -y

USER $username
WORKDIR /home/$username/openssl
RUN ./Configure
RUN make

USER root
RUN make install
RUN ldconfig /usr/local/lib64


# Download Artemis
USER $username
WORKDIR /home/$username/
RUN wget -c "https://www.apache.org/dyn/closer.cgi?filename=activemq/activemq-artemis/$artemis_ver/apache-artemis-$artemis_ver-bin.tar.gz&action=download"
RUN mv *apache-artemis-$artemis_ver* apache-artemis-$artemis_ver-bin.tar.gz
RUN tar -xvf apache-artemis-$artemis_ver-bin.tar.gz
RUN rm *.tar.gz

RUN echo "export ARTEMIS_HOME=$HOME" >> ~/.bashrc


# ==== ENTRY POINT =====
# Keep the container alive
CMD echo "test"  > tmp.txt && tail -f tmp.txt
















