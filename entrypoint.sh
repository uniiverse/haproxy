#!/bin/bash

if [ -z "$ETCD_NODE" ]
then
  echo "Missing ETCD_NODE env var"
  exit -1
fi

if [ -z "$ETCD_KEY_PREFIX" ]
then
  echo "Missing ETCD_KEY_PREFIX env var"
  exit -1
fi

set -eo pipefail

#confd will start haproxy, since conf will be different than existing (which is null)

echo "[haproxy-confd] booting container. ETCD: $ETCD_NODE"

function config_fail()
{
	echo "Failed to start due to config error"
	exit -1
}

# Dynamically set the $ETCD_KEY_PREFIX in a TOML file, which doesn't support environment variables
sed -i -e "s/\$ETCD_KEY_PREFIX/$ETCD_KEY_PREFIX/" /etc/confd/conf.d/haproxy.toml
sed -i -e "s/\$ETCD_KEY_PREFIX/$ETCD_KEY_PREFIX/" /etc/confd/templates/haproxy.tmpl

# Write the certificate out
ETCD_CACERT_PATH=/etc/confd/cacert.pem
echo -----BEGIN CERTIFICATE----- > $ETCD_CACERT_PATH
echo $ETCD_CACERT >> $ETCD_CACERT_PATH
echo -----END CERTIFICATE----- >> $ETCD_CACERT_PATH

# Loop until confd has updated the haproxy config
n=0
until confd -onetime -log-level debug -client-ca-keys $ETCD_CACERT_PATH -username $ETCD_USER -password $ETCD_PASS -basic-auth -node "$ETCD_NODE"; do
  if [ "$n" -eq "4" ];  then config_fail; fi
  echo "[haproxy-confd] waiting for confd to refresh haproxy.cfg"
  n=$((n+1))
  sleep $n
done

echo "[haproxy-confd] Initial HAProxy config created. Starting confd"

confd -log-level debug -client-ca-keys $ETCD_CACERT_PATH -username $ETCD_USER -password $ETCD_PASS -basic-auth -node "$ETCD_NODE"

