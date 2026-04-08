---
allowed-tools: Bash(nc:*), Bash(curl:*), Bash(python3:*)
argument-hint: <host> <port> [port2] [port3...]
description: Check if TCP ports are open on a given host
---

# Port Checker

Check whether TCP ports are open or closed.

## Instructions

1. Parse the host and port(s) from: **$ARGUMENTS**
2. For each port, attempt a TCP connection with a 3-second timeout
3. Report each port as OPEN or CLOSED
4. Present results in a table format

## Example Output

| Host      | Port | Status |
|-----------|------|--------|
| localhost | 80   | OPEN   |
| localhost | 443  | OPEN   |
| localhost | 8080 | CLOSED |

## Example

`/port-checker:check localhost 80 443 8080`
