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

---

## Demo: City Weather Plugin via OpenHands Cloud API

This demo shows how to launch a conversation with the city-weather plugin loaded from this repository.

### Prerequisites

- Access to a staging deployment with the experimental plugin PRs merged
- An API key for the environment

### Quick Start Script

Save this as `demo_weather_plugin.sh` and run it:

```bash
#!/bin/bash
#
# Demo: Launch city-weather plugin via OpenHands Cloud API
#
# This script creates a conversation with the city-weather plugin loaded,
# waits for the sandbox to be ready, and opens it in your browser.
#

# ============================================================================
# CONFIGURATION - Set these environment variables before running
# ============================================================================

# Your OpenHands Cloud staging URL (no trailing slash)
STAGING_URL="${STAGING_URL:-https://your-staging-url.all-hands.dev}"

# Your OpenHands API key
API_KEY="${API_KEY:-sk-oh-YOUR_API_KEY_HERE}"

# City to get weather for
CITY="${CITY:-Tokyo}"

# ============================================================================
# SCRIPT START
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== City Weather Plugin Demo ===${NC}"
echo ""

# Validate configuration
if [[ "$STAGING_URL" == *"your-staging-url"* ]]; then
    echo -e "${RED}Error: Set STAGING_URL environment variable${NC}"
    echo "  export STAGING_URL='https://your-staging.all-hands.dev'"
    exit 1
fi

if [[ "$API_KEY" == *"YOUR_API_KEY"* ]]; then
    echo -e "${RED}Error: Set API_KEY environment variable${NC}"
    echo "  export API_KEY='sk-oh-your-key-here'"
    exit 1
fi

echo "Staging URL: $STAGING_URL"
echo "City: $CITY"
echo ""

# Create conversation with plugin
echo -e "${YELLOW}Creating conversation with city-weather plugin...${NC}"

RESPONSE=$(curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {
      "content": [
        {
          "type": "text",
          "text": "What is the current weather in '"${CITY}"'? Please provide the temperature in both Fahrenheit and Celsius, and show the precipitation forecast for the next 4 hours."
        }
      ]
    },
    "plugin": {
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main"
    }
  }')

# Extract conversation ID
CONVERSATION_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -z "$CONVERSATION_ID" ]; then
    echo -e "${RED}Error: Failed to create conversation${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

echo -e "${GREEN}Conversation created: ${CONVERSATION_ID}${NC}"
echo ""

# Wait for sandbox to be ready
echo -e "${YELLOW}Waiting for sandbox to start...${NC}"
echo "(This typically takes 20-40 seconds)"
echo ""

MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    
    STATUS_RESPONSE=$(curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/${CONVERSATION_ID}" \
      -H "Authorization: Bearer ${API_KEY}")
    
    SANDBOX_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.sandbox_status // "unknown"')
    TITLE=$(echo "$STATUS_RESPONSE" | jq -r '.title // "Untitled"')
    
    echo -ne "\r  Attempt ${ATTEMPT}/${MAX_ATTEMPTS}: sandbox_status=${SANDBOX_STATUS}    "
    
    if [ "$SANDBOX_STATUS" == "running" ]; then
        echo ""
        echo -e "${GREEN}Sandbox is ready!${NC}"
        break
    fi
    
    if [ "$SANDBOX_STATUS" == "failed" ] || [ "$SANDBOX_STATUS" == "error" ]; then
        echo ""
        echo -e "${RED}Sandbox failed to start${NC}"
        echo "Response: $STATUS_RESPONSE"
        exit 1
    fi
    
    sleep 2
done

if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
    echo ""
    echo -e "${YELLOW}Warning: Sandbox may still be starting${NC}"
fi

# Output results
echo ""
echo -e "${GREEN}=== Conversation Ready ===${NC}"
echo ""
echo "Conversation ID: ${CONVERSATION_ID}"
echo "Title: ${TITLE}"
echo ""
echo "View in browser:"
echo -e "  ${GREEN}${STAGING_URL}/conversations/${CONVERSATION_ID}${NC}"
echo ""

# Try to open in browser (macOS)
if command -v open &> /dev/null; then
    echo "Opening in browser..."
    open "${STAGING_URL}/conversations/${CONVERSATION_ID}"
fi
```

### Manual Step-by-Step

If you prefer to run the commands manually:

#### 1. Set Environment Variables

```bash
export STAGING_URL="https://your-staging-url.all-hands.dev"
export API_KEY="sk-oh-YOUR_API_KEY_HERE"
```

#### 2. Create Conversation with Plugin

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
      "ref": "main"
    }
  }' | jq '{id, status}'
```

**Expected Response:**
```json
{
  "id": "abc123-def456-...",
  "status": "STARTING"
}
```

#### 3. Poll for Sandbox Ready

```bash
CONVERSATION_ID="your-conversation-id-here"

# Check status (repeat until sandbox_status is "running")
curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/${CONVERSATION_ID}" \
  -H "Authorization: Bearer ${API_KEY}" | jq '{id, title, sandbox_status}'
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
- The `github:` shorthand does not support subdirectory paths
- Wait ~30 seconds after creating a conversation for the runtime to start
- The plugin uses the free Open-Meteo API which requires no API key
