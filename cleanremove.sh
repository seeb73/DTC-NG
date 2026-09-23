#!/bin/bash
set -e

apt purge -y dtc-common dtc-core dtc-dos-firewall dtc-postfix-dovecot
mysql -u root -e "DROP USER IF EXISTS 'dtc'@'localhost'; DROP DATABASE IF EXISTS dtc; FLUSH PRIVILEGES;"
rm -rf /var/lib/dtc
