---
allowed-tools: Bash(curl:*)
argument-hint: <method> <url> [--body <json>] [--header <key:value>]
description: Send an HTTP request and display the response
---

# API Request

Send an HTTP request to an API endpoint.

## Instructions

1. Parse arguments from: **$ARGUMENTS**
2. Extract the HTTP method (GET, POST, PUT, DELETE, PATCH)
3. Extract the URL
4. Extract optional body (JSON) and headers
5. Build and execute a curl command with:
   - `-s` for silent mode
   - `-w "\n%{http_code}"` to capture status code
   - `-H "Content-Type: application/json"` if body is provided
6. Display:
   - Status code with color (2xx green, 4xx yellow, 5xx red)
   - Response headers (key ones)
   - Response body (pretty-printed if JSON)
   - Response time

## Example

`/api-tester:request GET https://api.example.com/users`
`/api-tester:request POST https://api.example.com/users --body {"name":"test"}`
