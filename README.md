# DevOpsfetch Script Documentation

## Introduction
The devopsfetch script is a comprehensive tool designed to gather and display various system information, including active ports, Docker containers, Nginx configurations, user logins, and system activities within a specified time range. The script offers a user-friendly interface and outputs data in a readable format.

## Installation

Run the installation script:

bash
sudo bash install_devopsfetch.sh

USAGE

bash
devopsfetch.sh [OPTIONS]

Options
-p <port_number>: Display active ports or detailed info about a specific port
-d <container_name>: List Docker images/containers or detailed info about a specific container
-n <domain>: Display Nginx domains/ports or detailed config for a specific domain
-u <username>: List users and their last login times or detailed info about a specific user
-t <start_time> <end_time>: Display activities within a specified time range
-h, --help: Show help message

Logging
Logs are saved in /var/log/devopsfetch.log and rotated daily. For more details, see the logrotate configuration.

Service
The devopsfetch service runs continuously and logs activities. It is managed via systemd.

### Final Notes

- Ensure all paths and permissions are correct.
- Test each function individually before integrating into the complete script.
- Adjust configurations according to your environment needs.

This setup should give you a solid starting point for building and deploying `devopsfetch` for server monitoring and retrieval.
