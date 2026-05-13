#!/bin/sh
# Pre-apply safety net. chezmoi runs every `run_before_*` script before touching
# any dest file, so this fires on every `chezmoi apply` (and `chezmoi update`).
#
# Why: `chezmoi apply` silently overwrites dest content with source-rendered
# content. If something edited the dest out-of-band (GUI tools, ad-hoc edits,
# `git config --global`), that drift is lost. We snapshot every managed dest
# file into a timestamped tarball under ~/.cache/chezmoi-backups/ so the prior
# state can be recovered.
set -eu

backup_dir="$HOME/.cache/chezmoi-backups"
mkdir -p "$backup_dir"
ts=$(date +%Y%m%d-%H%M%S)
archive="$backup_dir/$ts-pre-apply.tar.gz"

managed=$(chezmoi managed --include=files)

existing=""
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  [ -e "$HOME/$rel" ] || continue
  existing="$existing $rel"
done <<EOF
$managed
EOF

if [ -z "$existing" ]; then
  exit 0
fi

( cd "$HOME" && tar -czf "$archive" $existing 2>/dev/null ) || true

if [ -f "$archive" ]; then
  size=$(du -h "$archive" 2>/dev/null | awk '{print $1}')
  count=$(printf '%s\n' "$existing" | wc -w | tr -d ' ')
  printf '[chezmoi-safe] pre-apply snapshot of %s file(s), %s -> %s\n' "$count" "$size" "$archive" >&2
fi

# Retention: keep 30 most recent snapshots.
( cd "$backup_dir" && ls -1t *.tar.gz 2>/dev/null | tail -n +31 ) 2>/dev/null \
  | while IFS= read -r f; do rm -f "$backup_dir/$f"; done
