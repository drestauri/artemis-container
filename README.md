# artemis-container
Creating an Artemis container

# Usage Notes
The dnsname plugin is necessary for container's reference each other by name. Check it out at clone it to your container host VM:
```www.github.com/containers/dnsname```

Building that plugin also requires golang:
```sudo yum install go```

Change directories into dnsname where the Makefile is and run the following to build the dnsname plugin:
```
sudo make PREFIX=/usr
sudo make install PREFIX=/usr
```

You can then proceed to create your network for podman:
``` podman network create new-network```

And include it, along with a name, when you run your container:
```podman run -p 8161:8161 -p 61616:61616 --net new-network --name live-server -d rhel7-artemis-live```

Login to the container:
```podman exec -it live-server /bin/bash```

And you could be able to reference the other server by name (assuming it was run in the same fashion using a different port):
```curl -v backup-server:8162```

# TODO
 - Install nslookup
 - Need to get DNS to work in order to find other containers by name
   > dnsmasq? bind? both look like a pain to configure :(
 - Update the usage section below
 - Test thoroughly
 - Start implementing backups and other nodes

# Description
To get the service to run un-interrupted in a container, you need to run the container without a defined entry point and with the -d flag for "detached" (similar to running in the background for containers).
Also, the service start script had to be execute and then a log file opened with ```tail -f``` so that there is some active, running process to keep the container alive.

# Usage
Download the latest Artemis and replace the version information in the Docker file.

Navigate to: http://activemq.apache.org/components/artemis/download/

Copy the link to the tar.gz

Copy it to this directory using wget:
```wget -c "paste-link-inside-quotations"```

Rename the file: 
``` mv htpps://some.long.name.artemis-2.27.1.tar.gz artemis-2.27.1.tar.gz```
