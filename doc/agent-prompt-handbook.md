# Agent Prompt Handbook

A style guide for writing effective AgentSkills and Plugins for OpenHands and Claude Code.

> **Modeled after the Harbrace College Handbook**: Each rule has a code (e.g., "10b", "91a") that can be referenced when reviewing prompts. When you see "**10b**" marked on your skill, look up rule 10b to learn how to fix the issue.

---

## Table of Contents

- [Part 1: Foundations (1-10)](#part-1-foundations)
  - [1 – Context Window as Public Good](#1--context-window-as-public-good)
  - [2 – Progressive Disclosure Principle](#2--progressive-disclosure-principle)
  - [3 – Degrees of Freedom](#3--degrees-of-freedom)
- [Part 2: Skill Structure (10-20)](#part-2-skill-structure)
  - [10 – SKILL.md Essentials](#10--skillmd-essentials)
  - [11 – Bundled Resources](#11--bundled-resources)
  - [12 – What NOT to Include](#12--what-not-to-include)
- [Part 3: Description & Triggering (20-30)](#part-3-description--triggering)
  - [20 – Writing Effective Descriptions](#20--writing-effective-descriptions)
  - [21 – Trigger Patterns](#21--trigger-patterns)
  - [22 – Triggering Anti-patterns](#22--triggering-anti-patterns)
- [Part 4: Instruction Writing (30-40)](#part-4-instruction-writing)
  - [30 – Voice and Tone](#30--voice-and-tone)
  - [31 – Workflow Patterns](#31--workflow-patterns)
  - [32 – Output Patterns](#32--output-patterns)
- [Part 5: Organization & Architecture (40-50)](#part-5-organization--architecture)
  - [40 – Progressive Disclosure Patterns](#40--progressive-disclosure-patterns)
  - [41 – Reference File Guidelines](#41--reference-file-guidelines)
  - [42 – Size Limits](#42--size-limits)
- [Part 6: Plugins & Slash Commands (50-60)](#part-6-plugins--slash-commands)
  - [50 – Plugin Structure](#50--plugin-structure)
  - [51 – Slash Command Design](#51--slash-command-design)
  - [52 – Plugin Sources](#52--plugin-sources)
- [Part 7: Common Errors (60-70)](#part-7-common-errors)
  - [60 – Context Bloat](#60--context-bloat)
  - [61 – Triggering Problems](#61--triggering-problems)
  - [62 – Resource Misuse](#62--resource-misuse)
- [Part 8: Testing & Iteration (70-80)](#part-8-testing--iteration)
  - [70 – Testing Skills](#70--testing-skills)
  - [71 – Iteration Workflow](#71--iteration-workflow)
- [Part 9: Prompt Factoring (80-90)](#part-9-prompt-factoring)
  - [80 – Signs Your Prompt Needs Factoring](#80--signs-your-prompt-needs-factoring)
  - [81 – Factoring Strategies](#81--factoring-strategies)
  - [82 – Inline Code Anti-Patterns](#82--inline-code-anti-patterns)
- [Part 10: Multi-Phase Workflows (90-100)](#part-10-multi-phase-workflows)
  - [90 – Phase Separation Principle](#90--phase-separation-principle)
  - [91 – Planning Phase Best Practices](#91--planning-phase-best-practices)
  - [92 – Execution Phase Best Practices](#92--execution-phase-best-practices)
  - [93 – Verification Phase Best Practices](#93--verification-phase-best-practices)
- [Part 11: Assumption Verification (100-110)](#part-11-assumption-verification)
  - [100 – The Assumption Verification Principle](#100--the-assumption-verification-principle)
  - [101 – Verification Patterns](#101--verification-patterns)
  - [102 – Writing Conditional Instructions](#102--writing-conditional-instructions)
- [Part 12: Orchestration (110-120)](#part-12-orchestration)
  - [110 – Explicit Tool Invocation](#110--explicit-tool-invocation)
  - [111 – Orchestrator Pattern](#111--orchestrator-pattern)
  - [112 – Scope Management](#112--scope-management)
- [Appendices](#appendices)
  - [Appendix A: Quick Reference Card](#appendix-a-quick-reference-card)
  - [Appendix B: Glossary](#appendix-b-glossary)
  - [Appendix C: Factoring Checklist](#appendix-c-factoring-checklist)
  - [Appendix D: Phase Template](#appendix-d-phase-template)

---

# Part 1: Foundations

## 1 – Context Window as Public Good

The context window is a shared, finite resource. Skills share it with the system prompt, conversation history, other skills' metadata, and the user's actual request. Every token you add has a cost.

### 1a – Token cost awareness

Challenge each piece of information: "Does this paragraph justify its token cost?" If the answer is no, cut it.

**Example:**

❌ **Wasteful:**
```markdown
## Introduction to PDF Processing

PDF (Portable Document Format) is a file format developed by Adobe in 1992.
PDFs are widely used for documents that need to maintain their formatting
across different systems. This skill helps you work with PDF files in
various ways including extraction, modification, and creation...
```

✅ **Efficient:**
```markdown
## PDF Processing

Extract text, modify pages, or create new PDFs.
```

### 1b – Default assumption: The agent is smart

OpenHands already understands programming, file formats, APIs, and common patterns. Only add context that OpenHands doesn't already have—proprietary schemas, company-specific conventions, or non-obvious procedural knowledge.

**Ask yourself:** "Would a senior engineer need this explanation?"

### 1c – Challenge every paragraph

Before including any content, ask:
- Does OpenHands really need this explanation?
- Is this information already in OpenHands' training data?
- Can I show this with a 3-line example instead of a 10-line explanation?

**Prefer concise examples over verbose explanations.**

---

## 2 – Progressive Disclosure Principle

Skills use a three-level loading system to manage context efficiently.

### 2a – Metadata (always loaded)

The `name` and `description` fields from YAML frontmatter are **always** in context (~100 words). This is how OpenHands decides whether to activate your skill.

### 2b – Body (when triggered)

The SKILL.md body is loaded only **after** the skill triggers. Keep it under 500 lines and under 5,000 words.

### 2c – Bundled resources (on demand)

Files in `scripts/`, `references/`, and `assets/` are loaded only when OpenHands determines they're needed. Scripts can be executed without being read into context at all.

**Implication:** Put "when to use" information in the description (2a), not in the body (2b). The body isn't loaded until after triggering, so "When to Use This Skill" sections in the body don't help OpenHands decide to use the skill.

---

## 3 – Degrees of Freedom

Match the level of specificity to the task's fragility and variability. Think of OpenHands as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many valid routes (high freedom).

### 3a – High freedom (guidance-based)

Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Example:**
```markdown
Choose an appropriate data structure based on the access patterns.
Consider using a hash map for O(1) lookups or a sorted array for range queries.
```

### 3b – Medium freedom (templates/parameters)

Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.

**Example:**
```markdown
Use this template for error responses:

{
  "error": "<error_code>",
  "message": "<human_readable_message>",
  "details": { /* optional context */ }
}

Adjust fields based on the specific error type.
```

### 3c – Low freedom (scripts/sequences)

Use when operations are fragile/error-prone, consistency is critical, or a specific sequence must be followed.

**Example:**
```markdown
Execute these steps IN ORDER:

1. Run `scripts/backup_db.sh` (REQUIRED before any changes)
2. Run `scripts/migrate.py --dry-run` to preview
3. Run `scripts/migrate.py --apply` only if dry-run succeeds
4. Run `scripts/verify_migration.sh` to confirm

DO NOT skip steps or change order.
```

---

# Part 2: Skill Structure

## 10 – SKILL.md Essentials

Every skill requires a SKILL.md file with YAML frontmatter and a Markdown body.

### 10a – Frontmatter: `name` field

The skill name. Use lowercase with hyphens: `pdf-editor`, `bigquery-reports`, `vulnerability-fix`.

```yaml
---
name: pdf-editor
description: ...
---
```

### 10b – Frontmatter: `description` field (trigger mechanism)

**This is the most important field in your skill.** The description is the primary mechanism for triggering—it tells OpenHands when to use this skill.

Include:
1. What the skill does
2. Specific triggers/contexts for when to use it
3. File types, keywords, or scenarios that should activate it

**Example:**
```yaml
---
name: docx-editor
description: >
  Comprehensive document creation, editing, and analysis with support for
  tracked changes, comments, formatting preservation, and text extraction.
  Use when working with professional documents (.docx files) for:
  (1) Creating new documents, (2) Modifying or editing content,
  (3) Working with tracked changes, (4) Adding comments,
  or any other Word document tasks.
---
```

### 10c – Body: Instructions and guidance

The Markdown body contains instructions for using the skill. This is loaded only after the skill triggers.

- Use imperative voice ("Extract the text" not "You should extract the text")
- Keep under 500 lines
- Reference bundled resources clearly

---

## 11 – Bundled Resources

Skills can include three types of optional resources.

### 11a – `scripts/` – Deterministic, reusable code

Executable code (Python, Bash, etc.) for tasks requiring deterministic reliability or that would be rewritten repeatedly.

**When to include:**
- Same code is being rewritten repeatedly
- Deterministic reliability is needed
- Complex multi-step operations

**Benefits:**
- Token efficient (can execute without reading into context)
- Deterministic output
- Testable independently

**Example:** `scripts/rotate_pdf.py` for PDF rotation

### 11b – `references/` – Contextual documentation

Documentation loaded as-needed to inform OpenHands' thinking.

**When to include:**
- Database schemas
- API documentation
- Domain knowledge
- Company policies
- Detailed workflow guides

**Best practices:**
- If files are large (>10k words), include grep search patterns in SKILL.md
- Avoid duplication with SKILL.md content
- Keep only essential procedural instructions in SKILL.md; move details to references

**Example:** `references/schema.md` for database table schemas

### 11c – `assets/` – Output resources

Files used in output, not loaded into context.

**When to include:**
- Templates (PowerPoint, HTML boilerplate)
- Images, icons, logos
- Fonts
- Sample documents to copy/modify

**Example:** `assets/template.pptx` for presentation creation

---

## 12 – What NOT to Include

A skill should only contain essential files that directly support its functionality.

### 12a – No README.md, CHANGELOG.md

Do not include:
- README.md
- CHANGELOG.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md

### 12b – No user-facing documentation

Skills are for AI agents, not human users. Don't include documentation about how a human would use the skill.

### 12c – No auxiliary process documentation

Don't include context about:
- How the skill was created
- Setup and testing procedures
- Development decisions

**The skill should contain only what an AI agent needs to do the job at hand.**

---

# Part 3: Description & Triggering

## 20 – Writing Effective Descriptions

The description field determines when your skill activates. Write it carefully.

### 20a – What the skill does

Start with a clear statement of capability.

✅ **Good:** "Extract text from PDFs, fill PDF forms, and rotate/merge pages."

❌ **Bad:** "A helpful skill for PDF stuff."

### 20b – When to use it (triggers/contexts)

Explicitly list the scenarios that should trigger this skill.

✅ **Good:** "Use when working with .pdf files, filling forms, extracting text, or combining documents."

❌ **Bad:** (Relying on OpenHands to figure out when to use it)

### 20c – Complete enumeration of use cases

List all major use cases. Be comprehensive.

```yaml
description: >
  Query BigQuery databases for business analytics. Use when:
  (1) Generating reports on revenue, users, or engagement,
  (2) Analyzing sales pipeline or conversion metrics,
  (3) Investigating product usage patterns,
  (4) Building dashboards or data exports,
  (5) Any SQL query against the data warehouse.
```

---

## 21 – Trigger Patterns

### 21a – Keyword triggers (slash commands)

Skills can be triggered by explicit keywords like `/skill-name:command`.

```markdown
Trigger: /weather:now <city>
```

### 21b – Contextual activation

Skills can activate based on context in the conversation:
- File types being discussed (.pdf, .docx)
- Domain keywords (BigQuery, Salesforce)
- Task patterns (remediation, deployment)

### 21c – File-type associations

Associate skills with specific file types in the description:

```yaml
description: >
  Process Excel spreadsheets (.xlsx, .xls). Use when reading, writing,
  or analyzing spreadsheet data.
```

---

## 22 – Triggering Anti-patterns

### 22a – "When to Use" sections in body (not in description)

❌ **Wrong:** Putting trigger information in the SKILL.md body

```markdown
---
name: my-skill
description: Does something useful.
---

## When to Use This Skill

Use this skill when you need to...
```

The body isn't loaded until AFTER triggering. This section is useless.

✅ **Correct:** Put all "when to use" information in the description field.

### 22b – Vague descriptions

❌ **Vague:** "Helps with database tasks"

✅ **Specific:** "Query PostgreSQL databases, run migrations, and analyze query performance. Use when working with .sql files or database operations."

### 22c – Over-broad triggering

❌ **Over-broad:** "Use for any coding task"

This will activate inappropriately. Be specific about the skill's domain.

---

# Part 4: Instruction Writing

## 30 – Voice and Tone

### 30a – Use imperative/infinitive form

Write instructions as commands, not suggestions.

❌ **Wrong:** "You should extract the text from the PDF"

✅ **Correct:** "Extract the text from the PDF"

❌ **Wrong:** "It would be good to validate the input first"

✅ **Correct:** "Validate the input first"

### 30b – Concise over verbose

Cut unnecessary words.

❌ **Verbose:**
```markdown
In order to successfully complete this task, you will need to first
make sure that you have properly configured the environment variables
that are required for the API to function correctly.
```

✅ **Concise:**
```markdown
Set required environment variables before calling the API.
```

### 30c – Examples over explanations

Show, don't tell.

❌ **Explanation:**
```markdown
The date format should follow ISO 8601 standards, which means the year
comes first, followed by the month, then the day, with hyphens as separators.
```

✅ **Example:**
```markdown
Use ISO 8601 date format: `2024-01-15`
```

---

## 31 – Workflow Patterns

### 31a – Sequential workflows

For multi-step tasks, number the steps clearly:

```markdown
## Deployment Process

1. Run tests: `npm test`
2. Build: `npm run build`
3. Deploy: `npm run deploy`
4. Verify: Check /health endpoint returns 200
```

### 31b – Conditional/branching workflows

For tasks with decision points:

```markdown
## Migration Workflow

1. Determine the migration type:
   - **Schema change?** → Follow "Schema Migration" below
   - **Data migration?** → Follow "Data Migration" below

### Schema Migration
[steps]

### Data Migration
[steps]
```

### 31c – Decision trees

For complex decisions, use explicit if/then structure:

```markdown
## Error Handling

IF error is authentication failure:
  → Check token expiration, refresh if needed

IF error is rate limiting (429):
  → Wait 60 seconds, retry with exponential backoff

IF error is server error (5xx):
  → Retry up to 3 times, then escalate
```

---

## 32 – Output Patterns

### 32a – Template pattern (strict)

For strict requirements (API responses, data formats), provide exact templates:

```markdown
## Report Structure

ALWAYS use this exact structure:

# [Analysis Title]

## Executive Summary
[One-paragraph overview]

## Key Findings
- Finding 1 with supporting data
- Finding 2 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```

### 32b – Template pattern (flexible)

For flexible guidance, indicate adaptability:

```markdown
## Report Structure

Use this as a starting point, adapting as needed:

# [Title]

## Summary
[Overview - adjust length based on complexity]

## Details
[Organize sections based on what you discover]

## Next Steps
[Tailor to the specific context]
```

### 32c – Examples pattern (input/output pairs)

For style-dependent output, provide examples:

```markdown
## Commit Message Format

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output:
```
fix(reports): correct date formatting in timezone conversion
```
```

---

# Part 5: Organization & Architecture

## 40 – Progressive Disclosure Patterns

### 40a – High-level guide with references

Keep SKILL.md lean, link to details:

```markdown
# PDF Processing

## Quick Start
Extract text with pdfplumber: `pdfplumber.open(path).pages[0].extract_text()`

## Advanced Features
- **Form filling**: See [references/forms.md](references/forms.md)
- **API reference**: See [references/api.md](references/api.md)
- **Examples**: See [references/examples.md](references/examples.md)
```

### 40b – Domain-specific organization

For skills with multiple domains, organize by domain:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, OpenHands only reads `sales.md`.

### 40c – Conditional details

Show basic content, link to advanced:

```markdown
# Document Processing

## Basic Editing
Modify XML directly for simple edits.

## Advanced Features
- **Tracked changes**: See [references/redlining.md](references/redlining.md)
- **OOXML internals**: See [references/ooxml.md](references/ooxml.md)
```

---

## 41 – Reference File Guidelines

### 41a – Keep one level deep from SKILL.md

All reference files should link directly from SKILL.md. Avoid:

```
SKILL.md → references/main.md → references/details/specific.md  ❌
```

Instead:

```
SKILL.md → references/specific.md  ✅
```

### 41b – Add TOC for files >100 lines

For longer reference files, include a table of contents:

```markdown
# API Reference

## Table of Contents
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Error Codes](#error-codes)
- [Rate Limits](#rate-limits)

## Authentication
...
```

### 41c – Avoid deeply nested references

References should not reference other references. Keep the structure flat.

---

## 42 – Size Limits

### 42a – SKILL.md body: <500 lines

If your SKILL.md exceeds 500 lines, it needs factoring. See [Part 9: Prompt Factoring](#part-9-prompt-factoring).

### 42b – Metadata/description: ~100 words

Keep the description comprehensive but concise—aim for about 100 words.

### 42c – When to split content

Split content when:
- Body exceeds 500 lines
- Multiple distinct workflows exist
- Domain-specific sections are independent
- Content is only needed for specific use cases

---

# Part 6: Plugins & Slash Commands

## 50 – Plugin Structure

Plugins follow the Claude Code plugin format.

### 50a – `.claude-plugin/` or `.plugin/` directory

Plugins contain a manifest directory:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── run.md
└── skills/
    └── helper.md
```

### 50b – `plugin.json` manifest

The manifest describes the plugin:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description of what this plugin does"
}
```

### 50c – `commands/` directory

Slash commands are defined as Markdown files in `commands/`:

```
commands/
├── run.md      → /my-plugin:run
├── status.md   → /my-plugin:status
└── config.md   → /my-plugin:config
```

---

## 51 – Slash Command Design

### 51a – Naming conventions (`/plugin:command`)

Slash commands use the format `/plugin-name:command-name`:

- `/city-weather:now`
- `/deploy:staging`
- `/db:migrate`

Use lowercase with hyphens. Keep names short but descriptive.

### 51b – `$ARGUMENTS` placeholder

Commands can reference user-provided arguments with `$ARGUMENTS`:

```markdown
---
description: Get weather for a city
argument-hint: <city-name>
---

1. Parse the city name from: **$ARGUMENTS**
2. Call the geocoding API to get coordinates
3. Fetch weather data for those coordinates
```

When user sends `/weather:now Tokyo`, `$ARGUMENTS` = "Tokyo".

### 51c – `argument-hint` frontmatter

Provide hints about expected arguments:

```yaml
---
description: Deploy to an environment
argument-hint: <environment> [--dry-run]
---
```

---

## 52 – Plugin Sources

### 52a – GitHub shorthand format

```
github:username/repository
```

Example: `github:jpshackelford/openhands-sample-plugins`

### 52b – Git URL format

```
https://github.com/username/repository.git
```

### 52c – Repository path handling (`repo_path`)

For plugins in subdirectories, use the `repo_path` field separately:

```json
{
  "source": "github:jpshackelford/openhands-sample-plugins",
  "ref": "main",
  "repo_path": "plugins/city-weather"
}
```

**Do not** append the path to the source string.

---

# Part 7: Common Errors

## 60 – Context Bloat

### 60a – Overly verbose SKILL.md

**Symptom:** SKILL.md is thousands of lines long.

**Fix:** Factor into references and scripts. See [Part 9](#part-9-prompt-factoring).

### 60b – Duplicated content across files

**Symptom:** Same information appears in SKILL.md and reference files.

**Fix:** Information should live in ONE place. Prefer references for details, SKILL.md for essential workflow.

### 60c – Loading unnecessary references

**Symptom:** References are loaded for every invocation, even when not needed.

**Fix:** Use conditional references with clear triggers. See [40c](#40c--conditional-details).

---

## 61 – Triggering Problems

### 61a – Skill never activates

**Symptoms:**
- OpenHands doesn't use your skill even when relevant
- User has to explicitly ask for the skill

**Causes:**
- Description is too vague
- Trigger keywords are missing
- Use cases aren't enumerated

**Fix:** Rewrite description with specific triggers. See [Rule 20](#20--writing-effective-descriptions).

### 61b – Skill activates incorrectly

**Symptoms:**
- Skill activates for unrelated tasks
- Skill conflicts with other skills

**Causes:**
- Description is too broad
- Trigger keywords overlap with other skills

**Fix:** Narrow the description. Be more specific about when to use.

### 61c – Conflicting skills

**Symptom:** Multiple skills activate for the same task.

**Fix:** Ensure descriptions have clear, non-overlapping triggers. Consider combining related skills.

---

## 62 – Resource Misuse

### 62a – Scripts in references

**Symptom:** Executable code is in `references/` instead of `scripts/`.

**Fix:** Move executable code to `scripts/`. References are for documentation.

### 62b – References in assets

**Symptom:** Documentation is in `assets/` instead of `references/`.

**Fix:** Move documentation to `references/`. Assets are for output files (templates, images).

### 62c – Missing resource links

**Symptom:** Resources exist but SKILL.md doesn't mention them.

**Fix:** Add explicit references to all bundled resources with clear instructions on when to use them.

---

# Part 8: Testing & Iteration

## 70 – Testing Skills

### 70a – Testing with concrete examples

Before finalizing a skill, test it with real examples:

1. List 5-10 realistic user requests
2. Verify the skill triggers appropriately for each
3. Verify the output is correct

### 70b – Script validation

All scripts must be tested:

1. Run each script with sample inputs
2. Verify output matches expectations
3. Test edge cases and error conditions

If there are many similar scripts, test a representative sample.

### 70c – Trigger verification

Verify triggering behavior:

1. Test requests that SHOULD trigger the skill
2. Test requests that SHOULD NOT trigger the skill
3. Adjust description based on results

---

## 71 – Iteration Workflow

### 71a – Use skill on real tasks

The best testing is real usage. Deploy the skill and use it.

### 71b – Identify struggles/inefficiencies

Watch for:
- Tasks where the agent struggles or fails
- Tasks that take too many steps
- Tasks where the agent ignores instructions
- Tasks where output quality is poor

### 71c – Update and re-test

Based on observations:

1. Identify root cause (unclear instructions? missing context? wrong approach?)
2. Update SKILL.md or resources
3. Re-test with the same tasks
4. Repeat until reliable

---

# Part 9: Prompt Factoring

## 80 – Signs Your Prompt Needs Factoring

### 80a – Prompt exceeds 500 lines

If your SKILL.md or prompt is more than 500 lines, it's too long. Factor it.

### 80b – Multiple distinct phases in one prompt

If your prompt contains distinct phases (planning, execution, verification), consider separating them.

❌ **Monolithic:**
```markdown
## Phase 1: Gather Context
[200 lines of context-gathering instructions]

## Phase 2: Build Plan
[300 lines of planning instructions]

## Phase 3: Execute
[400 lines of execution instructions]

## Phase 4: Verify
[200 lines of verification instructions]
```

### 80c – Repeated code/logic blocks

If you see similar code or logic repeated, extract it.

### 80d – Mixed concerns (planning + execution + verification)

Different concerns should be in different skills or clearly separated phases.

---

## 81 – Factoring Strategies

### 81a – Extract phases into separate skills

Create separate skills for distinct phases:

```
vulnerability-fix/
├── SKILL.md (orchestrator)
├── skills/
│   ├── gather-context.md
│   ├── build-plan.md
│   ├── execute-fix.md
│   └── verify-result.md
```

### 81b – Extract reusable procedures into scripts

Code that's rewritten repeatedly belongs in scripts:

❌ **In prompt:**
```markdown
Run this bash script to check dependencies:
```bash
#!/bin/bash
for pkg in $(cat requirements.txt); do
  pip show $pkg || echo "Missing: $pkg"
done
```
```

✅ **Extracted:**
```markdown
Run `scripts/check_deps.sh` to verify dependencies.
```

### 81c – Extract domain knowledge into references

Large blocks of domain knowledge belong in references:

❌ **In SKILL.md:**
```markdown
## Database Schema

### users table
- id: UUID primary key
- email: VARCHAR(255) unique
- created_at: TIMESTAMP
[... 200 more lines of schema ...]
```

✅ **In references:**
```markdown
See [references/schema.md](references/schema.md) for complete database schema.
```

### 81d – Create orchestrator skill that invokes sub-skills

Create a high-level skill that coordinates sub-skills:

```markdown
# Vulnerability Remediation

## Workflow

1. **Gather context**: Invoke `/vuln:gather-context`
2. **Build plan**: Invoke `/vuln:build-plan`
3. **Execute fix**: Invoke `/vuln:execute`
4. **Verify result**: Invoke `/vuln:verify`

Only proceed to next step if current step succeeds.
```

---

## 82 – Inline Code Anti-Patterns

### 82a – Bash snippets embedded in prompts → extract to `scripts/`

❌ **Wrong:** 50-line bash script embedded in prompt

✅ **Correct:** `scripts/setup_env.sh` with one-line invocation in prompt

### 82b – JSON/YAML templates in body → move to `assets/`

❌ **Wrong:** Large JSON template embedded in SKILL.md

✅ **Correct:** `assets/template.json` with reference in SKILL.md

### 82c – API documentation in body → move to `references/`

❌ **Wrong:** Full API documentation embedded in SKILL.md

✅ **Correct:** `references/api.md` loaded when needed

---

# Part 10: Multi-Phase Workflows

## 90 – Phase Separation Principle

Complex tasks should be separated into distinct phases, each with a clear purpose.

### 90a – Planning phase: gather context, validate assumptions

The planning phase:
- Gathers information about the current state
- Validates assumptions before acting
- Defines the scope of changes
- Produces a plan for the execution phase

### 90b – Execution phase: apply changes with focused scope

The execution phase:
- Follows the plan from the planning phase
- Makes changes with focused, limited scope
- Creates checkpoints for recovery
- Does NOT re-plan or change direction

### 90c – Verification phase: confirm success, fix issues

The verification phase:
- Validates that changes achieved the goal
- Runs tests and checks
- Fixes minor issues
- Escalates or reduces scope if validation fails

---

## 91 – Planning Phase Best Practices

### 91a – Explicit context gathering before action

Always gather context before making decisions:

```markdown
## Planning Phase

1. Read the target files to understand current state
2. List all dependencies and their versions
3. Identify existing patterns in the codebase
4. Document findings before proceeding to plan
```

### 91b – Assumption verification: "Check X before assuming Y"

Never assume—verify:

```markdown
## Verify Assumptions

Before proceeding, verify:
- [ ] The target file exists at the expected path
- [ ] The library version matches expected (check package.json)
- [ ] The function signature matches the documentation
- [ ] The database schema includes required columns

If any assumption fails, STOP and reassess.
```

### 91c – Scope definition: what will and won't be changed

Explicitly define scope:

```markdown
## Scope

**In scope:**
- Update authentication middleware
- Add new JWT validation

**Out of scope:**
- Database schema changes
- Frontend modifications
- Other microservices
```

### 91d – Exit criteria: when is the plan "ready"?

Define when planning is complete:

```markdown
## Planning Exit Criteria

Planning is complete when:
1. All assumptions have been verified
2. Scope is clearly defined
3. Step-by-step execution plan is documented
4. Rollback procedure is identified
```

---

## 92 – Execution Phase Best Practices

### 92a – Single-responsibility execution steps

Each step should do ONE thing:

❌ **Wrong:**
```markdown
3. Update the config, restart the service, and verify it's running
```

✅ **Correct:**
```markdown
3. Update the config file
4. Restart the service
5. Verify the service is running
```

### 92b – Clean context between cycles

When running multiple cycles, start each with clean context:

```markdown
## Execution Cycle

For each fix:
1. Start with clean working directory
2. Apply single fix
3. Run tests
4. Commit if tests pass
5. Reset if tests fail
```

### 92c – Incremental commits/checkpoints

Commit frequently to enable recovery:

```markdown
## Checkpoints

After each successful step:
1. `git add -A && git commit -m "checkpoint: [step description]"`
2. Verify tests still pass
3. Proceed to next step
```

---

## 93 – Verification Phase Best Practices

### 93a – Critic process: evaluate output quality

After execution, critically evaluate:

```markdown
## Verification

1. Does the code compile? Run `make build`
2. Do tests pass? Run `make test`
3. Does the change address the original issue?
4. Are there any unintended side effects?
5. Is the code quality acceptable?
```

### 93b – Compilation/syntax validation

Always verify basic correctness:

```markdown
## Syntax Check

Before considering complete:
- [ ] Code compiles without errors
- [ ] No syntax errors in any language
- [ ] Linter passes with no new warnings
```

### 93c – Test execution

Run tests to verify correctness:

```markdown
## Test Verification

1. Run unit tests: `npm test`
2. Run integration tests: `npm run test:integration`
3. If any tests fail, fix or document why
```

### 93d – Scope reduction: abandon or simplify when blocked

If verification fails repeatedly, reduce scope:

```markdown
## If Blocked

After 3 failed attempts:
1. Identify the minimal viable fix
2. Document what was excluded and why
3. Create follow-up issue for excluded scope
4. Deliver reduced-scope solution with explanation
```

---

# Part 11: Assumption Verification

## 100 – The Assumption Verification Principle

The most common failure mode in complex prompts is acting on assumptions that don't match reality.

### 100a – Never assume—verify from actual code/state

❌ **Wrong:**
```markdown
Update the library version in pom.xml
```

✅ **Correct:**
```markdown
1. Verify pom.xml exists
2. Find the current library entry (may be different artifact ID)
3. Note current version
4. Update to target version
```

### 100b – Reference guidance ≠ current reality

External guidance (documentation, wikis, remediation guides) describes EXPECTED state, not ACTUAL state. Always verify.

```markdown
## Important

The remediation guide assumes Spring Boot 2.x.
First verify the actual Spring Boot version in the target repo.
If version differs, adapt the remediation accordingly.
```

### 100c – "If X then Y" must check X explicitly

Every conditional requires explicit verification:

❌ **Wrong:**
```markdown
Since the project uses Maven, run `mvn clean install`
```

✅ **Correct:**
```markdown
Check for pom.xml. If present, run `mvn clean install`.
If not present, check for build.gradle and use Gradle instead.
```

---

## 101 – Verification Patterns

### 101a – File existence checks before modification

```markdown
Before modifying [file]:
1. Verify file exists: `test -f [file]`
2. If not found, search for alternatives: `find . -name "[pattern]"`
3. Only proceed when correct file is located
```

### 101b – Dependency/library version verification

```markdown
Before applying version-specific fix:
1. Check actual version: `grep "library-name" package.json`
2. Compare with expected version from guidance
3. If versions differ, adapt approach accordingly
```

### 101c – Code pattern detection before transformation

```markdown
Before applying code transformation:
1. Search for expected pattern: `grep -r "pattern" src/`
2. If pattern not found, investigate why
3. Only transform code that matches expected pattern
```

### 101d – State validation before state change

```markdown
Before changing configuration:
1. Read current configuration
2. Document current state
3. Verify current state matches expectations
4. Only then apply changes
```

---

## 102 – Writing Conditional Instructions

### 102a – "First verify that [condition]. If not present, [alternative]"

Structure conditionals explicitly:

```markdown
First verify that `src/auth/middleware.js` exists.
- If present: Modify the existing middleware
- If not present: Check for `src/middleware/auth.js` (alternative location)
- If neither exists: Create new middleware file
```

### 102b – Explicit fallback paths

Always provide fallbacks:

```markdown
## Install Dependencies

Try npm first:
1. `npm install`

If npm fails (no package.json):
2. Try yarn: `yarn install`

If yarn fails:
3. Try pip: `pip install -r requirements.txt`

If all fail:
4. Report missing dependency configuration
```

### 102c – "Do not assume X; always check Y"

Use explicit anti-assumption statements:

```markdown
## Important

Do NOT assume:
- The file is in the standard location
- The library version matches documentation
- The function signature is unchanged

ALWAYS check:
- Actual file location with `find`
- Actual version in dependency file
- Actual function signature in source
```

---

# Part 12: Orchestration

## 110 – Explicit Tool Invocation

### 110a – Keyword triggers for planning tools

Use explicit keywords to invoke planning:

```markdown
## Start Planning

Use `/plan:start` to begin the planning phase.
This will:
1. Gather context from relevant files
2. List assumptions to verify
3. Define scope boundaries
```

### 110b – Keyword triggers for verification steps

Use explicit keywords for verification:

```markdown
## Verify Results

Use `/verify:all` to run full verification:
1. Compile check
2. Test suite
3. Lint check
4. Output review
```

### 110c – Keyword triggers for scope management

Use explicit keywords for scope control:

```markdown
## Scope Control

- `/scope:expand` - Add items to scope (with justification)
- `/scope:reduce` - Remove items from scope (document why)
- `/scope:report` - Show current scope status
```

---

## 111 – Orchestrator Pattern

### 111a – High-level skill that sequences sub-skills

Create an orchestrator that coordinates phases:

```markdown
# Remediation Orchestrator

## Workflow

1. `/remediate:gather` - Collect context and findings
2. `/remediate:plan` - Build remediation plan
3. `/remediate:verify-plan` - Validate plan assumptions
4. `/remediate:execute` - Apply fixes
5. `/remediate:verify-result` - Confirm success

Proceed to next step only when current step completes successfully.
```

### 111b – Decision points between phases

Include explicit decision points:

```markdown
## After Planning

Decision point: Is the plan ready for execution?

**Proceed if:**
- All assumptions verified
- Scope clearly defined
- Estimated changes < 500 lines

**Return to planning if:**
- Unverified assumptions remain
- Scope unclear
- Changes too large (factor into smaller PRs)
```

### 111c – Quality gates before proceeding

Define quality gates:

```markdown
## Quality Gates

### Gate 1: Plan Quality
- [ ] Assumptions documented and verified
- [ ] Scope bounded and reasonable
- [ ] Rollback procedure identified

### Gate 2: Execution Quality
- [ ] Code compiles
- [ ] Tests pass
- [ ] No new linter errors

### Gate 3: Final Quality
- [ ] PR is reviewable (<500 lines)
- [ ] Changes match original scope
- [ ] Documentation updated if needed
```

---

## 112 – Scope Management

### 112a – Recognizing when to reduce scope

Signs that scope should be reduced:

- Execution has failed 3+ times
- Estimated changes exceed 500 lines
- Multiple unrelated issues discovered
- Blocking dependency on external team

### 112b – "If blocked after N attempts, reduce scope to X"

Build in automatic scope reduction:

```markdown
## Scope Reduction Protocol

After 3 failed execution attempts:
1. Identify the simplest possible fix
2. Remove all non-essential changes
3. Document what was deferred
4. Deliver minimal fix with explanation
5. Create follow-up issues for deferred work
```

### 112c – Graceful degradation vs. complete failure

Prefer partial success over complete failure:

```markdown
## Failure Handling

If full remediation fails:
1. Identify what CAN be fixed
2. Fix what's possible
3. Document what couldn't be fixed and why
4. Deliver partial fix rather than nothing

A 60% fix merged is better than a 100% fix that never ships.
```

---

# Appendices

## Appendix A: Quick Reference Card

### Most Common Issues

| Code | Issue | Quick Fix |
|------|-------|-----------|
| **1a** | Prompt too verbose | Cut explanations, use examples |
| **10b** | Missing trigger info in description | Add "Use when..." to description |
| **22a** | "When to use" in body not description | Move to description field |
| **30a** | Wrong voice | Use imperative ("Do X" not "You should X") |
| **42a** | SKILL.md too long (>500 lines) | Factor into references/scripts |
| **80d** | Mixed phases in one prompt | Separate planning/execution/verification |
| **100a** | Acting on assumptions | Add verification steps |

### Size Guidelines

| Component | Target | Maximum |
|-----------|--------|---------|
| Description | ~100 words | 200 words |
| SKILL.md body | <300 lines | 500 lines |
| Reference files | <500 lines | 1000 lines (with TOC) |
| Total prompt | <1000 lines | Factor if larger |

### Structure Template

```
skill-name/
├── SKILL.md              # Required: <500 lines
├── scripts/              # Reusable code
├── references/           # Domain knowledge
└── assets/               # Templates, images
```

---

## Appendix B: Glossary

**AgentSkill**: A modular package that extends OpenHands with specialized knowledge, workflows, or tools.

**Assets**: Files used in output (templates, images, fonts) stored in `assets/` directory.

**Body**: The Markdown content of SKILL.md after the frontmatter.

**Bundled Resources**: Files included with a skill (`scripts/`, `references/`, `assets/`).

**Context Window**: The total amount of text the AI can consider at once. A shared, finite resource.

**Degrees of Freedom**: How much latitude the agent has in executing instructions (high/medium/low).

**Description**: The YAML frontmatter field that determines when a skill triggers.

**Factoring**: Breaking a large prompt into smaller, composable skills.

**Frontmatter**: The YAML metadata at the top of SKILL.md (between `---` markers).

**Orchestrator**: A skill that coordinates multiple sub-skills in sequence.

**Phase Separation**: Dividing work into distinct planning, execution, and verification phases.

**Plugin**: A package following Claude Code plugin format with manifest and commands.

**Progressive Disclosure**: Loading information in layers (metadata → body → resources) to manage context.

**References**: Documentation files stored in `references/` directory, loaded as needed.

**Scripts**: Executable code stored in `scripts/` directory.

**Slash Command**: An explicit trigger like `/plugin:command` that invokes a specific skill.

**Trigger**: The condition that causes a skill to activate (keywords, file types, context).

---

## Appendix C: Factoring Checklist

Use this checklist when your prompt exceeds 500 lines or contains multiple phases.

### Identification

- [ ] Is the prompt >500 lines?
- [ ] Are there multiple distinct phases (plan/execute/verify)?
- [ ] Are there repeated code blocks?
- [ ] Is there embedded documentation that could be a reference?
- [ ] Are there bash/code snippets that could be scripts?

### Extraction

- [ ] Move domain knowledge to `references/`
- [ ] Move reusable code to `scripts/`
- [ ] Move templates to `assets/`
- [ ] Create sub-skills for distinct phases

### Orchestration

- [ ] Create high-level orchestrator skill
- [ ] Define clear handoffs between phases
- [ ] Add quality gates between phases
- [ ] Include scope reduction protocol

### Verification

- [ ] Each component is <500 lines
- [ ] Each component has single responsibility
- [ ] Links between components are clear
- [ ] Overall workflow is documented

---

## Appendix D: Phase Template

Use this template for multi-phase workflows.

```markdown
# [Task Name]

## Phase 1: Planning

### Context Gathering
1. Read [relevant files]
2. Identify [current state]
3. Document findings

### Assumption Verification
Before proceeding, verify:
- [ ] [Assumption 1]
- [ ] [Assumption 2]
- [ ] [Assumption 3]

### Scope Definition
**In scope:**
- [Item 1]
- [Item 2]

**Out of scope:**
- [Item 1]
- [Item 2]

### Exit Criteria
Planning complete when:
- [ ] All assumptions verified
- [ ] Scope defined
- [ ] Plan documented

---

## Phase 2: Execution

### Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Checkpoints
After each step:
- Verify step completed
- Commit checkpoint
- Proceed or rollback

---

## Phase 3: Verification

### Checks
- [ ] Code compiles
- [ ] Tests pass
- [ ] Linter passes
- [ ] Changes match scope

### If Verification Fails
After 3 attempts:
1. Identify minimal viable fix
2. Reduce scope
3. Document deferred work
4. Deliver partial solution
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | 2025-01 | Initial draft |

---

*This handbook is modeled after the Harbrace College Handbook. When reviewing skills or prompts, reference rule codes (e.g., "10b", "91a") to identify specific issues.*
