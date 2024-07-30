#!/bin/bash
# ethernet.sh

GADGET_NAME="ethernet"
GADGET_PATH="/sys/kernel/config/usb_gadget/$GADGET_NAME"

log() {
    echo "$1"
}

error_exit() {
    log "Error: $1"
    exit 1
}

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run with sudo. Try: sudo ./ethernet.sh"
fi

# Load the libcomposite module
modprobe libcomposite || error_exit "Failed to load libcomposite module"

create_gadget() {
    mkdir -p $GADGET_PATH || error_exit "Failed to create gadget path"
    cd $GADGET_PATH || error_exit "Failed to change directory to gadget path"

    echo 0x1d6b > idVendor || error_exit "Failed to set idVendor"
    echo 0x0104 > idProduct || error_exit "Failed to set idProduct"
    echo 0x0100 > bcdDevice || error_exit "Failed to set bcdDevice"
    echo 0x0200 > bcdUSB || error_exit "Failed to set bcdUSB"

    mkdir -p strings/0x409 || error_exit "Failed to create strings directory"
    echo "deadbeef01234567890" > strings/0x409/serialnumber || error_exit "Failed to set serial number"
    echo "BadPi" > strings/0x409/manufacturer || error_exit "Failed to set manufacturer"
    echo "Generic USB Ethernet" > strings/0x409/product || error_exit "Failed to set product name"
    
    mkdir -p configs/c.1/strings/0x409 || error_exit "Failed to create configuration strings directory"
    echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration || error_exit "Failed to set configuration description"
    echo 250 > configs/c.1/MaxPower || error_exit "Failed to set MaxPower"

    mkdir -p functions/ecm.usb0 || error_exit "Failed to create ECM function directory"
    echo "02:01:02:03:04:08" > functions/ecm.usb0/dev_addr || error_exit "Failed to set device address"
    echo "02:01:02:03:04:09" > functions/ecm.usb0/host_addr || error_exit "Failed to set host address"
    ln -s functions/ecm.usb0 configs/c.1/ || error_exit "Failed to link ECM function"

    ls /sys/class/udc > UDC || error_exit "Failed to enable the USB gadget"
    log "Ethernet mode enabled"
}

remove_gadget() {
    cd $GADGET_PATH || error_exit "Failed to change directory to gadget path"
    echo "" > UDC || error_exit "Failed to disable the USB gadget"
    rm configs/c.1/ecm.usb0 || error_exit "Failed to remove ECM function link"
    rmdir functions/ecm.usb0 || error_exit "Failed to remove ECM function directory"
    log "Ethernet mode disabled"
}

# Main
case "$1" in
    enable)
        create_gadget
        ;;
    disable)
        remove_gadget
        ;;
    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac

