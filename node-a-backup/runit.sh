podman kill live-server
podman container prune -f

# Remove logs
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stdout.log
sudo rm /home/drestauri/.local/share/containers/storage/volumes/my-vol/_data/stderr.log


# Run the container
podman run -p 8162:8162 -p 61617:61617 \
	--net new-network \
	--name backup-server \
	--mount type=volume,source=my-vol,target=/app \
	-d rhel7-artemis-backup

