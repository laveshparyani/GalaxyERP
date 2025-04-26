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

# Function to check Ubuntu version
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$VERSION_ID"
    else
        print_message "Error: Could not determine Ubuntu version" "$RED"
        exit 1
    fi
}

# Function to install MariaDB based on Ubuntu version
install_mariadb() {
    local version=$(get_ubuntu_version)
    
    if [ "$version" = "24.04" ]; then
        print_message "Installing MariaDB for Ubuntu 24.04..." "$YELLOW"
        sudo -S apt-get install -y apt-transport-https curl || return 1
        sudo -S mkdir -p /etc/apt/keyrings || return 1
        sudo -S curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp' || return 1
        
        # Create MariaDB sources file
        echo "# MariaDB 11.8 repository list - created 2025-04-24 13:42 UTC
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
URIs: https://mirror.bharatdatacenter.com/mariadb/repo/11.8/ubuntu
Suites: noble
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp" | sudo -S tee /etc/apt/sources.list.d/mariadb.sources || return 1
        
        sudo -S apt-get update || return 1
        sudo -S apt-get install -y mariadb-server || return 1
    elif [ "$version" = "20.04" ]; then
        print_message "Installing MariaDB for Ubuntu 20.04..." "$YELLOW"
        sudo -S apt-get install -y software-properties-common || return 1
        sudo -S apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc' || return 1
        sudo -S add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.icm.edu.pl/pub/unix/database/mariadb/repo/10.3/ubuntu focal main' || return 1
        sudo -S apt update || return 1
        sudo -S apt install -y mariadb-server || return 1
    else
        print_message "Unsupported Ubuntu version. Please use Ubuntu 20.04 or 24.04." "$RED"
        exit 1
    fi
}

# Function to verify MariaDB installation
verify_mariadb() {
    if systemctl is-active --quiet mariadb; then
        print_message "MariaDB is running" "$GREEN"
        return 0
    else
        print_message "Error: MariaDB is not running" "$RED"
        return 1
    fi
}

# Function to install pipx and frappe-bench
install_frappe_bench() {
    print_message "Installing pipx..." "$YELLOW"
    if ! command_exists pipx; then
        sudo -S apt-get install -y pipx || { print_message "Error installing pipx" "$RED"; return 1; }
        pipx ensurepath || { print_message "Error ensuring pipx path" "$RED"; return 1; }
    fi

    # Add pipx to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        source ~/.bashrc
    fi

    print_message "Installing frappe-bench using pipx..." "$YELLOW"
    pipx install frappe-bench || { print_message "Error installing frappe-bench with pipx" "$RED"; return 1; }
    
    # Ensure bench command is available
    if ! command_exists bench; then
        print_message "Adding bench to PATH..." "$YELLOW"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        source ~/.bashrc
    fi
}

# Function to install and configure process manager
install_process_manager() {
    print_message "Installing and configuring process manager..." "$YELLOW"
    
    # Install supervisor if not present
    if ! command_exists supervisor; then
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
        
        print_message "Process manager configured successfully!" "$GREEN"
    else
        print_message "Error: frappe-bench directory not found" "$RED"
        return 1
    fi
}

