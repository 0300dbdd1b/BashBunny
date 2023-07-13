#!/bin/bash
# hid.sh

# Load the libcomposite module
modprobe libcomposite

if [ "$1" = "enable" ]; then
	if [ ! -d /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard ]; then
   		# Create the HID function for the keyboard
    	mkdir -p /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard
    	echo 1 > /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard/protocol
    	echo 1 > /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard/subclass
    	echo 8 > /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard/report_length

    	# Write the report descriptor for the keyboard
    	{
        	echo -ne \\x05\\x01  # Usage Page (Generic Desktop)
        	echo -ne \\x09\\x06  # Usage (Keyboard)
        	echo -ne \\xA1\\x01  # Collection (Application)
        	echo -ne \\x05\\x07  # Usage Page (Key Codes)
        	echo -ne \\x19\\xE0  # Usage Minimum (224)
        	echo -ne \\x29\\xE7  # Usage Maximum (231)
        	echo -ne \\x15\\x00  # Logical Minimum (0)
        	echo -ne \\x25\\x01  # Logical Maximum (1)
        	echo -ne \\x75\\x01  # Report Size (1)
        	echo -ne \\x95\\x08  # Report Count (8)
        	echo -ne \\x81\\x02  # Input (Data, Variable, Absolute)
        	echo -ne \\x95\\x01  # Report Count (1)
        	echo -ne \\x75\\x08  # Report Size (8)
        	echo -ne \\x81\\x03  # Input (Constant) ;5 bit padding
        	echo -ne \\x95\\x05  # Report Count (5)
        	echo -ne \\x75\\x01  # Report Size (1)
        	echo -ne \\x05\\x08  # Usage Page (LEDs)
        	echo -ne \\x19\\x01  # Usage Minimum (1)
        	echo -ne \\x29\\x05  # Usage Maximum (5)
        	echo -ne \\x91\\x02  # Output (Data, Variable, Absolute)
        	echo -ne \\x95\\x01  # Report Count (1)
        	echo -ne \\x75\\x03  # Report Size (3)
        	echo -ne \\x91\\x03  # Output (Constant) ;3 bit padding
        	echo -ne \\x95\\x06  # Report Count (6)
        	echo -ne \\x75\\x08  # Report Size (8)
        	echo -ne \\x15\\x00  # Logical Minimum (0)
        	echo -ne \\x25\\x65  # Logical Maximum (101)
        	echo -ne \\x05\\x07  # Usage Page (Key Codes)
        	echo -ne \\x19\\x00  # Usage Minimum (0)
        	echo -ne \\x29\\x65  # Usage Maximum (101)
        	echo -ne \\x81\\x00  # Input (Data, Array)
        	echo -ne \\xC0       # End Collection
    	} > /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard/report_desc
    	# Create the HID function for the mouse
    	mkdir -p /sys/kernel/config/usb_gadget/g1/functions/hid.mouse
    	echo 1 > /sys/kernel/config/usb_gadget/g1/functions/hid.mouse/protocol
    	echo 1 > /sys/kernel/config/usb_gadget/g1/functions/hid.mouse/subclass
    	echo 8 > /sys/kernel/config/usb_gadget/g1/functions/hid.mouse/report_length

    	# Write the report descriptor for the mouse
    	{
        	echo -ne \\x05\\x01  # Usage Page (Generic Desktop)
        	echo -ne \\x09\\x02  # Usage (Mouse)
        	echo -ne \\xA1\\x01  # Collection (Application)
        	echo -ne \\x09\\x01  # Usage (Pointer)
        	echo -ne \\xA1\\x00  # Collection (Physical)
        	echo -ne \\x05\\x09  # Usage Page (Button)
        	echo -ne \\x19\\x01  # Usage Minimum (1)
        	echo -ne \\x29\\x03  # Usage Maximum (3)
        	echo -ne \\x15\\x00  # Logical Minimum (0)
        	echo -ne \\x25\\x01  # Logical Maximum (1)
        	echo -ne \\x95\\x03  # Report Count (3)
        	echo -ne \\x75\\x01  # Report Size (1)
        	echo -ne \\x81\\x02  # Input (Data, Variable, Absolute)
        	echo -ne \\x95\\x01  # Report Count (1)
        	echo -ne \\x75\\x05  # Report Size (5)
        	echo -ne \\x81\\x01  # Input (Constant) ;5 bit padding
        	echo -ne \\x05\\x01  # Usage Page (Generic Desktop)
        	echo -ne \\x09\\x30  # Usage (X)
        	echo -ne \\x09\\x31  # Usage (Y)
        	echo -ne \\x15\\x81  # Logical Minimum (-127)
        	echo -ne \\x25\\x7F  # Logical Maximum (127)
        	echo -ne \\x75\\x08  # Report Size (8)
        	echo -ne \\x95\\x02  # Report Count (2)
        	echo -ne \\x81\\x06  # Input (Data, Variable, Relative)
        	echo -ne \\xC0       # End Collection
        	echo -ne \\xC0       # End Collection
    	} > /sys/kernel/config/usb_gadget/g1/functions/hid.mouse/report_desc

   		# Add the HID functions to the configuration
    	ln -s /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard /sys/kernel/config/usb_gadget/g1/configs/c.1/
    	ln -s /sys/kernel/config/usb_gadget/g1/functions/hid.mouse /sys/kernel/config/usb_gadget/g1/configs/c.1/

    	# Enable the gadget
    	echo "20980000.usb" > /sys/kernel/config/usb_gadget/g1/UDC
	else
		echo "hid module is already enabled"
	fi

elif [ "$1" = "disable" ]; then
    # Disable the gadget
    echo "" > /sys/kernel/config/usb_gadget/g1/UDC

    # Remove the HID functions from the configuration
    rm /sys/kernel/config/usb_gadget/g1/configs/c.1/hid.keyboard
    rm /sys/kernel/config/usb_gadget/g1/configs/c.1/hid.mouse

    # Delete the HID functions
    rmdir /sys/kernel/config/usb_gadget/g1/functions/hid.keyboard
    rmdir /sys/kernel/config/usb_gadget/g1/functions/hid.mouse
else
    echo "Usage: $0 {enable|disable}"
    exit 1
fi
