---
name: instantly-cli
description: Instantly.ai cold email platform API reference — endpoint shapes, CLI commands, field names, status codes. Use when you need to know Instantly API structure for campaigns, leads, accounts, analytics, warmup, inbox placement, or enrichment.
---

# Instantly.ai API Reference

- **Base URL:** `https://api.instantly.ai/api/v2`
- **Auth:** `Authorization: Bearer <key>`
- **Rate limit:** 100 req/10s, 600 req/min (workspace-wide)
- **Pagination:** Cursor-based (`--starting-after` UUID or datetime)

## Campaigns

```
GET    /campaigns           list [--limit N] [--status 0|1|2|3] [--search term]
GET    /campaigns/{id}      get
POST   /campaigns           create --name "Name"
PATCH  /campaigns/{id}      update
DELETE /campaigns/{id}      delete
POST   /campaigns/{id}/activate
POST   /campaigns/{id}/pause
```

Status: 0=Draft, 1=Active, 2=Paused, 3=Completed

## Leads

```
POST   /leads/list          list [--campaign-id X] [--limit N] [--interest-status N]
GET    /leads/{id}          get
POST   /leads               create --email X --campaign-id X
POST   /leads/bulk          bulk-add --campaign-id X --leads '[{...}]' [--skip-if-in-workspace]
DELETE /leads/bulk           bulk-delete --campaign-id X
PATCH  /leads/{id}/interest update-interest-status --interest-status N
POST   /leads/move          move --lead-ids X --to-campaign-id X
```

Note: Lead list is POST, not GET.

## Email Accounts

```
GET    /accounts            list [--limit N]
GET    /accounts/{id}       get
POST   /accounts            create --email X --smtp-host X --imap-host X
PATCH  /accounts/{email}    update [--daily-limit N]
DELETE /accounts/{id}       delete
POST   /accounts/warmup/enable    --account-ids "id1,id2"
POST   /accounts/warmup/disable   --account-ids "id1,id2"
GET    /accounts/{email}/vitals   test-vitals
POST   /accounts/{email}/pause
POST   /accounts/{email}/resume
```

Note: Some endpoints use email as ID, not numeric ID.

## Analytics

```
GET    /analytics/campaign         --id X [--start-date X] [--end-date X]
GET    /analytics/campaign-overview
GET    /analytics/daily/campaign   --campaign-id X
GET    /analytics/campaign-steps   --campaign-id X
GET    /analytics/daily/account
GET    /analytics/warmup           --emails "a@b.com,c@d.com"
```

## Emails / Unified Inbox

```
GET    /emails              list [--campaign-id X] [--is-read true|false] [--email-type reply]
GET    /emails/{id}         get
PATCH  /emails/{id}         update [--is-read true]
POST   /emails/reply        --reply-to-uuid X --to X --eaccount X --body-text "text"
POST   /emails/forward      --forward-uuid X --eaccount X --to X
GET    /emails/unread-count
```

## Inbox Placement

```
GET    /inbox-placement              list
POST   /inbox-placement              create --from sender@domain.com
GET    /inbox-placement/{id}/results results
GET    /inbox-placement-analytics/overview
GET    /inbox-placement-analytics/by-provider
GET    /inbox-placement-analytics/by-domain
```

## Other Groups

| Group | Commands |
|-------|----------|
| Webhooks | list, get, create, update, delete, test, event-types |
| Lead Lists | list, get, create, update, delete, verification-stats |
| Enrichment | enrich, count, get, run, create, ai, ai-progress |
| Blocklist | list, get, create, delete, bulk-add |
| Custom Tags | list, get, create, update, delete, search |
| Subsequences | list, get, create, update, delete, activate, pause |
| Workspace | get, update, members list/invite/remove, billing |
| Email Verification | verify, bulk-verify |

## Key Facts

- Account pagination uses datetime cursor; campaigns/leads use UUID cursor
- Interest status is numeric (not boolean like Bison)
- Rate limit is workspace-wide — shared across all API keys in workspace
- Lead list endpoint is POST (quirk)
- 156+ commands across 31 API groups total
