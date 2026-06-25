#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo "Building Immich server from source + starting (this is slow)..."
docker compose -f docker-compose.yml up -d --build
echo "Waiting for server health (up to 5 min)..."
for i in $(seq 1 100); do
  if curl -sf -m 3 http://localhost:2285/api/server/ping | grep -q pong; then
    echo "SUT healthy"
    # Last stdout line: hand the testbot the base URL so its built-in ready
    # check and test execution target the e2e port (2285), independent of
    # whatever the generated workspace.yml guessed.
    echo '{"baseUrl":"http://localhost:2285"}'
    exit 0
  fi
  sleep 3
done
echo "SUT failed to become healthy"; docker compose logs --tail 80; exit 1
