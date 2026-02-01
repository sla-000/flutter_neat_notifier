#!/bin/bash

# Gist IDs
COUNTER_ID="3a160a928c3c9ad0ff86292feabd3b5d"
HYDRATED_ID="9399b7b0b55520dfd79de5a306ae97b8"
UNDOREDO_ID="70970fba69ad18d50c58a2f5dc2a0ca3"
ASYNC_OPERATIONS_ID="" # TODO: Add Gist ID
MULTI_STATE_ID="" # TODO: Add Gist ID
CONTEXT_EXTENSIONS_ID="" # TODO: Add Gist ID

# Check for Gist Token
if [ -z "$GIST_TOKEN" ]; then
  echo "Error: GIST_TOKEN environment variable is missing."
  exit 1
fi

update_gist() {
  local name=$1
  local id=$2
  
  if [ -z "$id" ]; then
    echo "Skipping $name: No ID provided."
    return
  fi

  echo "Updating Gist for $name ($id)..."
  
  filepath="docs_site/static/examples/$name/main.dart"
  if [ ! -f "$filepath" ]; then
    echo "Error: File $filepath not found."
    return
  fi

  content=$(cat "$filepath")
  payload=$(jq -n --arg content "$content" '{"files": {"main.dart": {"content": $content}}}')

  response=$(curl -s -w "%{http_code}" -o /dev/null -X PATCH \
    -H "Authorization: token $GIST_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "https://api.github.com/gists/$id")

  if [ "$response" == "200" ]; then
    echo "Successfully updated $name."
  else
    echo "Failed to update $name. HTTP status: $response"
  fi
}

update_gist "counter" "$COUNTER_ID"
update_gist "hydrated" "$HYDRATED_ID"
update_gist "undoredo" "$UNDOREDO_ID"
update_gist "async_operations" "$ASYNC_OPERATIONS_ID"
update_gist "multi_state" "$MULTI_STATE_ID"
update_gist "context_extensions" "$CONTEXT_EXTENSIONS_ID"
