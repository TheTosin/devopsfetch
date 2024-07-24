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
display_ports() {
    port_filter="$1"

    if [ -z "$port_filter" ]; then
        echo "Active Ports and Services:"
        printf "| %-10s | %-10s | %-10s | %-20s | %-20s | %-10s |\n" "PROTOCOL" "RECV-Q" "SEND-Q" "LOCAL ADDRESS" "FOREIGN ADDRESS" "SERVICE"
        echo "-----------------------------------------------------------------------------------------------------------------------------"
        ss -tuln | awk 'NR>1 {
            split($5, a, ":")
            port = a[2]
            cmd = "grep -w " port " /etc/services 2>/dev/null | awk \"{print $1}\""
            cmd | getline service
            close(cmd)
            if (service == "") service = "Unknown"
            printf "| %-10s | %-10s | %-10s | %-20s | %-20s | %-10s |\n", $1, $2, $3, $5, $6, service
        }'
    else
        echo "Details for Port $port_filter:"
        printf "| %-10s | %-10s | %-10s | %-20s | %-20s | %-10s |\n" "PROTOCOL" "RECV-Q" "SEND-Q" "LOCAL ADDRESS" "FOREIGN ADDRESS" "SERVICE"
        echo "------------------------------------------------------------------------------------------------------------------------------"
        ss -tuln | awk -v port="$port_filter" '$5 ~ ":"port"($|,)" {
            split($5, a, ":")
            cmd = "grep -w " port " /etc/services 2>/dev/null | awk \"{print $1}\""
            cmd | getline service
            close(cmd)
            if (service == "") service = "Unknown"
            printf "| %-10s | %-10s | %-10s | %-20s | %-20s | %-10s |\n", $1, $2, $3, $5, $6, service
        }'
    fi
}
function list_docker() {
    echo " DOCKER STATUS "
    echo "----------------------------------------------------------------------------------------------------"
    echo "Docker Images:"
    printf "| %-20s | %-10s | %-15s | %-10s | %-15s |\n" "REPOSITORY" "TAG" "IMAGE ID" "SIZE" "CREATED"
    echo "----------------------------------------------------------------------------------------------------"
    docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | \
    awk '{printf "| %-20s | %-10s | %-15s | %-10s | %-15s |\n", $1, $2, $3, $4, $5" "$6" "$7}'

    echo ""
    echo "Docker Containers:"
    printf "| %-15s | %-15s | %-50s | %-20s | %-15s | %-15s |\n" "CONTAINER ID" "IMAGE" "COMMAND" "CREATED" "STATUS" "PORTS"
    echo "-----------------------------------------------------------------------------------------------------------------"
    docker ps -a --format "{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}" | \
    awk '{printf "| %-15s | %-15s | %-50s | %-20s | %-15s | %-15s |\n", $1, $2, $3, $4" "$5, $6, $7}'
}

function display_nginx() {
    if [ -z "$1" ]; then
        echo "Nginx Domains, Ports, and Proxies:"
        printf "%-30s %-15s %-30s %-50s\n" "DOMAIN" "PORT" "PROXY" "CONFIG FILE"
        awk '
        BEGIN { OFS="\t" }
        /server_name/ { domain=$2; gsub(";", "", domain) }
        /listen/ { port=$2; gsub(";", "", port) }
        /proxy_pass/ { proxy=$2; gsub(";", "", proxy) }
        /}/ {
            if (domain && port) {
                print domain, port, (proxy ? proxy : "N/A"), FILENAME
                domain=""; port=""; proxy=""
            }
        }
        ' /etc/nginx/nginx.conf /etc/nginx/sites-enabled/* | sort -u |
        while IFS=$'\t' read -r domain port proxy file; do
            printf "%-30s %-15s %-30s %-50s\n" "$domain" "$port" "$proxy" "$file"
        done
    else
        echo "Configuration for Domain $1:"
        awk '/server {/,/}/ {
            if ($0 ~ "server_name '"$1"';") {
                in_server = 1
                print "    " $0
                next
            }
            if (in_server) {
                print "    " $0
                if ($0 ~ "}") {
                    in_server = 0
                    exit
                }
            }
        }' /etc/nginx/nginx.conf /etc/nginx/sites-enabled/*
    fi
}
function list_users() {
    if [ -z "$1" ]; then
        echo "Users and Last Login Times:"
        echo "--------------------------------------------------------"
        printf "| %-20s | %-30s |\n" "USERNAME" "LAST LOGIN"
        echo "--------------------------------------------------------"
        lastlog | awk 'NR>1 {printf "| %-20s | %-30s |\n", $1, $4" "$5" "$6" "$7" "$8" "$9}'
    else
        echo "Details for User $1:"
        echo "-----------------------------------------------------------------------------------------------------------------"
        lastlog -u "$1" | awk 'NR>1 {printf "| %-20s | %-30s |\n", "USERNAME:", $1; printf "%-20s %-30s\n", "LAST LOGIN:", $4" "$5" "$6" "$7" "$8" "$9}'
    fi
}
function display_time_range() {
    echo " Activities between $1 and $2: "
    echo "----------------------------------------------------------------------------------------------------"
    journalctl --since "$1" --until "$2" --no-pager |
        awk '{printf "| %-20s | %-10s | %-30s | %s|\n", $1, $2, $3, substr($0, index($0,$4))}'
}
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
