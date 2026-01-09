#!/usr/bin/env python3
"""
Example: Loading a Claude Code format plugin with software-agent-sdk.

This demonstrates loading the city-weather plugin and using it to
fetch weather information.

NOTE: Slash commands like /city-weather:now are NOT supported by the SDK.
See doc/software-agent-sdk-usage.md "Gotchas" section for details.
"""

import os

from pydantic import SecretStr

from openhands.sdk import (
    Agent,
    AgentContext,
    Conversation,
    LLM,
    load_skills_from_dir,
)
from openhands.sdk.tool import Tool
from openhands.tools.terminal import TerminalTool


def main():
    # Check for API key
    api_key = os.getenv("LLM_API_KEY")
    if not api_key:
        print("Error: Set LLM_API_KEY environment variable")
        print("  export LLM_API_KEY='your-api-key'")
        return

    # Load skills from plugin directory
    # The SDK finds .md files with frontmatter and loads them as skills
    repo_skills, knowledge_skills, agent_skills = load_skills_from_dir(
        "plugins/city-weather"
    )

    print(f"Loaded {len(repo_skills)} repo skill(s)")
    for name, skill in repo_skills.items():
        print(f"  - {name}: {skill.description}")

    # Configure LLM
    llm = LLM(
        usage_id="weather-demo",
        model=os.getenv("LLM_MODEL", "anthropic/claude-sonnet-4-20250514"),
        api_key=SecretStr(api_key),
        base_url=os.getenv("LLM_BASE_URL"),
    )

    # Create agent context with the loaded skills
    # The skill content will be included in the system prompt
    #
    # NOTE: The skill is loaded as "always active" because Claude Code
    # command files don't have a `triggers:` field. This means the
    # weather instructions are always in context, not triggered on-demand.
    agent_context = AgentContext(skills=list(repo_skills.values()))

    # Create agent with terminal access for curl commands
    tools = [Tool(name=TerminalTool.name)]
    agent = Agent(llm=llm, tools=tools, agent_context=agent_context)

    # Create conversation
    conversation = Conversation(agent=agent, workspace=os.getcwd())

    # Ask about weather using natural language
    #
    # IMPORTANT: Do NOT use slash command syntax like "/city-weather:now Tokyo"
    # The SDK does not parse slash commands or substitute $ARGUMENTS.
    # See doc/software-agent-sdk-usage.md "Gotchas" section for details.
    #
    # Instead, just describe what you want - the skill instructions are
    # already in the agent's context.
    print("\nAsking: What's the weather in Tokyo?")
    print("-" * 40)
    conversation.send_message("What's the weather in Tokyo?")
    conversation.run()

    print(f"\nTotal cost: ${llm.metrics.accumulated_cost:.4f}")


if __name__ == "__main__":
    main()
