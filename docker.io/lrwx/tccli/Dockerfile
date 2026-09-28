ARG BASE_TAG="runtime"
FROM lrwx/uv-nvm:${BASE_TAG}

COPY <<-EOF /usr/local/bin/tccli
#!/usr/bin/env sh
exec uvx tccli $@
EOF
RUN uv pip install --system tccli && chmod a+x /usr/local/bin/tccli
VOLUME [ "/root/.tccli" ]

ENV UACME_VERBOSE="2" UACME_TYPE="dns-01"
RUN <<-EOF
set -eu
. /etc/os-release
if [ "${VERSION_CODENAME}"]; then
    apt-get install uacme
else
    apt-get install -t "${VERSION_CODENAME}-backports" uacme
fi
EOF
VOLUME [ "/etc/ssl/uacme" ]

COPY <<EOF /usr/local/bin/uacme-hook.sh
#!/usr/bin/env sh

extract_record_info() {
    local domain="$1"
    domain="${domain#_acme-challenge.}"

    # Zone is everything after the first dot (last part)
    ZONE="${domain##*.}"

    # Record name is everything before the zone
    # Handle wildcard (*) and empty record name (@)
    if [[ "$domain" == "*.$ZONE" ]]; then
        RECORD_NAME="*"
    elif [[ "$domain" == "$ZONE" ]]; then
        RECORD_NAME="@"
    else
        RECORD_NAME="${domain%.*$ZONE}"
    fi
}

# ── Helper: find TXT record by name ────────────────────────────────────────
# Find existing TXT record by domain name
find_record() {
    local domain="$1"

    extract_record_info "$domain"

    # List TXT records for the zone
    local result
    result="$(tccli dnspod DescribeRecordList \
        --secret-id "$TENCENTCLOUD_SECRET_ID" \
        --secret-key "$TENCENTCLOUD_SECRET_KEY" \
        --region "$TENCENTCLOUD_REGION" \
        --domain "$ZONE" \
        --record-type TXT \
        --offset 0 \
        --limit 100 2>/dev/null)"

    if [ -z "$result" ]; then
        echo ""
        return
    fi

    # Parse JSON to find matching record
    # Handle wildcard (*) records by matching the exact record name
    echo "$result" | jq -r '.Response.RecordList[] | select(.RecordName == "'"$RECORD_NAME"'") | .RecordId' 2>/dev/null | head -n1
}

# ── Helper: create or update TXT record ─────────────────────────────────────
# Creates new or updates existing TXT record
ensure_record() {
    local domain="$1"
    local value="$2"
    local ttl="${TENCENTCLOUD_TTL:-600}"

    extract_record_info "$domain"

    local record_id
    record_id="$(find_record "$domain")"

    if [ -n "$record_id" ]; then
        # Update existing record
        tccli dnspod ModifyRecord \
            --secret-id "$TENCENTCLOUD_SECRET_ID" \
            --secret-key "$TENCENTCLOUD_SECRET_KEY" \
            --region "$TENCENTCLOUD_REGION" \
            --domain "$ZONE" \
            --record-id "$record_id" \
            --record-name "$RECORD_NAME" \
            --record-type TXT \
            --record-value "$value" \
            --record-ttl "$ttl" \
            --record-line "Default" 2>/dev/null
    else
        # Create new record
        tccli dnspod CreateRecord \
            --secret-id "$TENCENTCLOUD_SECRET_ID" \
            --secret-key "$TENCENTCLOUD_SECRET_KEY" \
            --region "$TENCENTCLOUD_REGION" \
            --domain "$ZONE" \
            --record-name "$RECORD_NAME" \
            --record-type TXT \
            --record-value "$value" \
            --record-ttl "$ttl" \
            --record-line "Default" 2>/dev/null
    fi
}

# ── Helper: delete TXT record ──────────────────────────────────────────────
# Deletes TXT record by domain name
delete_record() {
    local domain="$1"

    extract_record_info "$domain"

    local record_id
    record_id="$(find_record "$domain")"

    if [ -n "$record_id" ]; then
        tccli dnspod DeleteRecord \
            --secret-id "$TENCENTCLOUD_SECRET_ID" \
            --secret-key "$TENCENTCLOUD_SECRET_KEY" \
            --region "$TENCENTCLOUD_REGION" \
            --domain "$ZONE" \
            --record-id "$record_id" 2>/dev/null
    fi
}

# ── Main DNS-01 challenge handling ─────────────────────────────────────────
case "$1" in
    "begin")
        case "$2" in
            "dns-01")
                local ident="$3"
                local token="$4"
                local auth="$5"
                local domain="_acme-challenge.$ident"

                ensure_record "$domain" "$auth"
                return $?
                ;;
            *)
                echo "Unsupported record type: $2" >&2
                exit 1
                ;;
        esac
        ;;

    "done"|"failed")
        case "$2" in
            "dns-01")
                local ident="$3"
                local token="$4"
                local auth="$5"
                local domain="_acme-challenge.$ident"

                delete_record "$domain"
                return $?
                ;;
            *)
                echo "Unsupported record type: $2" >&2
                exit 1
                ;;
        esac
        ;;

    *)
        echo "Usage: $0 {begin|done|failed} type ident token auth" >&2
        exit 1
        ;;
esac
EOF
RUN chmod a+x /usr/local/bin/uacme-hook.sh


## Simple test for current release - verify tccli is accessible via uvx
#RUN set -eu; \
#    echo "Testing tccli via uvx..."; \
#    uvx tccli --version 2>/dev/null || echo "tccli version check completed"

## Copy certificate issuance and renewal scripts
#COPY issue-renew.sh /app/issue-renew.sh
#RUN chmod +x /app/issue-renew.sh

## Copy test script
#COPY test-cert-issue.sh /app/test-cert-issue.sh
#RUN chmod +x /app/test-cert-issue.sh

## Copy environment example
#COPY .env.example /app/.env.example

## Working directory
#WORKDIR /app

## Default command
#CMD ["/app/issue-renew.sh"]
