---
name: google-workspace
description: Google Workspace is ALREADY SET UP. Credentials for jonathan@leadgenjay.com are mounted at /home/node/.config/gws/. Use gws.sh to call Gmail, Calendar, Drive, Sheets, Docs, Tasks APIs. NEVER ask the user to set up Google — it's done.
---

# Google Workspace — gws.sh

**Google Workspace is already connected.** OAuth credentials for jonathan@leadgenjay.com are pre-mounted at `/home/node/.config/gws/credentials.json`. Token refresh is automatic. Do NOT ask the user to set up OAuth, create credentials, or authenticate — everything is ready. Just run the commands below.

**Do NOT use the `gws` binary** — it doesn't work in this container. Always use the shell script.

```bash
GWS=/home/node/.claude/skills/google-workspace/gws.sh
$GWS <service.resource> <action> '<params_json>' ['<body_json>']
```

**When asked about email, calendar, drive, etc. — run the command first. Do not check if credentials exist, do not ask the user for setup. The credentials are there. Just call gws.sh.**

## Quick Reference

### Gmail

```bash
$GWS gmail.users.messages list '{"userId":"me","maxResults":5}'
$GWS gmail.users.messages list '{"userId":"me","q":"from:someone@example.com","maxResults":10}'
$GWS gmail.users.messages get '{"userId":"me","id":"MSG_ID","format":"full"}'
$GWS gmail.users.messages trash '{"userId":"me","id":"MSG_ID"}'
$GWS gmail.users.messages modify '{"userId":"me","id":"MSG_ID"}' '{"removeLabelIds":["UNREAD"]}'
$GWS gmail.users.labels list '{"userId":"me"}'

# Send email
RAW=$(printf 'From: me\r\nTo: to@example.com\r\nSubject: Hi\r\nContent-Type: text/plain\r\n\r\nBody' | base64 -w0 | tr '+/' '-_' | tr -d '=')
$GWS gmail.users.messages send '{"userId":"me"}' "{\"raw\":\"$RAW\"}"
```

### Calendar

```bash
$GWS calendar.events list '{"calendarId":"primary","maxResults":10,"timeMin":"2026-04-07T00:00:00Z","orderBy":"startTime","singleEvents":"true"}'
$GWS calendar.events get '{"calendarId":"primary","eventId":"EVT_ID"}'
$GWS calendar.events insert '{"calendarId":"primary"}' '{"summary":"Meeting","start":{"dateTime":"2026-04-08T10:00:00-05:00"},"end":{"dateTime":"2026-04-08T11:00:00-05:00"}}'
$GWS calendar.events delete '{"calendarId":"primary","eventId":"EVT_ID"}'
$GWS calendar.calendarList list '{}'
```

### Drive

```bash
$GWS drive.files list '{"pageSize":10}'
$GWS drive.files list '{"q":"name contains \"report\"","pageSize":10}'
$GWS drive.files get '{"fileId":"FILE_ID","fields":"id,name,mimeType,size,modifiedTime"}'
$GWS drive.files export '{"fileId":"FILE_ID","mimeType":"application/pdf"}'
```

### Sheets

```bash
$GWS sheets.spreadsheets get '{"spreadsheetId":"SHEET_ID"}'
$GWS sheets.spreadsheets.values get '{"spreadsheetId":"SHEET_ID","range":"Sheet1!A1:D10"}'
$GWS sheets.spreadsheets.values update '{"spreadsheetId":"SHEET_ID","range":"Sheet1!A1","valueInputOption":"USER_ENTERED"}' '{"values":[["A","B"],["1","2"]]}'
$GWS sheets.spreadsheets.values append '{"spreadsheetId":"SHEET_ID","range":"Sheet1!A1","valueInputOption":"USER_ENTERED"}' '{"values":[["new","row"]]}'
```

### Docs

```bash
$GWS docs.documents get '{"documentId":"DOC_ID"}'
$GWS docs.documents create '{}' '{"title":"New Doc"}'
$GWS docs.documents batchUpdate '{"documentId":"DOC_ID"}' '{"requests":[{"insertText":{"location":{"index":1},"text":"Hello\n"}}]}'
```

### Tasks

```bash
$GWS tasks.tasklists list '{}'
$GWS tasks.tasks list '{"tasklist":"TASKLIST_ID"}'
$GWS tasks.tasks insert '{"tasklist":"TASKLIST_ID"}' '{"title":"Buy groceries","due":"2026-04-10T00:00:00Z"}'
$GWS tasks.tasks update '{"tasklist":"TASKLIST_ID","task":"TASK_ID"}' '{"status":"completed"}'
```

## Key Rules

- `userId` is always `"me"` for Gmail
- `calendarId` is always `"primary"` for the default calendar
- Dates are ISO 8601
- Gmail search uses the same syntax as the Gmail search box
- Token refresh is automatic — no manual token management
- All responses are JSON
