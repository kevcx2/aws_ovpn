#!/bin/bash

#v0.3

#TODO:
#-----
#1. replace openvpn-2.5.1 with var
#2. add fancy output 

# cloning git repo
git clone https://github.com/samm-git/aws-vpn-client.git
cd aws-vpn-client/

# dl and unpack
wget https://swupdate.openvpn.org/community/releases/openvpn-2.5.1.tar.xz
tar xf openvpn-2.5.1.tar.xz
cp openvpn-v2.5.1-aws.patch openvpn-2.5.1
cd openvpn-2.5.1

# apply patch
patch -p1 < openvpn-v2.5.1-aws.patch

# install deps for openvpn
sudo apt install liblz4-dev liblzo2-dev libpam0g-dev libpkcs11-helper1-dev

# build openvpn 
./configure --with-crypto-library=openssl
make -j4 && echo 'built successfully' || echo 'failed to build'
sudo make install && echo 'installed successfully' || echo 'failed to install'

# copy binary to run by aws-connect.sh
cp src/openvpn/openvpn ../

#additional config copying
cd ../
cp ../aws-connect.sh ../vpn.conf .


echo 'build process is over. please run start.sh'
