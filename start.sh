#!/bin/bash

cd aws-vpn-client/

go run server.go &

echo 'server is running'

./aws-connect.sh
