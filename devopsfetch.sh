#!/bin/bash

function show_help() {
    echo "Usage: devopsfetch.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p <port_number>       Display active ports or detailed info about a specific port"
    echo "  -d <container_name>    List Docker images/containers or detailed info about a specific container"
    echo "  -n <domain>            Display Nginx domains/ports or detailed config for a specific domain"
    echo "  -u <username>          List users and their last login times or detailed info about a specific user"
    echo "  -t <start_time> <end_time>  Display activities within a specified time range"
    echo "  -h, --help             Show this help message"
}

function display_ports() {
    if [ -z "$1" ]; then
        echo "Active Ports and Services:"
        echo -e "Proto\tRecv-Q\tSend-Q\tLocal Address\tForeign Address\tState"
        ss -tuln | awk 'NR>1 {print $1 "\t" $2 "\t" $3 "\t" $5 "\t" $6 "\t" $7}' | column -t
    else
        echo "Details for Port $1:"
        echo -e "Proto\tRecv-Q\tSend-Q\tLocal Address\tForeign Address\tState"
        ss -tuln | grep ":$1 " | awk '{print $1 "\t" $2 "\t" $3 "\t" $5 "\t" $6 "\t" $7}' | column -t
    fi
}

function list_docker() {
    if [ -z "$1" ]; then
        echo "Docker Images:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}" | column -t
        echo ""
        echo "Docker Containers:"
        docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}" | column -t
    else
        if docker ps -a | grep -q "$1"; then
            echo "Details for Container $1:"
            docker inspect "$1" | jq '.[] | {Id: .Id, Name: .Name, Status: .State.Status, Image: .Config.Image, Ports: .NetworkSettings.Ports}'
        else
            echo "No such container found."
        fi
    fi
}

function display_nginx() {
    if [ -z "$1" ]; then
        echo "Nginx Domains and Ports:"
        grep -E 'server_name|listen' /etc/nginx/nginx.conf /etc/nginx/sites-enabled/* | awk '{print $1 "\t" $2}' | column -t
    else
        echo "Configuration for Domain $1:"
        grep -A 10 "server_name $1;" /etc/nginx/nginx.conf /etc/nginx/sites-enabled/*
    fi
}

function list_users() {
    if [ -z "$1" ]; then
        echo "Users and Last Login Times:"
        echo -e "Username\tLast Login"
        lastlog | awk 'NR>1 {print $1 "\t" $4 " " $5 " " $6 " " $7}' | column -t
    else
        echo "Details for User $1:"
        lastlog | grep "$1"
    fi
}

function display_time_range() {
    echo "Activities between $1 and $2:"
    journalctl --since "$1" --until "$2" --no-pager
}

# Parse command line arguments
while getopts ":p:d:n:u:t:h" opt; do
    case ${opt} in
        p)
            display_ports "$OPTARG"
            ;;
        d)
            list_docker "$OPTARG"
            ;;
        n)
            display_nginx "$OPTARG"
            ;;
        u)
            list_users "$OPTARG"
            ;;
        t)
            display_time_range "$OPTARG" "$3"
            shift
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            ;;
    esac
done
