---
name: github
description: GitHub is ALREADY SET UP. PAT for jonathangetonapod is mounted at /home/node/.config/github/token. Use github.sh to call GitHub REST API. NEVER ask the user to set up GitHub — it's done.
---

# GitHub — github.sh

**GitHub is already connected.** PAT for `jonathangetonapod` is pre-mounted. Do NOT ask for tokens or setup — just run commands.

```bash
GH=/home/node/.claude/skills/github/github.sh
$GH <METHOD> <endpoint> [body_json]
```

**When asked about repos, issues, PRs, etc. — run the command. Don't check if credentials exist.**

## Quick Reference

### User & Repos

```bash
$GH GET /user
$GH GET /user/repos?per_page=10&sort=updated
$GH GET /repos/jonathangetonapod/nanoclaw
```

### Issues

```bash
$GH GET /repos/OWNER/REPO/issues?state=open&per_page=10
$GH GET /repos/OWNER/REPO/issues/123
$GH POST /repos/OWNER/REPO/issues '{"title":"Bug title","body":"Description","labels":["bug"]}'
$GH PATCH /repos/OWNER/REPO/issues/123 '{"state":"closed"}'
$GH POST /repos/OWNER/REPO/issues/123/comments '{"body":"Comment text"}'
```

### Pull Requests

```bash
$GH GET /repos/OWNER/REPO/pulls?state=open
$GH GET /repos/OWNER/REPO/pulls/123
$GH POST /repos/OWNER/REPO/pulls '{"title":"PR title","head":"feature-branch","base":"main","body":"Description"}'
$GH POST /repos/OWNER/REPO/pulls/123/reviews '{"body":"LGTM","event":"APPROVE"}'
$GH PUT /repos/OWNER/REPO/pulls/123/merge '{"merge_method":"squash"}'
```

### Branches & Commits

```bash
$GH GET /repos/OWNER/REPO/branches
$GH GET /repos/OWNER/REPO/commits?per_page=5
$GH GET /repos/OWNER/REPO/commits/COMMIT_SHA
```

### Releases

```bash
$GH GET /repos/OWNER/REPO/releases?per_page=5
$GH GET /repos/OWNER/REPO/releases/latest
```

### Search

```bash
$GH GET '/search/repositories?q=nanoclaw+user:jonathangetonapod'
$GH GET '/search/issues?q=is:open+repo:OWNER/REPO+label:bug'
$GH GET '/search/code?q=TODO+repo:OWNER/REPO'
```

### Actions (CI/CD)

```bash
$GH GET /repos/OWNER/REPO/actions/runs?per_page=5
$GH GET /repos/OWNER/REPO/actions/runs/RUN_ID
$GH POST /repos/OWNER/REPO/actions/runs/RUN_ID/rerun
```

### Notifications

```bash
$GH GET /notifications?per_page=10
$GH PATCH /notifications '{"read":true}'
```

## Key Rules

- Default user is `jonathangetonapod`
- Pagination: add `?per_page=N&page=P` to GET requests
- All responses are JSON
- For paginated results, check the `Link` header or use `per_page`
