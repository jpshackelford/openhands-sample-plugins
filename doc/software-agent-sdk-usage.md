# Loading Plugins with OpenHands software-agent-sdk

This guide demonstrates how to load Claude Code format plugins using the OpenHands software-agent-sdk.

> **🎉 SDK 1.10.0 Released!** Full plugin support with slash commands is now available.
> Install with `pip install openhands-sdk>=1.10.0`

## Prerequisites

Install the OpenHands SDK (version 1.10.0 or later):

```bash
pip install "openhands-sdk>=1.10.0"
# or
uv add "openhands-sdk>=1.10.0"
```

## Quick Start

### Loading a Plugin with Slash Command Support

```python
import os
from pydantic import SecretStr
from openhands.sdk import Agent, Conversation, LLM
from openhands.sdk.plugin import PluginSource
from openhands.sdk.tool import Tool
from openhands.tools.terminal import TerminalTool

# Configure LLM
api_key = os.getenv("LLM_API_KEY")
llm = LLM(
    usage_id="weather-demo",
    model="anthropic/claude-sonnet-4-20250514",
    api_key=SecretStr(api_key),
)

# Create agent with terminal tool (needed for curl commands)
tools = [Tool(name=TerminalTool.name)]
agent = Agent(llm=llm, tools=tools)

# Create conversation with the plugin loaded
# The SDK will fetch and load the plugin, including slash commands
conversation = Conversation(
    agent=agent,
    workspace=os.getcwd(),
    plugins=[
        PluginSource(
            source="github:jpshackelford/openhands-sample-plugins",
            ref="main",
            repo_path="plugins/city-weather"
        )
    ]
)

# Use slash command to invoke the plugin
conversation.send_message("/city-weather:now Tokyo")
conversation.run()
```

## Complete Example

Here's a full working example using SDK 1.10.0+ plugin support:

