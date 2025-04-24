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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Ubuntu version
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$VERSION_ID"
    else
        echo "0"
    fi
}

# Function to install MariaDB based on Ubuntu version
install_mariadb() {
    local version=$(get_ubuntu_version)
    
    if [ "$version" = "24.04" ]; then
        print_message "Installing MariaDB for Ubuntu 24.04..." "$YELLOW"
        sudo apt-get install apt-transport-https curl
        sudo mkdir -p /etc/apt/keyrings
        sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
        
        # Create MariaDB sources file
        echo "# MariaDB 11.8 repository list - created 2025-04-24 13:42 UTC
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
URIs: https://mirror.bharatdatacenter.com/mariadb/repo/11.8/ubuntu
Suites: noble
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp" | sudo tee /etc/apt/sources.list.d/mariadb.sources
        
        sudo apt-get update
        sudo apt-get install mariadb-server
    elif [ "$version" = "20.04" ]; then
        print_message "Installing MariaDB for Ubuntu 20.04..." "$YELLOW"
        sudo apt-get install software-properties-common
        sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
        sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.icm.edu.pl/pub/unix/database/mariadb/repo/10.3/ubuntu focal main'
        sudo apt update
        sudo apt install mariadb-server
    else
        print_message "Unsupported Ubuntu version. Please use Ubuntu 20.04 or 24.04." "$RED"
        exit 1
    fi
}

# Main installation process
main() {
    print_message "Starting GalaxyERP setup..." "$GREEN"
    
    # Update system
    print_message "Updating system packages..." "$YELLOW"
    sudo apt-get update
    sudo apt-get upgrade -y
    
    # Install basic requirements
    print_message "Installing basic requirements..." "$YELLOW"
    sudo apt-get install -y git python3-dev python3-setuptools python3-pip virtualenv
    
    # Install Python venv based on version
    PYTHON_VERSION=$(python3 -V | cut -d' ' -f2 | cut -d'.' -f1,2)
    if [ "$PYTHON_VERSION" = "3.8" ]; then
        sudo apt install -y python3.8-venv
    elif [ "$PYTHON_VERSION" = "3.10" ]; then
        sudo apt install -y python3.10-venv
    fi
    
    # Install MariaDB
    install_mariadb
    
    # Configure MariaDB
    print_message "Configuring MariaDB..." "$YELLOW"
    sudo mysql_secure_installation
    
    # Configure MariaDB character set
    echo "[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4" | sudo tee -a /etc/mysql/my.cnf
    
    sudo service mysql restart
    
    # Install additional requirements
    print_message "Installing additional requirements..." "$YELLOW"
    sudo apt-get install -y libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf
    
    # Install Node.js
    print_message "Installing Node.js..." "$YELLOW"
    sudo apt-get install -y curl
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Install Yarn
    print_message "Installing Yarn..." "$YELLOW"
    sudo npm install -g yarn
    
    # Install frappe-bench
    print_message "Installing frappe-bench..." "$YELLOW"
    if ! command_exists pip3; then
        print_message "Installing pip3..." "$YELLOW"
        sudo apt-get install -y python3-pip
    fi
    
    sudo -H pip3 install frappe-bench
    
    # Initialize frappe-bench
    print_message "Initializing frappe-bench..." "$YELLOW"
    bench init frappe-bench --frappe-branch version-15
    
    print_message "\nSetup completed successfully!" "$GREEN"
    print_message "\nNext steps:" "$YELLOW"
    print_message "1. cd frappe-bench" "$NC"
    print_message "2. bench start" "$NC"
    print_message "3. In a new terminal, run: bench new-site your-site-name" "$NC"
    print_message "4. bench get-app erpnext --branch version-13" "$NC"
    print_message "5. bench --site your-site-name install-app erpnext" "$NC"
}

# Run main function
main 