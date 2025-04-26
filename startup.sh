#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display menu
show_menu() {
    clear
    echo -e "${BLUE}=== GalaxyERP Setup Menu ===${NC}"
    echo -e "${YELLOW}1.${NC} Build Everything from Scratch"
    echo -e "${YELLOW}2.${NC} Continue with Current GalaxyERP Setup"
    echo -e "${YELLOW}3.${NC} Exit"
    echo
    echo -n "Enter your choice (1-3): "
}

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to check if running in WSL
check_wsl() {
    if ! grep -q Microsoft /proc/version; then
        echo -e "${YELLOW}Warning: Not running in WSL environment. Some features may not work as expected.${NC}"
        echo -e "${YELLOW}Press Enter to continue anyway...${NC}"
        read
    fi
}

# Function to install and configure process manager
install_process_manager() {
    echo -e "${BLUE}Installing and configuring process manager...${NC}"
    
    # Install supervisor if not present
    if ! command -v supervisor &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y supervisor
    fi
    
    # Create supervisor configuration directory if it doesn't exist
    sudo mkdir -p /etc/supervisor/conf.d
    
    # Configure supervisor for Frappe bench
    if [ -d "frappe-bench" ]; then
        cd frappe-bench
        
        # Generate supervisor configuration
        bench setup supervisor --user $USER
        
        # Reload supervisor configuration
        sudo supervisorctl reread
        sudo supervisorctl update
        
        echo -e "${GREEN}Process manager configured successfully!${NC}"
    else
        handle_error "frappe-bench directory not found"
        return 1
    fi
}

# Main script
main() {
    check_wsl
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                echo -e "${BLUE}Starting fresh installation...${NC}"
                if [ -f "./cleanup.sh" ]; then
                    chmod +x ./cleanup.sh
                    ./cleanup.sh
                else
                    handle_error "cleanup.sh not found"
                    continue
                fi
                
                if [ -f "./setup.sh" ]; then
                    chmod +x ./setup.sh
                    ./setup.sh
                else
                    handle_error "setup.sh not found"
                    continue
                fi
                
                install_process_manager
                
                echo -e "${GREEN}Setup completed!${NC}"
                echo -e "${YELLOW}1.${NC} Start GalaxyERP"
                echo -e "${YELLOW}2.${NC} Create a new site"
                read -p "Enter your choice (1-2): " subchoice
                
                case $subchoice in
                    1)
                        cd frappe-bench
                        bench start
                        ;;
                    2)
                        if [ -f "./create_site.sh" ]; then
                            chmod +x ./create_site.sh
                            ./create_site.sh
                        else
                            handle_error "create_site.sh not found"
                        fi
                        ;;
                    *)
                        handle_error "Invalid choice"
                        ;;
                esac
                ;;
                
            2)
                echo -e "${BLUE}Continuing with current setup...${NC}"
                if [ -d "frappe-bench" ]; then
                    cd frappe-bench
                    install_process_manager
                    bench start
                else
                    handle_error "frappe-bench directory not found"
                fi
                ;;
                
            3)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
                
            *)
                handle_error "Invalid choice"
                ;;
        esac
    done
}

# Run main function
main 