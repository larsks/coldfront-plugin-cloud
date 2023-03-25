#!/bin/sh

set -xe

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install docker-compose python3-virtualenv
