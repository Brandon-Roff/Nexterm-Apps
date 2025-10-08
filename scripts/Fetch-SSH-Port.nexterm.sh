#!/bin/bash
# @name:  Fetch SSH Port
# @description: Fetches the SSH port from sshd_config, defaults to 22 if not set
# @author: Brandon Roff 

#!/bin/sh
port=$(grep -oP '^Port\s+\K\d+' /etc/ssh/sshd_config)
if [ -z "$port" ]; then
    default_port=22  # Default SSH port
    echo " The SSH port is set to the default: $default_port"
else
    echo " The SSH port is set to: $port"
fi