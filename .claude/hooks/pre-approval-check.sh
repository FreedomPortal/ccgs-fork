#!/bin/bash
# PreToolUse hook: Draft-first enforcement for AskUserQuestion approval gates
# Reads production/autosave-mode.txt to determine behavior:
#   off     = exit 0 immediately, no action
#   remind  = print reminder to stderr, allow call through (default)
#   enforce = check for recent draft; block with exit 2 if none found
# Default when file missing: remind

INPUT=$(cat)

# Only act on AskUserQuestion calls
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL" != "AskUserQuestion" ]; then
    exit 0
fi

# Read autosave mode (default: remind)
MODE="remind"
if [ -f "production/autosave-mode.txt" ]; then
    MODE=$(cat "production/autosave-mode.txt" | tr -d '[:space:]')
fi

# off = do nothing
if [ "$MODE" = "off" ]; then
    exit 0
fi

# Check for approval-gate language in questions
QUESTIONS=$(echo "$INPUT" | jq -r '.tool_input.questions[].question // empty' 2>/dev/null)
if ! echo "$QUESTIONS" | grep -qiE '(may I write|write this|shall I write|write the|write.*sprint|write.*review|write.*report|write.*verdict|write.*plan|save this|create this sprint)'; then
    exit 0
fi

# Approval gate detected
if [ "$MODE" = "enforce" ]; then
    # Check if a draft was written in the last 3 minutes
    DRAFT_OK=0
    DRAFTS_DIR="production/session-state/drafts"
    if [ -d "$DRAFTS_DIR" ]; then
        if find "$DRAFTS_DIR" -type f -mmin -3 2>/dev/null | grep -q .; then
            DRAFT_OK=1
        fi
    fi

    if [ "$DRAFT_OK" = "0" ]; then
        echo "" >&2
        echo "=== DRAFT-FIRST BLOCK (enforce mode) ===" >&2
        echo "Approval gate blocked: no draft found in production/session-state/drafts/" >&2
        echo "modified within the last 3 minutes." >&2
        echo "" >&2
        echo "Required action: write the work product to" >&2
        echo "  production/session-state/drafts/[skill]-draft-YYYYMMDD-HHMMSS.md" >&2
        echo "then retry." >&2
        echo "" >&2
        echo "Change level: edit production/autosave-mode.txt (off | remind | enforce)" >&2
        echo "Or run: /autosave-mode" >&2
        echo "=======================================" >&2
        exit 2
    fi
    # Draft exists — allow through
    exit 0
fi

# remind mode — print warning, allow through
echo "" >&2
echo "=== DRAFT-FIRST REMINDER ===" >&2
echo "Approval gate detected. Ensure work product is written to" >&2
echo "  production/session-state/drafts/[skill]-draft-YYYYMMDD-HHMMSS.md" >&2
echo "BEFORE this approval call. Crash at [y/N] = all work lost." >&2
echo "" >&2
echo "Change level: /autosave-mode (off | remind | enforce)" >&2
echo "=============================" >&2
exit 0
