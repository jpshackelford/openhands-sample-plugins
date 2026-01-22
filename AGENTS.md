# OpenHands Sample Plugins Repository

This repository contains sample plugins for OpenHands and documentation for testing the plugin API.

## Key Documentation

| Document | Purpose |
|----------|---------|
| [doc/plugin-capability-status.md](doc/plugin-capability-status.md) | Current feature status and step-by-step demo instructions |
| [doc/demo_weather_plugin.sh](doc/demo_weather_plugin.sh) | Automated demo script for the city-weather plugin |
| [doc/testing-troubleshooting.md](doc/testing-troubleshooting.md) | API endpoint patterns, common issues, and debugging tips |

## Quick Start

```bash
export STAGING_URL="https://your-staging.all-hands.dev"
export API_KEY="sk-oh-your-key-here"
./doc/demo_weather_plugin.sh "Tokyo"
```

## Sample Plugins

| Plugin | Path | Description |
|--------|------|-------------|
| magic-test | `plugins/magic-test` | Simple keyword-triggered skill for verifying plugin loading |
| city-weather | `plugins/city-weather` | Weather lookup using Open-Meteo API |
