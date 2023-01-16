podman kill backup-server
podman container prune -f

podman run -p 8162:8162 -p 61617:61617 --net new-network --name backup-server -d rhel7-artemis-backup

#podman run -p 8162:8162 -p 61617:61617 -ti --privileged --entrypoint /bin/bash rhel7-artemis-backup
#podman run -p 8162:8162 -p 61617:61617 -ti --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis-backup /bin/bash


#podman run -p 8162:8162 -p 61617:61617 --rm --privileged -ti -v /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis-backup
