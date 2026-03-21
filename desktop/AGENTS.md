# Agent Instructions

This project uses **GitHub Issues** (`gh` CLI) for issue tracking. Repo: `jbcrane13/TableTopics`.

## Quick Reference

```bash
gh issue list --repo jbcrane13/TableTopics --label "status:ready" --state open --json number,title,labels
gh issue edit <number> --repo jbcrane13/TableTopics --add-label "status:in-progress" --remove-label "status:ready"
gh issue close <number> --repo jbcrane13/TableTopics --comment "Done: <summary>"
```

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** with file operations to avoid hanging on confirmation prompts.

Shell commands like `cp`, `mv`, and `rm` may be aliased to include `-i` (interactive) mode on some systems, causing the agent to hang indefinitely waiting for y/n input.

**Use these forms instead:**
```bash
# Force overwrite without prompting
cp -f source dest           # NOT: cp source dest
mv -f source dest           # NOT: mv source dest
rm -f file                  # NOT: rm file

# For recursive operations
rm -rf directory            # NOT: rm -r directory
cp -rf source dest          # NOT: cp -r source dest
```

**Other commands that may prompt:**
- `scp` - use `-o BatchMode=yes` for non-interactive
- `ssh` - use `-o BatchMode=yes` to fail instead of prompting
- `apt-get` - use `-y` flag
- `brew` - use `HOMEBREW_NO_AUTO_UPDATE=1` env var

<!-- BEGIN GH ISSUES -->
## Issue Tracking with GitHub Issues

**IMPORTANT**: This project uses **GitHub Issues via `gh` CLI** for ALL issue tracking. Do NOT use `bd`/beads, markdown TODOs, or other tracking methods.

### Quick Start

```bash
# Check ready work
gh issue list --repo jbcrane13/TableTopics --label "status:ready" --state open --json number,title,labels

# Create issue
gh issue create --repo jbcrane13/TableTopics --title "Title" --body "Details" --label "type:feature,priority:medium,status:ready"

# Claim task
gh issue edit <number> --repo jbcrane13/TableTopics --add-label "status:in-progress" --remove-label "status:ready" --add-assignee "@me"

# Close when done
gh issue close <number> --repo jbcrane13/TableTopics --comment "Done: <summary>"
```

### Label Schema

**Type:** `type:bug` · `type:feature` · `type:task` · `type:epic` · `type:chore`
**Priority:** `priority:critical` · `priority:high` · `priority:medium` · `priority:low` · `priority:backlog`
**Status:** `status:ready` · `status:in-progress` · `status:blocked` · `status:review`
**Agent:** `agent:daneel` · `agent:quentin`

### Rules

- ✅ Use GitHub Issues for ALL task tracking
- ✅ Label every issue with type + priority + status
- ❌ Do NOT use `bd` / beads
- ❌ Do NOT create markdown TODO lists
<!-- END GH ISSUES -->
