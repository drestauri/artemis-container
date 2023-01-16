podman kill -a

podman container prune -f

podman rmi $(podman images -f dangling=true -q)
