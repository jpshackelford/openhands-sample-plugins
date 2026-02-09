---
allowed-tools: Bash(mkdir:*), Bash(npm:*), Write
argument-hint: <project-name>
description: Scaffold a new Node.js project with package.json and basic structure
---

# Node.js Project Scaffold

Create a new Node.js project from scratch.

## Instructions

1. Read the project name from: **$ARGUMENTS**
2. Create the directory structure:
   ```
   <project-name>/
   ├── src/
   │   └── index.js
   ├── tests/
   ├── package.json
   ├── .gitignore
   └── README.md
   ```
3. Generate a package.json with the project name, version 0.1.0, and a start script
4. Create a minimal .gitignore for Node.js
5. Create a README.md with the project name as title

## Example

`/project-init:node my-api`
