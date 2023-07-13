#!/bin/bash
# rndis_ethernet.sh

# Load the libcomposite module
modprobe libcomposite

if [ "$1" = "enable" ]; then
	if [! -d /sys/kernel/config/usb_gadget/g1/functions/rndis.usb0]; then
    	# Create the RNDIS Ethernet function
    	mkdir -p /sys/kernel/config/usb_gadget/g1/functions/rndis.usb0

    	# Add the RNDIS Ethernet function to the configuration
    	ln -s /sys/kernel/config/usb_gadget/g1/functions/rndis.usb0 /sys/kernel/config/usb_gadget/g1/configs/c.1/

    	# Enable the gadget
    	echo "20980000.usb" > /sys/kernel/config/usb_gadget/g1/UDC
	else
		echo "rndis_ethernet module is already enabled"
	fi
elif [ "$1" = "disable" ]; then
    # Disable the gadget
    echo "" > /sys/kernel/config/usb_gadget/g1/UDC

    # Remove the RNDIS Ethernet function from the configuration
    rm /sys/kernel/config/usb_gadget/g1/configs/c.1/rndis.usb0

    # Delete the RNDIS Ethernet function
    rmdir /sys/kernel/config/usb_gadget/g1/functions/rndis.usb0

    # Re-enable the gadget
    echo "20980000.usb" > /sys/kernel/config/usb_gadget/g1/UDC
else
    echo "Usage: $0 {enable|disable}"
    exit 1
fi
