# Andy — Main (Admin)

Elevated privileges. No trigger required. All messages processed.

## Container Mounts

| Container Path | Host Path | Access |
|----------------|-----------|--------|
| `/workspace/project` | Project root | read-only |
| `/workspace/project/store` | `store/` | read-write |
| `/workspace/group` | `groups/main/` | read-write |
| `/workspace/global` | `groups/global/` | read-write |

- DB: `/workspace/project/store/messages.db`
- Groups config: `registered_groups` table in SQLite

## Group Management

### Find groups

```bash
# From synced list (preferred)
cat /workspace/ipc/available_groups.json

# From SQLite (fallback)
sqlite3 /workspace/project/store/messages.db \
  "SELECT jid, name, last_message_time FROM chats WHERE jid LIKE '%@g.us' ORDER BY last_message_time DESC LIMIT 10;"

# Request fresh sync
echo '{"type": "refresh_groups"}' > /workspace/ipc/tasks/refresh_$(date +%s).json
```

### Register a group

1. Find JID from database/available_groups
2. Ask user about trigger requirement
3. Use `register_group` MCP tool with: jid, name, folder, trigger, requiresTrigger
4. Folder convention: `{channel}_{name}` — e.g. `whatsapp_family-chat`, `telegram_dev-team`, `slack_engineering`

### Group fields

- `jid` — unique chat identifier
- `folder` — channel-prefixed directory under `groups/`
- `trigger` — trigger word (default: `@Andy`)
- `requiresTrigger` — `true` (default) or `false` for solo/personal chats
- `isMain` — elevated privileges, no trigger
- `containerConfig.additionalMounts` — extra dirs mounted at `/workspace/extra/{name}`

### Trigger behavior

- `isMain: true` → all messages processed
- `requiresTrigger: false` → all messages processed
- Default → only `@Andy` prefixed messages

### Sender allowlist

Config at `~/.config/nanoclaw/sender-allowlist.json` on host:

```json
{"default":{"allow":"*","mode":"trigger"},"chats":{"<jid>":{"allow":["id1","id2"],"mode":"trigger"}},"logDenied":true}
```

- Modes: `trigger` (store all, only allowed trigger) or `drop` (discard non-allowed)
- `is_from_me` bypasses allowlist; bot messages filtered before evaluation
- Missing/invalid config → fail-open (all allowed)

### Remove a group

Delete entry from `registered_groups` table. Group folder preserved.

## Cross-Group Scheduling

```bash
schedule_task(prompt: "...", schedule_type: "cron", schedule_value: "0 9 * * 1", target_group_jid: "JID")
```

## Global Memory

Read/write `/workspace/global/CLAUDE.md` for facts shared across all groups. Only update when explicitly asked.

## Authentication

- Anthropic: API key (`ANTHROPIC_API_KEY`) or long-lived OAuth token (`CLAUDE_CODE_OAUTH_TOKEN`)
- Short-lived keychain tokens expire and cause 401s — use `/setup` skill
- OneCLI manages all credentials: `onecli --help`
