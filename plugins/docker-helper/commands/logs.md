---
allowed-tools: Bash(docker:*)
argument-hint: <container-name> [--lines=50]
description: Tail logs from a Docker container
---

# Docker Logs

View recent logs from a Docker container.

## Instructions

1. Parse the container name and optional line count from: **$ARGUMENTS**
2. Default to 50 lines if not specified
3. Run `docker logs --tail N <container>` to fetch the logs
4. Output the log lines with timestamps if available
5. If the container is not found, list available containers

## Example

`/docker-helper:logs my-app --lines=100`
