---
allowed-tools: Bash(find:*), Bash(wc:*)
description: Count files grouped by extension in the current directory
---

# File Counter

Count all files in the current directory tree, grouped by file extension.

## Instructions

1. Use find to list all files recursively in the current directory
2. Extract file extensions
3. Group and count by extension
4. Present results sorted by count (highest first)

## Example Output

| Extension | Count |
|-----------|-------|
| .ts       | 142   |
| .js       | 87    |
| .json     | 23    |
| .md       | 15    |
