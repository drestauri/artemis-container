# artemis-container
This project was created to test development of an Artemis container with SSL enabled, clustering, and High Availability (live/backup servers).

# Notices
These scripts were developed on a RHEL 8 VM and are not guaranteed to work on other OSs due to differences in the available packages.

Currently, the scripts are setup to support testing of an SSL enabled client-broker connection which has been unsuccessful so far.

# Getting Started
The shell scripts included in this project should contain all of the commands necessary to setup dependencies, build, and run an Artemis Broker with SSL enabled and a Client with the ActiveMQ Client libraries and GMSEC API installed.

Once the container's are run, verify they are running with
``` podman ps ```

You should see 2 containers with the names "ssl-container" and "client-container". You can now run scripts 7 and 8 to get a terminal in either of those containers. 

Both containers are currently setup to still need you to manually start the Artemis bus (ssl-container) and run whichever pub_test.sh (client-container) you wish to test.

# Usage
You should be able to just run scripts 0 through 6 to build and set everything up. Rerun individual scripts as needed to rebuild the Artemis servers or Clients. Then login to the running containers with scripts 7 and 8. Occasionally, you can run script 99 to clean up stale containers.

The way the scripts are setup, the ssl-container will have 3 ports open (61616, 61617, 61618) with 3 different certifate solutions applied (my own certs, GMSEC script generated certs, and the certs provided with the Artemis examples) and an additional port for TCP connections (61619).

The client-container has all 3 cert types in the home directory with 4 scripts for testing each of the above 4 connection methods. 

Note that all 3 SSL solutions result in the same failed connection and error messages, though the certs generated via my own cert process have an additional error so are likely no good. I am keeping them in there for future testing.

# TODO
 - Consider installing nslookup
 - Test thoroughly
 - Implement & Verify SSL enabled server
 - Implement Backup servers

