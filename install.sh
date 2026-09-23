#!/bin/bash
set -e

# DTC-NG installer for Debian 12/13. Mail backend: Postfix + Dovecot.
# Installs: dtc-common, dtc-core, dtc-dos-firewall, dtc-postfix-dovecot
#
# Version-agnostic on purpose (2026-09-23) -- an earlier copy hardcoded
# "0.40.1-3" in the banner text AND in the .deb filenames it installed,
# so it kept silently reinstalling a stale version 5 releases behind
# while the printed "What's new" list never matched what actually
# shipped. Detects whatever dtc-common_*_all.deb is actually present
# next to this script instead.

cd "$(dirname "$0")"

DEB_VERSION=$(ls dtc-common_*_all.deb 2>/dev/null | sed -E 's/dtc-common_(.+)_all\.deb/\1/' | sort -V | tail -1)
if [ -z "$DEB_VERSION" ]; then
        echo "ERROR: no dtc-common_*_all.deb found in $(pwd)"
        exit 1
fi

echo "=== DTC-NG ${DEB_VERSION} Installation Starting ==="

echo "Updating package lists..."
apt update

echo "Installing php-twig (required for admin panel templates)..."
apt install -y php-twig

echo "Installing DTC packages..."
apt install -y \
  "./dtc-common_${DEB_VERSION}_all.deb" \
  "./dtc-core_${DEB_VERSION}_all.deb" \
  "./dtc-dos-firewall_${DEB_VERSION}_all.deb" \
  "./dtc-postfix-dovecot_${DEB_VERSION}_all.deb"

echo ""
echo "=== Installation Complete (dtc-common ${DEB_VERSION}) ==="

if [ -f /usr/share/dtc/shared/mysql_config.php ]; then
        echo "OK  Database configured (mysql_config.php exists)"
else
        echo "!!  Database NOT configured yet -- the panel is not usable until this runs"
        echo "    Run: /usr/share/dtc/admin/install/nginx_db_bootstrap.sh <dtc-mysql-password> <adm-login> <adm-pass> <main-domain>"
fi

echo ""
echo "Access panel at: https://localhost/dtcadmin/ (or your configured domain)"
echo "Documentation: /usr/share/doc/dtc-common/"
