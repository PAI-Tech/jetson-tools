#!/bin/bash
# pai-aime-base-install
# Install new AIME jetson
# Created by Eran Caballero on Wed Feb 9 10:20:08 UTC 2022
# Copyrights PAI Tech INC 2022, all rights reserved

#This script contains:

	#Set JETSON specific settings
	#Installs & update all required packages
	#Setting parameters
	#Installs AIME o/s file system


set -e

# PAI includes

PAI=/var/PAI
PAI_LOGS=$PAI/Logs

# PAI Const
PIP_FOLDER="$HOME/.cache/pip"
PAI_APPS_FOLDER="$PAI/Apps"
PAI_SYSTEM_FOLDER="$PAI/System"
PAI_INSTALLER_NAME="Pai Sensor Project"
BASHRC_FILE="$HOME/.bashrc"
PROFILE_FILE="/etc/profile"
NODEJS_DOWNLOAD_LINK="https://deb.nodesource.com/setup_12.x"
FINDGLLIB_FILE_NAME_LOCATION="/usr/local/cuda/samples/common/findgllib.mk"
FINDGLLIB_FILE_DOWNLOAD_LINK="https://cdn.pai-net.org/pai-cdn/get-file?cdn-key=5956a637-af93-45f4-a88e-2d8eaadb26f9"
AIME_OS_FS_GIT_FOLDER_NAME="PAI-OS-INSTALLER"
AIME_OS_FS_GIT_LINK="https://github.com/PAI-Tech/PAI-OS-INSTALLER.git"
LIB_FOLDER="/usr/local/lib"
LIB_PKGCONFIG_FOLDER="$LIB_FOLDER/pkgconfig"
CUDA_FOLDER="/usr/local/cuda"
CUDA_BIN_FOLDER="$CUDA_FOLDER/bin"
CUDA_LIB64_FOLDER="$CUDA_FOLDER/lib64"
NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE="/etc/docker/daemon.json"
NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE_DOWNLOAD_LINK="https://cdn.pai-net.org/pai-cdn/get-file?cdn-key=9f3e56d3-d2c4-46f9-b1fd-3df13bc2429e"
NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE="/etc/nvidia-container-runtime/config.toml"
NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE_DOWNLOAD_LINK="https://cdn.pai-net.org/pai-cdn/get-file?cdn-key=865138be-3ca1-4b89-ac8b-ae30948af170"
NVIDIA_DEEPSTREAM_FOLDER="/opt/nvidia/deepstream/deepstream"
NVIDIA_DEEPSTREAM_LIB_FOLDER="$NVIDIA_DEEPSTREAM_FOLDER/lib"
DUSTYN_JETSON_INFERENCE_GIT_FOLDER_NAME="jetson-inference"
DUSTYN_JETSON_INFERENCE_GIT_LINK="https://github.com/dusty-nv/jetson-infrernce.git"


PAI_INSTALLER_NAME="Pai Prepare AIME Jetson Linux Ubuntu"

logfile="pai-os-base-install_`date +%Y%m%d-%H%M%S`"

# Validate sudo
if [ $(id -u) -ne 0 ]; then
        printf "Script must be run as root. Try 'sudo ./pai-os-base-install.sh'\n"
        exit 1
fi

# PAI functions

log(){
  typeset str="`date +'[%Y/%m/%d %H:%M:%S] '` $@"
  echo -e "${str}" |\
  tr -s ' ' |\
  tee -a ${logfile}
}

pai_intro()
{
	log "\e[91mPrepairing Linux OS For AIME\n"
	echo ""
	cp $FINDGLLIB_FILE_NAME_LOCATION $FINDGLLIB_FILE_NAME_LOCATION.bak
	wget -O $FINDGLLIB_FILE_NAME_LOCATION $FINDGLLIB_FILE_DOWNLOAD_LINK
	cp $NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE $NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE.bak
        wget -O $NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE $NVIDIA_CONTAINER_RUNTIME_CONFIG_FILE_DOWNLOAD_LINK
	cp $NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE $NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE.bak
        wget -O $NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE $NVIDIA_CONTAINER_RUNTIME_DAEMON_FILE_DOWNLOAD_LINK
	echo ""
}

