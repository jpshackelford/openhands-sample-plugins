---
allowed-tools: Bash(mkdir:*), Bash(python3:*), Write
argument-hint: <project-name>
description: Scaffold a new Python project with pyproject.toml and basic structure
---

# Python Project Scaffold

Create a new Python project from scratch.

## Instructions

1. Read the project name from: **$ARGUMENTS**
2. Create the directory structure:
   ```
   <project-name>/
   ├── src/<project_name>/
   │   └── __init__.py
   ├── tests/
   │   └── __init__.py
   ├── pyproject.toml
   ├── .gitignore
   └── README.md
   ```
3. Generate a pyproject.toml with project metadata
4. Create a minimal .gitignore for Python
5. Create a README.md with the project name

## Example

`/project-init:python my-library`
