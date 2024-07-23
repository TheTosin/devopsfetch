#!/bin/bash
function show_help() {
    echo "Usage: devopsfetch.sh [OPTION] [ARGUMENT]"
    echo ""
    echo "Options:"
    echo "  -p [port_number]    Display active ports. If port number is provided, show details for that port"
    echo "  -d [container_name] List Docker images and containers. If container name is provided, show details for that container"
    echo "  -n [domain]         Display Nginx domains/ports. If domain is provided, show config for that domain"
    echo "  -u [username]       List users and last login times. If username is provided, show details for that user"
    echo "  -t [start] [end]    Display activities within the specified time range"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  devopsfetch.sh -d           # List all Docker images and containers"
    echo "  devopsfetch.sh -d hello-world     # Show details for the hello-world container"
    echo "  devopsfetch.sh -p           # Show all active ports"
    echo "  devopsfetch.sh -p 80        # Show details for port 80"
}
function display_ports() {
    if [ -z "$1" ]; then
        echo "Active Ports and Services:"
        printf "%-10s %-10s %-10s %-20s %-20s %-20s %-10s\n" "PROTOCOL" "RECV-Q" "SEND-Q" "LOCAL ADDRESS" "FOREIGN ADDRESS" "SERVICE" "STATE"
        ss -tuln | awk 'NR>1 {
            split($5, a, ":")
            port = a[2]
            cmd = "grep -w " port " /etc/services 2>/dev/null | awk \"{print \$1}\""
            cmd | getline service
            close(cmd)
            if (service == "") service = "Unknown"
            printf "%-10s %-10s %-10s %-20s %-20s %-20s %-10s\n", $1, $2, $3, $5, $6, service, $7
        }'
    else
        echo "Details for Port $1:"
        printf "%-10s %-10s %-10s %-20s %-20s %-20s %-10s\n" "PROTOCOL" "RECV-Q" "SEND-Q" "LOCAL ADDRESS" "FOREIGN ADDRESS" "SERVICE" "STATE"
        ss -tuln | awk -v port="$1" '$5 ~ ":"port"($|,) {
            cmd = "grep -w " port " /etc/services 2>/dev/null | awk \"{print \$1}\""
            cmd | getline service
            close(cmd)
            if (service == "") service = "Unknown"
            printf "%-10s %-10s %-10s %-20s %-20s %-20s %-10s\n", $1, $2, $3, $5, $6, service, $7
        }'
    fi
}
function list_docker() {
    if [ -z "$1" ]; then
        echo "Docker Images:"
        printf "%-40s %-20s %-20s %-20s\n" "REPOSITORY" "TAG" "IMAGE ID" "CREATED"
        docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}" |
            awk '{printf "%-40s %-20s %-20s %-20s\n", $1, $2, $3, $4" "$5" "$6" "$7}'
        echo ""
        echo "Docker Containers:"
        printf "%-20s %-20s %-20s %-20s %-20s %-20s\n" "CONTAINER ID" "IMAGE" "COMMAND" "CREATED" "STATUS" "PORTS"
        docker ps -a --format "{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}" |
            awk '{printf "%-20s %-20s %-20s %-20s %-20s %-20s\n", $1, $2, $3, $4" "$5, $6, $7}'
    else
        echo "Details for Container $1:"
        docker inspect "$1" | jq '.[] | {Id, Name, Status: .State.Status, Image: .Config.Image, Ports: .NetworkSettings.Ports}' | jq -r 'to_entries | .[] | "\(.key): \(.value)"'
    fi
}
function display_nginx() {
    if [ -z "$1" ]; then
        echo "Nginx Domains and Ports:"
        printf "%-40s %-20s\n" "DOMAIN" "PORT"
        grep -E 'server_name|listen' /etc/nginx/nginx.conf /etc/nginx/sites-enabled/* |
            awk '{printf "%-40s %-20s\n", $2, $3}'
    else
        echo "Configuration for Domain $1:"
        grep -A 10 "server_name $1;" /etc/nginx/nginx.conf /etc/nginx/sites-enabled/* |
            sed 's/^/    /'  # Indent for readability
    fi
}
function list_users() {
    if [ -z "$1" ]; then
        echo "Users and Last Login Times:"
        printf "%-20s %-30s\n" "USERNAME" "LAST LOGIN"
        lastlog | awk 'NR>1 {printf "%-20s %-30s\n", $1, $4" "$5" "$6" "$7" "$8" "$9}'
    else
        echo "Details for User $1:"
        lastlog -u "$1" | awk 'NR>1 {printf "%-20s %-30s\n", "USERNAME:", $1; printf "%-20s %-30s\n", "LAST LOGIN:", $4" "$5" "$6" "$7" "$8" "$9}'
    fi
}
function display_time_range() {
    echo "Activities between $1 and $2:"
    journalctl --since "$1" --until "$2" --no-pager |
        awk '{printf "%-20s %-10s %-30s %s\n", $1, $2, $3, substr($0, index($0,$4))}'
}
# Main script logic
case "$1" in
    -p)
        display_ports "$2"
        ;;
    -d)
        list_docker "$2"
        ;;
    -n)
        display_nginx "$2"
        ;;
    -u)
        list_users "$2"
        ;;
    -t)
        display_time_range "$2" "$3"
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid option. Use -h for help."
        show_help
        exit 1
        ;;
esac
