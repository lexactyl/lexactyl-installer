#!/bin/bash

# Get OS information
os_name=$(lsb_release -is)
os_version=$(lsb_release -rs)

# Check for Ubuntu 20.04+ or Debian 11+
if [[ ("$os_name" == "Ubuntu" && "$os_version" > "20.04") || ("$os_name" == "Debian" && "$os_version" > "11") ]]; then
    # Clone the Lexactyl panel repository
    git clone https://github.com/Lexactyl/panel

    # Display post-installation message
    echo "Lexactyl successfully installed. Now configure config.toml and then run this command to configure webserver:"
    echo "bash <(curl -s https://raw.githubusercontent.com/Lexactyl/lexactyl-installer/master/web.sh)"
else
    echo "This command is only supported on Ubuntu 20.04+ or Debian 11+."
    exit 1
fi
