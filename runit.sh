podman run -p 8161:8161 -d rhel7-artemis

#podman run -p 8161:8161 -ti --privileged --entrypoint /bin/bash rhel7-artemis
#podman run -p 8161:8161 -ti --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis /bin/bash


#podman run -p 8161:8161 --rm --privileged -ti -v /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis