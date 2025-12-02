# Quick Start Guide

Get Graud running in under 5 minutes.

## Prerequisites

- Linux server with public IP
- Docker and Docker Compose installed
- Domain name pointing to your server
- Ports 80 and 443 open in firewall

## Installation

```bash
git clone https://github.com/hike05/graud.git
cd graud
./install.sh
```

Follow the prompts:
- **Domain**: Your public domain (e.g., `proxy.example.com`)
- **Email**: Valid email for Let's Encrypt
- **Username**: Proxy authentication username
- **Password**: Strong password for proxy access

The installer will:
1. Validate Docker environment
2. Create configuration
3. Deploy containers
4. Generate CrowdSec API key
5. Start all services

## Verification

Check services are running:
```bash
docker compose ps
```

Verify CrowdSec bouncer:
```bash
docker exec crowdsec cscli bouncers list
```

Test HTTP redirect:
```bash
curl -I http://your-domain.com
```

## Client Setup

### Download NaiveProxy

Get the latest release: https://github.com/klzgrad/naiveproxy/releases

### Configure Client

Create `config.json`:
```json
{
  "listen": ["socks://127.0.0.1:1080", "http://127.0.0.1:8080"],
  "proxy": "https://username:password@your-domain.com:443",
  "log": ""
}
```

### Run Client

```bash
./naive config.json
```

### System Proxy Setup

**macOS:**
```bash
networksetup -setwebproxy "Wi-Fi" 127.0.0.1 8080
networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 8080
```

**Linux:**
```bash
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
```

**Windows:**
Settings → Network → Proxy → Manual proxy setup
- HTTP: 127.0.0.1:8080
- HTTPS: 127.0.0.1:8080

## Next Steps

- Review logs: `docker compose logs -f`
- Monitor threats: `docker exec crowdsec cscli decisions list`
- Check metrics: `docker exec crowdsec cscli metrics`
- Read full documentation: [README.md](README.md)

## Troubleshooting

**Services not starting?**
```bash
docker compose logs
```

**SSL certificate issues?**
- Verify DNS is pointing to your server
- Check email is valid (not example.com)
- Wait a few minutes for Let's Encrypt validation

**Can't connect to proxy?**
- Verify credentials in `.env`
- Check firewall allows port 443
- Review Caddy logs: `docker compose logs graud`

## Support

- Documentation: [README.md](README.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Issues: [GitHub Issues](https://github.com/hike05/graud/issues)
