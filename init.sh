#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

# Check if Git is installed
if ! is_package_installed git; then
  echo "Git is not installed. Installing Git..."
  sudo apt update
  sudo apt install -y git
else
  echo "Git is already installed."
fi

# Check if Python 3 pip is installed
if ! is_package_installed python3-pip; then
  echo "Python 3 pip is not installed. Installing Python 3 pip..."
  sudo apt update
  sudo apt install -y python3-pip
else
  echo "Python 3 pip is already installed."
fi

# Create symlinks
ln -sv "$(pwd)/srcs/DuckyScript/DuckyInterpreter.py" /bin/Ducky
ln -sv "$(pwd)/srcs/BunnyScript/QUACK/Quack.py" /bin/QUACK
ln -sv "$(pwd)/srcs/BunnyScript/ATTACKMODE/AttackMode.py" /bin/ATTACKMODE
