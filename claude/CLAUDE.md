# Global Preferences

## Language
- Discussion, planning, Q&A: Traditional Chinese (zh-TW)
- Code, comments, commits, file content: English only

## Environment
- Shell: zsh (or sh on minimal systems)
- Package managers: homebrew (macOS), uv (Python), npm

## Git
- Never amend published commits; always create new ones
- Never skip hooks (--no-verify)

## Session Continuity
- If the conversation is very long, has many tool calls, or the user mentions usage limits, proactively suggest running /checkpoint before continuing.
- If RESUME.md exists at session start, read it immediately and announce: "Resuming: **<task>**. Next: <next step>." then proceed without re-planning.

## Default Claude Code Framework

### Primary Skills (all projects)
- `/record-adr`  — after any design decision
- `/grill-me`    — before architecture changes or major design discussions
- `/diagnose`    — before any bug fix
- `/checkpoint`  — when approaching context limits

### Harness (all projects)
- SessionStart:     `~/.claude/scripts/checkpoint-session-start.sh`
- UserPromptSubmit: `~/.claude/scripts/checkpoint-warn.sh`

### Session Config (all projects)
- Permanent permissions → `.claude/settings.json` (tracked, commit this)
- Session-only permissions → `.claude/settings.local.json` (never commit, periodic cleanup)
- `RESUME.md` → never commit (add to `.gitignore`)

### CLAUDE.md Maintenance
- After `/record-adr` completes, the skill proposes a diff to update project CLAUDE.md — review and apply if relevant.
- Project CLAUDE.md only needs to declare overrides and additions beyond this global baseline.
