#!/bin/bash
#
# Demo: Launch city-weather plugin via OpenHands Cloud API
#
# This script creates a conversation with the city-weather plugin loaded,
# waits for the sandbox to be ready, and opens it in your browser.
#
# Usage:
#   export STAGING_URL="https://your-staging.all-hands.dev"
#   export API_KEY="sk-oh-your-key-here"
#   ./demo_weather_plugin.sh [city]
#
# Example:
#   ./demo_weather_plugin.sh "New York"
#

# ============================================================================
# CONFIGURATION - Set these environment variables before running
# ============================================================================

# Your OpenHands Cloud staging URL (no trailing slash)
STAGING_URL="${STAGING_URL:-https://your-staging-url.all-hands.dev}"

# Your OpenHands API key
API_KEY="${API_KEY:-sk-oh-YOUR_API_KEY_HERE}"

# City to get weather for (can be passed as first argument)
CITY="${1:-${CITY:-Tokyo}}"

# ============================================================================
# SCRIPT START
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "  brew install jq  # macOS"
    echo "  apt install jq   # Ubuntu/Debian"
    exit 1
fi

echo -e "${BLUE}Configuration:${NC}"
echo "  Staging URL: $STAGING_URL"
echo "  City: $CITY"
echo ""

# Create conversation with plugin
# Note: The city-weather plugin is in a subdirectory, so we must specify repo_path
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
    "plugins": [{
      "source": "github:jpshackelford/openhands-sample-plugins",
      "ref": "main",
      "repo_path": "plugins/city-weather"
    }]
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
# Note: Sandbox startup can take 30-90+ seconds depending on load
echo -e "${YELLOW}Waiting for sandbox to start...${NC}"
echo "(This typically takes 30-90 seconds)"
echo ""

MAX_ATTEMPTS=45
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    
    # Use the search endpoint to get conversation status
    STATUS_RESPONSE=$(curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/search" \
      -H "Authorization: Bearer ${API_KEY}")
    
    # Find our conversation in the results
    SANDBOX_STATUS=$(echo "$STATUS_RESPONSE" | jq -r --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id) | .sandbox_status // "pending"')
    TITLE=$(echo "$STATUS_RESPONSE" | jq -r --arg id "$CONVERSATION_ID" '.items[] | select(.id == $id) | .title // "Untitled"')
    
    printf "\r  Attempt %d/%d: sandbox_status=%s          " "$ATTEMPT" "$MAX_ATTEMPTS" "$SANDBOX_STATUS"
    
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
    
    sleep 3
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

# Try to open in browser
if command -v open &> /dev/null; then
    # macOS
    echo "Opening in browser..."
    open "${STAGING_URL}/conversations/${CONVERSATION_ID}"
elif command -v xdg-open &> /dev/null; then
    # Linux
    echo "Opening in browser..."
    xdg-open "${STAGING_URL}/conversations/${CONVERSATION_ID}"
else
    echo "Copy the URL above to view in your browser."
fi
