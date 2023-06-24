#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run with sudo. Try: sudo ./setup.sh"
   exit 1
fi

# Check if python3-pip is installed, if not, install it
if ! command -v pip3 &> /dev/null; then
    echo "python3-pip is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
else
    echo "python3-pip is already installed."
fi

# Check if git is installed, if not, install it
if ! command -v git &> /dev/null; then
    echo "git is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y git
else
    echo "git is already installed."
fi

# Check if USB gadget is set, if not, launch the installer
if [ ! -f "/usr/bin/init_usb_gadget.sh" ]; then
    echo "USB gadget is not set. Launching the installer..."
    sudo chmod +x ./usb_gadget_installer.sh
    sudo ./usb_gadget_installer.sh
else
    echo "USB gadget is already set."
fi
