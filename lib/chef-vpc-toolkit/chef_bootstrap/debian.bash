function install_chef {

apt-get install -y lsb-release &> /dev/null || { echo "Failed to install lsb-release"; exit 1; }
CODENAME=$(/usr/bin/lsb_release -cs)
local INSTALL_TYPE=${1:-"CLIENT"} # CLIENT/SERVER

local CDN_BASE="http://c2521002.cdn.cloudfiles.rackspacecloud.com"
local TARBALL="chef-client-0.9.16-debian.6.0-x86_64.tar.gz"

if [[ "$CODENAME" == "squeeze" ]]; then
	if [[ "$INSTALL_TYPE" == "SERVER" ]]; then
		TARBALL="chef-server-0.9.16-debian.6.0-x86_64.tar.gz"
	else
        TARBALL="chef-client-0.9.16-debian.6.0-x86_64.tar.gz"
	fi
else
	echo "Only Debian 6.0 (Squeeze) is supported at this time."; exit 1;
fi

apt-get update &> /dev/null || { echo "Failed to apt-get update."; exit 1; }
dpkg -L rsync &> /dev/null || apt-get install -y rsync &> /dev/null

if ! dpkg -L chef &> /dev/null; then

    local CHEF_PACKAGES_DIR=$(mktemp -d)

    wget "$CDN_BASE/$TARBALL" -O "$CHEF_PACKAGES_DIR/chef.tar.gz" &> /dev/null \
        || { echo "Failed to download Chef RPM tarball."; exit 1; }
	cd $CHEF_PACKAGES_DIR
	tar xzf chef.tar.gz || { echo "Failed to extract Chef tarball."; exit 1; }
	rm chef.tar.gz

	echo "chef-solr    chef-solr/amqp_password    password  YA1B2C301234Z" | debconf-set-selections &> /dev/null || { echo "Failed to set debconf selections for chef-solr."; exit 1; }
	echo "chef    chef/chef_server_url    string  http://localhost:4000" | debconf-set-selections &> /dev/null || { echo "Failed to set debconf selections for chef."; exit 1; }
	apt-get install -y ucf &> /dev/null || { echo "Failed to install ucf pkg"; exit 1; }
	DEBIAN_FRONTEND=noninteractive dpkg -i -R chef* &> /dev/null || { echo "Failed to install the Chef Server via apt-get on $HOSTNAME."; exit 1; }

	cd /tmp
	rm -Rf $CHEF_PACKAGES_DIR

	/etc/init.d/chef-client stop &> /dev/null
	sleep 2
	kill -9 $(pgrep chef-client) &> /dev/null || true
	rm /var/log/chef/client.log

fi

}
