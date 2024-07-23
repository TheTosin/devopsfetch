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
```bash
devopsfetch.sh [OPTIONS]
```

Options

- `-p [port_number]`: Display active ports or detailed info about a specific port
- `-d [container_name]`: List Docker images/containers or detailed info about a specific container
- `-n [domain]`:  Display Nginx domains/ports or detailed config for a specific domain
- `-u [username]`: List users and their last login times or detailed info about a specific user
- `-t [start] [end]`: Display activities within the specified time range.
- `-h, --help`: Show the help message 

### Usage Examples

1. Display all active ports:
```bash
./devopsfetch.sh -p
```
2. Show details for a specific port (e.g., port 80):
```bash
./devopsfetch.sh -p 80
```
3. List all Docker images and containers:
```bash
./devopsfetch.sh -d
```
4. Show details for a specific Docker container:
```bash
./devopsfetch.sh -d hello-world
```
5. Display all Nginx domains and ports:
```bash
./devopsfetch.sh -n
```

6. Show Nginx configuration for a specific domain:
```bash
./devopsfetch.sh -n example.com
```

7. List all users and their last login times:
```bash
./devopsfetch.sh -u 
```

8. Show details for a specific user:
```bash
./devopsfetch.sh -u Bayo
```

9. Display activities within a specific time range:
```bash
./devopsfetch.sh -t "2023-07-01 00:00:00" "2023-07-02 23:59:59"
```

## Logging Mechanism

DevOpsFetch does not implement its own logging mechanism. However, it utilizes system logs and command outputs to provide information. Here's how you can retrieve logs for different components:

1. For port information: The script uses the `ss` command, which provides real-time socket statistics.

2. For Docker information: The script uses `docker` commands to fetch container and image information.

3. For Nginx information: The script reads Nginx configuration files located in `/etc/nginx/nginx.conf` and `/etc/nginx/sites-enabled/*`.

4. For user login information: The script uses the `lastlog` command to retrieve user login details.

5. For time-based activities: The script utilizes `journalctl` to fetch system logs within the specified time range.

To retrieve more detailed logs or troubleshoot issues, you can use the following commands:

- System logs: `journalctl`
- Docker logs: `docker logs <container_name>`
- Nginx logs: Check `/var/log/nginx/access.log` and `/var/log/nginx/error.log`
For more details, see the logrotate configuration.

## Service
The devopsfetch service runs continuously and logs activities. It is managed via systemd.

## Notes

- Ensure that you have the necessary permissions to run the script and access system information.
- Some commands may require root or sudo privileges to execute successfully.
- Test each function individually before integrating into the complete script.
- Adjust configurations according to your environment needs.

This setup should give you a solid starting point for building and deploying `devopsfetch` for server monitoring and retrieval.
