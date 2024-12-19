#! /usr/bin/env bash

# Exit on any error
set -e

# Start timestamp
echo "Starting setup at $(date)"

# Backup .bashrc----------------------------------------------------
cp ~/.bashrc ~/.bashrc.backup || echo "Warning: .bashrc backup failed"

# Install package updates-------------------------------------------
sudo apt update && sudo apt upgrade -y

# Install essential tools & requirements for building R-------------
sudo apt install -y build-essential git curl wget xclip openssh-server \
   nmap libnss-mdns avahi-daemon arp-scan trash-cli \
   net-tools htop dnsutils ufw samba openvpn smartmontools gparted \
   gfortran libreadline-dev libx11-dev libxt-dev libpng-dev libjpeg-dev \
   libcairo2-dev xvfb libbz2-dev libzstd-dev liblzma-dev libcurl4-openssl-dev \
   libpcre2-dev openjdk-11-jdk cmake git libsodium-dev libxml2-dev libgmp3-dev \
   libpq-dev libgdal-dev libudunits2-dev libharfbuzz-dev libfribidi-dev \
   libnode-dev libmagick++-dev libmpfr-dev libssl-dev libmysqlclient-dev \
   libxslt1-dev gdal-bin libsqlite3-dev libtiff-dev libfreetype-dev

# Download the newest version of R----------------------------------
cd ~ || exit 1

# Check if R download exists
if [ -f R-4.4.2.tar.gz ]; then
   echo "R source already downloaded"
else
   wget https://cran.r-project.org/src/base/R-4/R-4.4.2.tar.gz
fi

# Clean previous build if exists
rm -rf R-4.4.2
tar -xf R-4.4.2.tar.gz
cd R-4.4.2 || exit 1

# Configure and build
./configure --with-x --enable-R-shlib || {
   echo "R configure failed"
   exit 1
}

make || {
   echo "R make failed"
   exit 1
}

sudo make install || {
   echo "R installation failed"
   exit 1
}

# Verify installation
R --version

cd ..

# Cleanup
rm -rf R-4.4.2.tar.gz R-4.4.2

echo "R installation completed successfully!"
echo "Setup completed at $(date)"
