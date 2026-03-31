# OpenHands Sample Plugins

[![Try City Weather](https://img.shields.io/badge/Try%20City%20Weather-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0xIDE1aC0ydi02aDJ2NnptMC04aC0yVjdoMnYyeiIvPjwvc3ZnPg==)](https://app.all-hands.dev/launch?plugins=W3sic291cmNlIjogImdpdGh1YjpqcHNoYWNrZWxmb3JkL29wZW5oYW5kcy1zYW1wbGUtcGx1Z2lucyIsICJyZWYiOiAibWFpbiIsICJyZXBvX3BhdGgiOiAicGx1Z2lucy9jaXR5LXdlYXRoZXIifV0=)
[![Try Magic Test](https://img.shields.io/badge/Try%20Magic%20Test-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0xIDE1aC0ydi02aDJ2NnptMC04aC0yVjdoMnYyeiIvPjwvc3ZnPg==)](https://app.all-hands.dev/launch?plugins=W3sic291cmNlIjogImdpdGh1YjpqcHNoYWNrZWxmb3JkL29wZW5oYW5kcy1zYW1wbGUtcGx1Z2lucyIsICJyZWYiOiAibWFpbiIsICJyZXBvX3BhdGgiOiAicGx1Z2lucy9tYWdpYy10ZXN0In1d)

A sample plugin marketplace demonstrating the Claude Code plugin marketplace format for OpenHands.

> **🎉 SDK 1.10.0 Released!** Full plugin support with slash commands is now available.
> Install with `pip install openhands-sdk>=1.10.0`

## Marketplace Structure

This repository follows the [Claude Code plugin marketplace format](https://code.claude.com/docs/en/plugin-marketplaces):

```
openhands-sample-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace catalog
├── plugins/
│   └── city-weather/         # Plugin directory
│       ├── .claude-plugin/
│       │   └── plugin.json   # Plugin manifest
│       └── commands/
│           └── now.md    # Slash command
└── README.md
```

## Available Plugins

### city-weather

Get current weather, time, and precipitation forecast for any city worldwide.

**Features:**
- Current temperature in both Fahrenheit and Celsius
- Current time in the city's local timezone
- Precipitation probability for the next 4 hours

**Usage:**
```
/city-weather:now <city>
```

**Examples:**
```
/city-weather:now New York
/city-weather:now Tokyo
/city-weather:now London
```

## Installation

### Claude Code

Add this marketplace to Claude Code:

```
/plugin marketplace add https://github.com/jpshackelford/openhands-sample-plugins.git
```

Then install the city-weather plugin:

```
/plugin install city-weather@openhands-sample-plugins
```

### OpenHands SDK (1.10.0+)

Load plugins directly in Python with full slash command support:

```python
from openhands.sdk import Agent, Conversation, LLM
from openhands.sdk.plugin import PluginSource

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

See the [SDK Usage Guide](doc/software-agent-sdk-usage.md) for complete documentation.

## API

This plugin uses the free [Open-Meteo API](https://open-meteo.com/) which requires no API key.

## Testing with OpenHands Cloud

To test the plugin with OpenHands Cloud:

1. **Create a local environment file:**
   ```bash
   cp setenv.sh.example setenv.sh
   ```

2. **Edit `setenv.sh` with your credentials:**
   ```bash
   export STAGING_URL="https://your-staging-url.all-hands.dev"
   export API_KEY="sk-oh-YOUR_API_KEY_HERE"
   ```

3. **Source the environment file:**
   ```bash
   source ./setenv.sh
   ```

4. **Run the demo:**
   ```bash
   ./doc/demo_weather_plugin.sh "Fullerton CA"
   ```

The demo script will create a conversation with the plugin loaded, wait for the sandbox to start, and open it in your browser.

For more details, see the [Plugin Capability Status](doc/plugin-capability-status.md) documentation.

## License

MIT
