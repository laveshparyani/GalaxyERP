# GalaxyERP

A powerful cloud-based ERP solution built on Frappe/ERPNext, offering production management, warehouse systems, GST integration, and financial reporting. With 12+ years of experience and 90%+ customer satisfaction, it delivers innovative, scalable solutions for modern businesses.

## Quick Start Guide

### Step 1: Install WSL (Windows Subsystem for Linux)
1. Open PowerShell as Administrator
2. Run the following command:
   ```powershell
   wsl --install
   ```
3. Restart your computer
4. Open Ubuntu from the Start menu
5. Complete the initial setup (create username and password)

### Step 2: Clone and Setup
1. Open Ubuntu WSL terminal
2. Clone the repository:
```bash
git clone https://github.com/laveshparyani/GalaxyERP.git
cd GalaxyERP
```
3. Make scripts executable:
   ```bash
   # In PowerShell:
   wsl -d Ubuntu chmod +x setup.sh create_site.sh
   ```
4. Run the setup script:
   ```bash
   ./setup.sh
   ```
   This will:
   - Update system packages
   - Install all required dependencies
   - Set up MariaDB
   - Install Node.js and Yarn
   - Install frappe-bench
   - Initialize the frappe-bench environment

### Step 3: Create Your Site
1. After setup completes:
   ```bash
   cd frappe-bench
   ../create_site.sh
   ```
2. When prompted, enter your site name (e.g., mysite.com)
3. The script will:
   - Create your site
   - Install ERPNext
   - Configure everything automatically

### Step 4: Start the Server
```bash
# In the frappe-bench directory:
bench start
```

### Step 5: Access Your Site
1. Open your web browser
2. Go to: `http://your-site-name:8000`
3. Complete the initial setup wizard in the browser

## Prerequisites

### For Windows Users
- Windows 10 version 2004 or higher
- WSL2 with Ubuntu 20.04 or 24.04
- At least 4GB RAM
- 20GB free disk space

### For Linux Users
- Ubuntu 20.04 or 24.04 LTS
- At least 4GB RAM
- 20GB free disk space

## Manual Installation Steps (If scripts don't work)

If you encounter any issues with the automated scripts, you can follow these manual steps:

1. Update system packages:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

2. Install basic requirements:
```bash
   sudo apt-get install git python3-dev python3-setuptools python3-pip virtualenv
```

3. Install Python venv based on your Python version:
```bash
   # For Python 3.8
   sudo apt install python3.8-venv
   # For Python 3.10
   sudo apt install python3.10-venv
   ```

4. Install MariaDB:
   - For Ubuntu 24.04:
     ```bash
     sudo apt-get install apt-transport-https curl
     sudo mkdir -p /etc/apt/keyrings
     sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
     # Add MariaDB repository
     echo "# MariaDB 11.8 repository list
     X-Repolib-Name: MariaDB
     Types: deb
     URIs: https://mirror.bharatdatacenter.com/mariadb/repo/11.8/ubuntu
     Suites: noble
     Components: main main/debug
     Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp" | sudo tee /etc/apt/sources.list.d/mariadb.sources
     sudo apt-get update
     sudo apt-get install mariadb-server
     ```
   - For Ubuntu 20.04:
```bash
     sudo apt-get install software-properties-common
     sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
     sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://ftp.icm.edu.pl/pub/unix/database/mariadb/repo/10.3/ubuntu focal main'
     sudo apt update
     sudo apt install mariadb-server
     ```

5. Configure MariaDB:
```bash
   sudo mysql_secure_installation
```

6. Configure MariaDB character set:
```bash
   echo "[mysqld]
   character-set-client-handshake = FALSE
   character-set-server = utf8mb4
   collation-server = utf8mb4_unicode_ci

   [mysql]
   default-character-set = utf8mb4" | sudo tee -a /etc/mysql/my.cnf
   sudo service mysql restart
```

7. Install additional requirements:
   ```bash
   sudo apt-get install libmysqlclient-dev redis-server xvfb libfontconfig wkhtmltopdf
   ```

8. Install Node.js:
```bash
   sudo apt-get install curl
   curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
```

9. Install Yarn:
```bash
   sudo npm install -g yarn
```

10. Install frappe-bench:
```bash
    sudo -H pip3 install frappe-bench
```

11. Initialize frappe-bench:
```bash
    bench init frappe-bench --frappe-branch version-15
    ```

12. Create a new site:
    ```bash
    cd frappe-bench
    bench new-site your-site-name
    ```

13. Install ERPNext:
    ```bash
    bench get-app erpnext --branch version-13
    bench --site your-site-name install-app erpnext
    ```

14. Start the server:
```bash
    bench start
    ```

## Troubleshooting

### Common Issues and Solutions

1. **Permission Errors**
   - Make sure you're running commands in the correct directory
   - Check file permissions with `ls -la`

2. **MariaDB Installation Fails**
   - Verify your Ubuntu version: `lsb_release -a`
   - Follow the manual steps for your specific version

3. **Python-related Errors**
   - Check Python version: `python3 --version`
   - Install the correct Python venv package

4. **Node.js Installation Issues**
   - Clear npm cache: `npm cache clean -f`
   - Try installing Node.js manually

5. **Bench Start Fails**
   - Check if all services are running: `bench doctor`
   - Verify site configuration: `bench --site your-site-name show-config`

## Support

For any issues or questions, please:
1. Check the [Frappe/ERPNext documentation](https://docs.erpnext.com)
2. Create an issue in this repository
3. Contact our support team

## License

This project is licensed under the MIT License - see the LICENSE file for details.