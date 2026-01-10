# OpenHands Plugin Capability Status

## Current State

**Agent Skills support is now available in the software-agent-sdk.** The SDK supports loading plugins with skills, hooks, and MCP configuration via the `Plugin.load()` and `Plugin.fetch()` APIs.

### Experimental: Launching Plugins from OpenHands Cloud

There is experimental, unmerged capability for launching plugins directly from OpenHands Cloud. This work is tracked in the following PRs and issues:

| Repository | Issue/PR | Description |
|------------|----------|-------------|
| OpenHands/OpenHands | [#12316](https://github.com/OpenHands/OpenHands/issues/12316) | Support for bare git repository plugin marketplaces |
| OpenHands/software-agent-sdk | [#1645](https://github.com/OpenHands/software-agent-sdk/issues/1645) | Add `Plugin.fetch()` for remote plugin fetching and caching |
| OpenHands/software-agent-sdk | [#1650](https://github.com/OpenHands/software-agent-sdk/issues/1650) | Agent Server: Load plugins when starting conversations |
| OpenHands/OpenHands | [#12321](https://github.com/OpenHands/OpenHands/issues/12321) | App Server: Accept plugin spec in conversation start API |

> **📋 API Design Documentation:** See [OpenHands Issue #12087 comment](https://github.com/OpenHands/OpenHands/issues/12087#issuecomment-3733464400) for the complete API shape across App Server, Agent Server, and SDK layers.

---

## Demo: City Weather Plugin via OpenHands Cloud API

This demo shows how to launch a conversation with the city-weather plugin loaded from this repository.

### Prerequisites

- Access to a staging deployment with the experimental plugin PRs merged
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

> **Important:** The city-weather plugin is in a subdirectory, so you must specify the `path` field.

```bash
curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {
      "content": [
        {
          "type": "text",
          "text": "What is the current weather in Tokyo? Please provide the temperature in both Fahrenheit and Celsius, and show the precipitation forecast for the next 4 hours."
        }
      ]
    },
    "plugin": {
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main",
      "path": "plugins/city-weather"
    }
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

> **Note:** The GET endpoint requires the `?ids=` query parameter and returns an array.

```bash
CONVERSATION_ID="your-conversation-id-here"

# Check status (repeat until sandbox_status is "running")
# Note: Response is an array even for single ID
curl -s -X GET "${STAGING_URL}/api/v1/app-conversations?ids=${CONVERSATION_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.[0] | {id, title, sandbox_status}'
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

> **Note:** For plugins in subdirectories (like in marketplace repos), use the `path` field separately. Do not append the path to the source string.

---

## What the Plugin Does

The city-weather plugin provides instructions for fetching weather data using the [Open-Meteo API](https://open-meteo.com/). When loaded, the agent will:

1. Use the geocoding API to find city coordinates
2. Fetch current weather and hourly forecast
3. Present a formatted report with:
   - Current time in the city's timezone
   - Temperature in °F and °C
   - Precipitation forecast for next 4 hours

**Note:** The plugin instructions are loaded as an always-active skill. See [software-agent-sdk-usage.md](software-agent-sdk-usage.md) for details on how skill loading works and its limitations.

---

## Notes

- Plugin loading happens inside the sandbox/runtime, not on the app server
- Use the `path` field for plugins in subdirectories (do not append to source string)
- Sandbox startup typically takes 30-90 seconds depending on load
- The plugin uses the free Open-Meteo API which requires no API key
- See [testing-troubleshooting.md](testing-troubleshooting.md) for API troubleshooting tips
