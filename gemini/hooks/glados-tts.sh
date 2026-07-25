#!/usr/bin/env bash

# We receive a JSON payload on stdin from the Gemini CLI
input=$(cat)

# Extract the agent's response text
# The payload schema includes a 'prompt_response' field for the AfterAgent hook
response=$(echo "$input" | jq -r '.prompt_response')

# We pipe it to glados-say in the background so it doesn't block the CLI
echo "$response" | glados-say &

# We must return a valid JSON object to stdout
echo "{}"
