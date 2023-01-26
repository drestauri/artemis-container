# artemis-container
Creating an Artemis container

# Getting Started
The dnsname plugin is necessary for container's reference each other by name. Find it at the link below and clone it to your container host VM:
```www.github.com/containers/dnsname```

Building that plugin also requires golang:
```sudo yum install go```

Change directories into dnsname where the Makefile is and run the following to build the dnsname plugin:
```
sudo make PREFIX=/usr
sudo make install PREFIX=/usr
```

To see available networks:
``` podman network ls ```

You can then proceed to create your network for podman:
``` podman network create my-network```

To see available volumes:
``` podman volume ls ```

Also need to create a volume for storing container logs
``` podman volume create my-vol ```

You can list and inspect volumes to find the mountpoint where the data is stored locally
``` podman volume inspect my-vol ```

And include the network and volume, along with a name, when you run your container:
```podman run -p 8161:8161 -p 61616:61616 \
    --net new-network \
    --name live-server \
    --mount type=volume,source=my-vol,target=/app \
    -d rhel7-artemis-live```

Login to the container:
```podman exec -it live-server /bin/bash```

And you could be able to reference the other server by name (assuming it was run in the same fashion using a different port):
```curl -v backup-server:8162```

# TODO
 - Add Usage below
 - Consider installing nslookup
 - Test thoroughly
 - Implement SSL enabled server
 - Implement Backup servers

# Description
TBD

# Usage
TBD
