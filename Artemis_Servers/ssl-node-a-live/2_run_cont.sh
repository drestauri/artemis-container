podman kill ssl-container 2> /dev/null
podman container prune -f

# Remove logs
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log 2> /dev/null
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log 2> /dev/null


# If the container stays running
podman run -p 8161:8161 -p 61616:61616 -p 61617:61617 -p 61618:61618 -p 61619:61619 \
	--net my-network \
	--name ssl-container \
	--mount type=volume,source=my-vol,target=/app \
       	-d rhel7-artemis-ssl

# If the container doesn't stay running, login directly to keep it running
#podman run -ti --name my-container --entrypoint /bin/bash rhel7-raw
