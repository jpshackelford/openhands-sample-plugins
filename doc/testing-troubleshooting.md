# Plugin API Testing & Troubleshooting Guide

This guide covers common issues and troubleshooting tips when testing the OpenHands plugin REST API.

## Architecture Overview

OpenHands uses a **two-server architecture**:

| Server | Location | Purpose |
|--------|----------|---------|
| **App Server** | Cloud/Staging URL | Manages conversations, users, orchestration |
| **Agent Server** | Inside sandbox | Runs the agent, handles plugin loading, executes tools |

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Frontend /    │────▶│   App Server    │────▶│  Agent Server   │
│   API Client    │     │  (Cloud URL)    │     │  (In Sandbox)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                        │
                              │ Creates sandbox,       │ Fetches plugin,
                              │ passes plugin spec     │ loads skills,
                              │                        │ runs conversation
```

---

## App Server API

The App Server is your main entry point. It's at the staging/cloud URL you're given.

### Base URL
```bash
export STAGING_URL="https://ohpr-XXXXX-XX.staging.all-hands.dev"
```

### Authentication
```bash
-H "Authorization: Bearer ${API_KEY}"
```

### Key Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/app-conversations` | Create a new conversation start task (returns task ID) |
| GET | `/api/v1/app-conversations/start-tasks/search` | Check status of start tasks, get actual conversation ID |
| GET | `/api/v1/app-conversations/search` | List/search conversations with status and runtime info |

### Important: Task ID vs Conversation ID

The POST endpoint returns a **start task**, not the conversation directly:

```bash
# POST returns a task object
{
  "id": "task-uuid-here",           # This is the TASK ID
  "status": "WORKING",
  "app_conversation_id": null,      # Null until task completes
  ...
}
```

To get the actual conversation ID:
1. Poll `/api/v1/app-conversations/start-tasks/search` filtering by task ID
2. Wait for `status` to become `READY`
3. Get `app_conversation_id` from the completed task
4. Use that ID to find the conversation in `/api/v1/app-conversations/search`

```bash
# Poll start-tasks until READY
curl -s "${STAGING_URL}/api/v1/app-conversations/start-tasks/search" \
  -H "Authorization: Bearer ${API_KEY}" \
  | jq --arg id "$TASK_ID" '.items[] | select(.id == $id) | {status, app_conversation_id}'

# Response when ready:
{
  "status": "READY",
  "app_conversation_id": "actual-conversation-uuid"  # Use THIS ID
}
```

### Swagger Documentation
```
${STAGING_URL}/docs
```
> **Note:** Requires OAuth login on staging deployments.

---

## Agent Server API

The Agent Server runs **inside the sandbox** and has its own REST API. You get its URL from the conversation response.

### Getting the Runtime URL and Session Key

After creating a conversation, use the search endpoint to get runtime connection info:

```bash
# Create conversation
RESPONSE=$(curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"initial_message": {"content": [{"type": "text", "text": "Hello"}]}}')

CONVERSATION_ID=$(echo "$RESPONSE" | jq -r '.id')

# Use search endpoint to get conversation details including runtime URL
curl -s "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}" | jq --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id) | {sandbox_status, conversation_url, session_api_key}'
```

**Example Response (when ready):**
```json
{
  "sandbox_status": "RUNNING",
  "conversation_url": "https://xxxxx.staging-runtime.all-hands.dev/api/conversations/abc123",
  "session_api_key": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Querying the Runtime (Agent Server)

To query conversation events directly from the runtime, use the `conversation_url` with the `X-Session-API-Key` header:

```bash
# Get conversation_url and session_api_key from search endpoint first
CONVERSATION_URL="https://xxxxx.staging-runtime.all-hands.dev/api/conversations/abc123"
SESSION_API_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Query events from the runtime
curl -s "${CONVERSATION_URL}/events/search" \
  -H "X-Session-API-Key: ${SESSION_API_KEY}" | jq '.items[] | {kind, source}'
```

### Key Runtime Endpoints

| Method | Endpoint | Auth Header | Description |
|--------|----------|-------------|-------------|
| GET | `{conversation_url}/events/search` | `X-Session-API-Key` | Get conversation events |

### Example: Get Conversation Events

```bash
# Extract from search response
CONV_INFO=$(curl -s "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}" | jq --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id)')

CONVERSATION_URL=$(echo "$CONV_INFO" | jq -r '.conversation_url')
SESSION_API_KEY=$(echo "$CONV_INFO" | jq -r '.session_api_key')

# Query events
curl -s "${CONVERSATION_URL}/events/search" \
  -H "X-Session-API-Key: ${SESSION_API_KEY}" | jq '.items[] | {kind, source, text: (.llm_message.content[0].text // null)}'
