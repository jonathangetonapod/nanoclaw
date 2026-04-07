#!/bin/bash
# Google Workspace API helper for NanoClaw containers.
# The native gws binary doesn't work inside node:22-slim (GLIBC mismatch),
# so this script calls Google APIs directly via curl + OAuth token refresh.
#
# Usage:
#   gws.sh <service> <action> [params_json]
#
# Examples:
#   gws.sh gmail.users.messages list '{"userId":"me","maxResults":5}'
#   gws.sh calendar.events list '{"calendarId":"primary","maxResults":10}'
#   gws.sh drive.files list '{"q":"mimeType=\"application/pdf\"","pageSize":10}'
#   gws.sh sheets.spreadsheets get '{"spreadsheetId":"SHEET_ID"}'
#   gws.sh tasks.tasklists list '{}'
#   gws.sh gmail.users.messages send '{"userId":"me"}' '{"raw":"BASE64_EMAIL"}'

set -euo pipefail

CREDS_FILE="${GWS_CREDENTIALS:-/home/node/.config/gws/credentials.json}"
TOKEN_CACHE="/tmp/gws_token_cache"

# ── Token management ─────────────────────────────────────────
get_refresh_token() {
  jq -r '.refresh_token' "$CREDS_FILE"
}

get_client_id() {
  jq -r '.client_id' "$CREDS_FILE"
}

get_client_secret() {
  jq -r '.client_secret' "$CREDS_FILE"
}

refresh_access_token() {
  local response
  response=$(curl -s -X POST https://oauth2.googleapis.com/token \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$(get_refresh_token)" \
    -d "client_id=$(get_client_id)" \
    -d "client_secret=$(get_client_secret)")

  local token
  token=$(echo "$response" | jq -r '.access_token // empty')
  if [ -z "$token" ]; then
    echo "Error refreshing token: $response" >&2
    exit 1
  fi

  echo "$token" > "$TOKEN_CACHE"
  echo "$token"
}

get_access_token() {
  # Use cached token if less than 50 minutes old
  if [ -f "$TOKEN_CACHE" ]; then
    local age
    age=$(( $(date +%s) - $(stat -c %Y "$TOKEN_CACHE" 2>/dev/null || echo 0) ))
    if [ "$age" -lt 3000 ]; then
      cat "$TOKEN_CACHE"
      return
    fi
  fi
  refresh_access_token
}

# ── API endpoint mapping ─────────────────────────────────────
# Maps service.resource.method to base URL + HTTP method + path pattern
resolve_endpoint() {
  local service="$1"
  local action="$2"

  case "$service" in
    # Gmail
    gmail.users.messages)
      case "$action" in
        list)    echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/messages" ;;
        get)     echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/messages/{id}" ;;
        send)    echo "POST https://gmail.googleapis.com/gmail/v1/users/{userId}/messages/send" ;;
        trash)   echo "POST https://gmail.googleapis.com/gmail/v1/users/{userId}/messages/{id}/trash" ;;
        modify)  echo "POST https://gmail.googleapis.com/gmail/v1/users/{userId}/messages/{id}/modify" ;;
        delete)  echo "DELETE https://gmail.googleapis.com/gmail/v1/users/{userId}/messages/{id}" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;
    gmail.users.labels)
      case "$action" in
        list)    echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/labels" ;;
        get)     echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/labels/{id}" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;
    gmail.users.drafts)
      case "$action" in
        list)    echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts" ;;
        get)     echo "GET https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/{id}" ;;
        create)  echo "POST https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts" ;;
        send)    echo "POST https://gmail.googleapis.com/gmail/v1/users/{userId}/drafts/send" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Calendar
    calendar.events)
      case "$action" in
        list)    echo "GET https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events" ;;
        get)     echo "GET https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events/{eventId}" ;;
        insert)  echo "POST https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events" ;;
        update)  echo "PUT https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events/{eventId}" ;;
        delete)  echo "DELETE https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events/{eventId}" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;
    calendar.calendarList)
      case "$action" in
        list)    echo "GET https://www.googleapis.com/calendar/v3/users/me/calendarList" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Drive
    drive.files)
      case "$action" in
        list)    echo "GET https://www.googleapis.com/drive/v3/files" ;;
        get)     echo "GET https://www.googleapis.com/drive/v3/files/{fileId}" ;;
        create)  echo "POST https://www.googleapis.com/drive/v3/files" ;;
        delete)  echo "DELETE https://www.googleapis.com/drive/v3/files/{fileId}" ;;
        export)  echo "GET https://www.googleapis.com/drive/v3/files/{fileId}/export" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Sheets
    sheets.spreadsheets)
      case "$action" in
        get)     echo "GET https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}" ;;
        create)  echo "POST https://sheets.googleapis.com/v4/spreadsheets" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;
    sheets.spreadsheets.values)
      case "$action" in
        get)     echo "GET https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}" ;;
        update)  echo "PUT https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}" ;;
        append)  echo "POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:append" ;;
        clear)   echo "POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:clear" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Docs
    docs.documents)
      case "$action" in
        get)     echo "GET https://docs.googleapis.com/v1/documents/{documentId}" ;;
        create)  echo "POST https://docs.googleapis.com/v1/documents" ;;
        batchUpdate) echo "POST https://docs.googleapis.com/v1/documents/{documentId}:batchUpdate" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Tasks
    tasks.tasklists)
      case "$action" in
        list)    echo "GET https://tasks.googleapis.com/tasks/v1/users/@me/lists" ;;
        get)     echo "GET https://tasks.googleapis.com/tasks/v1/users/@me/lists/{tasklist}" ;;
        insert)  echo "POST https://tasks.googleapis.com/tasks/v1/users/@me/lists" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;
    tasks.tasks)
      case "$action" in
        list)    echo "GET https://tasks.googleapis.com/tasks/v1/lists/{tasklist}/tasks" ;;
        get)     echo "GET https://tasks.googleapis.com/tasks/v1/lists/{tasklist}/tasks/{task}" ;;
        insert)  echo "POST https://tasks.googleapis.com/tasks/v1/lists/{tasklist}/tasks" ;;
        update)  echo "PUT https://tasks.googleapis.com/tasks/v1/lists/{tasklist}/tasks/{task}" ;;
        delete)  echo "DELETE https://tasks.googleapis.com/tasks/v1/lists/{tasklist}/tasks/{task}" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    # Presentations (Slides)
    slides.presentations)
      case "$action" in
        get)     echo "GET https://slides.googleapis.com/v1/presentations/{presentationId}" ;;
        create)  echo "POST https://slides.googleapis.com/v1/presentations" ;;
        batchUpdate) echo "POST https://slides.googleapis.com/v1/presentations/{presentationId}:batchUpdate" ;;
        *)       echo "UNKNOWN" ;;
      esac ;;

    *)
      echo "UNKNOWN"
      ;;
  esac
}

