podman kill ssl-container
podman container prune -f

# Remove logs
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log


# If the container stays running
podman run --name ssl-container -d rhel7-artemis-ssl

# If the container doesn't stay running, login directly to keep it running
#podman run -ti --name my-container --entrypoint /bin/bash rhel7-raw
