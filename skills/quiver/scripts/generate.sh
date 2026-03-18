#!/bin/bash
# QuiverAI Text-to-SVG Generator
# Usage: generate.sh "prompt" [output-file] [--model MODEL] [--n N] [--instructions "STYLE"]

set -euo pipefail

API_BASE="https://api.quiver.ai/v1"

# Check API key
if [ -z "${QUIVERAI_API_KEY:-}" ]; then
  echo "Error: QUIVERAI_API_KEY is not set." >&2
  echo "Get a key at https://app.quiver.ai/settings/api-keys" >&2
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Usage: generate.sh \"prompt\" [output-file] [--model MODEL] [--n N] [--instructions \"STYLE\"]" >&2
  exit 1
fi

# Parse positional args
PROMPT="$1"
shift

# Second arg is output file if it doesn't start with --
OUTPUT_FILE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then
  OUTPUT_FILE="$1"
  shift
fi

# Defaults
MODEL="arrow-preview"
N=1
INSTRUCTIONS=""

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --model)     MODEL="$2";       shift 2 ;;
    --n)         N="$2";           shift 2 ;;
    --instructions) INSTRUCTIONS="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Default output filename from slugified prompt
if [ -z "$OUTPUT_FILE" ]; then
  SLUG=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-\|-$//g' | cut -c1-40)
  OUTPUT_FILE="${SLUG}.svg"
fi

# Strip .svg extension for multi-output naming
BASE="${OUTPUT_FILE%.svg}"

# Build JSON payload
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  --argjson n "$N" \
  --arg instructions "$INSTRUCTIONS" \
  '{model: $model, prompt: $prompt, n: $n, stream: false} +
   if $instructions != "" then {instructions: $instructions} else {} end')

echo "Generating SVG with QuiverAI..." >&2
echo "Prompt: $PROMPT" >&2
[ -n "$INSTRUCTIONS" ] && echo "Instructions: $INSTRUCTIONS" >&2
echo "Model: $MODEL | Variants: $N" >&2

RESPONSE=$(curl -s -X POST "$API_BASE/svgs/generations" \
  -H "Authorization: Bearer $QUIVERAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Check for API errors
if echo "$RESPONSE" | jq -e '.code' > /dev/null 2>&1; then
  CODE=$(echo "$RESPONSE" | jq -r '.code')
  MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
  echo "Error ($CODE): $MESSAGE" >&2
  exit 1
fi

# Extract and save SVGs
COUNT=$(echo "$RESPONSE" | jq '.data | length')

if [ "$COUNT" -eq 0 ]; then
  echo "Error: No SVGs returned." >&2
  exit 1
fi

SAVED_FILES=()

for i in $(seq 0 $((COUNT - 1))); do
  SVG=$(echo "$RESPONSE" | jq -r ".data[$i].svg")

  if [ "$COUNT" -eq 1 ]; then
    OUTPATH="$OUTPUT_FILE"
  else
    OUTPATH="${BASE}_$((i + 1)).svg"
  fi

  echo "$SVG" > "$OUTPATH"
  SAVED_FILES+=("$OUTPATH")
  echo "Saved: $OUTPATH" >&2
done

# Print saved paths as JSON array for Claude to read
printf '%s\n' "${SAVED_FILES[@]}" | jq -R . | jq -s '{saved: .}'
