#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to list available sites
list_sites() {
    echo -e "${BLUE}Available sites:${NC}"
    bench --site all list
}

# Function to create a new site
create_site() {
    read -p "Enter site name: " site_name
    if [ -z "$site_name" ]; then
        handle_error "Site name cannot be empty"
        return 1
    fi
    
    echo -e "${BLUE}Creating site: $site_name${NC}"
    bench new-site $site_name
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Site created successfully!${NC}"
        return 0
    else
        handle_error "Failed to create site"
        return 1
    fi
}

# Function to create and install app
create_and_install_app() {
    read -p "Enter app name: " app_name
    if [ -z "$app_name" ]; then
        handle_error "App name cannot be empty"
        return 1
    fi
    
    echo -e "${BLUE}Creating app: $app_name${NC}"
    bench make-app $app_name
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}App created successfully!${NC}"
        
        list_sites
        read -p "Enter site name to install app: " site_name
        
        if [ -z "$site_name" ]; then
            handle_error "Site name cannot be empty"
            return 1
        fi
        
        echo -e "${BLUE}Installing app on site: $site_name${NC}"
        bench --site $site_name install-app $app_name
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}App installed successfully!${NC}"
            return 0
        else
            handle_error "Failed to install app"
            return 1
        fi
    else
        handle_error "Failed to create app"
        return 1
    fi
}

# Main script
main() {
    if [ ! -d "frappe-bench" ]; then
        handle_error "frappe-bench directory not found"
        exit 1
    fi
    
    cd frappe-bench
    
    echo -e "${BLUE}=== Site Management ===${NC}"
    echo -e "${YELLOW}1.${NC} Create new site"
    echo -e "${YELLOW}2.${NC} Create and install app"
    echo -e "${YELLOW}3.${NC} List available sites"
    echo -e "${YELLOW}4.${NC} Exit"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            create_site
            ;;
        2)
            create_and_install_app
            ;;
        3)
            list_sites
            ;;
        4)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            handle_error "Invalid choice"
            ;;
    esac
}

# Run main function
main 