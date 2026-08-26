#!/usr/bin/env bash
# Claude Code status line: user@host path | branch | model | ctx% | rate-limit | session cost
# Styled after the akccakcctw zsh theme (two-line ╭─ / ╰─ prompt).
# Input: JSON via stdin (Claude Code statusLine schema)

set -uo pipefail

INPUT=$(cat)

RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
BLUE=$'\033[34m'
WHITE=$'\033[37m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'
SEP="${DIM}│${RESET}"

# 1) cwd ─────────────────────────────────────────────────────────────────────
CWD=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$INPUT")
[ -z "$CWD" ] && CWD="$(pwd)"
DISPLAY_CWD="${CWD/#$HOME/\~}"

# 2) git branch ──────────────────────────────────────────────────────────────
GIT_BRANCH=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null \
            || git -C "$CWD" rev-parse --short HEAD 2>/dev/null \
            || echo "")

# 3) model ───────────────────────────────────────────────────────────────────
MODEL_NAME=$(jq -r '.model.display_name // .model.id // "unknown"' <<<"$INPUT")
MODEL_ID=$(jq -r '.model.id // ""' <<<"$INPUT")

# 4) context remaining ───────────────────────────────────────────────────────
# Determine context window size from model id
case "$MODEL_ID" in
  *"[1m]"*|*"-1m"*) CTX_LIMIT=1000000 ;;
  *) CTX_LIMIT=200000 ;;
esac

TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
USED_TOKENS=0
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  # Find the most recent assistant message with usage data; sum input + cache tokens
  USED_TOKENS=$(tac "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.message.usage) | .message.usage
             | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' 2>/dev/null \
    | head -1)
  USED_TOKENS=${USED_TOKENS:-0}
fi

if [ "$USED_TOKENS" -gt 0 ]; then
  REMAINING=$(( CTX_LIMIT - USED_TOKENS ))
  PCT=$(( REMAINING * 100 / CTX_LIMIT ))
  [ "$PCT" -lt 0 ] && PCT=0
  if   [ "$PCT" -le 10 ]; then CTX_COLOR="$RED"
  elif [ "$PCT" -le 25 ]; then CTX_COLOR="$YELLOW"
  else                          CTX_COLOR="$GREEN"
  fi
  # Format remaining as k/M for readability
  if [ "$REMAINING" -ge 1000000 ]; then
    HUMAN=$(awk "BEGIN{printf \"%.1fM\", $REMAINING/1000000}")
  elif [ "$REMAINING" -ge 1000 ]; then
    HUMAN=$(awk "BEGIN{printf \"%.0fk\", $REMAINING/1000}")
  else
    HUMAN="$REMAINING"
  fi
  CTX_DISPLAY="${CTX_COLOR}ctx ${PCT}% (${HUMAN} left)${RESET}"
else
  CTX_DISPLAY="${DIM}ctx --${RESET}"
fi

# 5) rate limits (5h session + 7d weekly) ────────────────────────────────────
# Claude Code >= 2.1.x puts server-reported quota on stdin as
#   .rate_limits.{five_hour,seven_day,seven_day_opus,...}
#     = { used_percentage: 0-100, resets_at: <unix epoch> }
# (some builds emit utilization / ISO-8601 instead — both are handled below)
# These are authoritative — prefer them over any local estimate.

# Humanize seconds-until-reset: 3d4h / 2h13m / 47m
human_left() {
  awk -v s="$1" 'BEGIN{
    if (s <= 0) { print "now"; exit }
    d = int(s/86400); h = int((s%86400)/3600); m = int((s%3600)/60)
    if (d > 0)      { if (h > 0) printf "%dd%dh", d, h; else printf "%dd", d }
    else if (h > 0) { if (m > 0) printf "%dh%dm", h, m; else printf "%dh", h }
    else            { printf "%dm", (m > 0 ? m : 1) }
  }'
}

pct_color() {
  if   [ "$1" -ge 90 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "$1" -ge 70 ] 2>/dev/null; then printf '%s' "$YELLOW"
  else                                   printf '%s' "$GREEN"
  fi
}

# Render one window: label + rounded utilization + time until reset.
render_window() {
  local key="$1" label="$2" util resets_at secs
  util=$(jq -r --arg k "$key" '.rate_limits[$k] | (.used_percentage // .utilization) // empty' <<<"$INPUT" 2>/dev/null)
  [ -z "$util" ] && return 1
  util=$(awk "BEGIN{printf \"%.0f\", $util}")

  local out="$(pct_color "$util")${label} ${util}%${RESET}"

  # resets_at is a unix epoch on current builds; older/other surfaces use ISO 8601.
  resets_at=$(jq -r --arg k "$key" '.rate_limits[$k].resets_at // empty' <<<"$INPUT" 2>/dev/null)
  if [ -n "$resets_at" ]; then
    case "$resets_at" in
      ''|*[!0-9]*) EPOCH=$(date -d "$resets_at" +%s 2>/dev/null || echo 0) ;;
      *)           EPOCH="$resets_at" ;;
    esac
    secs=$(( EPOCH - $(date +%s) ))
    [ "$secs" -gt 0 ] 2>/dev/null && out="${out}${DIM} ($(human_left "$secs"))${RESET}"
  fi
  printf '%s' "$out"
}

FIVE_H_DISPLAY=$(render_window five_hour "5h" || true)
# Prefer the model-specific weekly cap when present (Opus/Sonnet have their own).
WEEK_DISPLAY=""
case "$MODEL_ID" in
  *opus*)   WEEK_DISPLAY=$(render_window seven_day_opus   "wk" || true) ;;
  *sonnet*) WEEK_DISPLAY=$(render_window seven_day_sonnet "wk" || true) ;;
