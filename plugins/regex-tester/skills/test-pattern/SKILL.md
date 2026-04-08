---
description: Test a regular expression against input text and explain the pattern
triggers:
  - test regex
  - regex match
  - pattern test
allowed-tools: Bash(python3:*)
---

# Regex Tester

Test and explain regular expressions.

## Instructions

When the user asks to test a regex pattern:

1. Identify the regex pattern and the test string from context
2. Run the pattern against the test string
3. Show all matches with their positions
4. Show captured groups if any
5. Provide a plain-English explanation of what the regex does

## Example

User: "test regex `\d{3}-\d{4}` against '555-1234 and 666-7890'"

Response should show:
- Match 1: "555-1234" at position 0-7
- Match 2: "666-7890" at position 13-20
- Explanation: Matches 3 digits, a hyphen, then 4 digits
