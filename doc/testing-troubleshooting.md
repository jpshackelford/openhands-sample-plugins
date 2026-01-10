# Plugin API Testing & Troubleshooting Guide

This guide covers common issues and troubleshooting tips when testing the OpenHands plugin REST API.

## API Endpoint Reference

### App Server Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/app-conversations` | Create a new conversation (with optional plugin) |
| GET | `/api/v1/app-conversations?ids={id}` | Get conversation status (note: `ids` param required) |

### Authentication

All API requests require Bearer token authentication:

```bash
-H "Authorization: Bearer ${API_KEY}"
```

---

## Common Issues

### 1. GET Endpoint Returns HTML Instead of JSON

**Symptom:** API calls return HTML (the frontend app) instead of JSON.

**Cause:** Some URL patterns are handled by the frontend router, not the API.

**Solution:** Always use the `/api/v1/` prefix for API calls:

```bash
# ✅ Correct - API endpoint
curl "${STAGING_URL}/api/v1/app-conversations?ids=${ID}" -H "Authorization: Bearer ${API_KEY}"

# ❌ Wrong - Frontend route (returns HTML)
curl "${STAGING_URL}/api/v1/app-conversations/${ID}" -H "Authorization: Bearer ${API_KEY}"

# ❌ Wrong - Frontend route
curl "${STAGING_URL}/conversations/${ID}/events" -H "Authorization: Bearer ${API_KEY}"
```

### 2. GET Conversations Returns Validation Error

**Symptom:** 
```json
{"detail":[{"type":"missing","loc":["query","ids"],"msg":"Field required"}]}
```

**Cause:** The `ids` query parameter is required.

**Solution:** Include the `?ids=` parameter:

```bash
# ✅ Correct
curl "${STAGING_URL}/api/v1/app-conversations?ids=${CONVERSATION_ID}" -H "Authorization: Bearer ${API_KEY}"
```

### 3. Conversation Returns `[null]`

**Symptom:** GET request returns `[null]` instead of conversation data.

**Possible Causes:**
- Conversation is still initializing (sandbox starting up)
- Conversation failed to start
- Invalid conversation ID

**Solution:** 
- Wait longer (sandbox startup takes 30-90+ seconds)
- Check the original POST response for errors
- Verify the conversation ID is correct

### 4. Plugin Not Loading (Agent Uses Other Tools)

**Symptom:** Agent answers questions using tools like `tavily_tavily_search` instead of plugin-provided skills.

**Possible Causes:**
- Plugin path not specified for subdirectory plugins
- Plugin fetch failed silently
- Plugin manifest not found

**Diagnosis:**
1. Check if `path` field is needed (for plugins in subdirectories)
2. Look at conversation events for plugin loading logs
3. Verify the plugin repository structure

**Solution for this repository:**
```json
{
  "plugin": {
    "source": "github:jpshackelford/openhands-sample-plugins",
    "ref": "main",
    "path": "plugins/city-weather"  // Required - plugin is in subdirectory
  }
}
```

### 5. Swagger Docs Require Login

**Symptom:** Accessing `${STAGING_URL}/docs` redirects to GitHub OAuth login.

**Cause:** Swagger UI is behind OAuth proxy on staging deployments.

**Workaround:** Use the API directly with Bearer token authentication, or authenticate via browser first.

---

## Timing Expectations

| Operation | Typical Duration |
|-----------|------------------|
| Conversation creation (POST) | < 1 second |
| Sandbox startup | 30-90 seconds |
| Plugin fetch (git clone) | 5-15 seconds |
| Plugin load | < 1 second |

**Recommendations:**
- Poll every 3-5 seconds when waiting for sandbox
- Set max attempts to 30-45 (90-135 seconds total)
- Don't give up too early - some deploys are slower

---

## Verifying Plugin Loaded Successfully

### What to Look For

When a plugin loads successfully, you should see in the agent's behavior:
- Agent uses skills/instructions from the plugin
- Agent does NOT fall back to general tools like web search

When a plugin FAILS to load:
- Agent tries to answer using other available tools
- May use `tavily_tavily_search` or similar for information retrieval

### Checking Events (if available)

Look for plugin-related log messages:
- `"Fetching plugin from: ..."` - Plugin fetch started
- `"Loading plugin from: ..."` - Plugin load started  
- `"Loaded plugin 'name' with N skills..."` - Success

---

## Repository Structure

This repository is a **marketplace-style** repo with plugins in subdirectories:

```
openhands-sample-plugins/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace metadata (NOT a plugin)
└── plugins/
    └── city-weather/       # Actual plugin
        ├── .claude-plugin/
        │   └── plugin.json # Plugin manifest
        └── commands/
```

**Key Point:** The root level does NOT have a plugin manifest. You must use `path: "plugins/city-weather"` to point to the actual plugin.

---

## Quick Diagnostic Script

```bash
#!/bin/bash
# Quick diagnostic for plugin API testing

STAGING_URL="${STAGING_URL:?Set STAGING_URL}"
API_KEY="${API_KEY:?Set API_KEY}"

echo "=== Testing API Connectivity ==="
curl -s -o /dev/null -w "Status: %{http_code}\n" \
  "${STAGING_URL}/api/v1/app-conversations?ids=test" \
  -H "Authorization: Bearer ${API_KEY}"

echo ""
echo "=== Creating Test Conversation ==="
RESPONSE=$(curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {"content": [{"type": "text", "text": "Hello"}]},
    "plugin": {
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main",
      "path": "plugins/city-weather"
    }
  }')

echo "Response: $RESPONSE"
ID=$(echo "$RESPONSE" | jq -r '.id // "FAILED"')
echo "Conversation ID: $ID"

if [ "$ID" != "FAILED" ] && [ "$ID" != "null" ]; then
  echo ""
  echo "=== Checking Status (wait 10s) ==="
  sleep 10
  curl -s "${STAGING_URL}/api/v1/app-conversations?ids=${ID}" \
    -H "Authorization: Bearer ${API_KEY}" | jq '.[0] | {id, status, sandbox_status}'
fi
```

---

## Related Documentation

- [Plugin Capability Status](plugin-capability-status.md) - Current feature status and demo instructions
- [Demo Script](demo_weather_plugin.sh) - Automated demo script
- [API Design](https://github.com/OpenHands/OpenHands/issues/12087#issuecomment-3733464400) - Complete API shape documentation
