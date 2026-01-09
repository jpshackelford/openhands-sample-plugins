# Loading Plugins with OpenHands software-agent-sdk

This guide demonstrates how to load Claude Code format plugins using the OpenHands software-agent-sdk.

## Prerequisites

Install the OpenHands SDK:

```bash
pip install openhands-sdk
# or
uv add openhands-sdk
```

## Quick Start

### Loading the Plugin

```python
from openhands.sdk import load_skills_from_dir, AgentContext, Agent, LLM, Conversation
from openhands.sdk.tool import Tool
from openhands.tools.terminal import TerminalTool
from pydantic import SecretStr
import os

# Load skills from the plugin directory
# The SDK will find and parse all .md files with frontmatter
repo_skills, knowledge_skills, agent_skills = load_skills_from_dir(
    "plugins/city-weather"
)

print(f"Loaded repo skills: {list(repo_skills.keys())}")
# Output: Loaded repo skills: ['commands/now']
```

### Using with an Agent

```python
# Configure LLM
api_key = os.getenv("LLM_API_KEY")
llm = LLM(
    usage_id="weather-demo",
    model="anthropic/claude-sonnet-4-20250514",
    api_key=SecretStr(api_key),
)

# Create agent context with loaded skills
# NOTE: Slash commands like /city-weather:now are not supported.
# See the "Gotchas" section below for details.
agent_context = AgentContext(
    skills=list(repo_skills.values())
)

# Create agent with terminal tool (needed for curl commands)
tools = [Tool(name=TerminalTool.name)]
agent = Agent(llm=llm, tools=tools, agent_context=agent_context)

# Create conversation
conversation = Conversation(agent=agent, workspace=os.getcwd())

# Send a message - the skill instructions are already in context,
# so the agent knows how to fetch weather data
conversation.send_message("What's the weather in Tokyo?")
conversation.run()
```

## Complete Example

Here's a full working example:

```python
#!/usr/bin/env python3
"""
Example: Loading a Claude Code format plugin with software-agent-sdk.

This demonstrates loading the city-weather plugin and using it to
fetch weather information.
"""

import os
from pydantic import SecretStr

from openhands.sdk import (
    Agent,
    AgentContext,
    Conversation,
    LLM,
    load_skills_from_dir,
)
from openhands.sdk.tool import Tool
from openhands.tools.terminal import TerminalTool


def main():
    # Check for API key
    api_key = os.getenv("LLM_API_KEY")
    if not api_key:
        print("Error: Set LLM_API_KEY environment variable")
        return

    # Load skills from plugin directory
    repo_skills, knowledge_skills, agent_skills = load_skills_from_dir(
        "plugins/city-weather"
    )

    print(f"Loaded {len(repo_skills)} repo skill(s)")
    for name, skill in repo_skills.items():
        print(f"  - {name}: {skill.description}")

    # Configure LLM
    llm = LLM(
        usage_id="weather-demo",
        model=os.getenv("LLM_MODEL", "anthropic/claude-sonnet-4-20250514"),
        api_key=SecretStr(api_key),
        base_url=os.getenv("LLM_BASE_URL"),
    )

    # Create agent context with the loaded skills
    # The skill content will be included in the system prompt
    agent_context = AgentContext(skills=list(repo_skills.values()))

    # Create agent with terminal access for curl commands
    tools = [Tool(name=TerminalTool.name)]
    agent = Agent(llm=llm, tools=tools, agent_context=agent_context)

    # Create conversation
    conversation = Conversation(agent=agent, workspace=os.getcwd())

    # Ask about weather - the agent has the instructions in context
    # and will use curl to fetch from Open-Meteo API
    print("\nAsking: What's the weather in Tokyo?")
    print("-" * 40)
    conversation.send_message("What's the weather in Tokyo?")
    conversation.run()

    print(f"\nTotal cost: ${llm.metrics.accumulated_cost:.4f}")


if __name__ == "__main__":
    main()
```

### Running the Example

