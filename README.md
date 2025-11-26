# Graud

Production-ready forward proxy stack built on Draug (custom Caddy build) with CrowdSec threat protection.

## Stack

- **[Draug](https://github.com/hike05/draug)** - Custom Caddy build with forward_proxy, CrowdSec bouncer, and additional plugins
- **[CrowdSec](https://www.crowdsec.net/)** - Collaborative IPS with real-time threat intelligence
- **HTTP/3** - Modern protocol support with automatic HTTPS

## Quick Start

```bash
git clone https://github.com/hike05/graud.git
cd graud
./install.sh
```

The installer will:
- Validate Docker environment
- Prompt for domain, email, and credentials
- Deploy containers with health checks
- Auto-generate CrowdSec bouncer API key
- Configure and start all services

## Manual Setup

1. Configure environment:
```bash
cp .env.example .env
nano .env
```

2. Deploy stack:
```bash
docker compose up -d
```

3. Generate bouncer key:
```bash
docker exec crowdsec cscli bouncers add graud-bouncer -o raw
```

4. Update `.env` with the key and restart:
```bash
docker compose restart graud
```

## Configuration

Environment variables in `.env`:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `proxy.example.com` |
| `EMAIL` | Contact email for Let's Encrypt | `admin@example.com` |
| `NAIVE_USER` | Proxy authentication username | `user` |
| `NAIVE_PASS` | Proxy authentication password | `secure_password` |
| `BOUNCER_KEY` | CrowdSec API key (auto-generated) | `abc123...` |

## Client Configuration

Configure your proxy client to connect:

```
https://username:password@your-domain.com:443
```

Supports standard forward proxy protocols.

## Operations

**View status:**
```bash
docker compose ps
docker exec crowdsec cscli bouncers list
docker exec crowdsec cscli metrics
```

**View logs:**
```bash
docker compose logs -f graud
docker compose logs -f crowdsec
```

**Update:**
```bash
docker compose pull
docker compose up -d
```

**Manage CrowdSec:**
```bash
# View active decisions
docker exec crowdsec cscli decisions list

# Add IP to whitelist
docker exec crowdsec cscli decisions add --ip 1.2.3.4 --type ban --duration 4h

# View alerts
docker exec crowdsec cscli alerts list
```

## Architecture

```
Internet → Caddy (80/443) → Forward Proxy → Upstream
                ↓
           CrowdSec Bouncer
                ↓
           CrowdSec LAPI
```

- Draug handles TLS termination and HTTP/3
- CrowdSec bouncer blocks malicious IPs before reaching proxy
- All logs stored in `/var/log/graud`

## Production Checklist

- [ ] Use a valid domain with DNS pointing to your server
- [ ] Configure firewall to allow ports 80, 443 (TCP/UDP)
- [ ] Use strong credentials in `.env`
- [ ] Set up log rotation for `/var/log/graud`
- [ ] Monitor CrowdSec alerts regularly
- [ ] Keep Docker images updated
- [ ] Backup CrowdSec database: `./crowdsec/data/crowdsec.db`

## Troubleshooting

**Graud fails to start:**
- Check `BOUNCER_KEY` is set in `.env`
- Verify bouncer exists: `docker exec crowdsec cscli bouncers list`
- View logs: `docker compose logs graud`

**SSL certificate errors:**
- Ensure domain DNS is correctly configured
- Check email is valid (not example.com)
- For local testing, use `localhost` or add custom domain to `/etc/hosts`

**CrowdSec not blocking threats:**
- Verify bouncer is connected: `docker exec crowdsec cscli bouncers list`
- Check decisions exist: `docker exec crowdsec cscli decisions list`
- Review CrowdSec logs: `docker compose logs crowdsec`

## Documentation

- [Quick Start Guide](QUICKSTART.md)
- [Architecture Details](ARCHITECTURE.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## Components

This project uses:
- [Draug](https://github.com/hike05/draug) - Custom Caddy distribution
- [CrowdSec](https://github.com/crowdsecurity/crowdsec) - Collaborative security engine
- Docker and Docker Compose for orchestration
