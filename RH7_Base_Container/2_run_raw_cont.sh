podman kill my-container
podman container prune -f

# Remove logs
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log
#sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log


# If the container stays running
podman run --name my-container -d rhel7-min

# If the container doesn't stay running, login directly to keep it running
#podman run -ti --name my-container --entrypoint /bin/bash rhel7-raw
