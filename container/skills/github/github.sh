#!/bin/bash
# GitHub API helper for NanoClaw containers.
# Reads PAT from mounted config and calls GitHub REST API via curl.
#
# Usage:
#   github.sh <method> <endpoint> [body_json]
#
# Examples:
#   github.sh GET /user
#   github.sh GET /user/repos?per_page=5
#   github.sh GET /repos/owner/repo/issues?state=open
#   github.sh POST /repos/owner/repo/issues '{"title":"Bug","body":"Details"}'
#   github.sh PATCH /repos/owner/repo/issues/1 '{"state":"closed"}'

set -euo pipefail

TOKEN_FILE="${GITHUB_TOKEN_FILE:-/home/node/.config/github/token}"
API_BASE="https://api.github.com"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "Error: GitHub token not found at $TOKEN_FILE" >&2
  exit 1
fi

TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')

if [ $# -lt 2 ]; then
  echo "Usage: github.sh <METHOD> <endpoint> [body_json]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  github.sh GET /user" >&2
  echo "  github.sh GET /repos/owner/repo/pulls" >&2
  echo "  github.sh POST /repos/owner/repo/issues '{\"title\":\"Bug\"}'" >&2
  exit 1
fi

METHOD="$1"
ENDPOINT="$2"
BODY="${3:-}"

# Build URL — support full URLs or relative paths
if [[ "$ENDPOINT" == http* ]]; then
  URL="$ENDPOINT"
else
  URL="${API_BASE}${ENDPOINT}"
fi

CURL_ARGS=(-s -X "$METHOD" "$URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28")

if [ -n "$BODY" ] && [ "$METHOD" != "GET" ]; then
  CURL_ARGS+=(-H "Content-Type: application/json" -d "$BODY")
fi

RESPONSE=$(curl "${CURL_ARGS[@]}")
echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
