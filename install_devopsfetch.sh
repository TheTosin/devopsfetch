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
sudo apt-get install -y docker.io nginx jq

print_header "Copying devopsfetch Script"
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch
print_header "Creating Systemd Service"
bash -c 'cat > /etc/systemd/system/devopsfetch.service <<EOF
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target
[Service]
ExecStart=/usr/local/bin/devopsfetch -t "1 hour ago" "now"
Restart=always
RestartSec=60
[Install]
WantedBy=multi-user.target
EOF'

print_header "Starting and Enabling devopsfetch Service"
systemctl daemon-reload
systemctl enable devopsfetch
systemctl start devopsfetch
cat <<EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
    postrotate
        systemctl reload devopsfetch.service > /dev/null 2>/dev/null || true
    endscript
}
EOF

print_header "Installation Completed"
