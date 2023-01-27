

# This script will install dependencies and make sure your environment
# is setup to support the later steps

DEV_DIR=~/dev

mkdir $DEV_DIR 2> /dev/null
cd $DEV_DIR

OS_CHECK=$(cat /etc/*release | grep -i version | grep "8\.")

if
	[ -z "$OS_CHECK" ]
then
	echo "This automation is only meant to be run from a RHEL8 VM"
else
	# Building DNS plugin requires go
	sudo yum install go -y

	# Install the DNS plugin for podman so that you can reference
	# other container's by hostname instead of by IP
	# Source: www.github.com/containers/dnsname
	# SSH:
	#git clone git@github.com:containers/dnsname.git
	# HTTPS:
	git clone https://github.com/containers/dnsname.git

	cd $DEV_DIR/dnsname
	sudo make PREFIX=/usr
	sudo make install PREFIX=/usr

	# Create personal network for the containers to be on for DNS
	podman network create my-network

	# Create a volume for storing logs (or other data)
	podman volume create my-vol

fi
