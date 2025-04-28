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
    echo -e "${YELLOW}1.${NC} Fresh Installation (Build Everything from Scratch)"
    echo -e "${YELLOW}2.${NC} Continue with Existing GalaxyERP"
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

# Function to install MariaDB
install_mariadb() {
    echo -e "${YELLOW}Installing MariaDB...${NC}"
    sudo apt-get update
    sudo apt-get install -y mariadb-server mariadb-client
    
    # Start MariaDB service
    echo -e "${YELLOW}Starting MariaDB service...${NC}"
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    
    # Configure MariaDB
    echo -e "${YELLOW}Configuring MariaDB...${NC}"
    
    # Set root password and configure authentication
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'GalaxyERP@DB';"
    sudo mysql -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    
    # Drop existing database if it exists
    sudo mysql -u root -pGalaxyERP@DB -e "DROP DATABASE IF EXISTS GalaxyERP;"
    
    # Create database and user
    sudo mysql -u root -pGalaxyERP@DB -e "CREATE DATABASE IF NOT EXISTS GalaxyERP;"
    sudo mysql -u root -pGalaxyERP@DB -e "CREATE USER IF NOT EXISTS 'galaxyerp'@'localhost' IDENTIFIED BY 'GalaxyERP@DB';"
    sudo mysql -u root -pGalaxyERP@DB -e "GRANT ALL PRIVILEGES ON GalaxyERP.* TO 'galaxyerp'@'localhost';"
    sudo mysql -u root -pGalaxyERP@DB -e "FLUSH PRIVILEGES;"
    
    # Configure MariaDB character set
    echo -e "${YELLOW}Configuring MariaDB character set...${NC}"
    echo "[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4" | sudo tee -a /etc/mysql/my.cnf
    
    sudo systemctl restart mariadb
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
        
        # Create supervisor configuration file
        echo "[program:frappe]
        command=bench start
        directory=$(pwd)
        user=$USER
        autostart=true
        autorestart=true
        stderr_logfile=/var/log/supervisor/frappe.err.log
        stdout_logfile=/var/log/supervisor/frappe.out.log" | sudo tee /etc/supervisor/conf.d/frappe.conf
        
        # Create log directory if it doesn't exist
        sudo mkdir -p /var/log/supervisor
        
        # Reload supervisor configuration
        sudo supervisorctl reread
        sudo supervisorctl update
        
        # Start supervisor service
        sudo systemctl start supervisor
        sudo systemctl enable supervisor
        
        echo -e "${GREEN}Process manager configured successfully!${NC}"
    else
        handle_error "frappe-bench directory not found"
        return 1
    fi
}

# Function to clean up existing bench
cleanup_bench() {
    if [ -d "frappe-bench" ]; then
        echo -e "${YELLOW}Cleaning up existing frappe-bench...${NC}"
        rm -rf frappe-bench
    fi
}

# Function to check and initialize bench
check_and_init_bench() {
    if [ -d "frappe-bench" ]; then
        cd frappe-bench
        if [ ! -d "apps/frappe" ] || [ ! -f "common_site_config.json" ]; then
            echo -e "${YELLOW}Existing frappe-bench is not properly initialized. Cleaning up...${NC}"
            cd ..
            cleanup_bench
            echo -e "${YELLOW}Initializing new frappe-bench...${NC}"
            if ! bench init frappe-bench --frappe-branch version-15; then
                handle_error "Failed to initialize frappe-bench"
                return 1
            fi
            
            cd frappe-bench
            
            # Get frappe and erpnext apps
            echo -e "${YELLOW}Getting frappe and erpnext apps...${NC}"
            if ! bench get-app frappe --branch version-15; then
                handle_error "Failed to get frappe app"
                return 1
            fi
            
            if ! bench get-app erpnext --branch version-15; then
                handle_error "Failed to get erpnext app"
                return 1
            fi
            
            # Install dependencies
            bench setup requirements
            bench setup procfile
            bench setup supervisor --user $USER
            bench setup nginx
            bench setup redis
        else
            echo -e "${YELLOW}Existing frappe-bench found and properly initialized.${NC}"
        fi
    else
        echo -e "${YELLOW}Initializing new frappe-bench...${NC}"
        if ! bench init frappe-bench --frappe-branch version-15; then
            handle_error "Failed to initialize frappe-bench"
            return 1
        fi
        
        cd frappe-bench
        
        # Get frappe and erpnext apps
        echo -e "${YELLOW}Getting frappe and erpnext apps...${NC}"
        if ! bench get-app frappe --branch version-15; then
            handle_error "Failed to get frappe app"
            return 1
        fi
        
        if ! bench get-app erpnext --branch version-15; then
            handle_error "Failed to get erpnext app"
            return 1
        fi
        
        # Install dependencies
        bench setup requirements
        bench setup procfile
        bench setup supervisor --user $USER
        bench setup nginx
        bench setup redis
    fi
    return 0
}

