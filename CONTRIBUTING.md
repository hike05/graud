# Contributing to Graud

Thank you for your interest in contributing to Graud!

## Development Setup

1. Fork and clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/graud.git
cd graud
```

2. Create a feature branch:
```bash
git checkout -b feature/your-feature
```

3. Make your changes

4. Test locally:
```bash
./install.sh
```

5. Commit with clear messages:
```bash
git commit -m "Add: feature description"
```

6. Push and create a pull request:
```bash
git push origin feature/your-feature
```

## Testing

Before submitting, verify your changes:

```bash
# Clean environment
docker compose down -v
rm -f .env

# Test installation
./install.sh

# Verify services
docker compose ps
docker exec crowdsec cscli bouncers list
docker compose logs graud | grep "started"

# Test HTTP redirect
curl -I http://localhost

# Check CrowdSec integration
docker exec crowdsec cscli metrics
```

## Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing formatting conventions
- Keep shell scripts POSIX-compatible where possible
- Use 4 spaces for indentation in shell scripts
- Use 2 spaces for YAML files

## Pull Request Guidelines

Your PR should:
- Have a clear description of what it does
- Reference any related issues
- Include testing steps
- Update documentation if needed
- Pass all existing tests

### PR Title Format

- `Add: new feature description`
- `Fix: bug description`
- `Update: component/documentation description`
- `Refactor: code improvement description`

## Reporting Issues

When reporting bugs, include:

- Operating system and version
- Docker and Docker Compose versions
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs: `docker compose logs`
- Configuration (sanitized, no secrets)

### Issue Template

```markdown
**Environment:**
- OS: 
- Docker version: 
- Docker Compose version: 

**Description:**
Brief description of the issue

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Logs:**
```
Paste relevant logs here
```
```

## Documentation

When updating documentation:

- Use clear, concise language
- Include code examples where helpful
- Update all relevant files (README, ARCHITECTURE, etc.)
- Check for broken links
- Verify commands work as documented

## Security

**Do not open public issues for security vulnerabilities.**

Report security issues privately by:
1. Opening a security advisory on GitHub
2. Or emailing the maintainers directly

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Component Updates

When updating components:

### Draug Image
- Test with new image version
- Update docker-compose.yml
- Document any breaking changes
- Update CHANGELOG.md

### CrowdSec
- Test compatibility with bouncer
- Update configuration if needed
- Document migration steps
- Update CHANGELOG.md

### Dependencies
- Test all functionality
- Update documentation
- Note any breaking changes

## Release Process

Maintainers follow this process for releases:

1. Update CHANGELOG.md with version and date
2. Update version references in documentation
3. Create git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release with changelog

## Questions?

- Check existing documentation
- Search closed issues
- Open a discussion on GitHub
- Join community channels (if available)

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.
