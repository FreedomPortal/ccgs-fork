#!/bin/bash
# PostToolUse hook: Memory checkpoint reminder after significant file writes
# Reminds Claude to flush conversational discoveries to agent memory immediately
# Exit 0 = allow (this hook never blocks)

INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL" != "Write" ] && [ "$TOOL" != "Edit" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip if already writing to agent memory -- no need to remind
if echo "$FILE_PATH" | grep -qE '\.claude/agent-memory/'; then
    exit 0
fi

# Trigger on significant design/architecture writes
if echo "$FILE_PATH" | grep -qE '(design/gdd/|docs/architecture/|design/ux/|design/narrative/)'; then
    echo "" >&2
    echo "=== MEMORY CHECKPOINT ===" >&2
    echo "A design or architecture file was just written." >&2
    echo "Before continuing: did this session surface any of the following?" >&2
    echo "  - New comparable titles or reference games" >&2
    echo "  - Design decisions, pillars, or settled questions" >&2
    echo "  - Technical constraints or architectural choices" >&2
    echo "  - Production facts (scope, dates, platform, monetization)" >&2
    echo "If yes -- write to the relevant agent memory file NOW." >&2
    echo "Crashes lose unbacked knowledge. Don't wait until session end." >&2
    echo "=========================" >&2
fi

exit 0