```bash
export LLM_API_KEY="your-api-key"
cd openhands-sample-plugins
python doc/example_weather.py
```

## How It Works

1. **Skill Loading**: The SDK's `load_skills_from_dir()` function scans for `.md` files with YAML frontmatter
2. **Frontmatter Parsing**: The SDK parses standard AgentSkills fields (`description`, `allowed-tools`, etc.)
3. **Context Injection**: Skills are added to the `AgentContext` and included in the system prompt
4. **Agent Execution**: The LLM receives the skill instructions and can follow them when relevant

### What Gets Parsed

| Frontmatter Field | SDK Support |
|-------------------|-------------|
| `description` | ✅ Parsed and stored |
| `allowed-tools` | ✅ Parsed as list |
| `triggers` | ✅ Creates KeywordTrigger |
| `license` | ✅ Parsed |
| `metadata` | ✅ Parsed |
| `argument-hint` | ❌ Ignored (Claude Code specific) |

---

## Gotchas

### Slash Commands Are Not Supported

**The software-agent-sdk does not implement Claude Code's slash command system.**

In Claude Code, you would invoke this plugin with:
```
/city-weather:now Tokyo
```

This syntax triggers the command and substitutes `Tokyo` into the `$ARGUMENTS` placeholder in the skill content.

**In the software-agent-sdk:**
- The `/city-weather:now` syntax has no special meaning
- No command parsing occurs
- The `$ARGUMENTS` placeholder is not substituted - it remains as literal text

**Workaround**: Simply describe what you want naturally:
```
What's the weather in Tokyo?
```

The skill instructions are already in the agent's context, so it knows how to fulfill weather requests.

### Skills Load as "Always Active" (No Triggers)

Claude Code command files don't include a `triggers:` field, so the SDK loads them as **always-active repo skills** (`trigger=None`).

This means:
- The skill content is **always** included in the system prompt
- There's no on-demand activation based on keywords
- For large plugins, this increases token usage on every request

**To add keyword triggers**, you would need to add a `triggers:` field to the frontmatter:

```yaml
---
description: Get current weather for a city
triggers:
  - weather
  - temperature
  - forecast
allowed-tools: Bash(curl:*)
---
```

However, this breaks Claude Code compatibility since Claude Code doesn't recognize the `triggers` field.

### The `$ARGUMENTS` Placeholder

Claude Code replaces `$ARGUMENTS` with the text after the slash command:
```
/city-weather:now Tokyo  →  $ARGUMENTS = "Tokyo"
```

The software-agent-sdk does **not** perform this substitution. The placeholder remains as literal text in the skill content:

```markdown
1. Parse the city name from the arguments: **$ARGUMENTS**
```

The LLM will see `$ARGUMENTS` in the instructions but will typically understand from context that it should use the city name from the user's message.

### Directory Structure Expectations

The SDK expects skills in specific locations:
- `SKILL.md` files in subdirectories (AgentSkills standard)
- Any `.md` file with frontmatter (OpenHands format)

Claude Code's structure (`commands/now.md`) works because any `.md` file with frontmatter is loaded, but the skill name becomes `commands/now` rather than a cleaner identifier.

---

## Compatibility Summary

| Feature | Claude Code | software-agent-sdk |
|---------|-------------|-------------------|
| Load `.md` with frontmatter | ✅ | ✅ |
| Parse `description` | ✅ | ✅ |
| Parse `allowed-tools` | ✅ | ✅ |
| Slash command invocation | ✅ `/cmd:name args` | ❌ |
| `$ARGUMENTS` substitution | ✅ | ❌ |
| `argument-hint` field | ✅ | ❌ Ignored |
| Keyword triggers | ❌ | ✅ via `triggers:` field |
| Always-active skills | ✅ | ✅ (default) |

---

## Related Resources

- [OpenHands SDK Skills Guide](https://docs.openhands.dev/sdk/guides/skill)
- [AgentSkills Specification](https://agentskills.io/specification)
- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
