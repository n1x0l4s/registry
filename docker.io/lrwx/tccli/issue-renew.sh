#!/bin/bash

set -euo pipefail

# ── Configuration defaults ──────────────────────────────────────────────────
export TENCENTCLOUD_REGION="${TENCENTCLOUD_REGION:-ap-guangzhou}"
export TENCENTCLOUD_TTL="${TENCENTCLOUD_TTL:-600}"
export TENCENTCLOUD_POLLING_INTERVAL="${TENCENTCLOUD_POLLING_INTERVAL:-2}"
export TENCENTCLOUD_PROPAGATION_TIMEOUT="${TENCENTCLOUD_PROPAGATION_TIMEOUT:-60}"

# ── Validate required env vars ──────────────────────────────────────────────
if [ -z "${TENCENTCLOUD_SECRET_ID:-}" ] || [ -z "${TENCENTCLOUD_SECRET_KEY:-}" ]; then
    echo "ERROR: TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY must be set" >&2
    exit 1
fi

# ── Paths ───────────────────────────────────────────────────────────────────
CERT_DIR="/etc/headscale"
FULLCHAIN="$CERT_DIR/cert.crt"
PRIVKEY="$CERT_DIR/cert.key"

# ── Ensure uacme is installed ─────────────────────────────────────────────
if ! command -v uacme &> /dev/null; then
    echo "Installing uacme..."
    . /etc/os-release
    if [ "${VERSION_CODENAME}" ]; then
        apt-get update && apt-get install -y uacme
    else
        apt-get update && apt-get install -y -t "${VERSION_CODENAME}-backports" uacme
    fi
fi

# ── Issue or renew certificates ─────────────────────────────────────────────
# We use uacme directly with our custom hook script
# The hook uses tccli to create/delete TXT records in DNSPod

echo "Issuing/renewing certificates for example.com and *.example.com..."

# Create certificate directory
mkdir -p "$CERT_DIR"

# Issue certificates for each domain with wildcard support
for domain in "cn"; do
    echo "Processing $domain..."

    # Remove existing certificate if any
    rm -f "$FULLCHAIN" "$PRIVKEY"

    # Issue certificate using uacme with our custom hook
    uacme issue \
        --domain "$domain" \
        --key-file "$PRIVKEY" \
        --fullchain-file "$FULLCHAIN" \
        --hook "/usr/local/bin/uacme-hook.sh" \
        --contact "mailto:admin@example.com" \
        --server "https://acme-v02.api.letsencrypt.org/directory" \
        --must-staple \
        --eab-kid "" \
        --eab-hmac-key "" \
        --verbose \
        --wait 30 \
        --max-tries 5 \
        --ca-file "$CERT_DIR/cert.ca" \
        --reloadcmd "docker compose -f /etc/headscale/docker-compose.yml restart nginx"

    if [ $? -ne 0 ]; then
        echo "ERROR: uacme issuance failed for $domain" >&2
        exit 1
    fi

    echo "Certificate issued successfully for $domain"

    # Verify the certificate
    if [ -f "$FULLCHAIN" ]; then
        echo "Verifying certificate..."
        openssl x509 -in "$FULLCHAIN" -noout -subject -issuer -dates 2>/dev/null || true
        echo "Certificate verification complete."
    fi

done

echo "All certificates issued successfully."
echo "Certificate installed to $FULLCHAIN and $PRIVKEY"
echo "Nginx will be reloaded automatically."

echo "Done."