```python
#!/usr/bin/env python3
"""
Example: Loading a Claude Code format plugin with software-agent-sdk 1.10.0+.

This demonstrates loading the city-weather plugin and using slash commands
to fetch weather information.
"""

import os
from pydantic import SecretStr

from openhands.sdk import Agent, Conversation, LLM
from openhands.sdk.plugin import PluginSource
from openhands.sdk.tool import Tool
from openhands.tools.terminal import TerminalTool


def main():
    # Check for API key
    api_key = os.getenv("LLM_API_KEY")
    if not api_key:
        print("Error: Set LLM_API_KEY environment variable")
        print("  export LLM_API_KEY='your-api-key'")
        return

    # Configure LLM
    llm = LLM(
        usage_id="weather-demo",
        model=os.getenv("LLM_MODEL", "anthropic/claude-sonnet-4-20250514"),
        api_key=SecretStr(api_key),
        base_url=os.getenv("LLM_BASE_URL"),
    )

    # Create agent with terminal access for curl commands
    tools = [Tool(name=TerminalTool.name)]
    agent = Agent(llm=llm, tools=tools)

    # Create conversation with the city-weather plugin loaded
    # The plugin is fetched from GitHub and loaded automatically
    conversation = Conversation(
        agent=agent,
        workspace=os.getcwd(),
        plugins=[
            PluginSource(
                source="github:jpshackelford/openhands-sample-plugins",
                ref="main",
                repo_path="plugins/city-weather"
            )
        ]
    )

    # Use slash command to invoke the plugin
    # The SDK will:
    # 1. Recognize the /city-weather:now trigger
    # 2. Activate the command skill
    # 3. Substitute "Tokyo" into $ARGUMENTS
    city = "Tokyo"
    print(f"\nInvoking: /city-weather:now {city}")
    print("-" * 40)
    conversation.send_message(f"/city-weather:now {city}")
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

## How It Works (SDK 1.10.0+)

The SDK 1.10.0 introduced full plugin support with the `Plugin` class:

1. **Plugin Fetching**: `Plugin.fetch()` retrieves plugins from GitHub, git URLs, or local paths
2. **Plugin Loading**: `Plugin.load()` parses the plugin structure including:
   - `plugin.json` manifest
   - Skills from `skills/` directory
   - Commands from `commands/` directory (converted to keyword-triggered skills)
   - Hooks from `hooks/hooks.json`
   - MCP configuration from `.mcp.json`
3. **Slash Commands**: Commands are automatically converted to skills with `KeywordTrigger`:
   - `/city-weather:now` triggers the `now` command from the `city-weather` plugin
   - The text after the command (e.g., "Tokyo") is available as `$ARGUMENTS`

### Plugin Structure

The SDK recognizes the Claude Code plugin format:

```
plugin-name/
├── .claude-plugin/           # or .plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                # Slash commands (→ KeywordTrigger skills)
│   └── now.md
├── skills/                  # Agent Skills
├── hooks/                   # Event handlers
│   └── hooks.json
├── .mcp.json                # MCP server configuration
└── README.md
```

### What Gets Parsed

| Plugin Component | SDK Support |
|-----------------|-------------|
| `plugin.json` manifest | ✅ `PluginManifest` |
| `commands/*.md` | ✅ → `KeywordTrigger` skills |
| `skills/*.md` | ✅ Loaded as skills |
| `hooks/hooks.json` | ✅ `HookConfig` |
| `.mcp.json` | ✅ MCP server config |
| `agents/*.md` | ✅ `AgentDefinition` |
| `description` frontmatter | ✅ Parsed |
| `allowed-tools` frontmatter | ✅ Parsed as list |
| `argument-hint` frontmatter | ✅ Parsed and shown in skill content |

---

## Slash Commands

### How Slash Commands Work

When you load a plugin with the `plugins` parameter, the SDK:

1. **Fetches** the plugin from the specified source (GitHub, git URL, or local path)
2. **Loads** commands from the `commands/` directory
3. **Converts** each command to a skill with a `KeywordTrigger`:
   - Trigger keyword: `/<plugin-name>:<command-name>`
   - Example: `/city-weather:now`
4. **Activates** the skill when the user message matches the trigger

### Example Usage

```python
# User sends slash command
conversation.send_message("/city-weather:now Tokyo")

# The SDK:
# 1. Matches "/city-weather:now" to the KeywordTrigger
# 2. Activates the "city-weather:now" skill
# 3. "Tokyo" is available as $ARGUMENTS in the skill content
```

### The `$ARGUMENTS` Placeholder

Commands can use `$ARGUMENTS` to reference user-provided arguments:

```markdown
---
description: Get current weather for a city
argument-hint: <city name>
---

1. Parse the city name from: **$ARGUMENTS**
2. Use the geocoding API to find coordinates...
```

When the user sends `/city-weather:now Tokyo`:
- `$ARGUMENTS` = `"Tokyo"`
- The skill content shows this placeholder to the LLM
- The LLM understands to use "Tokyo" as the city name

---

## Alternative: Manual Skill Loading

If you prefer to load skills manually (without the full plugin system), you can still use `load_skills_from_dir()`:

```python
from openhands.sdk import load_skills_from_dir, AgentContext, Agent, Conversation

# Load skills directly from a directory
repo_skills, knowledge_skills, agent_skills = load_skills_from_dir(
    "plugins/city-weather"
)

# Create agent context with loaded skills
agent_context = AgentContext(skills=list(repo_skills.values()))

# Create agent and conversation
agent = Agent(llm=llm, tools=tools, agent_context=agent_context)
conversation = Conversation(agent=agent, workspace=os.getcwd())

# With manual loading, use natural language instead of slash commands
conversation.send_message("What's the weather in Tokyo?")
```

> **Note:** Manual skill loading does not set up `KeywordTrigger` for slash commands.
> Skills are loaded as "always active" and included in every prompt.

---

## Compatibility Summary

| Feature | Claude Code | software-agent-sdk 1.10.0+ |
|---------|-------------|---------------------------|
| Load `.md` with frontmatter | ✅ | ✅ |
| Parse `description` | ✅ | ✅ |
| Parse `allowed-tools` | ✅ | ✅ |
| Parse `argument-hint` | ✅ | ✅ |
| Slash command invocation | ✅ `/cmd:name args` | ✅ via `KeywordTrigger` |
| `$ARGUMENTS` substitution | ✅ | ✅ (shown in skill content) |
| Plugin fetching from GitHub | ✅ | ✅ `Plugin.fetch()` |
| Hooks support | ✅ | ✅ `HookConfig` |
| MCP configuration | ✅ | ✅ `.mcp.json` |
| Keyword triggers | ❌ | ✅ via `triggers:` field |
| Plugin marketplaces | ✅ | ✅ `Marketplace` class |

---

## Related Resources

- [OpenHands SDK Skills Guide](https://docs.openhands.dev/sdk/guides/skill)
- [OpenHands SDK Plugin Documentation](https://docs.openhands.dev/sdk/guides/plugins)
- [AgentSkills Specification](https://agentskills.io/specification)
- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
