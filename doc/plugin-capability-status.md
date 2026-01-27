# OpenHands Plugin Capability Status

## Current State

> **🎉 SDK 1.10.0 Released!** Full plugin support with slash commands is now available.
> Install with `pip install openhands-sdk>=1.10.0`

**Full plugin support is now available in the OpenHands SDK 1.10.0+.** The SDK supports:

- Loading plugins from GitHub, git URLs, or local paths via `Plugin.fetch()` and `Plugin.load()`
- Slash commands converted to `KeywordTrigger` skills (e.g., `/city-weather:now`)
- Skills, hooks, MCP configuration, and agent definitions
- Plugin marketplaces via the `Marketplace` class

### Plugin Loading Support

| Platform | Status | Notes |
|----------|--------|-------|
| **software-agent-sdk** | ✅ **1.10.0+ Released** | Full plugin support with `Conversation(plugins=[...])` |
| **OpenHands Cloud** | ✅ Supported | Plugin loading via API with `plugins` field |
| **Claude Code** | ✅ Compatible | Same plugin format works in both systems |

### Key PRs

| Repository | PR | Description | Status |
|------------|----------|-------------|--------|
| OpenHands/software-agent-sdk | [#1651](https://github.com/OpenHands/software-agent-sdk/pull/1651) | Agent Server: Support plugin loading when starting conversations | ✅ Merged |
| OpenHands/OpenHands | [#12338](https://github.com/OpenHands/OpenHands/pull/12338) | App Server: Accept plugin spec in conversation start API | ✅ Merged |

> **📋 API Design Documentation:** See [OpenHands Issue #12087 comment](https://github.com/OpenHands/OpenHands/issues/12087#issuecomment-3733464400) for the complete API shape across App Server, Agent Server, and SDK layers.

---

## Demo: Using the SDK Directly

With SDK 1.10.0+, you can load and use plugins directly in Python:

```python
from openhands.sdk import Agent, Conversation, LLM
from openhands.sdk.plugin import PluginSource
from pydantic import SecretStr

llm = LLM(model="anthropic/claude-sonnet-4-20250514", api_key=SecretStr("..."))
agent = Agent(llm=llm, tools=[...])

# Load plugin and use slash command
conversation = Conversation(
    agent=agent,
    plugins=[
        PluginSource(
            source="github:jpshackelford/openhands-sample-plugins",
            repo_path="plugins/city-weather"
        )
    ]
)
conversation.send_message("/city-weather:now Tokyo")
conversation.run()
```

See [software-agent-sdk-usage.md](software-agent-sdk-usage.md) for the complete guide.

---

## Demo: City Weather Plugin via OpenHands Cloud API

This demo shows how to launch a conversation with the city-weather plugin loaded from this repository.

### Prerequisites

- Access to OpenHands Cloud (app.all-hands.dev or staging environment)
- An API key for the environment

### Quick Start Script

Use the [demo_weather_plugin.sh](demo_weather_plugin.sh) script in this directory:

```bash
export STAGING_URL="https://your-staging.all-hands.dev"
export API_KEY="sk-oh-your-key-here"
./demo_weather_plugin.sh "New York"
```

### Manual Step-by-Step

If you prefer to run the commands manually:

#### 1. Set Environment Variables

```bash
export STAGING_URL="https://your-staging-url.all-hands.dev"
export API_KEY="sk-oh-YOUR_API_KEY_HERE"
```

#### 2. Create Conversation with Plugin

> **Important:** The city-weather plugin is in a subdirectory, so you must specify the `repo_path` field.

```bash
curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {
      "content": [
        {
          "type": "text",
          "text": "/city-weather:now Tokyo"
        }
      ]
    },
    "plugins": [{
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main",
      "repo_path": "plugins/city-weather"
    }]
  }' | jq '{id, status}'
```

**Expected Response:**
```json
{
  "id": "abc123-def456-...",
  "status": "WORKING"
}
```

#### 3. Poll for Sandbox Ready

Use the search endpoint to check conversation status:

```bash
CONVERSATION_ID="your-conversation-id-here"

# Check status (repeat until sandbox_status is "RUNNING")
curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}" | jq --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id) | {id, title, sandbox_status}'
```

#### 4. View in Browser

```
${STAGING_URL}/conversations/${CONVERSATION_ID}
```

---

## Plugin Source Formats

| Format | Example |
|--------|---------|
| GitHub shorthand | `github:jpshackelford/openhands-sample-plugins` |
| Git URL | `https://github.com/jpshackelford/openhands-sample-plugins.git` |
| Local path | `/path/to/openhands-sample-plugins` |

> **Note:** For plugins in subdirectories (like in marketplace repos), use the `repo_path` field separately. Do not append the path to the source string.

---

## What the Plugin Does

The city-weather plugin provides instructions for fetching weather data using the [Open-Meteo API](https://open-meteo.com/). When loaded, the agent will:

1. Use the geocoding API to find city coordinates
2. Fetch current weather and hourly forecast
3. Present a formatted report with:
   - Current time in the city's timezone
   - Temperature in °F and °C
   - Precipitation forecast for next 4 hours

**Note:** With SDK 1.10.0+, commands are loaded with `KeywordTrigger` so they activate only when you use the slash command (e.g., `/city-weather:now`). See [software-agent-sdk-usage.md](software-agent-sdk-usage.md) for the complete SDK usage guide.

---

## Notes

- Plugin loading happens inside the sandbox/runtime, not on the app server
- Use the `repo_path` field for plugins in subdirectories (do not append to source string)
- The `plugins` field is an array, allowing multiple plugins to be loaded
- Sandbox startup typically takes 30-90 seconds depending on load
- The plugin uses the free Open-Meteo API which requires no API key
- See [testing-troubleshooting.md](testing-troubleshooting.md) for API troubleshooting tips
