#!/usr/bin/env bash
set -euo pipefail

if [[ "${CONFIRM_VPS_RELEASE:-}" != "yes" ]]; then
  echo "Refusing VPS release: set CONFIRM_VPS_RELEASE=yes in an approved release workflow." >&2
  exit 64
fi

: "${VPS_HOST:?VPS_HOST is required}"
: "${VPS_DEPLOY_USER:?VPS_DEPLOY_USER is required}"
: "${VPS_ROOT:?VPS_ROOT is required}"

VPS_PORT="${VPS_PORT:-22}"
RELEASE_ID="${RELEASE_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REMOTE="${VPS_DEPLOY_USER}@${VPS_HOST}"

if [[ ! "$VPS_PORT" =~ ^[0-9]+$ ]]; then
  echo "VPS_PORT must be numeric." >&2
  exit 64
fi
if [[ ! "$VPS_ROOT" =~ ^/[A-Za-z0-9._/-]+$ ]]; then
  echo "VPS_ROOT must be an absolute, space-free path." >&2
  exit 64
fi
if [[ ! "$RELEASE_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "RELEASE_ID contains unsupported characters." >&2
  exit 64
fi

cd "$REPO_ROOT"
node ops/vps/scripts/preflight.mjs

ssh -p "$VPS_PORT" "$REMOTE" "install -d -m 0755 '${VPS_ROOT}/releases/${RELEASE_ID}' '${VPS_ROOT}/shared'"

tar \
  --exclude='.git' \
  --exclude='ops/vps' \
  --exclude='.github' \
  -czf - \
  CNAME README.md aure coreweaver-labs googlef40b1c9053cf9205.html index.html llms.txt robots.txt schema.json sitemap.xml \
  | ssh -p "$VPS_PORT" "$REMOTE" "tar -xzf - -C '${VPS_ROOT}/releases/${RELEASE_ID}'"

ssh -p "$VPS_PORT" "$REMOTE" "
  test -f '${VPS_ROOT}/releases/${RELEASE_ID}/index.html' &&
  ln -sfn '${VPS_ROOT}/releases/${RELEASE_ID}' '${VPS_ROOT}/current' &&
  find '${VPS_ROOT}/releases' -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r | tail -n +6 | xargs -r -I{} rm -rf '${VPS_ROOT}/releases/{}'
"

echo "Released ${RELEASE_ID} to ${REMOTE}:${VPS_ROOT}/current"
