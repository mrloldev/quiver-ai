#!/bin/bash
# QuiverAI Image-to-Illustration Generator
# Generates a NEW SVG illustration inspired by a reference image -- NOT a pixel-for-pixel trace.
# Uses the generate endpoint with the image as a reference.
#
# Usage: illustrate.sh "image-url-or-file" [output-file] [--prompt "DESCRIPTION"] [--model MODEL]
#                      [--instructions "STYLE"] [--n N] [--image EXTRA_IMAGE] [--temperature N]

set -euo pipefail

API_BASE="https://api.quiver.ai/v1"

if [ $# -lt 1 ]; then
  echo "Usage: illustrate.sh \"image-url-or-file\" [output-file] [--api-key KEY] [--prompt \"DESCRIPTION\"] [--model MODEL] [--instructions \"STYLE\"] [--n N] [--image EXTRA_IMAGE] [--temperature N]" >&2
  exit 1
fi

IMAGE_INPUT="$1"
shift

# Second arg is output file if it doesn't start with --
OUTPUT_FILE=""
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then
  OUTPUT_FILE="$1"
  shift
fi

# Defaults
PROMPT=""
MODEL="arrow-1.1"
INSTRUCTIONS=""
N=1
EXTRA_IMAGES=()
TEMPERATURE=""

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --api-key)      QUIVERAI_API_KEY="$2"; shift 2 ;;
    --prompt)       PROMPT="$2";           shift 2 ;;
    --model)        MODEL="$2";            shift 2 ;;
    --instructions) INSTRUCTIONS="$2";     shift 2 ;;
    --n)            N="$2";                shift 2 ;;
    --image)        EXTRA_IMAGES+=("$2");  shift 2 ;;
    --temperature)  TEMPERATURE="$2";      shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Resolve API key: env var → interactive prompt
if [ -z "${QUIVERAI_API_KEY:-}" ]; then
  if [ -t 0 ]; then
    echo "QuiverAI API key not set. Get one at https://app.quiver.ai/settings/api-keys" >&2
    read -rsp "Enter API key: " QUIVERAI_API_KEY </dev/tty
    echo >&2
  else
    echo "Error: QUIVERAI_API_KEY is not set. Pass --api-key KEY or set the environment variable." >&2
    exit 1
  fi
fi

# Build a default prompt if none provided
if [ -z "$PROMPT" ]; then
  PROMPT="Create an SVG illustration inspired by this reference image"
fi

# Default output filename from input image basename
if [ -z "$OUTPUT_FILE" ]; then
  BASENAME=$(basename "$IMAGE_INPUT" | sed 's/\.[^.]*$//')
  OUTPUT_FILE="${BASENAME}-illustration.svg"
fi

# Strip .svg extension for multi-output naming
BASE="${OUTPUT_FILE%.svg}"

# Build references array: main image first, then any --image extras
build_image_ref() {
  local img="$1"
  if [[ "$img" =~ ^https?:// ]]; then
    jq -n --arg url "$img" '{url: $url}'
    echo "Reference image (URL): $img" >&2
  else
    if [ ! -f "$img" ]; then
      echo "Error: Image file not found: $img" >&2
      exit 1
    fi
    local b64
    b64=$(base64 < "$img")
    jq -n --arg b64 "$b64" '{base64: $b64}'
    echo "Reference image (file): $img" >&2
  fi
}

MAIN_REF=$(build_image_ref "$IMAGE_INPUT")
REFERENCES_JSON=$(jq -n --argjson ref "$MAIN_REF" '[$ref]')

for img in "${EXTRA_IMAGES[@]}"; do
  REF=$(build_image_ref "$img")
  REFERENCES_JSON=$(echo "$REFERENCES_JSON" | jq --argjson ref "$REF" '. + [$ref]')
done

# Build JSON payload -- uses the generate endpoint with images as references
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  --argjson n "$N" \
  --arg instructions "$INSTRUCTIONS" \
  --argjson references "$REFERENCES_JSON" \
  --arg temperature "$TEMPERATURE" \
  '{model: $model, prompt: $prompt, n: $n, stream: false, references: $references} +
   if $instructions != "" then {instructions: $instructions} else {} end +
   if $temperature != "" then {temperature: ($temperature | tonumber)} else {} end')

echo "Generating illustration with QuiverAI..." >&2
echo "Prompt: $PROMPT" >&2
[ -n "$INSTRUCTIONS" ] && echo "Instructions: $INSTRUCTIONS" >&2
echo "Model: $MODEL | Variants: $N" >&2
[ -n "$TEMPERATURE" ] && echo "Temperature: $TEMPERATURE" >&2

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
