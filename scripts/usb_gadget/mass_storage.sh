#!/bin/bash
# mass_storage.sh

GADGET_NAME="mass_storage"
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
    error_exit "This script must be run with sudo. Try: sudo ./mass_storage.sh"
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
    echo "Generic Mass Storage" > strings/0x409/product || error_exit "Failed to set product name"
    
    mkdir -p configs/c.1/strings/0x409 || error_exit "Failed to create configuration strings directory"
    echo "Config 1: Mass Storage" > configs/c.1/strings/0x409/configuration || error_exit "Failed to set configuration description"
    echo 250 > configs/c.1/MaxPower || error_exit "Failed to set MaxPower"

    mkdir -p functions/mass_storage.0 || error_exit "Failed to create mass storage function directory"
    echo 1 > functions/mass_storage.0/stall || error_exit "Failed to set stall"
    echo 0 > functions/mass_storage.0/lun.0/cdrom || error_exit "Failed to set cdrom"
    echo 0 > functions/mass_storage.0/lun.0/ro || error_exit "Failed to set read-only"
    echo 0 > functions/mass_storage.0/lun.0/removable || error_exit "Failed to set removable"
    echo /path/to/image/file > functions/mass_storage.0/lun.0/file || error_exit "Failed to set backing file"
    ln -s functions/mass_storage.0 configs/c.1/ || error_exit "Failed to link mass storage function"

    ls /sys/class/udc > UDC || error_exit "Failed to enable the USB gadget"
    log "Mass Storage mode enabled"
}

remove_gadget() {
    cd $GADGET_PATH || error_exit "Failed to change directory to gadget path"
    echo "" > UDC || error_exit "Failed to disable the USB gadget"
    rm configs/c.1/mass_storage.0 || error_exit "Failed to remove mass storage function link"
    rmdir functions/mass_storage.0 || error_exit "Failed to remove mass storage function directory"
    log "Mass Storage mode disabled"
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

