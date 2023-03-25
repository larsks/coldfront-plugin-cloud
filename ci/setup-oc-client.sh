#!/bin/sh

set -xe

curl -sf -O "https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/stable/openshift-client-linux.tar.gz"
sudo tar -xf openshift-client-linux.tar.gz -C /usr/local/bin oc kubectl
