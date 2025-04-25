#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command succeeded
check_command() {
    if [ $? -eq 0 ]; then
        print_message "$1" "$GREEN"
        return 0
    else
        print_message "$2" "$RED"
        return 1
    fi
}

# Function to validate site name
validate_site_name() {
    local site_name=$1
    if [[ ! $site_name =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
        print_message "Invalid site name. Site name should only contain letters, numbers, and hyphens." "$RED"
        return 1
    fi
    return 0
}

# Function to check if bench is installed
check_bench() {
    if ! command -v bench >/dev/null 2>&1; then
        print_message "Error: bench command not found. Please run setup.sh first." "$RED"
        exit 1
    fi
}

# Function to check if we're in frappe-bench directory
check_frappe_bench() {
    if [ ! -d "sites" ]; then
        print_message "Error: Please run this script from the frappe-bench directory" "$RED"
        print_message "Run: cd frappe-bench" "$YELLOW"
        exit 1
    fi
}

# Function to check if MariaDB is running
check_mariadb() {
    if ! systemctl is-active --quiet mariadb; then
        print_message "Error: MariaDB is not running" "$RED"
        print_message "Please start MariaDB: sudo service mysql start" "$YELLOW"
        exit 1
    fi
}

# Function to check if Redis is running
check_redis() {
    if ! systemctl is-active --quiet redis-server; then
        print_message "Error: Redis is not running" "$RED"
        print_message "Please start Redis: sudo service redis-server start" "$YELLOW"
        exit 1
    fi
}

# Function to create site
create_site() {
    local site_name=$1
    
    print_message "\nCreating site: $site_name" "$YELLOW"
    bench new-site "$site_name" || { print_message "Error creating site" "$RED"; return 1; }
    
    print_message "\nInstalling ERPNext..." "$YELLOW"
    bench get-app erpnext --branch version-13 || { print_message "Error installing ERPNext" "$RED"; return 1; }
    
    print_message "\nInstalling ERPNext on site..." "$YELLOW"
    bench --site "$site_name" install-app erpnext || { print_message "Error installing ERPNext on site" "$RED"; return 1; }
    
    return 0
}

# Main site creation process
main() {
    print_message "GalaxyERP Site Creation Wizard" "$GREEN"
    print_message "=============================" "$GREEN"
    
    # Check prerequisites
    check_bench
    check_frappe_bench
    check_mariadb
    check_redis
    
    # Ask user if they want to create a site
    while true; do
        read -p "Do you want to create a new site? (Y/n): " create_site
        case $create_site in
            [Yy]* ) break;;
            [Nn]* ) 
                print_message "\nNo site will be created. You can run this script again later." "$YELLOW"
                print_message "You are now in the frappe-bench directory." "$GREEN"
                print_message "To start the server, run: bench start" "$NC"
                exit 0;;
            * ) print_message "Please answer Y or n" "$YELLOW";;
        esac
    done
    
    # Get site name
    while true; do
        read -p "Enter your site name (e.g., mysite.com): " site_name
        if validate_site_name "$site_name"; then
            break
        fi
    done
    
    # Create site and install ERPNext
    if create_site "$site_name"; then
        print_message "\nSite created and ERPNext installed successfully!" "$GREEN"
        print_message "\nYour site is ready to use!" "$GREEN"
        print_message "\nTo start your site:" "$YELLOW"
        print_message "1. Run: bench start" "$NC"
        print_message "2. Open your browser and go to: http://$site_name:8000" "$NC"
    else
        print_message "\nError: Site creation failed" "$RED"
        print_message "Please check the error messages above and try again." "$YELLOW"
        exit 1
    fi
}

# Run main function
main 