# OpenHands Sample Plugins

A sample plugin marketplace demonstrating the Claude Code plugin marketplace format for OpenHands.

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

### OpenHands

This marketplace is compatible with OpenHands plugin support. See the [OpenHands SDK Skills Guide](https://docs.openhands.dev/sdk/guides/skill) for details on plugin and skill support. For experimental OpenHands Cloud plugin launching, see the [Plugin Capability Status](doc/plugin-capability-status.md) documentation.

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
