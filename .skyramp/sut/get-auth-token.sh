#!/usr/bin/env bash
set -euo pipefail

IMMICH_URL="http://localhost:2283/api"
ADMIN_EMAIL="testbot@testbot.com"
ADMIN_PASSWORD="testbotpassword1"
ADMIN_NAME="Testbot Admin"

# Wait for the server to be ready
echo "Waiting for Immich server to be ready..." >&2
timeout 300 bash -c 'until curl -sf http://localhost:2283/api/server/ping > /dev/null 2>&1; do sleep 3; done' >&2
echo "Server is ready." >&2

# Create admin user (idempotent — fails silently if already registered)
echo "Creating admin user..." >&2
curl -sf -X POST \
  "${IMMICH_URL}/auth/admin-sign-up" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\",\"name\":\"${ADMIN_NAME}\"}" \
  > /dev/null 2>&1 || echo "Admin signup skipped (user may already exist)" >&2

# Login and capture access token
echo "Logging in as admin..." >&2
TOKEN=$(curl -sf -X POST \
  "${IMMICH_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" \
  | jq -r '.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "ERROR: Failed to obtain access token" >&2
  exit 1
fi

echo "$TOKEN"
