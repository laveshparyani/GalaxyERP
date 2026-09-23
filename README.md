# GalaxyERP – Frappe/ERPNext setup scripts for WSL

Bash scripts that take a fresh Ubuntu on **Windows Subsystem for Linux (WSL2)** to a working
Frappe/ERPNext development bench: system packages, MariaDB (with the right charset), Node and
Yarn, `frappe-bench`, a bench with ERPNext, and a site. A menu-driven `startup.sh` handles
fresh installs and existing benches; `cleanup.sh` removes everything again.

They also work on native Ubuntu 20.04, 22.04 and 24.04.

> This repo contains **only the setup scripts**. The GalaxyERP custom app lives in the
> [GalaxyNext](https://github.com/laveshparyani/GalaxyNext) repository.

## Scripts

| Script | What it does |
|---|---|
| `setup.sh` | One-shot install of all dependencies: apt packages, MariaDB (version picked by Ubuntu release), Redis, Node 18 + Yarn, wkhtmltopdf, `frappe-bench`, then `bench init`. |
| `startup.sh` | Interactive menu. **1** Fresh installation (everything from scratch, creates site `GalaxyERP.com` with ERPNext). **2** Continue with an existing bench (update and start). |
| `create_site.sh` | Small menu to list sites, create a new site, or get and install an app on a site. |
| `cleanup.sh` | Removes MariaDB, Redis, Node, the bench and related files. Use it to start over. |

Passwords are **never** stored in the scripts. `startup.sh` prompts for the MariaDB root
password and the site's Administrator password, or reads them from the environment for
unattended runs:

```bash
MARIADB_ROOT_PASSWORD='...' ADMIN_PASSWORD='...' ./startup.sh
```

## Quick start

1. **Install WSL** (PowerShell as Administrator), then restart and open Ubuntu from the Start menu:
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
2. **Clone and run** inside the Ubuntu terminal:
   ```bash
   git clone https://github.com/laveshparyani/GalaxyERP.git
   cd GalaxyERP
   chmod +x *.sh
   ./setup.sh
   ```
3. **Create a site** (or use `startup.sh` option 1, which does this for you):
   ```bash
   cd frappe-bench
   ../create_site.sh
   ```
4. **Start** the bench and open `http://<your-site>:8000` in a browser:
   ```bash
   bench start
   ```

## Requirements

- Windows 10 2004+ or Windows 11 with WSL2, or native Ubuntu 20.04 / 22.04 / 24.04
- 4 GB RAM and 20 GB free disk, minimum
- Internet access for apt, pip, npm and GitHub

## Manual installation

If a script fails on your machine, the steps it automates are the standard ones from the
[Frappe installation guide](https://frappeframework.com/docs/user/en/installation):
install `python3-dev`, `mariadb-server`, `redis-server`, `wkhtmltopdf`, Node 18 and Yarn;
set MariaDB to `utf8mb4` in `/etc/mysql/my.cnf`; `pip install frappe-bench`;
`bench init frappe-bench --frappe-branch version-15`; `bench new-site`; `bench get-app erpnext`
and `bench --site <site> install-app erpnext`.

## Troubleshooting

- **MariaDB install fails:** check `lsb_release -a`; the scripts pick the MariaDB repo by
  Ubuntu version. On 24.04 they add the MariaDB 11.x repository.
- **`bench` not found after install:** `frappe-bench` is installed with pipx into
  `~/.local/bin`. Open a new terminal or `source ~/.bashrc`.
- **Permission errors:** run the scripts as your normal user, not with `sudo`; they call `sudo`
  themselves where needed.
- **Starting over:** `./cleanup.sh`, then `./setup.sh`.

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md). Report security issues privately as
described in [SECURITY.md](.github/SECURITY.md).

## License

[MIT](LICENSE) © 2025 Lavesh Paryani
