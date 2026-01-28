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

# Use slash command to directly invoke the plugin skill
# This guarantees the plugin's skill is used rather than letting the agent choose
RESPONSE=$(curl -s -X POST "${STAGING_URL}/api/v1/app-conversations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": {
      "content": [
        {
          "type": "text",
          "text": "/city-weather:now '"${CITY}"'"
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
#
# IMPORTANT: The conversation ID returned from POST may not match the ID that
# appears in search results (this appears to be a known quirk). We track the
# count of conversations before/after to detect when our new one appears.
echo -e "${YELLOW}Waiting for sandbox to start...${NC}"
echo "(This typically takes 30-90 seconds)"
echo ""

# Get initial count of conversations
INITIAL_COUNT=$(curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/search" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.items | length')

MAX_ATTEMPTS=45
ATTEMPT=0
FOUND_NEW=false

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    
    # Use the search endpoint to get conversation status
    STATUS_RESPONSE=$(curl -s -X GET "${STAGING_URL}/api/v1/app-conversations/search" \
      -H "Authorization: Bearer ${API_KEY}")
    
    CURRENT_COUNT=$(echo "$STATUS_RESPONSE" | jq '.items | length')
    
    # Check if a new conversation appeared (count increased)
    if [ "$CURRENT_COUNT" -gt "$INITIAL_COUNT" ] || [ "$FOUND_NEW" == "true" ]; then
        FOUND_NEW=true
        # Get the most recent conversation's status and ID
        SANDBOX_STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.items[0].sandbox_status // "pending"')
        CONVERSATION_ID=$(echo "$STATUS_RESPONSE" | jq -r '.items[0].id // empty')
        TITLE=$(echo "$STATUS_RESPONSE" | jq -r '.items[0].title // "Untitled"')
    else
        SANDBOX_STATUS="waiting for conversation..."
    fi
    
    printf "\r  Attempt %d/%d: %s          " "$ATTEMPT" "$MAX_ATTEMPTS" "$SANDBOX_STATUS"
    
    # Note: API returns uppercase status values (RUNNING, PAUSED, etc.)
    if [ "$SANDBOX_STATUS" == "RUNNING" ]; then
        echo ""
        echo -e "${GREEN}Sandbox is ready!${NC}"
        break
    fi
    
    if [ "$SANDBOX_STATUS" == "FAILED" ] || [ "$SANDBOX_STATUS" == "ERROR" ]; then
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
