# Contributing

## Workflow

1. Branch off the latest `master`:
   - `feature/<short-name>` for new work
   - `fix/<short-name>` for bug fixes
   - `chore/<short-name>` for maintenance
2. Keep commits small, with a clear message: `script: what changed`
   (e.g. `startup.sh: detect Ubuntu 24.04 MariaDB repo`).
3. Push the branch and open a pull request into `master`. Fill in the template,
   especially **How it was tested** (which Ubuntu version, fresh WSL or existing).
4. Merge once it has been tested. The branch is deleted automatically.

`master` is protected: no force-pushes or deletion, and changes land through pull requests.

## Testing a change

The safest test is a throw-away WSL distro:

```powershell
wsl --install -d Ubuntu-24.04
```

Then clone the repo inside it and run the script you changed end to end.
`cleanup.sh` removes everything the other scripts install.

## Rules

- **No credentials in scripts.** Passwords are prompted (`read -rsp`) or taken from the
  environment. Never hard-code them, even for local development.
- **No database dumps or site folders.** `*.sql` and `frappe-bench/` are ignored; keep it so.
- Scripts must work on Ubuntu 20.04, 22.04 and 24.04 under WSL2. Test on the version you
  changed behaviour for and say so in the PR.
- Prefer `set -e`-safe commands and check exit codes; the scripts run on other people's machines.

## Reporting issues

Use the **Bug report** or **Feature request** templates. For security problems, see
[SECURITY.md](SECURITY.md).
