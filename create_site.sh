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

# Function to validate site name
validate_site_name() {
    local site_name=$1
    if [[ ! $site_name =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
        print_message "Invalid site name. Site name should only contain letters, numbers, and hyphens." "$RED"
        return 1
    fi
    return 0
}

# Main site creation process
main() {
    print_message "GalaxyERP Site Creation Wizard" "$GREEN"
    print_message "=============================" "$GREEN"
    
    # Check if we're in the frappe-bench directory
    if [ ! -d "sites" ]; then
        print_message "Error: Please run this script from the frappe-bench directory" "$RED"
        print_message "Run: cd frappe-bench" "$YELLOW"
        exit 1
    fi
    
    # Get site name
    while true; do
        read -p "Enter your site name (e.g., mysite.com): " site_name
        if validate_site_name "$site_name"; then
            break
        fi
    done
    
    # Create the site
    print_message "\nCreating site: $site_name" "$YELLOW"
    bench new-site "$site_name"
    
    if [ $? -eq 0 ]; then
        print_message "\nSite created successfully!" "$GREEN"
        
        # Install ERPNext
        print_message "\nInstalling ERPNext..." "$YELLOW"
        bench get-app erpnext --branch version-13
        
        if [ $? -eq 0 ]; then
            print_message "\nInstalling ERPNext on site..." "$YELLOW"
            bench --site "$site_name" install-app erpnext
            
            if [ $? -eq 0 ]; then
                print_message "\nERPNext installed successfully!" "$GREEN"
                print_message "\nYour site is ready to use!" "$GREEN"
                print_message "\nTo start your site:" "$YELLOW"
                print_message "1. Run: bench start" "$NC"
                print_message "2. Open your browser and go to: http://$site_name:8000" "$NC"
            else
                print_message "Error installing ERPNext on site" "$RED"
                exit 1
            fi
        else
            print_message "Error installing ERPNext" "$RED"
            exit 1
        fi
    else
        print_message "Error creating site" "$RED"
        exit 1
    fi
}

# Run main function
main 