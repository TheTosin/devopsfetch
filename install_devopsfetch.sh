#!/bin/bash

function print_header() {
    local header="$1"
    echo
    echo "==============================="
    echo "$header"
    echo "==============================="
}

print_header "Installing Dependencies"
sudo apt-get update
sudo apt-get install -y docker.io nginx

print_header "Copying devopsfetch Script"
sudo cp /mnt/c/Users/HP/downloads/devopsfetch/devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch

print_header "Creating Systemd Service"
sudo bash -c 'cat > /etc/systemd/system/devopsfetch.service <<EOF
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -t "1 hour ago" "now"
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF'

print_header "Starting and Enabling devopsfetch Service"
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch
sudo systemctl start devopsfetch

print_header "Installation Completed"
