FROM rhel7

MAINTAINER Red Hat, Inc.

# User Arguments
ARG username=drestauri
ARG default_pw=password
ARG root_pw=securepass

#labels for container catalog
LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
LABEL io.openshift.tags="base rhel7"

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#====== ROOT USER =======
# Install apps while still root user
RUN yum update -y;
RUN yum groupinstall "Development Tools" -y

RUN yum install java-11-openjdk -y
RUN yum install wget -y
RUN yum install less -y
RUN yum install python3 -y

# Set the root pw
RUN echo root:$root_pw | chpasswd

# Create a new user, add them to sudoers (disabled), give a defualt pw,  and switch to it
RUN useradd $username
RUN echo $username:$default_pw | chpasswd


WORKDIR /home/$username/

# ==== ENTRY POINT =====
# Keep the container alive
CMD echo "test"  > tmp.txt && tail -f tmp.txt