pai_update_os()
{
	log "\e[34mUpdating OS & Installing Default (Jetson-Linux)...\n"
	PAI_REQUIERED_PREPARE_INSTALLATION="nano curl htop pydf zip unzip htop git build-essential gcc g++ make ubuntu-drivers-common libssl-dev libffi-dev libomp-dev software-properties-common python-pip python3-pip python-dev python-numpy python-tk python3-dev python3-tk python3-numpy python-setuptools python-scipy python3-pil python3-smbus python3-matplotlib libpython3-dev libopenmpi-dev ninja-build libatlas-base-dev libatlas3-base net-tools libgl1-mesa-dri mesa-va-drivers mesa-vdpau-drivers ubuntu-drivers-common openssh-server libfreetype6-dev libboost1.65-dev libboost-filesystem1.65-dev libboost-system1.65-dev libboost-date-time1.65-dev libboost-atomic1.65-dev libboost-chrono1.65-dev libboost-date-time1.65-dev libboost-system1.65-dev libboost-dev libboost-tools-dev magics++ libboost-log1.65-dev libboost-thread1.65-dev libkml-dev libboost-log-dev libboost-thread-dev yasm nasm wget sysstat cmake libopus-dev libass-dev libtool libc6 libc6-dev libnuma1 libnuma-dev sysstat x264 libx264-dev libx265-dev libvpx-dev libfdk-aac-dev libmp3lame-dev pkg-config libtiff5-dev freeglut3-dev libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev libglfw3-dev libgles2-mesa-dev libavcodec-dev libavformat-dev libv4l-dev libxvidcore-dev libgtk-3-dev libhdf5-serial-dev graphviz gfortran libswscale-dev libavresample-dev libxvidcore-dev x264 libfaac-dev libmp3lame-dev libtheora-dev libfaac-dev libmp3lame-dev libvorbis-dev libavresample-dev checkinstall libopencore-amrnb-dev libopencore-amrwb-dev libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils libgtk-3-dev libopencv-dev yasm libdc1394-22-dev libxine2-dev libv4l-dev libtbb-dev libeigen3-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils qt5-default libvtk6-dev ant default-jdk zlib1g-dev libwebp-dev libtiff5-dev libopenexr-dev libgdal-dev libtbb2 libglew-dev python-opencv python-vtk6 liblapacke liblapacke-dev libopenblas-base libopenblas-dev libtmglib-dev libtmglib3 doxygen graphviz python-pil python-pil.imagetk python-decorator mesa-utils hdf5-tools libhdf5-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran python3-venv libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libgtk2.0-dev libgtk-3-dev libpng-dev libjpeg-dev libopenexr-dev libtiff-dev libwebp-dev ffmpeg"
	apt-get -qq update
	apt-get -y -qq install apt-utils
	apt-get -y -qq install nvidia-jetpack
	apt-get -y -qq upgrade
	apt-get -y -qq dist-upgrade
	apt-get -y -qq install $PAI_REQUIERED_PREPARE_INSTALLATION
	apt-get -y -qq autoremove
	apt-get clean
	log "\e[34mOS updated :)\n"
	cd /usr/include/linux
	ln -s -f ../libv4l1-videodev.h videodev.h
	chown -R $USER:$USER $HOME/.cache/
	echo ""
	echo ""
}

pai_update_locale()
{
	locale-gen "he_IL.UTF-8"
	locale-gen "en_US.UTF-8"
	#dpkg-reconfigure locales #IBM
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 #Jetson #MS
	timedatectl set-timezone Asia/Jerusalem
	log "\e[31mLocale (UTF+TZ) updated\n"
	echo ""
}

pai_handle_sudoers()
{
	log "\e[34mHandling Sudoers\n"
	dpkg-statoverride --update --add root sudo 4750 /bin/su
	echo ""
}

pai_update_profiles()
{
	if grep -r "PAI :]" "$PROFILE_FILE";
	then 
		log "\e[31mProfile file already updated\n"
	else
		echo "# PAI :]" >> $PROFILE_FILE
		echo "PAI=/var/PAI" >> $PROFILE_FILE
		echo "" >> $PROFILE_FILE
		echo "PATH=$CUDA_BIN_FOLDER:$PATH" >> $PROFILE_FILE
		echo "LD_PATH_LIBRARY=$CUDA_LIB64_FOLDER:$LIB_FOLDER:$NVIDIA_DEEPSTREAM_LIB_FOLDER" >> $PROFILE_FILE
		echo "LD_LIBRARY_PATH=$LIB_FOLDER:$CUDA_LIB64_FOLDER" >> $PROFILE_FILE
		echo "LIBRARY_PATH=$LIBRARY_PATH:$CUDA_LIB64_FOLDER" >> $PROFILE_FILE
		echo "LD_RUN_PATH=$LIB_FOLDER" >> $PROFILE_FILE
		echo "PKG_CONFIG_PATH=$LIB_PKGCONFIG_FOLDER" >> $PROFILE_FILE
		echo "" >> $PROFILE_FILE
		. $PROFILE_FILE
#		echo "nameserver 8.8.8.8" >> /etc/resolv.conf
		log "\e[31mProfile file updated\n"
		echo ""
	fi
}

