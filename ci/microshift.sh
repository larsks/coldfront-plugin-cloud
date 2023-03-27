#
# Installs Microshift on Docker
#
set -xe

: "${ACCT_MGT_VERSION:="master"}"
: "${ACCT_MGT_REPOSITORY:="https://github.com/cci-moc/openshift-acct-mgt.git"}"
: "${KUBECONFIG:=$HOME/.kube/config}"

test_dir="$PWD/testdata"
rm -rf "$test_dir"
mkdir -p "$test_dir"

echo '127.0.0.1  onboarding-onboarding.cluster.local' | sudo tee -a /etc/hosts

sudo docker run -d --rm --name microshift --privileged \
    --network host \
    -v microshift-data:/var/lib \
    quay.io/microshift/microshift-aio:latest

sudo docker run -d --name registry --network host registry:2

mkdir -p ~/.kube

for try in {0..10}; do
	echo "copying kubeconfig {$try}"
	sudo docker cp microshift:/var/lib/microshift/resources/kubeadmin/kubeconfig \
		"${KUBECONFIG}" && break
	sleep 2
done

while ! oc get route -A; do
    echo "Waiting on Microshift"
    sleep 5
done

# Install OpenShift Account Management
git clone "${ACCT_MGT_REPOSITORY}" "$test_dir/openshift-acct-mgt"
git -C "$test_dir/openshift-acct-mgt" checkout "$ACCT_MGT_VERSION"
sudo docker build "$test_dir/openshift-acct-mgt" -t "localhost:5000/cci-moc/openshift-acct-mgt:latest"
sudo docker push "localhost:5000/cci-moc/openshift-acct-mgt:latest"

oc apply -k "$test_dir/openshift-acct-mgt/k8s/overlays/crc"
oc wait -n onboarding --for=condition=available --timeout=800s deployment/onboarding

sleep 60
