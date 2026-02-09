---
allowed-tools: Bash(git:*)
argument-hint: [number-of-days]
description: Summarize recent git activity for the repository
---

# Git Summary

Provide a summary of recent git activity.

## Instructions

1. Parse the number of days from: **$ARGUMENTS** (default to 7 if not specified)
2. Run `git log --since="N days ago" --oneline` to get recent commits
3. Run `git shortlog --since="N days ago" -sn` to get contributor stats
4. Run `git branch -a` to list branches
5. Present a formatted summary with:
   - Total commits in the period
   - Top contributors
   - Active branches
   - Most recent commit message

## Example

`/git-summary:recent 30`
