---
name: bison-api
description: Bison (EmailBison) cold email platform API reference — endpoint shapes, field names, status values. Use when you need to know Bison API structure for campaigns, replies, leads, sender emails, warmup, or workspace stats. Base URL send.leadgenjay.com.
---

# Bison API Reference

- **Base URL:** `https://send.leadgenjay.com`
- **Auth:** `Authorization: Bearer <API_KEY>`
- **Rate Limit:** 3000 req/min (50 req/s)
- **Pagination:** Page-based (`?page=1`), 15 items/page
- **Response wrapper:** `{ data: ... }`

## Endpoints

### Campaigns

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/campaigns` | List with stats inline (emails_sent, opened, replied, bounced, interested, total_leads) |
| GET | `/api/campaigns/{id}` | Single with stats |
| POST | `/api/campaigns/{id}/stats` | Requires start_date, end_date. Returns sequence_step_stats[] |
| GET | `/api/campaigns/{id}/replies` | Filters: status, folder, read, lead_id, tag_ids |
| GET | `/api/campaigns/{id}/leads` | Each lead has per-campaign lead_campaign_data |
| GET | `/api/campaigns/{id}/scheduled-emails` | Includes lead + sender_email objects |
| GET | `/api/campaigns/{id}/sender-emails` | Sender accounts for campaign |
| GET | `/api/campaigns/{id}/line-area-chart-stats` | Time series. Requires start_date, end_date |
| GET | `/api/campaigns/v1.1/{id}/sequence-steps` | Subject, body, wait_in_days, variants |

### Replies

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/replies` | Filters: campaign_id, status, folder, read, lead_id, tag_ids |
| GET | `/api/replies/{id}` | Full body (html_body, text_body) |
| GET | `/api/replies/{id}/conversation-thread` | current_reply, older_messages[], newer_messages[] |
| POST | `/api/replies/{id}/reply` | Supports reply_all, attachments |
| POST | `/api/replies/{id}/forward` | |
| PATCH | `/api/replies/{id}/mark-as-interested` | |
| PATCH | `/api/replies/{id}/mark-as-read-or-unread` | `{ read: bool }` |
| PATCH | `/api/replies/{id}/mark-as-automated-or-not-automated` | `{ automated: bool }` |

### Leads

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/leads` | Filters: lead_campaign_status, emails_sent, opens, replies, verification_statuses, tag_ids |
| GET | `/api/leads/{id}` | id = numeric ID or email address |
| GET | `/api/leads/{id}/replies` | |
| GET | `/api/leads/{id}/sent-emails` | |
| POST | `/api/leads` | first_name, last_name, email required |
| POST | `/api/leads/multiple` | Bulk create (max 500) |
| POST | `/api/leads/bulk/csv` | CSV upload |

### Sender Emails & Warmup

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/sender-emails` | Stats: emails_sent_count, total_replied_count, bounced_count, warmup_enabled |
| GET | `/api/warmup/sender-emails` | warmup_score, warmup_emails_sent, bounces. Requires start_date, end_date |
| PATCH | `/api/warmup/sender-emails/enable` | `{ sender_email_ids: [] }` |
| PATCH | `/api/warmup/sender-emails/disable` | |

### Workspace & Events

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/workspaces/v1.1/stats` | Requires start_date, end_date |
| GET | `/api/workspaces/v1.1/line-area-chart-stats` | Time series |
| GET | `/api/campaign-events/stats` | Filterable by campaign_ids, sender_email_ids |

## Key Data Shapes

```json
// Campaign: { id, name, status, emails_sent, opened, replied, bounced, interested, total_leads, total_leads_contacted }
// Reply: { id, folder, subject, read, interested, automated_reply, text_body, html_body, date_received, campaign_id, lead_id, from_email_address }
// Lead: { id, first_name, last_name, email, title, company, status, custom_variables[], overall_stats: { emails_sent, opens, replies } }
```

## Key Facts

- Stats are inline on campaign list — no separate enrichment call needed
- Campaign status values: Active, Draft, Launching, Stopped, Completed, Paused, Failed, Queued, Archived
- Reply interest: boolean `interested: true/false` (not numeric)
- Pagination is page-based, not cursor-based