# Main installation process
main() {
    print_message "Starting GalaxyERP setup..." "$GREEN"
    
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
    
    # Install dos2unix if not present
    if ! command_exists dos2unix; then
        print_message "Installing dos2unix..." "$YELLOW"
        sudo -S apt-get install -y dos2unix || { print_message "Error installing dos2unix" "$RED"; exit 1; }
    fi
    
    # Convert setup and create_site scripts to Unix format
    print_message "Converting scripts to Unix format..." "$YELLOW"
    dos2unix setup.sh || { print_message "Error converting setup.sh" "$RED"; exit 1; }
    dos2unix create_site.sh || { print_message "Error converting create_site.sh" "$RED"; exit 1; }
    
    # Make scripts executable
    chmod +x setup.sh create_site.sh || { print_message "Error making scripts executable" "$RED"; exit 1; }
    
    # Update system
    print_message "Updating system packages..." "$YELLOW"
    sudo -S apt-get update || { print_message "Error updating packages" "$RED"; exit 1; }
    sudo -S apt-get upgrade -y || { print_message "Error upgrading packages" "$RED"; exit 1; }
    
    # Install basic requirements
    print_message "Installing basic requirements..." "$YELLOW"
    sudo -S apt-get install -y git python3-dev python3-setuptools python3-pip virtualenv || { print_message "Error installing basic requirements" "$RED"; exit 1; }
    
    # Install Python venv based on version
    PYTHON_VERSION=$(python3 -V | cut -d' ' -f2 | cut -d'.' -f1,2)
    if [ "$PYTHON_VERSION" = "3.8" ]; then
        sudo -S apt install -y python3.8-venv || { print_message "Error installing Python 3.8 venv" "$RED"; exit 1; }
    elif [ "$PYTHON_VERSION" = "3.10" ]; then
        sudo -S apt install -y python3.10-venv || { print_message "Error installing Python 3.10 venv" "$RED"; exit 1; }
    else
        print_message "Warning: Unsupported Python version $PYTHON_VERSION" "$YELLOW"
    fi
    
    # Install MariaDB
    install_mariadb || { print_message "Error installing MariaDB" "$RED"; exit 1; }
    
    # Verify MariaDB installation
    verify_mariadb || { print_message "Error verifying MariaDB installation" "$RED"; exit 1; }
    
    # Configure MariaDB
    print_message "Configuring MariaDB..." "$YELLOW"
    sudo -S mysql_secure_installation || { print_message "Error configuring MariaDB" "$RED"; exit 1; }
    
    # Configure MariaDB character set
    echo "[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4" | sudo -S tee -a /etc/mysql/my.cnf || { print_message "Error configuring MariaDB character set" "$RED"; exit 1; }
    
    sudo -S service mysql restart || { print_message "Error restarting MariaDB" "$RED"; exit 1; }
    
    # Install additional requirements
    print_message "Installing additional requirements..." "$YELLOW"
    sudo -S apt-get install -y libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf || { print_message "Error installing additional requirements" "$RED"; exit 1; }
    
    # Install Node.js
    print_message "Installing Node.js..." "$YELLOW"
    sudo -S apt-get install -y curl || { print_message "Error installing curl" "$RED"; exit 1; }
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -S -E bash - || { print_message "Error setting up Node.js repository" "$RED"; exit 1; }
    sudo -S apt-get install -y nodejs || { print_message "Error installing Node.js" "$RED"; exit 1; }
    
    # Install Yarn
    print_message "Installing Yarn..." "$YELLOW"
    sudo -S npm install -g yarn || { print_message "Error installing Yarn" "$RED"; exit 1; }
    
    # Install frappe-bench using pipx
    install_frappe_bench || { print_message "Error installing frappe-bench" "$RED"; exit 1; }
    
    # Initialize frappe-bench
    print_message "Initializing frappe-bench..." "$YELLOW"
    bench init frappe-bench --frappe-branch version-15 || { print_message "Error initializing frappe-bench" "$RED"; exit 1; }
    
    # Change to frappe-bench directory
    cd frappe-bench || { print_message "Error changing to frappe-bench directory" "$RED"; exit 1; }
    
    # Build assets
    print_message "Building assets..." "$YELLOW"
    bench build || { print_message "Error building assets" "$RED"; exit 1; }
    
    # Install and configure process manager
    install_process_manager || { print_message "Error configuring process manager" "$RED"; exit 1; }
    
    print_message "\nSetup completed successfully!" "$GREEN"
    print_message "\nYou are now in the frappe-bench directory." "$GREEN"
    print_message "\nTo create a new site, run:" "$YELLOW"
    print_message "../create_site.sh" "$NC"
    print_message "\nTo start the development server, run:" "$YELLOW"
    print_message "bench start" "$NC"
}

# Run main function
main 