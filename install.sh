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

echo_yellow "Removing bloatware..."
sudo curl -fsSL https://raw.githubusercontent.com/raspberrycoulis/remove-bloat/master/remove-bloat.sh | bash

# Install Python and Sensor tools.
echo_yellow "Installing essentials..."
sudo apt-get install git jq python3 python3-setuptools i2c-tools -qq
sudo apt-get install python3-pip python3-venv python3-pil python3-w1thermsensor -qq
sudo apt-get install libfreetype6-dev libjpeg-dev build-essential -qq

# Add Pi user to I2C group.
sudo usermod -a -G i2c pi

# Enable I2C/1-Wire on Raspberry Pi
echo_yellow "Enabling I2C / 1-Wire interfaces..."
sudo cat <<BASH >> /boot/config.txt

# I2C / 1-Wire
dtoverlay=w1-gpio-pullup,gpiopin=27
# Improve performance by increasing I2C baudrate to 400KHz
dtparam=i2c_arm=on,i2c_baudrate=400000
BASH

# Enable SSH (create empty SSH file in boot)
# sudo touch /boot/ssh
# Update hostname
# sudo hostname piodome

# Set up GPIO pullup pin for DS18B20
# Removes need for dedicated external power.
sudo modprobe w1-gpio
sudo modprobe w1-therm
sudo dtoverlay w1-gpio gpiopin=27 pullup=1

# Set Python3 as default
cat <<BASH >> ~/.bashrc

# Set Python3 as default
alias python='/usr/bin/python3'
alias pip=pip3
BASH
source ~/.bashrc

# Update Python tools
pip install --upgrade pip setuptools wheel virtualenv

# Download sensor repos.
git clone git@github.com:kyletaylored/piodome.git
cd piodome

# Set up Virtual Environment / activate
# python3 -m venv env
# source env/bin/activate

# Install dependencies
pip install -r requirements.txt

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
