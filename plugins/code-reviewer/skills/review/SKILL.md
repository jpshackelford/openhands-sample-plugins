---
description: Review code for quality, bugs, security issues, and style improvements
triggers:
  - review this code
  - code review
  - review my changes
allowed-tools: Read, Grep, Glob, Bash(git:*)
---

# Code Review Skill

Perform a thorough code review when triggered.

## Instructions

When the user asks for a code review:

1. Identify the files or diff to review (from context, git diff, or specified files)
2. Analyze each file for:
   - **Bugs**: Logic errors, off-by-one errors, null/undefined risks
   - **Security**: Injection risks, exposed secrets, unsafe operations
   - **Performance**: N+1 queries, unnecessary re-renders, memory leaks
   - **Style**: Naming conventions, dead code, overly complex logic
3. Rate each finding as: Critical / Warning / Suggestion
4. Present findings grouped by severity
5. Include the file path and line number for each finding

## Output Format

### Critical
- `src/auth.ts:42` - Password compared without constant-time comparison

### Warnings
- `src/api.ts:15` - Missing error handling on fetch call

### Suggestions
- `src/utils.ts:88` - Consider extracting this into a helper function
