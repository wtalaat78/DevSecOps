#!/usr/bin/env bash
# DevSecOps Maximum Linux/macOS Installer
set -euo pipefail

PLATFORM="both"
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_SRC="${PKG_ROOT}/skill"

install_skill() {
  local dest="$1"
  if [[ -d "$dest" ]]; then
    if [[ "$FORCE" != "true" ]]; then
      echo "Destination exists: $dest. Re-run with --force to backup and replace."
      exit 1
    fi
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    mv "$dest" "${dest}.backup-${stamp}"
    echo "Backed up existing skill to ${dest}.backup-${stamp}"
  fi
  mkdir -p "$dest"
  cp -R "${SKILL_SRC}/"* "$dest/"
  mkdir -p "${dest}/references" "${dest}/templates"
  cp -R "${PKG_ROOT}/references/"* "${dest}/references/"
  cp -R "${PKG_ROOT}/templates/"* "${dest}/templates/"
  echo "Installed skill to $dest"
}

START_TAG="<!-- DEVSECOPS-MAXIMUM:START -->"
END_TAG="<!-- DEVSECOPS-MAXIMUM:END -->"

add_managed_block() {
  local target_file="$1"
  local content="$2"
  mkdir -p "$(dirname "$target_file")"
  touch "$target_file"

  # Remove existing block if present
  if grep -q "$START_TAG" "$target_file" 2>/dev/null; then
    sed -i.bak "/${START_TAG}/,/${END_TAG}/d" "$target_file"
    rm -f "${target_file}.bak"
  fi

  printf "\n%s\n%s\n%s\n" "$START_TAG" "$content" "$END_TAG" >> "$target_file"
  echo "Updated managed policy block in $target_file"
}

if [[ "$PLATFORM" == "antigravity" || "$PLATFORM" == "both" ]]; then
  AGY_DEST="${HOME}/.gemini/config/skills/devsecops-maximum"
  install_skill "$AGY_DEST"
  
  RULE_SRC="${PKG_ROOT}/platform/antigravity/global-rule.md"
  if [[ -f "$RULE_SRC" ]]; then
    mkdir -p "${HOME}/.gemini/config/rules"
    cp "$RULE_SRC" "${HOME}/.gemini/config/rules/devsecops.md"
    RULE_CONTENT="$(cat "$RULE_SRC")"
    add_managed_block "${HOME}/.gemini/config/AGENTS.md" "$RULE_CONTENT"
  fi
fi

if [[ "$PLATFORM" == "claude" || "$PLATFORM" == "both" ]]; then
  CLAUDE_DEST="${HOME}/.claude/skills/devsecops-maximum"
  install_skill "$CLAUDE_DEST"
  
  CLAUDE_SRC="${PKG_ROOT}/platform/claude/global-instructions.md"
  if [[ -f "$CLAUDE_SRC" ]]; then
    CLAUDE_CONTENT="$(cat "$CLAUDE_SRC")"
    add_managed_block "${HOME}/.claude/CLAUDE.md" "$CLAUDE_CONTENT"
  fi
fi

echo "DevSecOps Maximum installed successfully for platform: $PLATFORM"
