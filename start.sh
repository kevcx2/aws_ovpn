#!/bin/bash

#v1.0

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ ! -d aws-vpn-client ]; then
	echo -e "${RED}[failed to download/build openvpn. please run build.sh first!] ${NC}"
	exit 1
fi

cd aws-vpn-client/

echo -e "${BLUE}[starting server] ${NC}"
go run server.go &

echo -e "${BLUE}[trying to connect] ${NC}"
./aws-connect.sh
