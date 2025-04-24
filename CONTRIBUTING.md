# Contributing to GalaxyERP

Thank you for your interest in contributing to GalaxyERP! We welcome contributions from the community to help make this project better.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/GalaxyERP.git
   ```
3. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

1. Follow the setup instructions in the README.md file
2. Make sure all tests pass before making changes
3. Create a custom app for your modifications:
   ```bash
   bench new-app galaxyerp_custom
   ```

## Making Changes

1. Keep your changes focused and atomic
2. Follow the existing code style and conventions
3. Write clear, descriptive commit messages
4. Add tests for new features
5. Update documentation as needed

## Code Style Guidelines

- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use type hints where appropriate

## Testing

1. Run existing tests:
   ```bash
   bench --site your-site run-tests
   ```
2. Add new tests for your features
3. Ensure all tests pass before submitting

## Submitting Changes

1. Push your changes to your fork
2. Create a Pull Request (PR) to the main repository
3. Describe your changes in detail
4. Reference any related issues
5. Wait for review and address any feedback

## Additional Guidelines

- Don't modify core ERPNext files directly
- Use custom apps for modifications
- Document all customizations
- Create backups before major changes
- Follow version control best practices

## Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Give credit where it's due
- Report unacceptable behavior

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Questions about the codebase
- Contribution clarifications

Thank you for contributing to GalaxyERP! 