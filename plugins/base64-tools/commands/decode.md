---
argument-hint: <base64-string>
description: Decode a Base64 string to plain text
---

# Base64 Decode

Decode a Base64-encoded string back to plain text.

## Instructions

1. Read the Base64 string from: **$ARGUMENTS**
2. Handle both standard and URL-safe Base64 variants
3. Decode and output the plain text result
4. If decoding fails, report that the input is not valid Base64

## Example

`/base64-tools:decode SGVsbG8gV29ybGQ=`
