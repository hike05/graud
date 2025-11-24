# GRAUD

Gateway Routing And Unified Defense - Production-ready proxy server.

## Quick Start

```bash
cp .env.example .env
# Edit .env with your settings
docker compose up -d
```

## Configuration

Edit `.env`:
- `DOMAIN` - Your domain
- `NAIVE_USER` - Proxy username
- `NAIVE_PASS` - Proxy password
- `EMAIL` - Email for Let's Encrypt

## Features

- Forward proxy with naive protocol 
- Rate limiting 
- Layer 4 support
- HTTP/3 ready
- Auto TLS via Let's Encrypt
- Probe resistance

## Client Setup

Use any naive protocol compatible client with:
- Server: `https://your-domain.com:443`
- Username: from `NAIVE_USER`
- Password: from `NAIVE_PASS`

## Based On

Built with [draug](https://github.com/hike05/draug) - custom Caddy image with plugins.
