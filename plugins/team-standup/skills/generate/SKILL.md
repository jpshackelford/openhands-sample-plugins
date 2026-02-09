---
description: Generate a daily standup summary from recent git activity
triggers:
  - standup
  - daily standup
  - what did I do yesterday
allowed-tools: Bash(git:*), Bash(gh:*)
disable-model-invocation: false
user-invocable: true
---

# Team Standup Generator

Generate a standup summary from git and GitHub activity.

## Instructions

When the user asks for a standup summary:

1. **Yesterday's Work**: Run `git log --since="yesterday" --until="today" --author="$(git config user.name)" --oneline` to find commits
2. **Today's Plan**: Check for open issues assigned to the user with `gh issue list --assignee @me`
3. **Blockers**: Check for any PRs awaiting review with `gh pr list --author @me`

4. Format the output as:

### Standup - [Date]

**Done:**
- [List of yesterday's commits/work items]

**Today:**
- [List of planned work from assigned issues]

**Blockers:**
- [Any PRs waiting for review or open questions]

## Example

User: "standup"
