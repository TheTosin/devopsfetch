#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y docker.io nginx

# Copy the devopsfetch script
echo "Copying devopsfetch script..."
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch

# Create a systemd service file
echo "Creating systemd service..."
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

# Reload systemd, enable and start the service
echo "Starting and enabling devopsfetch service..."
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch
sudo systemctl start devopsfetch

echo "Installation completed."
