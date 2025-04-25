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

# Function to check if running in WSL
is_wsl() {
    if [ -f /proc/version ] && grep -q Microsoft /proc/version; then
        return 0
    else
        return 1
    fi
}

# Function to remove MariaDB
remove_mariadb() {
    print_message "Removing MariaDB..." "$YELLOW"
    
    # Stop MariaDB service
    sudo systemctl stop mariadb || true
    
    # Remove MariaDB packages
    sudo apt-get remove --purge -y mariadb-server mariadb-client mariadb-common || true
    sudo apt-get autoremove -y || true
    
    # Remove MariaDB data directory
    sudo rm -rf /var/lib/mysql || true
    
    # Remove MariaDB configuration
    sudo rm -rf /etc/mysql || true
    
    # Remove MariaDB repository
    sudo rm -f /etc/apt/sources.list.d/mariadb.sources || true
    sudo rm -f /etc/apt/keyrings/mariadb-keyring.pgp || true
}

# Function to remove Node.js and Yarn
remove_nodejs() {
    print_message "Removing Node.js and Yarn..." "$YELLOW"
    
    # Remove Yarn
    sudo npm uninstall -g yarn || true
    
    # Remove Node.js
    sudo apt-get remove --purge -y nodejs || true
    sudo apt-get autoremove -y || true
    
    # Remove Node.js repository
    sudo rm -f /etc/apt/sources.list.d/nodesource.list || true
}

# Function to remove frappe-bench
remove_frappe_bench() {
    print_message "Removing frappe-bench..." "$YELLOW"
    
    # Remove frappe-bench using pipx
    pipx uninstall frappe-bench || true
    
    # Remove frappe-bench directory
    if [ -d "frappe-bench" ]; then
        rm -rf frappe-bench || true
    fi
}

# Function to remove Python packages
remove_python_packages() {
    print_message "Removing Python packages..." "$YELLOW"
    
    # Remove pipx
    sudo apt-get remove --purge -y pipx || true
    
    # Remove Python packages installed by setup script
    sudo apt-get remove --purge -y python3-dev python3-setuptools python3-pip virtualenv || true
    sudo apt-get autoremove -y || true
}

# Function to remove additional requirements
remove_additional_requirements() {
    print_message "Removing additional requirements..." "$YELLOW"
    
    # Remove packages installed by setup script
    sudo apt-get remove --purge -y libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf || true
    sudo apt-get autoremove -y || true
}

# Main cleanup process
main() {
    print_message "Starting GalaxyERP cleanup..." "$GREEN"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_message "Error: Please do not run this script as root" "$RED"
        exit 1
    fi
    
    # Check if running in WSL
    if is_wsl; then
        print_message "Running in WSL environment..." "$YELLOW"
    else
        print_message "Warning: Not running in WSL environment. Some features may not work as expected." "$YELLOW"
    fi
    
    # Ask for confirmation
    read -p "Are you sure you want to remove all GalaxyERP components? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Cleanup cancelled." "$YELLOW"
        exit 1
    fi
    
    # Remove MariaDB
    remove_mariadb
    
    # Remove Node.js and Yarn
    remove_nodejs
    
    # Remove frappe-bench
    remove_frappe_bench
    
    # Remove Python packages
    remove_python_packages
    
    # Remove additional requirements
    remove_additional_requirements
    
    # Clean up apt
    print_message "Cleaning up apt..." "$YELLOW"
    sudo apt-get clean || true
    sudo apt-get autoremove -y || true
    
    print_message "\nCleanup completed!" "$GREEN"
    print_message "Note: Some system packages that were installed as dependencies may still remain." "$YELLOW"
    print_message "If you want to remove them, please review the list carefully before removing." "$YELLOW"
}

# Run main function
main 