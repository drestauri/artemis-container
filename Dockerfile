FROM rhel7

MAINTAINER Red Hat, Inc.

#labels for container catalog
LABEL summary="Provides the latest release of Red Hat Enterprise Linux 7 in a fully featured and supported base image."
LABEL io.k8s.display-name="Red Hat Enterprise Linux 7"
LABEL io.openshift.tags="base rhel7"

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy over the server setup and unpack it
COPY artemis-live-a.tar.gz /tmp/artemis-cluster/

WORKDIR /tmp/artemis-cluster/

CMD ["tar", "-xvf", "artemis-live-a.tar.gz"]

# Expose the ports needed for the servers
EXPOSE 61616
EXPOSE 8161
EXPOSE 61617
EXPOSE 8162


CMD ["/bin/bash"]
