#!/bin/bash

# Get data on the fernet tokens
TOKEN_CHECK=$(/usr/bin/fetch_fernet_tokens.py -t 86400 -n 4)

# Ensure the primary token exists and is not stale
if $(echo "$TOKEN_CHECK" | grep -q '"update_required":"false"'); then
    exit 0;
fi

# For each host node sync tokens
/usr/bin/rsync -azu --delete -e 'ssh -i /var/lib/keystone/.ssh/id_rsa -p 8023 -F /var/lib/keystone/.ssh/config' keystone@172.16.1.32:/etc/keystone/fernet-keys/ /etc/keystone/fernet-keys
/usr/bin/rsync -azu --delete -e 'ssh -i /var/lib/keystone/.ssh/id_rsa -p 8023 -F /var/lib/keystone/.ssh/config' keystone@172.16.1.33:/etc/keystone/fernet-keys/ /etc/keystone/fernet-keys
