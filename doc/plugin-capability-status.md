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

## Demo: Loading Plugins via API

This demo shows how to launch a conversation with a plugin loaded from a GitHub repository.

### Prerequisites

- Access to a staging deployment with the experimental plugin PRs
- An API key for the environment

### Setup

```bash
export STAGING_URL="https://your-staging-url.all-hands.dev"
export API_KEY="sk-oh-YOUR_API_KEY_HERE"
```

### Create a Conversation with a Plugin

```bash
curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {"content": [{"type": "text", "text": "Your prompt here"}]},
    "plugin": {
      "source": "github:owner/repo",
      "ref": "main"
    }
  }' | jq '{id, status}'
```

**Plugin Source Formats:**

| Format | Example |
|--------|---------|
| GitHub shorthand | `github:owner/repo` |
| Git URL | `https://github.com/owner/repo.git` |
| Local path | `/path/to/plugin` |

### Check Conversation Status

```bash
curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/search?limit=5" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.items[] | {id, title, sandbox_status}'
```

### View in Browser

```
${STAGING_URL}/conversations/${CONVERSATION_ID}
```

---

## Available Test Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| Anthropic Skills | `github:anthropics/skills` | Brand guidelines, frontend design, document tools |

---

## Notes

- Plugin loading happens inside the sandbox/runtime, not on the app server
- The `github:` shorthand does not support subdirectory paths
- Wait ~30 seconds after creating a conversation for the runtime to start