# Function to continue with existing GalaxyERP
continue_with_existing() {
    echo -e "${BLUE}Setting up existing GalaxyERP...${NC}"
    
    # Install required dependencies
    echo -e "${YELLOW}Installing required dependencies...${NC}"
    sudo apt-get update
    sudo apt-get install -y git python3-dev python3-setuptools python3-pip virtualenv libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf
    
    # Install pipx if not present
    if ! command -v pipx &> /dev/null; then
        echo -e "${YELLOW}Installing pipx...${NC}"
        sudo apt-get install -y pipx
        pipx ensurepath
    fi
    
    # Install Node.js and Yarn
    echo -e "${YELLOW}Installing Node.js and Yarn...${NC}"
    sudo apt-get install -y curl
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g yarn
    
    # Install frappe-bench using pipx
    echo -e "${YELLOW}Installing frappe-bench...${NC}"
    if ! pipx install frappe-bench; then
        handle_error "Failed to install frappe-bench using pipx"
        return 1
    fi
    
    # Add pipx to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        source ~/.bashrc
    fi
    
    # Pull latest code from GitHub
    echo -e "${YELLOW}Pulling latest code from GitHub...${NC}"
    if ! git pull origin master; then
        handle_error "Failed to pull latest code from GitHub"
        return 1
    fi
    
    # Check and initialize bench
    if ! check_and_init_bench; then
        return 1
    fi
    
    # Install MariaDB
    if ! install_mariadb; then
        handle_error "Failed to install and configure MariaDB"
        return 1
    fi
    
    # Build assets
    echo -e "${YELLOW}Building assets...${NC}"
    if ! bench build; then
        handle_error "Failed to build assets"
        return 1
    fi
    
    # Check if site exists
    if ! bench --site GalaxyERP.com list-apps &>/dev/null; then
        echo -e "${YELLOW}Setting up GalaxyERP site...${NC}"
        if ! bench new-site GalaxyERP.com --mariadb-root-password GalaxyERP@DB --admin-password GalaxyERP@Admin --db-name GalaxyERP --db-password GalaxyERP@DB; then
            handle_error "Failed to create new site"
            return 1
        fi
        
        # Install apps
        echo -e "${YELLOW}Installing apps...${NC}"
        if ! bench --site GalaxyERP.com install-app frappe; then
            handle_error "Failed to install frappe app"
            return 1
        fi
        
        if ! bench --site GalaxyERP.com install-app erpnext; then
            handle_error "Failed to install erpnext app"
            return 1
        fi
    else
        echo -e "${YELLOW}Site already exists, updating...${NC}"
        if ! bench --site GalaxyERP.com update; then
            handle_error "Failed to update site"
            return 1
        fi
    fi
    
    # Configure process manager
    if ! install_process_manager; then
        handle_error "Failed to configure process manager"
        return 1
    fi
    
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${YELLOW}To start GalaxyERP, run:${NC}"
    echo -e "bench start"
    
    # Start GalaxyERP
    read -p "Do you want to start GalaxyERP now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! bench start; then
            handle_error "Failed to start GalaxyERP"
            return 1
        fi
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
                        if [ -f "../create_site.sh" ]; then
                            chmod +x ../create_site.sh
                            ../create_site.sh
                        else
                            handle_error "create_site.sh not found"
                            continue
                        fi
                        ;;
                    *)
                        handle_error "Invalid choice"
                        ;;
                esac
                ;;
                
            2)
                continue_with_existing
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