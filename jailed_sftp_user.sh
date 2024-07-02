#!/bin/bash

# Function to check if a user exists
user_exists() {
    if getent passwd "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Prompt the user for user name, check if the user exists, and configure password
while true; do
    read -p "Input desired SFTP user name: " user_name

    if user_exists "$user_name"; then
        echo "User '$user_name' already exists."
        read -p "Do you want to proceed with this user? (y/n): " proceed_choice
        if [[ "$proceed_choice" == "y" || "$proceed_choice" == "Y" ]]; then
            break
        else
            echo "Please input a different user name."
        fi
    else
        useradd -m -s /sbin/nologin "$user_name"
        passwd "$user_name"
        break
    fi
done

# create directory for sftp files with appropriate ownership and permissions
mkdir -p /home/$user_name/uploads
echo "uploads dir created"
chown root:root /home/$user_name
echo "ownership set for $user_name home directory"
chmod 755 /home/$user_name
echo "permission set for $user_name home directory"
chown $user_name:$user_name /home/$user_name/uploads
echo "ownership set for uploads directory under $user_name home directory"
chmod 700 /home/$user_name/uploads
echo "permission set for uploads directory under $user_name home directory"

# Edit ssh config file to restrict the user from accessing other system files
bash -c "cat >> /etc/ssh/sshd_config <<EOF
Match User $user_name
    ChrootDirectory /home/$user_name
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
EOF"
echo "SSH configuration file updated"

# restart the ssh service
if systemctl restart ssh; then
    echo "SSH service restarted successfully."
else
    systemctl restart sshd
    echo "SSHD service restarted successfully"
