---
allowed-tools: Bash(docker:*)
description: Show running Docker containers and their resource usage
---

# Docker Status

Show the status of Docker containers.

## Instructions

1. Run `docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"` to list running containers
2. Run `docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"` for resource usage
3. Combine into a single formatted report
4. Highlight any containers that are restarting or unhealthy

## Example

`/docker-helper:status`
