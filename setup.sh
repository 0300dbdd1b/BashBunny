#!/bin/bash

apt install -y python3-pip

grep -q -F 'dwc2' /etc/modules || echo 'dwc2' >> /etc/modules
grep -q -F 'libcomposite' /etc/modules || echo 'libcomposite' >> /etc/modules
grep -q -F 'dtoverlay=dwc2' /boot/config.txt || echo 'dtoverlay=dwc2' >> /boot/config.txt

# Create startup script for the gadget
if [ ! -f /root/usb.sh ]; then
    cat <<EOF | sudo tee /root/usb.sh
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p g1
cd g1
echo 0x1d6b > idVendor 
echo 0x0104 > idProduct 
echo 0x0100 > bcdDevice 
echo 0x0200 > bcdUSB 

# English (U.S.) strings
mkdir -p strings/0x409

echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Turing Industries" > strings/0x409/manufacturer
echo "PiZero Gadget" > strings/0x409/product

# Function instance
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 8 > functions/hid.usb0/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x26\\xff\\x00\\x05\\x07\\x19\\x00\\x2a\\xff\\x00\\x81\\x00\\xc0 > functions/hid.usb0/report_desc

mkdir -p functions/mass_storage.0
dd if=/dev/zero of=/piusb_fat32.img bs=1M count=512
mkdosfs /piusb_fat32.img -n PIUSB
echo "/piusb_fat32.img" > functions/mass_storage.0/lun.0/file

# Link HID function to USB configuration
mkdir -p configs/c.1
ln -s functions/hid.usb0 configs/c.1/
ln -s functions/mass_storage.0 configs/c.1/

# Bind the gadget to the UDC
ls /sys/class/udc > UDC
EOF

    # Make the script executable
    sudo chmod +x /root/usb.sh
fi

# Check if script is already in /etc/rc.local
if ! grep -Fxq "/root/usb.sh" /etc/rc.local
then
    # Add the script to /etc/rc.local so it runs at startup
    sudo sed -i -e '$i \nohup /root/usb.sh &\n' /etc/rc.local
fi