pai_update_bashrc()
{
    if grep -r "PAI :]" "$BASHRC_FILE";
        then 
                log "\e[34mBashrc file already updated\n"
	else
		echo "" >> $BASHRC_FILE
		echo "# PAI :]" >> $BASHRC_FILE
		echo "PAI=/var/PAI" >> $BASHRC_FILE
		echo "" >> $BASHRC_FILE
		echo "xhost +" >> $BASHRC_FILE
		echo "# Start X if no DISPLAY" >> $BASHRC_FILE
		echo "if [ -z "$DISPLAY" ]" >> $BASHRC_FILE
		echo "then" >> $BASHRC_FILE
		echo "  startx > /dev/null 2>&1 &" >> $BASHRC_FILE
		echo "  export DISPLAY=:1.0" >> $BASHRC_FILE
		echo "fi" >> $BASHRC_FILE
		. $BASHRC_FILE
		log "\e[34mBashrc file updated\n"
		echo ""
	fi
}

pai_ssh_setup()
{
	log "\e[31mSet SSH Setup\n"
	SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
	log "Reconfigure password authentication"
	sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG_FILE
	apt-get -y -qq install openssh-client openssh-server openssh-sftp-server
	service ssh restart
	log "\e[31mDone...\n"
	echo ""
}

pai_nodejs_install()
{
    log "\e[34mInstalling Nodejs\n"
	curl -sL $NODEJS_DOWNLOAD_LINK | sudo -E bash - && \
	apt-get -y -qq install nodejs
	npm i -g fsevents
	npm i -g forever
	chown -R $USER:$(id -gn $USER) $HOME/.config
	usermod -aG docker $USER
	log "\e[34mDone...\n"
	echo ""
}

pai_install_os_fs()
{
	log "\e[31mInstalling AIME O/S FS\n"
	git clone $AIME_OS_FS_GIT_LINK
	chown -R $USER:$USER $AIME_OS_FS_GIT_FOLDER_NAME
	python3 ./$AIME_OS_FS_GIT_FOLDER_NAME/setup.py install
	rm -rf $AIME_OS_FS_GIT_FOLDER_NAME
	chown -R $USER:$USER $PAI_APPS_FOLDER
	chown -R $USER:$USER $PAI_SYSTEM_FOLDER
	log "\e[31mDone...\n"
	echo ""
}

pai_install_jetson_inference()
{
	#Installs also Torch & Torchvision
	log "\e[34mInstalling Dustyn Jetson-Inference\n"
	echo ""
	chown -R $HOME/.config
	pip3 install setuptools
	pip3 install Cython
	pip3 install scikit-build
	pip3 install ninja
	chown -R $USER:$USER $PAI_APPS_FOLDER
	chown -R $USER:$USER $PAI_SYSTEM_FOLDER
	git clone --recursive $DUSTYN_JETSON_INFERENCE_GIT_LINK $PAI_APPS_FOLDER/$DUSTYN_JETSON_INFERENCE_GIT_FOLDER_NAME
	cd $PAI_APPS_FOLDER/$DUSTYN_JETSON_INFERENCE_GIT_FOLDER_NAME
	mkdir -p build && cd build
	cmake ..
	make -j$(nproc)
	make install
	sudo ldconfig
	cd ../..
	python3 -c "\nimport torch; print(torch.__version__\n)"
	log "\n\e[34mJetson Inference installed successfully\n"
	echo ""
}

pai_install_jtop()
{

	log "\e[32mInstallaing Jtop"
	echo ""
	sudo -H pip3 install -U jetson-stats
	apt -y -qq autoremove
	log "\e[31mJtop installed.. Please reboot to use"
}

# PAI MAIN FLOW

pai_intro
pai_install_os_fs
pai_update_profiles
pai_update_bashrc
pai_update_os
pai_update_locale
pai_handle_sudoers
pai_ssh_setup
pai_nodejs_install
pai_install_jetson_inference
pai_install_jtop