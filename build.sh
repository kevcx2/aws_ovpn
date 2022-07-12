#!/bin/bash

#v1.0

O_VER='2.5.1'
OVPN_VER=openvpn-${O_VER}
PATCH_VER=openvpn-v${O_VER}
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

JOBS=`nproc`

echo -e "${BLUE}[using $OVPN_VER] ${NC}"

#cleanup
if [ -d aws-vpn-client ]; then
	rm -rf aws-vpn-client
fi

# cloning git repo
echo -e "${BLUE}[cloning git repo] ${NC}"
git clone https://github.com/samm-git/aws-vpn-client.git
if [ $? -ne "0" ]; then
	echo -e "${RED}[failed to download repo ] ${NC}"
	exit 1
fi

cd aws-vpn-client/

# dl and unpack
echo -e "${BLUE}[downloading openvpn] ${NC}"
wget https://swupdate.openvpn.org/community/releases/${OVPN_VER}.tar.xz
if [ $? -ne "0" ]; then
	echo -e "${RED}[failed to download openvpn ] ${NC}"
	exit 1
fi

echo -e "${BLUE}[unpacking] ${NC}"
tar xf ${OVPN_VER}.tar.xz
cp ${PATCH_VER}-aws.patch ${OVPN_VER}
cd ${OVPN_VER}

# apply patch
echo -e "${BLUE}[patching] ${NC}"
patch -p1 < ${PATCH_VER}-aws.patch
if [ $? -ne "0" ]; then
	echo -e "${RED}[failed to patch openvpn ] ${NC}"
	exit 1
fi

# install deps for openvpn
echo -e "${BLUE}[installing deps] ${NC}"
sudo apt install -y liblz4-dev liblzo2-dev libpam0g-dev libpkcs11-helper1-dev
if [ $? -ne "0" ]; then
	echo -e "${RED}[failed to install deps] ${NC}"
	exit 1
fi

# build openvpn 
echo -e "${BLUE}[configuring openvpn] ${NC}"
./configure --with-crypto-library=openssl
if [ $? -ne "0" ]; then
	echo -e "${RED}[failed to configure openvpn ] ${NC}"
	exit 1
fi
echo -e "${BLUE}[building openvpn] ${NC}"
make -j${JOBS} && echo -e "${BLUE}built successfully ${NC}" || echo 'failed to build'
echo -e "${BLUE}[installing openvpn] ${NC}"
sudo make install && echo -e "${BLUE}installed successfully ${NC}" || echo 'failed to install'

# copy binary to run by aws-connect.sh
cp src/openvpn/openvpn ../

#additional config copying
cd ../
cp ../aws-connect.sh ../vpn.conf .

echo -e "${BLUE}[build process is over. please run start.sh] ${NC}"
