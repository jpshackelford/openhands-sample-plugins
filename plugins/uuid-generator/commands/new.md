---
allowed-tools: Bash(python3:*), Bash(uuidgen:*)
argument-hint: [count] [--v7]
description: Generate one or more UUIDs
---

# UUID Generator

Generate universally unique identifiers.

## Instructions

1. Parse arguments from: **$ARGUMENTS**
2. Determine count (default 1) and version (default v4)
3. Generate the requested number of UUIDs
4. Output each UUID on its own line
5. If multiple, also show the count generated

## Example

`/uuid-generator:new 5`
`/uuid-generator:new 1 --v7`
