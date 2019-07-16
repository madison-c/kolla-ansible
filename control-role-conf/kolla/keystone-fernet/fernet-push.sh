#!/bin/bash

/usr/bin/rsync -az -e 'ssh -i /var/lib/keystone/.ssh/id_rsa -p 8023 -F /var/lib/keystone/.ssh/config' --delete /etc/keystone/fernet-keys/ keystone@172.16.1.32:/etc/keystone/fernet-keys
/usr/bin/rsync -az -e 'ssh -i /var/lib/keystone/.ssh/id_rsa -p 8023 -F /var/lib/keystone/.ssh/config' --delete /etc/keystone/fernet-keys/ keystone@172.16.1.33:/etc/keystone/fernet-keys
