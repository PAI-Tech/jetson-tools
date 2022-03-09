#!/bin/bash
# Install-for-sensor-Jetson
# Created by Eran Caballero on Wed Feb 16 10:20:08 UTC 2022
# Copyrights PAI Tech INC 2022, all rights reserved

# This script contains:

	# Installs all required packages
	# Setting parameters
	# Installs Jetson GPIO Sersors requirements

set -e

# PAI includes

PAI=/var/PAI
PAI_LOGS=$PAI/Logs

# PAI Const
PIP_FOLDER="$HOME/.cache/pip"
PAI_APPS_FOLDER="$PAI/Apps"
PAI_INSTALLER_NAME="Pai Sensor Project"
GPIO_GROUP_NAME="gpio"
GIT_REPO_JETSON_GPIO="https://github.com/NVIDIA/jetson-gpio.git"
GIT_REPO_JETSON_GPIO_FOLDER="$PAI_APPS_FOLDER/jetson-gpio"
LIBI2C_GROUP_NAME="libi2c"
GIT_REPO_JETSON_LIBI2C="https://github.com/amaork/libi2c.git"
GIT_REPO_JETSON_LIBI2C_FOLDER="$PAI_APPS_FOLDER/libi2c"
PYTHON3_SETUP_INSTALL_COMMAND="python3 setup.py install"

logfile=_`date +%Y%m%d-%H%M%S`

# Validate sudo
if [ $(id -u) -ne 0 ]; then
        printf "Script must be run as root. Try 'sudo ./install-gpio-python.sh'\n"
        exit 1
fi

# PAI functions

log(){
  typeset str="`date +'[%Y/%m/%d %H:%M:%S] '` $@"
  echo -e "${str}" |\
  tr -s ' ' |\
  tee -a ${logfile}
}

# Give permissions for PIP
chown -R ${USER}:${USER} $PIP_FOLDER

pai_jetson_gpio_install()
{
	log -e "\e[91m$PAI_INSTALLER_NAME\n"
	log -e "\e[34mInstalling requirments for Sensor Project\n"
	echo ""
	mkdir -p $PAI_APPS_FOLDER
	chown -R ${USER}:${USER} $PAI_APPS_FOLDER
	echo ""

	log -e "\e[33mInstall Jetson GPIO + BMP280\n"
	git clone $GIT_REPO_JETSON_GPIO $GIT_REPO_JETSON_GPIO_FOLDER
	chown -R ${USER}:${USER} $GIT_REPO_JETSON_GPIO_FOLDER
	cd $GIT_REPO_JETSON_GPIO_FOLDER
	$PYTHON3_SETUP_INSTALL_COMMAND
	cd ..
	cp $GIT_REPO_JETSON_GPIO_FOLDER/build/lib/Jetson/GPIO/99-gpio.rules /etc/udev/rules.d/
	udevadm control --reload-rules && sudo udevadm trigger
	groupadd -f $GPIO_GROUP_NAME
	usermod -aG $GPIO_GROUP_NAME ${USER}
	groupadd -f $LIBI2C_GROUP_NAME
	usermod -aG $LIBI2C_GROUP_NAME ${USER}
	pip3 install bmp280
	echo ""

	log -e "\e[34mInstalling libi2c\n"
	git clone $GIT_REPO_JETSON_LIBI2C $GIT_REPO_JETSON_LIBI2C_FOLDER
	chown -R ${USER}:${USER} $GIT_REPO_JETSON_LIBI2C_FOLDER
	cd $GIT_REPO_JETSON_LIBI2C_FOLDER
	$PYTHON3_SETUP_INSTALL_COMMAND
	cd ..
	echo ""

	log -e "\e[33mInstalling websocket\n"
	sudo -H pip3 install adafruit-circuitpython-servokit
	pip3 install websocket-client
	echo ""

	log -e "\e[34mValidates correct connection\n"
	i2cdetect -y -r 1
	echo ""
	log -e "\e[1mMake sure you see "'>>>>>76<<<<<'"\n"
	echo ""
	sleep 5

	log -e "\e[34mImporting Air Pressure Project\n"
	wget -O $PAI_APPS_FOLDER/AirPressureProject.tar.gz https://cdn.pai-net.org/pai-cdn/get-file?cdn-key=c7a12501-4fe6-4696-8957-86761f504eab
	tar -xvf AirPressureProject.tar.gz > /dev/null
	chown -R ${USER}:${USER} AirPressureProject/
	rm AirPressureProject.tar.gz

}

# PAI MAIN FLOW

pai_jetson_gpio_install