```

This is useful for debugging plugin loading - look for events related to skill loading.

---

## Common Issues

### 1. GET Endpoint Returns HTML Instead of JSON

**Symptom:** API calls return HTML (the frontend app) instead of JSON.

**Cause:** Some URL patterns are handled by the frontend router, not the API.

**Solution:** Use the correct API endpoints:

```bash
# ✅ Correct - Use search endpoint for listing conversations
curl "${STAGING_URL}/api/v1/app-conversations/search" -H "Authorization: Bearer ${API_KEY}"

# ❌ Wrong - Frontend route (returns HTML)
curl "${STAGING_URL}/api/v1/app-conversations/${ID}" -H "Authorization: Bearer ${API_KEY}"

# ❌ Wrong - Frontend route
curl "${STAGING_URL}/conversations/${ID}/events" -H "Authorization: Bearer ${API_KEY}"
```

### 2. Finding Your Conversation

**Symptom:** Can't find or query a specific conversation.

**Solution:** Use the search endpoint and filter by ID:

```bash
# ✅ Correct - use search endpoint
curl "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}" | jq --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id)'
```

### 3. Conversation Not Appearing in Search

**Symptom:** Newly created conversation doesn't appear in search results.

**Possible Causes:**
- Conversation is still initializing (sandbox starting up)
- Conversation failed to start

**Solution:** 
- Wait longer (sandbox startup takes 30-90+ seconds)
- Check the original POST response for errors
- Verify the conversation ID is correct

### 4. Plugin Not Loading (Agent Uses Other Tools)

**Symptom:** Agent answers questions using tools like `tavily_tavily_search` instead of plugin-provided skills.

**Possible Causes:**
- Plugin `repo_path` not specified for subdirectory plugins
- Plugin fetch failed silently
- Plugin manifest not found
- **Natural language prompt lets agent choose its approach**

**Diagnosis:**
1. Check if `repo_path` field is needed (for plugins in subdirectories)
2. Look at conversation events for plugin loading logs
3. Verify the plugin repository structure

**Solution for this repository:**
```json
{
  "plugins": [{
    "source": "github:jpshackelford/openhands-sample-plugins",
    "ref": "main",
    "repo_path": "plugins/city-weather"
  }]
}
```

### 5. Use Slash Commands to Guarantee Plugin Skill Invocation

**Symptom:** Plugin loads successfully but agent uses other tools (like web search) instead of the plugin's skills.

**Cause:** When you use natural language prompts, the agent may recognize the plugin skill but choose a different approach it deems more appropriate.

**Solution:** Use slash commands to directly invoke plugin skills:

```bash
# ❌ Natural language - agent may choose different tools
"text": "What is the weather in Tokyo?"

# ✅ Slash command - directly invokes plugin skill
"text": "/city-weather:now Tokyo"
```

**How to find available slash commands:**
- Check the plugin's `commands/` directory
- Each `.md` file corresponds to a command: `/<plugin-name>:<command> <args>`
- Example: `commands/now.md` → `/city-weather:now <city>`

**Test Results Comparison:**

| Approach | Plugin Skill Used? | Tools Invoked |
|----------|-------------------|---------------|
| Natural language: "What is the weather in Tokyo?" | ❌ No (agent chose differently) | `tavily_tavily_search` |
| Slash command: `/city-weather:now Tokyo` | ✅ Yes | `terminal` (curl) as plugin specifies |

### 6. Swagger Docs Require Login

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

**Key Point:** The root level does NOT have a plugin manifest. You must use `repo_path: "plugins/city-weather"` to point to the actual plugin.

---

## Quick Diagnostic Script

```bash
#!/bin/bash
# Quick diagnostic for plugin API testing

STAGING_URL="${STAGING_URL:?Set STAGING_URL}"
API_KEY="${API_KEY:?Set API_KEY}"

echo "=== Testing API Connectivity ==="
curl -s -o /dev/null -w "Status: %{http_code}\n" \
  "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}"

echo ""
echo "=== Creating Test Conversation ==="
RESPONSE=$(curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {"content": [{"type": "text", "text": "Hello"}]},
    "plugins": [{
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main",
      "repo_path": "plugins/city-weather"
    }]
  }')

echo "Response: $RESPONSE"
ID=$(echo "$RESPONSE" | jq -r '.id // "FAILED"')
echo "Conversation ID: $ID"

if [ "$ID" != "FAILED" ] && [ "$ID" != "null" ]; then
  echo ""
  echo "=== Checking Status (wait 10s) ==="
  sleep 10
  curl -s "${STAGING_URL}/api/v1/app-conversations/search" \
    -H "Authorization: Bearer ${API_KEY}" | jq --arg id "$ID" '.items[] | select(.id == $id) | {id, sandbox_status, conversation_url}'
fi
```

---

## Related Documentation

- [Plugin Capability Status](plugin-capability-status.md) - Current feature status and demo instructions
- [Demo Script](demo_weather_plugin.sh) - Automated demo script
- [API Design](https://github.com/OpenHands/OpenHands/issues/12087#issuecomment-3733464400) - Complete API shape documentation