esac
[ -z "$WEEK_DISPLAY" ] && WEEK_DISPLAY=$(render_window seven_day "wk" || true)

RATE_DISPLAY="$FIVE_H_DISPLAY"

# Fallback: no rate_limits on stdin (API key / Bedrock / Vertex). Estimate via
# ccusage, whose limit is derived from the user's historical max block usage.
if [ -n "$RATE_DISPLAY" ]; then
  RATE_JSON=""
elif command -v ccusage >/dev/null 2>&1; then
  RATE_JSON=$(timeout 3 ccusage blocks --json --active --token-limit max 2>/dev/null || echo "")
elif command -v bunx >/dev/null 2>&1; then
  RATE_JSON=$(timeout 3 bunx --silent ccusage blocks --json --active --token-limit max 2>/dev/null || echo "")
else
  RATE_JSON=""
fi

if [ -n "$RATE_JSON" ]; then
  BLOCK_TOK=$(jq -r '.blocks[0].totalTokens // empty' <<<"$RATE_JSON" 2>/dev/null)
  BLOCK_LIMIT=$(jq -r '.blocks[0].tokenLimitStatus.limit // empty' <<<"$RATE_JSON" 2>/dev/null)
  BLOCK_LEFT=$(jq -r '.blocks[0].projection.remainingMinutes // empty' <<<"$RATE_JSON" 2>/dev/null)

  BLOCK_PCT=""
  if [ -n "$BLOCK_TOK" ] && [ -n "$BLOCK_LIMIT" ] && [ "$BLOCK_LIMIT" -gt 0 ] 2>/dev/null; then
    BLOCK_PCT=$(awk "BEGIN{printf \"%.0f\", $BLOCK_TOK * 100 / $BLOCK_LIMIT}")
  fi

  if [ -n "$BLOCK_PCT" ]; then
    if   [ "$BLOCK_PCT" -ge 90 ] 2>/dev/null; then RATE_COLOR="$RED"
    elif [ "$BLOCK_PCT" -ge 70 ] 2>/dev/null; then RATE_COLOR="$YELLOW"
    else                                            RATE_COLOR="$GREEN"
    fi
    RATE_DISPLAY="${RATE_COLOR}5h ${BLOCK_PCT}%${RESET}"
    if [ -n "$BLOCK_LEFT" ]; then
      if [ "$BLOCK_LEFT" -ge 60 ] 2>/dev/null; then
        LEFT_HUMAN=$(awk "BEGIN{h=int($BLOCK_LEFT/60); m=$BLOCK_LEFT%60; if(m==0) printf \"%dh\", h; else printf \"%dh%dm\", h, m}")
      else
        LEFT_HUMAN="${BLOCK_LEFT}m"
      fi
      RATE_DISPLAY="${RATE_DISPLAY}${DIM} (${LEFT_HUMAN} left)${RESET}"
    fi
  fi
fi
[ -z "$RATE_DISPLAY" ] && RATE_DISPLAY="${DIM}rl n/a${RESET}"

# 6) session cost ────────────────────────────────────────────────────────────
COST=$(jq -r '.cost.total_cost_usd // empty' <<<"$INPUT")
DUR_MS=$(jq -r '.cost.total_duration_ms // 0' <<<"$INPUT")
if [ -n "$COST" ]; then
  COST_DISPLAY="${MAGENTA}\$$(printf '%.4f' "$COST")${RESET}"
  if [ "$DUR_MS" -gt 0 ]; then
    DUR_MIN=$(awk "BEGIN{printf \"%.0f\", $DUR_MS/60000}")
    [ "$DUR_MIN" -gt 0 ] && COST_DISPLAY="${COST_DISPLAY}${DIM} (${DUR_MIN}m)${RESET}"
  fi
else
  COST_DISPLAY="${DIM}\$--${RESET}"
fi

# 0) PS1-style identity header ───────────────────────────────────────────────
# Mirrors the akccakcctw zsh theme: ╭─ user@host  ~/path  ⎇ branch
USER_HOST="${BOLD}${GREEN}$(whoami)@$(hostname -s)${RESET}"
PS1_PATH="${BOLD}${BLUE}${DISPLAY_CWD}${RESET}"

if [ -n "$GIT_BRANCH" ]; then
  IDENTITY_LINE="╭─ ${USER_HOST}  ${PS1_PATH}  ${YELLOW}‹${GIT_BRANCH}›${RESET}"
else
  IDENTITY_LINE="╭─ ${USER_HOST}  ${PS1_PATH}"
fi

# Assemble ───────────────────────────────────────────────────────────────────
# path and branch are omitted — the user's shell prompt already shows them
PARTS=("${WHITE}${MODEL_NAME}${RESET}" "$CTX_DISPLAY" "$RATE_DISPLAY")
[ -n "$WEEK_DISPLAY" ] && PARTS+=("$WEEK_DISPLAY")
PARTS+=("$COST_DISPLAY")

INFO_LINE=""
for i in "${!PARTS[@]}"; do
  if [ "$i" -eq 0 ]; then INFO_LINE="${PARTS[$i]}"
  else INFO_LINE="${INFO_LINE} ${SEP} ${PARTS[$i]}"; fi
done

printf "%s\n╰─ %s" "$IDENTITY_LINE" "$INFO_LINE"
