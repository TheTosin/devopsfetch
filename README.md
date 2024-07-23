# DevOpsfetch Script Documentation

## Introduction
DevOpsFetch is a Bash script that provides various system and service information for DevOps professionals. It offers a simple command-line interface to retrieve details about ports, Docker containers, Nginx configurations, user logins, and system activities within a specified time range. The script offers a user-friendly interface and outputs data in a readable format.

## Installation and configuration steps

### Prerequisites

Ensure you have bash, ss, docker, jq, and journalctl installed on your system.
You need root or sudo privileges to run some commands in this script.

1. Clone this repository or download the `devopsfetch.sh` script.
```bash
curl -o devopsfetch.sh https://path/to/your/script/devopsfetch.sh
```

```bash
curl -o /usr/local/bin/devopsfetch.sh https://path/to/your/script/devopsfetch.sh
```

3. Make the script executable:
   
```bash
   chmod +x devopsfetch.sh
```
3. Optionally, move the script to a directory in your PATH for easy access:
 ```bash
sudo mv devopsfetch.sh /usr/local/bin/devopsfetch
```
4. Verify installation :
```bash   
/usr/local/bin/devopsfetch.sh -h
```

```bash
devopsfetch.sh -h
```

Run the installation script:

```bash
sudo bash install_devopsfetch.sh
```
## Configuration

No additional configuration is required. However, ensure that you have the necessary permissions to access system information and run commands like `docker`, `ss`, and `journalctl`.

## Usage

The general syntax for using DevOpsFetch is:
```bash
devopsfetch.sh [OPTION] [ARGUMENT]
```
### Command-line Flags

- `-p [port_number]`: Display active ports. If a port number is provided, show details for that specific port.
- `-d [container_name]`: List Docker images and containers. If a container name is provided, show details for that specific container.
- `-n [domain]`: Display Nginx domains/ports. If a domain is provided, show the configuration for that specific domain.
- `-u [username]`: List users and last login times. If a username is provided, show details for that specific user.
- `-t [start] [end]`: Display activities within the specified time range.
- `-h, --help`: Show the help message with usage information.

### Usage Examples

1. Display all active ports:




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
