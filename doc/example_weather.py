#!/usr/bin/env python3
"""
Example: Loading a Claude Code format plugin with software-agent-sdk 1.10.0+.

This demonstrates loading the city-weather plugin and using slash commands
to fetch weather information.

Requires: openhands-sdk >= 1.10.0
Install:  pip install "openhands-sdk>=1.10.0"
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
    # The SDK will:
    # 1. Fetch the plugin from GitHub
    # 2. Load commands from commands/ directory
    # 3. Convert commands to KeywordTrigger skills (e.g., /city-weather:now)
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
    # The SDK recognizes /city-weather:now as a KeywordTrigger and activates
    # the command skill with "Tokyo" as $ARGUMENTS
    city = os.getenv("CITY", "Tokyo")
    print(f"\nInvoking: /city-weather:now {city}")
    print("-" * 40)
    conversation.send_message(f"/city-weather:now {city}")
    conversation.run()

    print(f"\nTotal cost: ${llm.metrics.accumulated_cost:.4f}")


if __name__ == "__main__":
    main()
