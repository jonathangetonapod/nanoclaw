---
name: high-ticket-portal
description: HTM Portal API reference — 124 endpoints for client management, campaigns, mailbox health, tasks, meetings, AI analysis, documents, knowledge base, and dashboard KPIs. Use when you need HTM Portal API structure. Triggers on mentions of high ticket, portal, HTM, client list, tasks, campaigns, mailbox health, or portal API.
---

# HTM Portal API Reference

- **Base URL:** `https://high-ticket-portal-production.up.railway.app/api/`
- **Auth:** Supabase session, Bearer `htm_...` key, or `requireAuth`/`requireAdmin`
- **124 endpoints**

## v1 — Clients API (Bearer htm_... auth)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/clients` | List all. Query: q (fuzzy search), include, platform, strategist, csm, fresh, fields, format=csv |
| GET | `/api/v1/clients/[name]` | Full detail + notes, tasks, context, github, commits. Query: include |
| GET | `/api/v1/clients/[name]/notes` | Query: channel (slack\|call\|email\|meeting\|other), limit (max 500) |
| POST | `/api/v1/clients/[name]/notes` | Body: `{ text, channel?, author?, noteDate? }` |
| DELETE | `/api/v1/clients/[name]/notes` | Body: `{ id }` |
| GET | `/api/v1/clients/[name]/tasks` | Query: status, assigned_to, limit. Returns summary counts |
| POST | `/api/v1/clients/[name]/tasks` | Single or batch: `{ description }` or `{ tasks: [...] }` |
| PATCH | `/api/v1/clients/[name]/tasks` | Body: `{ id, status?, description?, assigned_to?, due_date? }` |
| DELETE | `/api/v1/clients/[name]/tasks` | Body: `{ id }` |
| GET | `/api/v1/clients/[name]/campaigns` | Auto-resolves platform + API key. Query: analytics |
| GET | `/api/v1/clients/[name]/activity` | Unified timeline. Query: limit (max 200), since, type (task_created\|task_status_change\|note_added\|github_push) |
| GET | `/api/v1/clients/[name]/github` | Check repo exists, last commit |
| POST | `/api/v1/clients/[name]/github` | Create repo + push all assets (empty body — server auto-fetches) |
| GET | `/api/v1/clients/[name]/context` | ICP, requirements, comms config |
| PUT | `/api/v1/clients/[name]/context` | Upsert: icpSummary, specialRequirements, transcriptNotes, clientEmail, slackChannelId |
| DELETE | `/api/v1/clients/[name]/context` | |
| GET | `/api/v1/clients/[name]/documents` | Query: includeText |
| DELETE | `/api/v1/clients/[name]/documents` | Body: `{ id }` |
| GET | `/api/v1/clients/[name]/outcomes` | Testimonial, case study status |
| POST | `/api/v1/clients/[name]/outcomes` | Body: `{ outcome?, outcomeDate?, testimonialRecorded?, caseStudyRecorded?, notes? }` |
| DELETE | `/api/v1/clients/[name]/outcomes` | |
| GET | `/api/v1/clients/[name]/communications` | Contact frequency, health score, aiSummary |

## Tasks & Meetings

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/tasks` | Query: status (open\|in_progress\|done), assigned_to, client_name |
| POST | `/api/tasks` | Body: `{ tasks: [{ description, client_name, assigned_to, source, due_date? }] }` |
| PATCH | `/api/tasks` | Body: `{ id, status?, description?, assigned_to?, due_date? }` |
| DELETE | `/api/tasks` | Body: `{ id }` |
| GET | `/api/tasks/summary` | Returns: overdue, due_today, open_total, unprocessed_meetings |
| POST | `/api/tasks/extract` | AI 5-pass extraction from Fathom transcript. Body: `{ recordingId }` |
| POST | `/api/tasks/webhook` | Fathom webhook (HMAC verified) |
| GET | `/api/tasks/activity` | Query: task_id, changed_by, since, limit |
| POST | `/api/tasks/activity` | Body: `{ task_id, from_status?, to_status, changed_by? }` |
| GET | `/api/meetings` | List (newest first, limit 50) |
| PATCH | `/api/meetings` | Body: `{ id, tasks_extracted? }` |

## Clients — Data & GitHub

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/campaigns` | Query: clientName (req), platform (req), apiKey |
| POST | `/api/clients/insights` | AI performance analysis. Body: `{ stats }` |
| POST | `/api/clients/comment-counts` | Batch Notion counts. Body: `{ pageIds[] }` |
| GET | `/api/clients/[name]/comments` | Notion comments |
| POST | `/api/clients/[name]/comments` | Body: `{ text }` |
| GET | `/api/clients/[name]/github` | Check repo exists |
| POST | `/api/clients/[name]/github` | Create repo + push all assets atomically |
| GET | `/api/clients/[name]/github/commits` | Query: page, per_page (max 100) |
| POST | `/api/clients/[name]/links` | Save intake form URL or strategy call recording |
| GET | `/api/clients/[name]/context` | ICP, requirements |
| PUT | `/api/clients/[name]/context` | Upsert (Zod validated) |
| DELETE | `/api/clients/[name]/context` | |
| GET | `/api/clients/outcomes` | Query: clientName |
| POST | `/api/clients/outcomes` | Set outcome, testimonial, case study |
| DELETE | `/api/clients/outcomes` | Delete + cancel commissions |
| GET | `/api/team-members` | Strategist/CSM roster |
| GET | `/api/commissions` | Query: format=csv |
| POST | `/api/commissions` | Actions: add-commission, update-commission, toggle-status |

