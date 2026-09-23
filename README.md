# DTC-NG

A free/libre web hosting control panel — accounts, domains, DNS, mail
(Postfix/Dovecot/Cyrus), MySQL databases, FTP and VPS management from one
panel — targeting Debian 12 (bookworm) and 13 (trixie).

## What is DTC?

DTC ("Domain Technologie Control") is an open-source hosting control panel
originally written by Thomas Goirand, first released in 2006 and long
distributed as a Debian package (`gplhost.com`). It lets a hosting provider
or self-hoster manage multiple domains and their web, mail, DNS and database
services from a single admin panel, with a separate client panel for each
hosted account.

## What is DTC-NG?

DTC-NG is a from-the-ground-up modernization of DTC, rebuilt against a
current Debian baseline instead of the Apache/PHP5-era assumptions the
original codebase carried. The two are related by lineage and shared
domain model, not by being the same code running unchanged — most of the
serving stack has been redesigned:

- **nginx + PHP-FPM** instead of Apache + mod_php, with a per-account
  PHP-FPM pool (`open_basedir`-isolated) rather than one shared PHP process
  for every hosted site.
- **A privileged Python worker** (`worker/worker.py`) that performs every
  system-level operation (writing nginx/PHP-FPM/BIND/Postfix/Dovecot
  config, reloading services) via a job queue — PHP itself never runs as
  root or shells out to system commands.
- **Real classes replacing procedural globals**, migrated in incrementally
  wherever code is touched, rather than a big-bang rewrite.
- **Per-module self-contained configuration** (`DtcModuleConfig`) for new
  registrar/payment integrations, instead of every module permanently
  adding its own columns to one shared, single-row `config` table.
- **A single, idempotent database bootstrap**
  (`admin/install/nginx_db_bootstrap.sh`) instead of Apache-era,
  MySQL-4-style `mysql.user` manipulation.

Debian 12 and 13 are the only supported targets — both are verified to
install cleanly from the same source with no manual intervention. BSD and
RPM-based distributions (FreeBSD, SUSE, RHEL/CentOS) are explicitly out of
scope; older code paths for them may still exist in the tree as inherited
history, but nothing is tested or maintained against them.

## Status

Actively under development, including real production migrations. Expect
the install/bootstrap path, packaging, and parts of the admin UI to keep
changing as remaining legacy (Apache-era installer paths, procedural
code not yet ported to classes, the old skinning mechanism) gets replaced
piece by piece rather than all at once.

## Installing

```sh
apt install ./dtc-common_*.deb ./dtc-core_*.deb ./dtc-dos-firewall_*.deb ./dtc-postfix-dovecot_*.deb
/usr/share/dtc/admin/install/nginx_db_bootstrap.sh <mysql-password> <admin-login> <admin-password> <main-domain>
```

The first command installs the panel; debconf will ask a few setup
questions along the way. The second sets up the database and initial
admin account. On a Debian 12/13 host with a local MariaDB server and no
prior DTC installation, this is the whole install.

## License

LGPL (mostly LGPL-2), inherited from upstream DTC. A handful of vendored
files carry their own licenses (GPL-2, Apache-2.0, BSD) — see
`debian/copyright` for the exact breakdown per file.
