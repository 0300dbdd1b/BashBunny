#!/bin/bash
# serial.sh

# Load the libcomposite module
modprobe libcomposite

if [ "$1" = "enable" ]; then
	if [ ! -d /sys/kernel/config/usb_gadget/g1/functions/acm.usb0 ]; then
    	# Create the serial function
    	mkdir -p /sys/kernel/config/usb_gadget/g1/functions/acm.usb0

    	# Add the serial function to the configuration
    	ln -s /sys/kernel/config/usb_gadget/g1/functions/acm.usb0 /sys/kernel/config/usb_gadget/g1/configs/c.1/

    	# Enable the gadget
    	echo "20980000.usb" > /sys/kernel/config/usb_gadget/g1/UDC
	else
		echo "serial module is already enabled"
	fi 
elif [ "$1" = "disable" ]; then
    # Disable the gadget
    echo "" > /sys/kernel/config/usb_gadget/g1/UDC

    # Remove the serial function from the configuration
    rm /sys/kernel/config/usb_gadget/g1/configs/c.1/acm.usb0

    # Delete the serial function
    rmdir /sys/kernel/config/usb_gadget/g1/functions/acm.usb0
else
    echo "Usage: $0 {enable|disable}"
    exit 1
fi
