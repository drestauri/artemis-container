# artemis-container
Creating an Artemis container

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
