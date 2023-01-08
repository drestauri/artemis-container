# artemis-container
Creating an Artemis container

# TODO:
Currently trying to get the service to stat automatically and be managed by systemd. When I run the "../bin/artemis-service start" command it works fine, but I can't seem to get it to work when the container is started.
I have been running it and defining an entry point to the shell. They may be a way to set that to also run the service start script, or perhaps it did run and isn't staying alive... I could even setup a cron to run a keep-alive like python script but I don't think that's appropriate. I suspect there will need to be some long running process in order to keep the container alive.

# Usage
Download the latest Artemis and replace the version information in the Docker file.

Navigate to: http://activemq.apache.org/components/artemis/download/

Copy the link to the tar.gz

Copy it to this directory using wget:
```wget -c "paste-link-inside-quotations"```

Rename the file: 
``` mv htpps://some.long.name.artemis-2.27.1.tar.gz artemis-2.27.1.tar.gz```