## Campaign Analytics

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/campaigns/analytics` | Query: clientName, platform (req), startDate, endDate, overview |
| GET | `/api/campaigns/details` | Query: clientName, campaignId, platform (all req) |
| GET | `/api/campaigns/leads` | Query: clientName, platform, campaignId (all req) |
| POST | `/api/campaigns/sequences` | Bulk fetch. Body: `{ clientName, platform, apiKey, campaigns[] }` |
| GET | `/api/campaigns/step-stats` | Per-step stats. Query: clientName, platform, campaignId |
| POST | `/api/campaigns/analyze-replies` | AI reply analysis. Body: `{ clientName, platform, apiKey, campaignIds[] }` |
| POST | `/api/validate-campaign` | AI validation. Rate limited |
| POST | `/api/extract-icp` | AI ICP extraction from transcript. Min 50 chars |

## Mailbox Health

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/mailbox-health` | Aggregate health. Cache 10min. Query: refresh |
| POST | `/api/mailbox-delete` | Body: `{ email, clientName, platform, bisonId? }` |
| GET | `/api/warmup-analytics` | Instantly warmup. Query: clientName (req), emails |
| GET | `/api/bison/sender-emails` | Query: clientName (req) |
| GET | `/api/instantly/sender-emails` | Query: clientName (req) |

## EmailGuard

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/emailguard/limits` | Credit usage |
| POST | `/api/emailguard/dns-check` | SPF/DKIM/DMARC. Body: `{ domain, selector? }` |
| POST | `/api/emailguard/blacklist` | Body: `{ domain }` |
| POST | `/api/emailguard/spamhaus` | Create check (4 credits). Body: `{ domain }` |
| GET | `/api/emailguard/spamhaus` | Poll result. Query: uuid (req) |
| POST | `/api/emailguard/inbox-tests` | Body: `{ name }` |
| GET | `/api/emailguard/inbox-tests` | List or get by uuid |

## AI Routes (all rate-limited)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/ai/benchmark` | Campaign metrics vs industry standards |
| POST | `/api/ai/summarize-thread` | Email thread summary |
| POST | `/api/ai/risk-score` | Client retention risk |
| POST | `/api/ai/reverse-icp` | ICP from reply data |
| POST | `/api/ai/optimize-campaigns` | Full optimization analysis |
| POST | `/api/ai/classify-replies` | Intent classification (max 20/batch) |
| POST | `/api/ai/generate-copy` | 3 email copy variants |
| POST | `/api/ai/analyze-leads` | Lead-ICP alignment (max 50) |
| POST | `/api/ai/generate-response` | Reply to lead response |
| POST | `/api/ai/campaign-autopsy` | Diagnose underperformers |
| POST | `/api/ai/gtm-strategy` | GTM pivot (uses KB RAG) |

## Communications

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/communication/clients` | Analyze comms via Gmail + GPT |
| GET | `/api/communication/notes` | Query: clientName |
| POST | `/api/communication/notes` | Body: `{ clientName, text, channel?, author? }` |
| DELETE | `/api/communication/notes` | Body: `{ id }` |
| GET | `/api/emails` | Query: clientName, platform (req) |
| POST | `/api/emails/scan-opportunities` | AI scan mislabeled leads (SSE) |
| GET | `/api/slack-channels` | Cached 5min |
| GET | `/api/slack/history` | Query: channel (req), limit (7d\|30d\|50) |

## Documents & Knowledge Base

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/documents` | Query: clientName, action=stats, includeText |
| POST | `/api/documents` | FormData upload (max 10MB) |
| DELETE | `/api/documents` | Query: id (req) |
| POST | `/api/documents/auto-extract` | Extract ICP from doc, save to context |
| POST | `/api/documents/import-url` | Import Google Doc/Sheet |
| POST | `/api/knowledge/search` | Semantic search. Body: `{ query, threshold?, limit? }` |
| POST | `/api/knowledge/upload` | Text to KB (SSE) |
| POST | `/api/knowledge/upload-file` | File to KB (FormData, SSE, max 10MB) |
| POST | `/api/knowledge/url` | Import URL/YouTube (SSE) |
| GET | `/api/knowledge/list` | All sources |
| DELETE | `/api/knowledge/delete` | Body: `{ source_id }` |
| GET | `/api/knowledge/stats` | total_sources, total_chunks |

## Dashboard

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/dashboard` | Aggregated KPIs. Cache 30s |
| GET | `/api/dashboard/campaign-health` | Per-client health + AI. Cache 10min/30min |
| GET | `/api/dashboard/campaign-trends/instantly` | Query: clientName, campaignIds, period |
| GET | `/api/dashboard/campaign-trends/bison` | Query: clientName, campaignIds, period |

## Settings, Auth & Admin

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/settings` | Query: key |
| POST | `/api/settings` | Body: `{ key, value }` |
| GET/POST | `/api/settings/api-keys` | Get masked status / save keys |
| GET/POST/DELETE | `/api/account/api-keys` | Personal API key CRUD |
| GET | `/api/users` | Admin only |
| PATCH | `/api/users/[id]` | Admin only |
| GET | `/api/auth/gmail` | OAuth redirect |
| GET | `/api/auth/gmail/callback` | Code exchange |
| GET | `/api/auth/gmail/status` | Connection status |

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
- v1 client API uses Bearer `htm_...` tokens; other routes use Supabase session
- AI routes require OpenAI or Anthropic keys in settings
- SSE streaming: scan-opportunities, knowledge/upload, knowledge/upload-file, knowledge/url
- Cache TTLs: dashboard 30s, mailbox-health 10min, campaign-health 10min+30min AI, slack-channels 5min
- v1 GitHub push auto-fetches all data server-side (empty body)
- v1 activity endpoint provides unified timeline across tasks, notes, and commits