# ── URL builder ───────────────────────────────────────────────
build_url() {
  local url_template="$1"
  local params_json="${2:-{\}}"

  local url="$url_template"
  local query_params=""

  # Replace path parameters {param} and collect remaining as query params
  for key in $(echo "$params_json" | jq -r 'keys[]'); do
    local value
    value=$(echo "$params_json" | jq -r --arg k "$key" '.[$k] // empty')
    if echo "$url" | grep -q "{$key}"; then
      url=$(echo "$url" | sed "s|{$key}|$(printf '%s' "$value" | jq -sRr @uri)|g")
    else
      if [ -n "$query_params" ]; then
        query_params="${query_params}&${key}=$(printf '%s' "$value" | jq -sRr @uri)"
      else
        query_params="${key}=$(printf '%s' "$value" | jq -sRr @uri)"
      fi
    fi
  done

  if [ -n "$query_params" ]; then
    echo "${url}?${query_params}"
  else
    echo "$url"
  fi
}

# ── Main ──────────────────────────────────────────────────────
if [ $# -lt 2 ]; then
  echo "Usage: gws.sh <service.resource> <action> [params_json] [body_json]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  gws.sh gmail.users.messages list '{\"userId\":\"me\",\"maxResults\":5}'" >&2
  echo "  gws.sh calendar.events list '{\"calendarId\":\"primary\"}'" >&2
  echo "  gws.sh drive.files list '{\"pageSize\":10}'" >&2
  echo "  gws.sh sheets.spreadsheets.values get '{\"spreadsheetId\":\"ID\",\"range\":\"Sheet1!A1:D10\"}'" >&2
  echo "  gws.sh tasks.tasklists list '{}'" >&2
  exit 1
fi

SERVICE="$1"
ACTION="$2"
PARAMS="${3:-{\}}"
BODY="${4:-}"

ENDPOINT=$(resolve_endpoint "$SERVICE" "$ACTION")
if [ "$ENDPOINT" = "UNKNOWN" ]; then
  echo "Error: Unknown endpoint: $SERVICE $ACTION" >&2
  echo "Run 'gws.sh' with no args to see available services." >&2
  exit 1
fi

HTTP_METHOD=$(echo "$ENDPOINT" | cut -d' ' -f1)
URL_TEMPLATE=$(echo "$ENDPOINT" | cut -d' ' -f2)
URL=$(build_url "$URL_TEMPLATE" "$PARAMS")
TOKEN=$(get_access_token)

# Build curl command
CURL_ARGS=(-s -X "$HTTP_METHOD" "$URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

if [ -n "$BODY" ] && [ "$HTTP_METHOD" != "GET" ]; then
  CURL_ARGS+=(-d "$BODY")
fi

# Execute and handle token expiry (retry once)
RESPONSE=$(curl "${CURL_ARGS[@]}")
if echo "$RESPONSE" | jq -e '.error.code == 401' >/dev/null 2>&1; then
  TOKEN=$(refresh_access_token)
  CURL_ARGS=(-s -X "$HTTP_METHOD" "$URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json")
  if [ -n "$BODY" ] && [ "$HTTP_METHOD" != "GET" ]; then
    CURL_ARGS+=(-d "$BODY")
  fi
  RESPONSE=$(curl "${CURL_ARGS[@]}")
fi

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
