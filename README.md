
# PiZero BashBunny

A PiZero BashBunny (Work In Progress)
## Installation

Install the prerequisites

```bash
sudo curl -LOk https://github.com/Marcaday/BashBunny/archive/master.zip && 
sudo unzip master.zip -d BashBunnyFolder && 
sudo rm -rf master.zip && 
sudo mv BashBunnyFolder/BashBunny-main ./BashBunny &&
sudo rm -rf BashBunnyFolder &&
cd ./BashBunny &&
sudo chmod +x ./setup.sh &&
sudo ./setup.sh
```
Once the usb gadget set you can now  use the python script to inject keystrokes
```bash
    python3 srcs/DuckyScript/DuckyInterpreter.py ./payloads/hello_world.ds
```
