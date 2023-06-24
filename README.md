
# PiZero BashBunny

A PiZero BashBunny (Work In Progress)
## Installation

Install the prerequisites with curl (note: Installing with cu

```bash
sudo apt-get install -y git &&
sudo git clone https://github.com/Marcaday/BashBunny &&
cd BashBunny &&
sudo chmod +x ./setup.sh &&
sudo ./setup.sh 
```
Once the usb gadget set you can now  use the python script to inject keystrokes
```bash
    python3 srcs/DuckyScript/DuckyInterpreter.py ./payloads/hello_world.ds
```
