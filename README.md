
# PiZero BashBunny

A PiZero BashBunny (Work In Progress)
## Installation

Install the prerequisites with curl (note: Installing with cu

```bash
cd /home &&
sudo apt-get install -y git &&
sudo git clone https://github.com/Marcaday/BashBunny &&
cd BashBunny &&
sudo chmod +x ./scripts/setup.sh &&
sudo ./scripts/setup.sh 
```
Once the usb gadget set you can now  use the python script to inject keystrokes
```bash
    python3 srcs/DuckyScript/DuckyInterpreter.py ./payloads/hello_world.ds
```
