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
