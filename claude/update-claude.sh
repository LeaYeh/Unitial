#!/bin/sh
# Update Claude Code config: pull skills repo, re-sync symlinks and local skills.
# Usage: update-claude [--unitial-dir <path>] [--no-pull]
#   SKILLS_DIR   env var or ~/skills (default)
#   UNITIAL_DIR  env var or --unitial-dir flag; if set, also pulls Unitial and re-links CLAUDE.md
#   --no-pull    skip git pull steps (useful in CI where repos are already checked out)

CHMOD="/bin/chmod"
MKDIR="/bin/mkdir"
NO_PULL=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --unitial-dir) UNITIAL_DIR="$2"; shift 2 ;;
    --no-pull)     NO_PULL=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

SKILLS_DIR="${SKILLS_DIR:-${HOME}/skills}"

# 1. Pull skills repo
if [ -d "${SKILLS_DIR}/.git" ]; then
  if [ "$NO_PULL" -eq 0 ]; then
    printf 'Updating skills repo (%s)...\n' "$SKILLS_DIR"
    git -C "${SKILLS_DIR}" pull --ff-only || { printf 'ERROR: git pull failed\n' >&2; exit 1; }
  fi
else
  printf 'ERROR: skills repo not found at %s\n' "${SKILLS_DIR}" >&2
  exit 1
fi

# 2. Re-sync symlinks
${MKDIR} -p ~/.claude
ln -sf "${SKILLS_DIR}/settings.json" ~/.claude/settings.json
rm -rf ~/.claude/commands
ln -sf "${SKILLS_DIR}/commands" ~/.claude/commands
printf 'Symlinks updated.\n'

# 3. Optionally pull Unitial and re-link CLAUDE.md
if [ -n "${UNITIAL_DIR}" ]; then
  if [ "$NO_PULL" -eq 0 ] && [ -d "${UNITIAL_DIR}/.git" ]; then
    printf 'Updating Unitial (%s)...\n' "$UNITIAL_DIR"
    git -C "${UNITIAL_DIR}" pull --ff-only || printf 'WARNING: Unitial git pull failed, skipping\n'
  fi
  ln -sf "${UNITIAL_DIR}/claude/CLAUDE.md" ~/.claude/CLAUDE.md
  printf 'CLAUDE.md re-linked from Unitial.\n'
fi

# 4. Re-copy checkpoint scripts
${MKDIR} -p ~/.claude/scripts/
CHECKPOINT_SCRIPTS="${SKILLS_DIR}/plugins/checkpoint/skills/checkpoint/scripts"
if [ -d "$CHECKPOINT_SCRIPTS" ]; then
  for script in checkpoint-session-start.sh checkpoint-warn.sh; do
    if [ -f "${CHECKPOINT_SCRIPTS}/${script}" ]; then
      cp "${CHECKPOINT_SCRIPTS}/${script}" ~/.claude/scripts/
      ${CHMOD} +x ~/.claude/scripts/"${script}"
    fi
  done
  printf 'Checkpoint scripts updated.\n'
fi

printf '\nClaude Code configuration updated.\n'
