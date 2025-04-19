# GalaxyERP

A powerful cloud-based ERP solution built on Frappe/ERPNext, offering production management, warehouse systems, GST integration, and financial reporting. With 12+ years of experience and 90%+ customer satisfaction, it delivers innovative, scalable solutions for modern businesses.

## Features
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
- Python
- MariaDB
- Redis
- Node.js

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

5. Install GalaxyERP:
```bash
bench get-app https://github.com/laveshparyani/GalaxyERP.git
bench --site galaxyerp.local install-app galaxyerp
```

6. Start the development server:
```bash
bench start
```

## Contributing
Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License
This project is licensed under the MIT License - see the LICENSE.md file for details. 