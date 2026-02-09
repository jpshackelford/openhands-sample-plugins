---
allowed-tools: Bash(date:*), Bash(python3:*)
argument-hint: <timestamp-or-date>
description: Convert between Unix timestamps and human-readable dates
---

# Timestamp Converter

Convert timestamps between formats.

## Instructions

1. Read the input from: **$ARGUMENTS**
2. If the input is numeric, treat it as a Unix timestamp and convert to:
   - ISO 8601 format
   - Human-readable local time
   - Human-readable UTC time
3. If the input is a date string, convert to:
   - Unix timestamp (seconds)
   - Unix timestamp (milliseconds)
4. Show all conversions in a clear format

## Example

`/timestamp-converter:convert 1700000000`
`/timestamp-converter:convert 2024-01-15T10:30:00Z`
