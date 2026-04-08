---
argument-hint: <json-string-or-file>
description: Pretty-print and validate JSON input
---

# JSON Formatter

Format and validate JSON data.

## Instructions

1. Read the input from: **$ARGUMENTS**
2. If the input looks like a file path, read the file contents
3. Parse the JSON to validate it
4. If invalid, report the error with the position
5. If valid, output the pretty-printed JSON with 2-space indentation

## Example

`/json-formatter:format {"name":"test","value":123}`
