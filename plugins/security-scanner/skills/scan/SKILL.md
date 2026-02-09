---
description: Scan the current project for common security vulnerabilities and misconfigurations
triggers:
  - security scan
  - check for vulnerabilities
  - find security issues
allowed-tools: Read, Grep, Glob, Bash(git:*)
model: sonnet
context: fork
agent: general-purpose
---

# Security Scanner Skill

Perform a security scan of the current codebase.

## Instructions

When the user requests a security scan:

1. **Secrets Detection**: Search for hardcoded credentials, API keys, tokens, passwords
   - Look for patterns like `password = "`, `api_key`, `secret`, `token`
   - Check .env files are in .gitignore
   - Scan git history for accidentally committed secrets

2. **Dependency Vulnerabilities**: Check for known issues
   - Look at package.json / requirements.txt / go.mod for dependencies
   - Flag any obviously outdated or known-vulnerable versions

3. **Code Patterns**: Identify risky code patterns
   - SQL string concatenation (injection risk)
   - `eval()` or `exec()` usage
   - Unsafe deserialization
   - Missing input validation on user-facing endpoints

4. **Configuration**: Check security-relevant configs
   - CORS settings
   - HTTPS enforcement
   - Authentication middleware usage

5. Present findings grouped by severity (Critical / High / Medium / Low)

## Output Format

### Scan Summary
- Files scanned: N
- Issues found: N (X critical, Y high, Z medium)

### Findings
Each finding includes: severity, file, line, description, and remediation.
