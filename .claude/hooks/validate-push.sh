#!/bin/bash
# Claude Code PreToolUse hook: Validates git push commands
# Blocks pushes to main/master; warns on develop
# Exit 0 = allow, Exit 2 = block
#
# Input schema (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git push origin main" } }

INPUT=$(cat)

# Parse command -- use jq if available, fall back to grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only process git push commands
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+push'; then
    exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
MATCHED_BRANCH=""

# Check if pushing to main, master, or develop
for branch in main master develop; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        MATCHED_BRANCH="$branch"
        break
    fi
    # Also check if the branch is explicitly named in the push command
    if echo "$COMMAND" | grep -qE "[[:space:]]${branch}([[:space:]]|$)"; then
        MATCHED_BRANCH="$branch"
        break
    fi
done

if [ "$MATCHED_BRANCH" = "main" ] || [ "$MATCHED_BRANCH" = "master" ]; then
    echo "" >&2
    echo "BLOCKED: Direct push to '$MATCHED_BRANCH' is not allowed." >&2
    echo "" >&2
    echo "Use a feature branch instead:" >&2
    echo "  git checkout -b feature/your-feature-name" >&2
    echo "  git push origin feature/your-feature-name" >&2
    echo "" >&2
    echo "Merge to $MATCHED_BRANCH via pull request after review." >&2
    exit 2
fi

if [ "$MATCHED_BRANCH" = "develop" ]; then
    echo "Warning: Pushing directly to 'develop'." >&2
    echo "Ensure build passes and unit tests are green before merging." >&2
fi

exit 0
