---
allowed-tools: Read
argument-hint: <file-path>
description: Generate a table of contents from a Markdown file's headings
---

# Markdown TOC Generator

Generate a table of contents for a Markdown file.

## Instructions

1. Read the file specified in: **$ARGUMENTS**
2. Extract all headings (lines starting with #, ##, ###, etc.)
3. Skip the first H1 if it appears to be the document title
4. Generate a nested Markdown list with links:
   - H2 becomes top-level items
   - H3 becomes indented sub-items
   - H4 becomes double-indented sub-items
5. Create anchor links using GitHub-style slug format (lowercase, hyphens)
6. Output the TOC as a Markdown list

## Example Output

```markdown
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
- [Usage](#usage)
  - [CLI Options](#cli-options)
- [Contributing](#contributing)
```

## Example

`/markdown-toc:generate README.md`
