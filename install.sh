#!/usr/bin/bash

# Console colors
red='\033[0;31m'
green='\033[0;32m'
green_bg='\033[42m'
yellow='\033[1;33m'
NC='\033[0m'
echo_red () { echo -e "${red}$1${NC}"; }
echo_green () { echo -e "${green}$1${NC}"; }
echo_green_bg () { echo -e "${green_bg}$1${NC}"; }
echo_yellow () { echo -e "${yellow}$1${NC}"; }

# Update system
echo_yellow "Starting Piodome installation..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and Sensor tools.
sudo apt-get install python3 python3-setuptools i2c-tools libjpeg-dev zlib1g-dev -y
sudo apt-get install python3-pip python3-venv python3-pil python3-smbus -y

# Enable I2C on Raspberry Pi
# sudo sed -in "s/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/1" /boot/config.txt
# Enable SSH (create empty SSH file in boot)
# sudo touch /boot/ssh
# Update hostname
# sudo hostname piodome

# Set Python3 as default
cat <<BASH >> ~/.bashrc

# Set Python3 as default
alias python='/usr/bin/python3'
alias pip=pip3
BASH

# Update Python tools
pip install --upgrade pip setuptools wheel virtualenv

# Download sensor repos.
git clone git@github.com:kyletaylored/piodome.git
cd piodome

# Set up Virtual Environment / activate
# python3 -m venv env
# source env/bin/activate

# Install dependencies
pip3 install -r requirements.txt

# Install Node based on Arm version.
function install_node {
	# Create local vars.
	local dl_file="node.tar.xz"
	local dl_dir="node_store"

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

OS=`echo $(uname -m)`
echo "${OS} detected..."
case ${OS} in
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
