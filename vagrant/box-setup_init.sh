#!/bin/bash
set -x
set -e

# update to buster (if not on buster already)
printf "\ndeb http://deb.debian.org/debian/ buster main\n" > /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get purge mysql-common
apt-get purge exim4

apt-get -o Dpkg::Options::='--force-confnew' --force-yes -fuy dist-upgrade
apt-get --purge autoremove
