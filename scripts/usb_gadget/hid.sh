#!/bin/bash
# hid.sh

GADGET_NAME="hid"
GADGET_PATH="/sys/kernel/config/usb_gadget/$GADGET_NAME"


# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
	error_exit "This script must be run with sudo. Try: sudo ./hid.sh"
fi

log()
{
    echo "$1"
}

error_exit()
{
    log "Error: $1"
    exit 1
}


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
    echo "Generic USB" > strings/0x409/product || error_exit "Failed to set product name"
    
    mkdir -p configs/c.1/strings/0x409 || error_exit "Failed to create configuration strings directory"
    echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration || error_exit "Failed to set configuration description"
    echo 250 > configs/c.1/MaxPower || error_exit "Failed to set MaxPower"

    setup_hid_function "keyboard" "\\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0"
    setup_hid_function "mouse" "\\x05\\x01\\x09\\x02\\xA1\\x01\\x09\\x01\\xA1\\x00\\x05\\x09\\x19\\x01\\x29\\x03\\x15\\x00\\x25\\x01\\x95\\x03\\x75\\x01\\x81\\x02\\x95\\x01\\x75\\x05\\x81\\x03\\x05\\x01\\x09\\x30\\x09\\x31\\x15\\x81\\x25\\x7F\\x75\\x08\\x95\\x02\\x81\\x06\\xC0\\xC0"

    ls /sys/class/udc > UDC || error_exit "Failed to enable the USB gadget"
    log "HID mode enabled"
}

setup_hid_function() {
    FUNCTION_NAME=$1
    REPORT_DESC=$2

    mkdir -p functions/hid.$FUNCTION_NAME || error_exit "Failed to create $FUNCTION_NAME function directory"
    echo 1 > functions/hid.$FUNCTION_NAME/protocol || error_exit "Failed to set $FUNCTION_NAME protocol"
    echo 1 > functions/hid.$FUNCTION_NAME/subclass || error_exit "Failed to set $FUNCTION_NAME subclass"
    echo 8 > functions/hid.$FUNCTION_NAME/report_length || error_exit "Failed to set $FUNCTION_NAME report length"
    echo -ne $REPORT_DESC > functions/hid.$FUNCTION_NAME/report_desc || error_exit "Failed to set $FUNCTION_NAME report descriptor"
    ln -s functions/hid.$FUNCTION_NAME configs/c.1/ || error_exit "Failed to link $FUNCTION_NAME function"
}

remove_gadget() {
    cd $GADGET_PATH || error_exit "Failed to change directory to gadget path"
    echo "" > UDC || error_exit "Failed to disable the USB gadget"
    rm configs/c.1/hid.keyboard || error_exit "Failed to remove keyboard function link"
    rm configs/c.1/hid.mouse || error_exit "Failed to remove mouse function link"
    rmdir functions/hid.keyboard || error_exit "Failed to remove keyboard function directory"
    rmdir functions/hid.mouse || error_exit "Failed to remove mouse function directory"
    log "HID mode disabled"
}



# Load the libcomposite module
modprobe libcomposite || error_exit "Failed to load libcomposite module"

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

