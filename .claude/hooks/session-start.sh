#!/bin/bash
# Claude Code SessionStart hook: Load project context at session start
# Outputs context information that Claude sees when a session begins
#
# Input schema (SessionStart): No stdin input

echo "=== Claude Code Game Studios — Session Context ==="

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
    echo "Branch: $BRANCH"

    # Recent commits
    echo ""
    echo "Recent commits:"
    git log --oneline -5 2>/dev/null | while read -r line; do
        echo "  $line"
    done
fi

# Current sprint (find most recent sprint file)
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_SPRINT" ]; then
    echo ""
    echo "Active sprint: $(basename "$LATEST_SPRINT" .md)"
fi

# Current milestone
LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MILESTONE" ]; then
    echo "Active milestone: $(basename "$LATEST_MILESTONE" .md)"
fi

# Open bug count
BUG_COUNT=0
for dir in tests/playtest production; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "BUG-*.md" 2>/dev/null | wc -l)
        BUG_COUNT=$((BUG_COUNT + count))
    fi
done
if [ "$BUG_COUNT" -gt 0 ]; then
    echo "Open bugs: $BUG_COUNT"
fi

# Code health quick check
if [ -d "src" ]; then
    TODO_COUNT=$(grep -r "TODO" src/ 2>/dev/null | wc -l)
    FIXME_COUNT=$(grep -r "FIXME" src/ 2>/dev/null | wc -l)
    if [ "$TODO_COUNT" -gt 0 ] || [ "$FIXME_COUNT" -gt 0 ]; then
        echo ""
        echo "Code health: ${TODO_COUNT} TODOs, ${FIXME_COUNT} FIXMEs in src/"
    fi
fi

# --- Active session state recovery ---
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "=== ACTIVE SESSION STATE DETECTED ==="
    echo "A previous session left state at: $STATE_FILE"
    echo "Read this file to recover context and continue where you left off."
    echo ""
    echo "Quick summary:"
    head -20 "$STATE_FILE" 2>/dev/null
    TOTAL_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null)
    if [ "$TOTAL_LINES" -gt 20 ]; then
        echo "  ... ($TOTAL_LINES total lines — read the full file to continue)"
    fi
    echo "=== END SESSION STATE PREVIEW ==="
fi

# --- Publishing pipeline check ---
ROADMAP_FILE="production/publishing/publishing-roadmap.md"
COMMUNITY_FILE="production/publishing/community-status.md"

echo ""
echo "=== PUBLISHING PIPELINE ==="

if [ ! -f "$ROADMAP_FILE" ]; then
    echo "⚠️  No publishing roadmap found."
    echo "   Publishing work should start in pre-production — not at launch."
    echo "   Run /marketing-plan to create your publishing roadmap now."
else
    echo "Publishing roadmap: found"

    # Count overdue items (lines with 🔴)
    OVERDUE_COUNT=$(grep -c "🔴" "$ROADMAP_FILE" 2>/dev/null || echo 0)
    # Count unlocked items (lines with 🟡)
    UNLOCKED_COUNT=$(grep -c "🟡" "$ROADMAP_FILE" 2>/dev/null || echo 0)

    if [ "$OVERDUE_COUNT" -gt 0 ]; then
        echo "🔴 Overdue publishing tasks: $OVERDUE_COUNT"
        grep "🔴" "$ROADMAP_FILE" 2>/dev/null | head -3 | while read -r line; do
            echo "   $line"
        done
        if [ "$OVERDUE_COUNT" -gt 3 ]; then
            echo "   ... ($OVERDUE_COUNT total — run /publish-check for full list)"
        fi
    fi

    if [ "$UNLOCKED_COUNT" -gt 0 ]; then
        echo "🟡 Publishing tasks unlocked by current dev stage: $UNLOCKED_COUNT"
        grep "🟡" "$ROADMAP_FILE" 2>/dev/null | head -3 | while read -r line; do
            echo "   $line"
        done
        if [ "$UNLOCKED_COUNT" -gt 3 ]; then
            echo "   ... ($UNLOCKED_COUNT total — run /publish-check for full list)"
        fi
    fi

    if [ "$OVERDUE_COUNT" -eq 0 ] && [ "$UNLOCKED_COUNT" -eq 0 ]; then
        echo "✅ No overdue or unlocked publishing tasks."
    fi
fi

# Community status summary
if [ -f "$COMMUNITY_FILE" ]; then
    # Find platforms with no recent post (lines containing "—" or "not set up")
    INACTIVE=$(grep -c "not set up\|—\|No posts" "$COMMUNITY_FILE" 2>/dev/null || echo 0)
    if [ "$INACTIVE" -gt 0 ]; then
        echo "💬 Community: $INACTIVE platform(s) inactive or not set up"
        echo "   Run /community-plan to review."
    else
        echo "💬 Community: active"
    fi
fi

echo "=== END PUBLISHING CHECK ==="

echo "==================================="
exit 0
