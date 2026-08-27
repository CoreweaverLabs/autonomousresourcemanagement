#!/usr/bin/env bash
set -euo pipefail

: "${PUBLIC_URL:?PUBLIC_URL is required, e.g. https://field-systems.example.com}"
HEALTHCHECK_PATHS="${HEALTHCHECK_PATHS:-/}"
MAX_TIME_SECONDS="${MAX_TIME_SECONDS:-20}"

if [[ ! "$PUBLIC_URL" =~ ^https:// ]]; then
  echo "PUBLIC_URL must use HTTPS." >&2
  exit 64
fi
if [[ ! "$MAX_TIME_SECONDS" =~ ^[0-9]+$ ]]; then
  echo "MAX_TIME_SECONDS must be numeric." >&2
  exit 64
fi

base="${PUBLIC_URL%/}"
for path in $HEALTHCHECK_PATHS; do
  response="$(curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 --max-time "$MAX_TIME_SECONDS" --write-out ' status=%{http_code} total=%{time_total}s' --output /dev/null "${base}${path}")"
  echo "${base}${path}${response}"
done
