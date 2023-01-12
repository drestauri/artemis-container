podman run -p 8161:8161 -p 61616:61616 --net new-network --name live-server -d rhel7-artemis-live

#podman run -p 8161:8161 -p 61616:61616 -ti --privileged --entrypoint /bin/bash rhel7-artemis
#podman run -p 8161:8161 -p 61616:61616 -ti --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis /bin/bash


#podman run -p 8161:8161 -p 61616:61616 --rm --privileged -ti -v /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis
