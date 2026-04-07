---
name: high-ticket-portal
description: HTM Portal API reference — 112 endpoints for client management, campaign analytics, mailbox health, task/meeting extraction, AI analysis, knowledge base, and dashboard KPIs. Use when you need HTM Portal API structure for clients, campaigns, leads, replies, mailbox health, tasks, documents, or AI operations. Base URL is the portal app.
---

# HTM Portal API Reference

- **Base URL:** `/api/`
- **Auth:** Supabase session, Bearer `htm_...` key, or `requireAuth`/`requireAdmin`
- **Rate limit:** AI routes are rate-limited

## v1 — Clients API (Bearer auth)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/clients` | List all. Query: include, platform, strategist, csm, fresh |
| GET | `/api/v1/clients/[name]` | Full detail + notes, tasks, context, github, commits |
| GET | `/api/v1/clients/[name]/notes` | Query: channel, limit (max 500) |
| POST | `/api/v1/clients/[name]/notes` | Body: `{ text, channel?, author?, noteDate? }` |
| DELETE | `/api/v1/clients/[name]/notes` | Body: `{ id }` |
| GET | `/api/v1/clients/[name]/tasks` | Query: status, assigned_to, limit. Returns summary counts |
| POST | `/api/v1/clients/[name]/tasks` | Single or batch: `{ description }` or `{ tasks: [...] }` |
| PATCH | `/api/v1/clients/[name]/tasks` | Body: `{ id, status?, description?, assigned_to?, due_date? }` |
| DELETE | `/api/v1/clients/[name]/tasks` | Body: `{ id }` |
| GET | `/api/v1/clients/[name]/campaigns` | Auto-resolves platform + API key. Query: analytics |

## Tasks & Meetings

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/tasks` | Query: status (open\|in_progress\|done), assigned_to, client_name |
| POST | `/api/tasks` | Body: `{ tasks: [{ description, client_name, assigned_to, source }] }` |
| PATCH | `/api/tasks` | Body: `{ id, status?, description?, assigned_to?, due_date? }` |
| DELETE | `/api/tasks` | Body: `{ id }` |
| GET | `/api/tasks/summary` | Returns: overdue, due_today, open_total, unprocessed_meetings |
| POST | `/api/tasks/extract` | AI 5-pass extraction from Fathom transcript. Body: `{ recordingId }` |
| POST | `/api/tasks/webhook` | Fathom webhook (HMAC verified) |
| GET | `/api/tasks/activity` | Query: task_id, changed_by, since, limit |
| POST | `/api/tasks/activity` | Body: `{ task_id, from_status?, to_status, changed_by? }` |
| GET | `/api/meetings` | List meetings (newest first, limit 50) |
| PATCH | `/api/meetings` | Body: `{ id, tasks_extracted? }` |

## Clients — Data & GitHub

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/campaigns` | Query: clientName (req), platform (req), apiKey |
| POST | `/api/clients/insights` | AI performance analysis. Body: `{ stats }` |
| POST | `/api/clients/comment-counts` | Batch Notion comment counts. Body: `{ pageIds[] }` |
| GET | `/api/clients/[name]/comments` | Notion comments |
| POST | `/api/clients/[name]/comments` | Body: `{ text }` |
| GET | `/api/clients/[name]/github` | Check repo exists, last commit |
| POST | `/api/clients/[name]/github` | Create repo + push all assets atomically |
| GET | `/api/clients/[name]/github/commits` | Query: page, per_page (max 100) |
| POST | `/api/clients/[name]/links` | Save intake form URL or strategy call recording |
| GET | `/api/clients/[name]/context` | ICP, requirements, comms config |
| PUT | `/api/clients/[name]/context` | Upsert context (Zod validated) |
| DELETE | `/api/clients/[name]/context` | |
| GET | `/api/clients/outcomes` | Query: clientName |
| POST | `/api/clients/outcomes` | Set outcome, testimonial, case study |
| DELETE | `/api/clients/outcomes` | Delete + cancel related commissions |
| GET | `/api/team-members` | Strategist/CSM roster |
| GET | `/api/commissions` | Query: format=csv for export |
| POST | `/api/commissions` | Actions: add-commission, update-commission, toggle-status |

## Campaign Analytics

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/campaigns/analytics` | Query: clientName (req), platform (req), startDate, endDate, overview |
| GET | `/api/campaigns/details` | Query: clientName, campaignId, platform (all req) |
| GET | `/api/campaigns/leads` | Query: clientName, platform, campaignId (all req) |
| POST | `/api/campaigns/sequences` | Bulk fetch sequences. Body: `{ clientName, platform, apiKey, campaigns[] }` |
| GET | `/api/campaigns/step-stats` | Per-step stats. Query: clientName, platform, campaignId |
| POST | `/api/campaigns/analyze-replies` | AI reply analysis. Body: `{ clientName, platform, apiKey, campaignIds[] }` |
| POST | `/api/validate-campaign` | AI validation (copy+leads+ICP). Rate limited |
| POST | `/api/extract-icp` | AI ICP extraction from transcript. Min 50 chars |

## Mailbox Health

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/mailbox-health` | Aggregate health. Returns summary + mailboxes[]. Cache 10min |
| POST | `/api/mailbox-delete` | Body: `{ email, clientName, platform, bisonId? }` |
| GET | `/api/warmup-analytics` | Instantly warmup. Query: clientName (req), emails |
| GET | `/api/bison/sender-emails` | Bison sender list. Query: clientName (req) |
| GET | `/api/instantly/sender-emails` | Instantly sender list. Query: clientName (req) |

## EmailGuard

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/emailguard/limits` | Credit usage: inboxPlacement, spamFilter, spamhausIntel |
| POST | `/api/emailguard/dns-check` | SPF/DKIM/DMARC. Body: `{ domain, selector? }` |
| POST | `/api/emailguard/blacklist` | Blacklist + SURBL. Body: `{ domain }` |
| POST | `/api/emailguard/spamhaus` | Create reputation check (4 credits). Body: `{ domain }` |
| GET | `/api/emailguard/spamhaus` | Poll result. Query: uuid (req) |
| POST | `/api/emailguard/inbox-tests` | Create inbox test. Body: `{ name }` |
| GET | `/api/emailguard/inbox-tests` | List or get by uuid |

## AI Routes (all rate-limited)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/ai/benchmark` | Campaign metrics vs industry standards |
| POST | `/api/ai/summarize-thread` | Email thread summary |
| POST | `/api/ai/risk-score` | Client retention risk scoring |
| POST | `/api/ai/reverse-icp` | Reverse-engineer ICP from reply data |
| POST | `/api/ai/optimize-campaigns` | Full campaign optimization analysis |
| POST | `/api/ai/classify-replies` | Reply intent classification (max 20/batch) |
| POST | `/api/ai/generate-copy` | Generate 3 email copy variants |
| POST | `/api/ai/analyze-leads` | Lead-ICP alignment (max 50 leads) |
| POST | `/api/ai/generate-response` | Generate reply to lead response |
| POST | `/api/ai/campaign-autopsy` | Diagnose underperforming campaigns |
| POST | `/api/ai/gtm-strategy` | GTM strategy pivot (uses KB RAG) |

## Communications

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/communication/clients` | Analyze email comms via Gmail + GPT |
| GET | `/api/communication/notes` | Query: clientName |
| POST | `/api/communication/notes` | Body: `{ clientName, text, channel?, author? }` |
| DELETE | `/api/communication/notes` | Body: `{ id }` |
| GET | `/api/emails` | Query: clientName (req), platform (req) |
| POST | `/api/emails/scan-opportunities` | AI scan for mislabeled leads (SSE stream) |
| GET | `/api/slack-channels` | Cached 5min |
| GET | `/api/slack/history` | Query: channel (req), limit (7d\|30d\|50) |

## Documents & Knowledge Base

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/documents` | Query: clientName, action=stats, includeText |
| POST | `/api/documents` | FormData upload (max 10MB: PDF, DOCX, TXT, CSV, MD) |
| DELETE | `/api/documents` | Query: id (req) |
| POST | `/api/documents/auto-extract` | Extract ICP from doc text, save to context |
| POST | `/api/documents/import-url` | Import Google Doc/Sheet |
| POST | `/api/knowledge/search` | Semantic search. Body: `{ query, threshold?, limit?, source_type? }` |
| POST | `/api/knowledge/upload` | Text to KB (SSE). Body: `{ text, title, type }` |
| POST | `/api/knowledge/upload-file` | File to KB (FormData, SSE, max 10MB) |
| POST | `/api/knowledge/url` | Import URL/YouTube (SSE) |
| GET | `/api/knowledge/list` | All sources |
| DELETE | `/api/knowledge/delete` | Body: `{ source_id }` |
| GET | `/api/knowledge/stats` | total_sources, total_chunks |

## Dashboard

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/dashboard` | Aggregated KPIs. Cache 30s. Query: refresh |
| GET | `/api/dashboard/campaign-health` | Per-client health + AI analysis. Cache 10min data, 30min AI |
| GET | `/api/dashboard/campaign-trends/instantly` | Query: clientName, campaignIds, period (all req) |
| GET | `/api/dashboard/campaign-trends/bison` | Query: clientName, campaignIds, period (all req) |

## Settings, Auth & Admin

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/settings` | Query: key |
| POST | `/api/settings` | Body: `{ key, value }` |
| GET | `/api/settings/api-keys` | Masked key status |
| POST | `/api/settings/api-keys` | Body: `{ openai?, anthropic? }` |
| GET | `/api/account/api-keys` | List personal API keys |
| POST | `/api/account/api-keys` | Generate key. Body: `{ label? }` |
| DELETE | `/api/account/api-keys` | Body: `{ id }` |
| GET | `/api/users` | Admin only |
| PATCH | `/api/users/[id]` | Admin only |
| GET | `/api/auth/gmail` | Redirect to Google OAuth |
| GET | `/api/auth/gmail/callback` | OAuth code exchange |
| GET | `/api/auth/gmail/status` | Returns: connected, email |

## Metrics & Fathom

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/metrics` | Query: date, metric_type, source |
| POST | `/api/metrics/analyze` | AI analysis |
| POST | `/api/metrics/backfill` | Historical backfill |
| GET | `/api/fathom/transcript` | Query: recordingId (req) |
| GET | `/api/fathom/action-items` | Query: recordingId (req) |
| GET | `/api/fathom/summary` | Query: recordingId (req) |

## Key Facts

- Platform values: `instantly` or `bison`
- Task statuses: `open`, `in_progress`, `done`
- Campaign status (Instantly): 0=Draft, 1=Active, 2=Paused, 3=Completed
- Campaign status (Bison): Active, Draft, Launching, Stopped, Completed, Paused, Failed, Queued, Archived
- AI routes require OpenAI or Anthropic API keys configured in settings
- SSE streaming routes: scan-opportunities, knowledge/upload, knowledge/upload-file, knowledge/url
- Cache TTLs: dashboard 30s, mailbox-health 10min, campaign-health 10min data + 30min AI, slack-channels 5min
- v1 client API uses Bearer `htm_...` tokens; other routes use Supabase session or requireAuth
