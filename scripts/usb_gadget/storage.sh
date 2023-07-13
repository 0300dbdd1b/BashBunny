#!/bin/bash
# storage.sh

# Load the libcomposite module
modprobe libcomposite

if [ "$1" = "enable" ]; then
	if [ ! -d /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0 ]; then
    	# Create the mass storage function
    	mkdir -p /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0
    	echo 1 > /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0/stall
    	echo 0 > /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/cdrom
    	echo 0 > /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/ro
    	echo 0 > /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/nofua
    	echo "/dev/mmcblk0" > /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0/lun.0/file

    	# Add the mass storage function to the configuration
    	ln -s /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0 /sys/kernel/config/usb_gadget/g1/configs/c.1/

    	# Enable the gadget
    	echo "20980000.usb" > /sys/kernel/config/usb_gadget/g1/UDC
	else
		echo "storage module is already enabled"
	fi 
elif [ "$1" = "disable" ]; then
    # Disable the gadget
    echo "" > /sys/kernel/config/usb_gadget/g1/UDC

    # Remove the mass storage function from the configuration
    rm /sys/kernel/config/usb_gadget/g1/configs/c.1/mass_storage.usb0

    # Delete the mass storage function
    rmdir /sys/kernel/config/usb_gadget/g1/functions/mass_storage.usb0
else
    echo "Usage: $0 {enable|disable}"
    exit 1
fi
