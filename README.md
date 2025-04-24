# GalaxyERP

A powerful cloud-based ERP solution built on Frappe/ERPNext, designed for modern businesses. GalaxyERP extends ERPNext's capabilities with enhanced features for production management, warehouse systems, and financial operations, with special focus on Indian GST compliance.

## Key Features
- Multiple Production Houses Management
- Advanced Warehouse Management System
- Production Process Definition
- Job Work Management
- Financial Reporting System
- Enhanced Inventory Management
- GST Integration (GSTR-1, GSTR-2, GSTR-3B)
- E-Way Bill Generation
- Auto SMS Notifications
- Credit Limit Management
- Customized GST Invoicing
- Bank Reconciliation
- Third-party Application Integration
- Chatbot Integration

## Technology Stack
- Frappe Framework
- ERPNext
- Python 3.x
- MariaDB 10.x
- Redis 6.x
- Node.js 16.x

## Prerequisites
- Python 3.x
- Node.js 16.x or higher
- Redis
- MariaDB/MySQL
- Git

## Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/laveshparyani/GalaxyERP.git
cd GalaxyERP
```

2. Install Frappe Bench:
```bash
pip install frappe-bench
```

3. Initialize a new bench:
```bash
bench init frappe-bench
cd frappe-bench
```

4. Create a new site:
```bash
bench new-site galaxyerp.local
```

5. Install ERPNext (if not already installed):
```bash
bench get-app erpnext
bench --site galaxyerp.local install-app erpnext
```

6. Install GalaxyERP:
```bash
bench get-app galaxyerp
bench --site galaxyerp.local install-app galaxyerp
```

7. Start the development server:
```bash
bench start
```

## Configuration

### Site Configuration
1. Set up your site configuration in `sites/galaxyerp.local/site_config.json`
2. Configure email settings in the ERPNext interface
3. Set up GST credentials in GalaxyERP settings

### Custom App Development
To customize GalaxyERP, create a custom app:
```bash
bench new-app galaxyerp_custom
bench --site galaxyerp.local install-app galaxyerp_custom
```

## Development Guidelines

1. Never modify core ERPNext or GalaxyERP files directly
2. Use custom apps for all modifications
3. Follow PEP 8 coding standards for Python
4. Document all customizations
5. Write tests for new features
6. Create backups before major changes

## Contributing
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## Support
- For bugs and feature requests, please create an issue
- For quick questions, use the discussions section
- For commercial support, contact our team

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- ERPNext Community
- Frappe Framework Team
- All our contributors and users 