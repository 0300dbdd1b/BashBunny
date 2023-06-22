#!/bin/bash

mkdir /bunny/mnt
mkdir /bunny/storage

apt install -y python3-pip

grep -q -F 'dwc2' /etc/modules || echo 'dwc2' >> /etc/modules
grep -q -F 'libcomposite' /etc/modules || echo 'libcomposite' >> /etc/modules
grep -q -F 'dtoverlay=dwc2' /boot/config.txt || echo 'dtoverlay=dwc2' >> /boot/config.txt

