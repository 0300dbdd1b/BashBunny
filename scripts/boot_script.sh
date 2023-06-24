#!/bin/bash

# Read config file
source /home/BashBunny/bunny.conf

# If startupscript is None, then no script is run
if [ "$startupscript" != "None" ]; then

    # Make sure the startup script is executable
    chmod +x /home/BashBunny/srcs/DuckyScript/DuckyInterpreter.py

    # Execute the startup script with DuckyInterpreter.py
    /home//BashBunny/srcs/DuckyScript/DuckyInterpreter.py $startupscript
fi

