#!/usr/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade

# Install Python and Sensor tools.
sudo apt-get install python3 python3-setuptools python3-pip python-imaging python-smbus i2c-tools libjpeg zlib1g
pip3 install virtualenv --upgrade pip setuptools wheel

# Download sensor repos.
git clone git@github.com:kyletaylored/piodome.git
cd piodome

# Set up Virtual Environment
python3 -m venv env
source env/bin/activate

# Install dependencies
pip3 install -r requirements.txt

# Install Node based on Arm version.
function install_node {
	# Create local vars.
	local dl_file = "node.tar.xz"
	local dl_dir = "node_store"

	# Download file to predermined file name.
	wget -O $dl_file $1
	# Create download directory and extract there.
	mkdir $dl_dir
	tar -xf -C $dl_dir $dl_file --strip 1
	# Copy all files to /usr/local
	sudo cp -r $dl_dir/* /usr/local/
	# Cleanup
	rm -rf $dl_dir
	rm -f $dl_file
}

OS = $(uname -m)
echo "$OS detected..."
case $OS in
	armv6l)
		install_node "https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-armv6l.tar.xz"
	    ;;
	armv7l)
		install_node "https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-armv7l.tar.xz"
	    ;;
    arm64)
		install_node "https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-arm64.tar.xz"
	    ;;
	*) echo "System not supported."
	   exit 1
	   ;;
esac

if [[ $(type -t npm) != "" ]]; then
  echo "NPM exists. Continuing...";
  npm install pm2@latest -g
 else
  echo "NPM does not exist. Please install it, or see the README.md.";
  exit 1;
 fi
