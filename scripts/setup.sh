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

# Kernel Stuff
if ! grep -q "dtoverlay=dwc2" /boot/config.txt; then
    echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
else
    echo "dtoverlay=dwc2 already in /boot/config.txt"
fi

if ! grep -q "dwc2" /etc/modules; then
    echo "dwc2" | sudo tee -a /etc/modules
else
    echo "dwc2 already in /etc/modules"
fi

if ! grep -q "libcomposite" /etc/modules; then
    echo "libcomposite" | sudo tee -a /etc/modules
else
    echo "libcomposite already in /etc/modules"
fi

if ! grep -q "modules-load=dwc2" /boot/cmdline.txt; then
    sudo sed -i 's/rootwait/rootwait modules-load=dwc2/' /boot/cmdline.txt
else
    echo "modules-load=dwc2 already in /boot/cmdline.txt"
fi

# Ensure scripts are executable
sudo chmod +x /home/BashBunny/scripts/usb_gadget/hid.sh
sudo chmod +x /home/BashBunny/scripts/usb_gadget/mass_storage.sh
sudo chmod +x /home/BashBunny/scripts/usb_gadget/usb_ethernet.sh

# Check if /bin folder exists, if not, create it
if [ ! -d "/home/BashBunny/bin" ]; then
    sudo mkdir /home/BashBunny/bin
fi

### DUCKY
# Check if the symlink /bin/DUCKY exists, if not, create it. 
if [ ! -L "/home/BashBunny/bin/DUCKY" ]; then
    sudo chmod +x "/home/BashBunny/srcs/DuckyScript/DuckyInterpreter.py"
    sudo ln -s "/home/BashBunny/srcs/DuckyScript/DuckyInterpreter.py" "/home/BashBunny/bin/DUCKY"
    sudo chmod +x "/home/BashBunny/bin/DUCKY"
fi

# Check if the alias DUCKY exists, if not, create it. 
if ! grep -q "alias DUCKY" /home/$SUDO_USER/.bashrc ; then
    echo "alias DUCKY='/home/BashBunny/srcs/DuckyScript/DuckyInterpreter.py' " >> /home/$SUDO_USER/.bashrc
    source /home/$SUDO_USER/.bashrc
fi

# Function to enable gadgets
enable_gadgets() {
    /home/BashBunny/scripts/usb_gadget/hid.sh enable
    /home/BashBunny/scripts/usb_gadget/mass_storage.sh enable
    /home/BashBunny/scripts/usb_gadget/usb_ethernet.sh enable
    echo "All gadgets enabled"
}

# Function to disable gadgets
disable_gadgets() {
    /home/BashBunny/scripts/usb_gadget/hid.sh disable
    /home/BashBunny/scripts/usb_gadget/mass_storage.sh disable
    /home/BashBunny/scripts/usb_gadget/usb_ethernet.sh disable
    echo "All gadgets disabled"
}

# Main
case "$1" in
    enable)
        enable_gadgets
        ;;
    disable)
        disable_gadgets
        ;;
    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac

