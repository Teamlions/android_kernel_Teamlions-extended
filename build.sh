#!/bin/bash
# Author- Muralivijay, bitrvmpd
clear
echo "#######################################################"
echo "##### Teamlions-Extended Kernel - Build Script ########"
echo "#######################################################"

# Any2kernel2
echo "Clone Any2kernel2 if you don,t have "
git clone https://github.com/muralivijay/AnyKernel2.git -b 9.0-teamlions-rolex ~/AnyKernel2_teamlions/

# Toolchain
echo "Clone Linaro arm64 toolchain if you don,t have "
git clone https://github.com/Teamlions/aarch64-linux-gnu-7.3.git aarch64-linux-gnu-7.3

# Make clean build
echo "${blu}Make clean build?${txtrst}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) make clean && make mrproper && sh ~/AnyKernel2_teamlions/cleanup.sh ; break;;
        No ) break;;
    esac
done

# CCACHE configuration
# ====================
# If you want you can install ccache to speedup recompilation time.
# In ubuntu just run "sudo apt-get install ccache".
# By default CCACHE will use 2G, change the value of CCACHE_MAX_SIZE
# to meet your needs.
if [ -x "$(command -v ccache)" ]
then
  # If you want to clean the ccache
  # run this script with -clear-ccache
  if [[ "$*" == *"-clear-ccache"* ]]
  then
    echo -e "\n\033[0;31m> Cleaning ~/.ccache contents\033[0;0m"
    rm -rf ~/.ccache
  fi
  # If you want to build *without* using ccache
  # run this script with -no-ccache flag
  if [[ "$*" != *"-no-ccache"* ]] 
  then
    export USE_CCACHE=1
    export CCACHE_DIR=~/.ccache
    export CCACHE_MAX_SIZE=2G
    echo -e "\n> $(ccache -M $CCACHE_MAX_SIZE)"
    echo -e "\n\033[0;32m> Using ccache, to disable it run this script with -no-ccache\033[0;0m\n"
  else
    echo -e "\n\033[0;31m> NOT Using ccache, to enable it run this script without -no-ccache\033[0;0m\n"
  fi
else
  echo -e "\n\033[0;33m> [Optional] ccache not installed. You can install it (in ubuntu) using 'sudo apt-get install ccache'\033[0;0m\n"
fi

# Want to use a different toolchain? (Linaro, UberTC, etc)
# ==================================
# point CROSS_COMPILE to the folder of the desired toolchain
# don't forget to specify the prefix. Mine is: aarch64-linux-android-
CROSS_COMPILE=~/aarch64-linux-gnu-7.3/bin/aarch64-linux-gnu-

# Are we using ccache?
if [ -n "$USE_CCACHE" ]
then
  CROSS_COMPILE="ccache $CROSS_COMPILE"
fi

# Export ARCH-arm64 & Launch rolex
echo " Config Kernel if you want add or disable any driver or feature "
echo "                                                                "
export ARCH=arm64 && export SUBARCH=arm64 && make rolex_defconfig && make menuconfig

# Build Process
echo -e "> Opening rolex_config file...\n"
echo -e "> Starting kernel compilation using rolex_defconfig file...\n"
  CROSS_COMPILE=$CROSS_COMPILE make -j$( nproc --all )

start=$SECONDS

# Get current kernel version
KERNEL_VERSION=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')
echo -e "\n\n> Packing Teamlions-Extended Kernel v$KERNEL_VERSION\n\n"
# Pack the kernel as a flashable TWRP zip. Pie Edition
~/AnyKernel2_teamlions/build.sh $KERNEL_VERSION PIE

end=$SECONDS
duration=$(( end - start ))
printf "\n\033[0;33m> Completed in %dh:%dm:%ds\n" $(($duration/3600)) $(($duration%3600/60)) $(($duration%60))
echo -e "=====================================\n"
