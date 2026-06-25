#!/usr/bin/env bash
set -euo pipefail
EMAIL="${IMMICH_ADMIN_EMAIL:-admin@immich.test}"; PASS="${IMMICH_ADMIN_PASSWORD:-password}"
# First run creates the admin; subsequent runs 400 (ignored).
curl -sf -m 10 -X POST http://localhost:2285/api/auth/admin-sign-up \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"name\":\"Admin\"}" >/dev/null 2>&1 || true
curl -sf -m 10 -X POST http://localhost:2285/api/auth/login \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['accessToken'])"
