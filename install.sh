#!/bin/bash
set -e

echo "================================"
echo "Graud Installer"
echo "Draug + CrowdSec Forward Proxy"
echo "================================"
echo ""

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Install: https://docs.docker.com/compose/install/"
    exit 1
fi

DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
fi

echo "✅ Docker environment validated"
echo ""

read -p "Domain (e.g., proxy.example.com): " DOMAIN
read -p "Email for Let's Encrypt: " EMAIL
read -p "Proxy username: " NAIVE_USER
read -sp "Proxy password: " NAIVE_PASS
echo ""
echo ""

echo "📝 Generating configuration..."
cat > .env << EOF
DOMAIN=${DOMAIN}
EMAIL=${EMAIL}
NAIVE_USER=${NAIVE_USER}
NAIVE_PASS=${NAIVE_PASS}
BOUNCER_KEY=
EOF

echo "✅ Configuration saved to .env"
echo ""

echo "🚀 Deploying containers..."
$DOCKER_COMPOSE up -d

echo ""
echo "⏳ Waiting for CrowdSec..."

RETRY=0
MAX_RETRIES=30
until docker inspect crowdsec --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; do
    if [ $RETRY -ge $MAX_RETRIES ]; then
        echo "❌ CrowdSec health check timeout"
        exit 1
    fi
    sleep 2
    RETRY=$((RETRY + 1))
done

echo "✅ CrowdSec ready"
sleep 3

echo "🔑 Generating bouncer API key..."

docker exec crowdsec cscli bouncers delete graud-bouncer 2>/dev/null || true

BOUNCER_KEY_RAW=$(docker exec crowdsec cscli bouncers add graud-bouncer -o raw 2>&1)

if echo "$BOUNCER_KEY_RAW" | grep -q "Error"; then
    BOUNCER_KEY=""
else
    BOUNCER_KEY=$(echo "$BOUNCER_KEY_RAW" | tr -d '%\n\r ' | head -c 100)
fi

if [ -z "$BOUNCER_KEY" ]; then
    echo "⚠️  Auto-generation failed. Manual steps:"
    echo "  docker exec crowdsec cscli bouncers add graud-bouncer -o raw"
    echo "  Add key to .env: BOUNCER_KEY=<generated_key>"
    echo "  Restart: $DOCKER_COMPOSE restart graud"
else
    BOUNCER_KEY_ESCAPED=$(echo "$BOUNCER_KEY" | sed 's/[\/&+]/\\&/g')
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/BOUNCER_KEY=.*/BOUNCER_KEY=${BOUNCER_KEY_ESCAPED}/" .env
    else
        sed -i "s/BOUNCER_KEY=.*/BOUNCER_KEY=${BOUNCER_KEY_ESCAPED}/" .env
    fi
    
    echo "✅ Bouncer key configured"
    echo ""
    
    echo "🔄 Restarting proxy..."
    $DOCKER_COMPOSE up -d graud
    sleep 3
fi

echo ""
echo "================================"
echo "✅ Installation Complete"
echo "================================"
echo ""
echo "Services:"
$DOCKER_COMPOSE ps
echo ""
echo "Proxy endpoint: https://${DOMAIN}"
echo "Username: ${NAIVE_USER}"
echo ""
echo "Verify bouncer:"
echo "  docker exec crowdsec cscli bouncers list"
echo ""
echo "View logs:"
echo "  $DOCKER_COMPOSE logs -f"
echo ""
