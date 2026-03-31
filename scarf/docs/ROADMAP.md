# Scarf — Feature Roadmap

## Tier 1 — High Value, Data Already Available

### 1. Insights Dashboard
Rich usage analytics pulled from the sessions and messages SQLite tables:
- Overview stats: sessions, messages, tool calls, tokens, active time, avg session duration
- Model breakdown: sessions and tokens per model
- Platform breakdown: CLI vs Telegram vs Discord usage
- Top tools chart: ranked tool usage with call counts and percentages
- Activity patterns: sessions by day-of-week, peak hours heatmap
- Notable sessions: longest, most messages, most tokens, most tool calls
- Time period selector: last 7/30/90 days

### 2. Tool Management Panel
- List all toolsets with enabled/disabled status and descriptions
- Toggle switches to enable/disable tools (via `hermes tools enable/disable`)
- Per-platform tool configuration
- MCP tool status

### 3. Session Management Enhancements
- Rename sessions from the Sessions browser (via `hermes sessions rename`)
- Delete sessions (via `hermes sessions delete`)
- Export sessions to JSONL (via `hermes sessions export`)
- Session stats card (total count, DB size, per-platform breakdown)

## Tier 2 — Medium Value, New Service Code Required

### 4. Skills Hub
- Search remote registries for new skills (6 sources)
- Install/uninstall skills from GUI
- Skill update indicator
- Trust level badges (builtin, local, hub)

### 5. Gateway Control Center
- Start/stop/restart gateway from GUI
- Real-time status: PID, uptime, connected platforms
- Pairing management: view approved users, approve/revoke
- Platform status per messaging service

### 6. System Health View
- Mirror `hermes status` and `hermes doctor` output
- API key validation, auth provider status, external tools
- Update available indicator

## Tier 3 — Nice to Have

### 7. Profile Management
- List/create/switch profiles (isolated Hermes instances)

### 8. Plugin Management
- Install from Git, enable/disable, update

### 9. MCP Server Management
- Add/remove/test MCP servers, toggle tools per server

### 10. Config Editor
- Structured form editor for config.yaml with validation
