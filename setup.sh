#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo 'This script must be run as PWD' ; exit 1 ; fi

PWD=$(dirname "$(readlink -f "$0")")

WORKDIR="/usr/src/lempstack"

# Set default resolver
#-----------------------------------------------------------------------------------------
rm -f /etc/resolv.conf
touch /etc/resolv.conf
{
    echo 'nameserver 1.1.1.1'
    echo 'nameserver 209.244.0.3'
} > /etc/resolv.conf

# Change mirror repository
#-----------------------------------------------------------------------------------------
COUNTRY=`wget -qO- ipapi.co/json | grep '"country":' | sed -E 's/.*"([^"]+)".*/\1/'`

echo -e "\nPreparing for installation, installing dependencies..."
if [ $COUNTRY == "ID" ] ; then
    cat $PWD/repository/sources-id.list > /etc/apt/sources.list
else if [ $COUNTRY == "SG" ] ; then
    cat $PWD/repository/sources-sg.list > /etc/apt/sources.list
else
    cat $PWD/repository/sources.list > /etc/apt/sources.list
fi
sed -i "s/CODENAME/$(lsb_release -cs)/" /etc/apt/sources.list

apt update -qq ; apt -yqq full-upgrade
apt -yqq install git curl crudini openssl

# Clone setup file and begin instalation process
#-----------------------------------------------------------------------------------------
if [[ -d $WORKDIR ]]; then rm -fr $WORKDIR ; fi

git clone https://github.com/riipandi/lempstack $WORKDIR ; cd $_

crudini --set config.ini 'system' 'country' $COUNTRY
find $PWD/snippets/ -type f -exec chmod +x {} \;
find . -type f -name '*.sh' -exec chmod +x {} \;
find . -type f -name '.git*' -exec rm -fr {} \;
rm -fr /etc/apt/sources.list.d/*

echo -e "\nStarting the installer..."

bash $PWD/install.sh
