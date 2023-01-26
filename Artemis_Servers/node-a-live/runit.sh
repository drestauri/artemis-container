podman kill live-server
podman container prune -f

# Remove logs
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log


# Run the container
podman run -p 8161:8161 -p 61616:61616 \
	--net my-network \
	--name live-server \
	--mount type=volume,source=my-vol,target=/app \
	-d rhel7-artemis-live

#podman run -p 8161:8161 -p 61616:61616 -ti --privileged --entrypoint /bin/bash rhel7-artemis
#podman run -p 8161:8161 -p 61616:61616 -ti --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis /bin/bash


#podman run -p 8161:8161 -p 61616:61616 --rm --privileged -ti -v /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7-artemis
