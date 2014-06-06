#!/bin/bash -e
#
# Name:         provision.sh
#
# Purpose:      quick start the vagrant box with all the things
#
# Comments:
#
# Usage:        vagrant up (on the repo root)
#
# Author:       Ricardo Amaro (mail@ricardoamaro.com)
# Contributors: Jeremy Thorson jthorson
#
# Bugs/Issues:  Use the issue queue on drupal.org
#               IRC #drupal-infrastructure
#
# Docs:         README.md for complete information
#

export HOME="/home/vagrant"

# Database Selection
export database=mysql
while getopts ":d:" opt; do
  case $opt in
    d)
      echo "Provisioning with $OPTARG" >&2
      export database=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ -f /home/vagrant/modernizing_testbot__dockerfiles/PROVISIONED ];
then
	echo "You seem to have this box installed"
	echo "I'll just give you a shell..."
	swapon /var/swapfile
	cd /home/vagrant/modernizing_testbot__dockerfiles
	./build_all.sh update
else
	echo 'Defaults        env_keep +="HOME"' >> /etc/sudoers
	echo "Installing and building the all thing..."
	echo "on: $(hostname) with user: $(whoami) home: $HOME"
	swapoff -a
	dd if=/dev/zero of=/var/swapfile bs=1M count=2048
	chmod 600 /var/swapfile
	mkswap /var/swapfile
	swapon /var/swapfile
	/bin/echo "/var/swapfile swap swap defaults 0 0" >>/etc/fstab
	apt-get update
	apt-get install -y git mc ssh gawk grep sudo htop mysql-client php5-cli
	apt-get autoclean
	cd /home/vagrant/modernizing_testbot__dockerfiles
	./build_all.sh cleanup $database
	touch PROVISIONED
fi

chown -fR vagrant:vagrant /home/vagrant
echo "Box started, run vagrant halt to stop."
echo
echo "To access the box and run tests, do:"
echo "vagrant ssh"
echo "cd modernizing_testbot__dockerfiles"
#echo 'Example: sudo TESTGROUPS="Bootstrap" DRUPALBRANCH="8.x" PATCH="/path/inthebox/to/your.patch,." ./run.sh'
