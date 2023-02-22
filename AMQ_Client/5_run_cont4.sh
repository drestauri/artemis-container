#podman kill client-container 2> /dev/null
#podman container prune -f

# Remove logs
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log 2> /dev/null
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log 2> /dev/null


# If the container stays running
podman run \
	--net my-network \
       --name client-container4 \
       --mount type=volume,source=my-vol,target=/app \
       -d rhel7-client

# If the container doesn't stay running, login directly to keep it running
#podman run -ti --name my-container --entrypoint /bin/bash rhel7-raw
