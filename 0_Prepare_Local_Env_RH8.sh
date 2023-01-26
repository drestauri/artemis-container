

# This script will install dependencies and make sure your environment
# is setup to support the later steps

DEV_DIR=~/dev

mkdir $DEV_DIR 2> /dev/null
cd $DEV_DIR

OS_CHECK=$(cat /etc/*release | grep -i version | grep "7\.")

if
	[ -z "$OS_CHECK" ]
then
	echo "This automation is only meant to be run from a RHEL8 VM"
else
	# Building DNS plugin requires go
	sudo yum install go -y

	# Install the DNS plugin for podman
	git clone git@github.com:containers/dnsname.git

	cd $DEV_DIR/dnsname
	pwd

fi
