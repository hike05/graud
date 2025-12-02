# Architecture

## Overview

Graud is a containerized forward proxy stack combining Draug (custom Caddy build) with CrowdSec threat protection.

```
┌─────────────────────────────────────────────────────────┐
│                        Internet                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
            ┌────────────────┐
            │   Caddy:80     │  HTTP → HTTPS redirect
            └────────┬───────┘
                     │
                     ▼
            ┌────────────────┐
            │  Caddy:443     │  TLS termination, HTTP/3
            │  (TCP + UDP)   │
            └────────┬───────┘
                     │
                     ▼
            ┌────────────────┐
            │ CrowdSec       │  IP reputation check
            │ Bouncer        │
            └────────┬───────┘
                     │
                ┌────┴────┐
                │ Blocked │ → 403 Forbidden
                └─────────┘
                     │
                     ▼ Allowed
            ┌────────────────┐
            │ Forward Proxy  │  Basic authentication
            │                │
            └────────┬───────┘
                     │
                     ▼
            ┌────────────────┐
            │  Rate Limiter  │  100 req/min per IP
            └────────┬───────┘
                     │
                     ▼
            ┌────────────────┐
            │   Upstream     │
            │   Internet     │
            └────────────────┘
```

## Components

### Draug (graud container)
- **Image**: `ghcr.io/hike05/draug:latest`
- **Base**: Custom Caddy build
- **Ports**: 80/tcp, 443/tcp, 443/udp
- **Plugins**:
  - forward_proxy (naive fork) - Chromium-style traffic camouflage
  - caddy-crowdsec-bouncer - CrowdSec integration
- **Purpose**: 
  - TLS termination with automatic HTTPS
  - HTTP/3 (QUIC) support
  - NaiveProxy-compatible forward proxy
  - Traffic masquerading as regular HTTPS
  - CrowdSec threat protection
  - Access logging

### CrowdSec (crowdsec container)
- **Image**: `crowdsecurity/crowdsec:latest`
- **Purpose**:
  - Real-time threat detection
  - IP reputation management
  - Collaborative security intelligence
  - Decision engine for blocking malicious IPs

### Network Flow

1. **Client Request** → Caddy receives connection on port 443
2. **TLS Handshake** → Caddy terminates TLS, validates certificate
3. **CrowdSec Check** → Bouncer queries LAPI for IP reputation
4. **Authentication** → Basic auth validates proxy credentials
5. **Rate Limiting** → Checks request rate per IP
6. **Proxy** → Forwards request to upstream destination
7. **Logging** → Records access in JSON format

## Data Persistence

### Volumes

- `caddy_data` - Caddy data directory (certificates, etc.)
- `caddy_config` - Caddy configuration cache
- `./crowdsec/config` - CrowdSec configuration files
- `./crowdsec/data` - CrowdSec database and decisions
- `/var/log/graud` - Access logs

### Important Files

- `.env` - Environment configuration (secrets)
- `Caddyfile` - Caddy server configuration
- `crowdsec/data/crowdsec.db` - CrowdSec SQLite database
- `crowdsec/config/local_api_credentials.yaml` - LAPI credentials

## Security Model

### Defense Layers

1. **Network**: Firewall rules (ports 80, 443 only)
2. **Application**: CrowdSec IP filtering
3. **Authentication**: Basic auth for proxy access
4. **Rate Limiting**: Per-IP request throttling
5. **TLS**: Modern cipher suites (TLS 1.2+)

### Threat Protection

- **Brute Force**: CrowdSec detects and blocks
- **DDoS**: Rate limiting + CrowdSec scenarios
- **Scanning**: Automated threat detection
- **Known Threats**: CrowdSec community blocklists

## Configuration

### Environment Variables

All sensitive configuration is stored in `.env`:

- `DOMAIN` - Public domain name
- `EMAIL` - Let's Encrypt contact
- `NAIVE_USER` - Proxy username
- `NAIVE_PASS` - Proxy password
- `BOUNCER_KEY` - CrowdSec API key

### Caddy Configuration

The `Caddyfile` defines:

- Global options (order directives)
- CrowdSec integration
- TLS settings
- Forward proxy configuration
- Rate limiting rules
- Logging format

### CrowdSec Configuration

Located in `./crowdsec/config/`:

- `config.yaml` - Main configuration
- `acquis.yaml` - Log sources
- `profiles.yaml` - Decision profiles
- Collections, parsers, scenarios in subdirectories

## Monitoring

### Health Checks

- **CrowdSec**: `cscli version` every 10s
- **Caddy**: Depends on CrowdSec health

### Metrics

- Caddy metrics endpoint: `localhost:2019/metrics`
- CrowdSec metrics: `cscli metrics`

### Logs

- **Access logs**: `/var/log/graud/access.log` (JSON)
- **Caddy logs**: `docker compose logs graud`
- **CrowdSec logs**: `docker compose logs crowdsec`

## Scalability

### Horizontal Scaling

To scale behind a load balancer:

1. Deploy multiple instances
2. Share CrowdSec LAPI endpoint
3. Use same `BOUNCER_KEY` across instances
4. Sync certificates via shared volume or cert manager

### Vertical Scaling

Resource limits can be added to `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
```

## Backup Strategy

### Critical Data

1. **CrowdSec Database**: `./crowdsec/data/crowdsec.db`
2. **Configuration**: `.env`, `Caddyfile`, `./crowdsec/config/`
3. **Certificates**: `caddy_data` volume (auto-renewed)

### Backup Command

```bash
tar -czf graud-backup-$(date +%Y%m%d).tar.gz \
  .env Caddyfile docker-compose.yml \
  crowdsec/config/ crowdsec/data/crowdsec.db
```

## Disaster Recovery

1. Restore configuration files
2. Run `./install.sh` or `docker compose up -d`
3. CrowdSec will rebuild from database
4. Caddy will request new certificates if needed

## Component Licenses

This project integrates multiple open-source components. Please review their respective licenses:

- [Caddy](https://github.com/caddyserver/caddy) - Apache 2.0
- [CrowdSec](https://github.com/crowdsecurity/crowdsec) - MIT
- [forward_proxy](https://github.com/caddyserver/forwardproxy) - Apache 2.0
- [caddy-crowdsec-bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) - MIT
