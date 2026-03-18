#!/bin/bash
# QuiverAI Image-to-SVG Vectorizer
# Usage: vectorize.sh "image-url-or-file" [output-file] [--model MODEL] [--auto-crop]

set -euo pipefail

API_BASE="https://api.quiver.ai/v1"

# Check API key
if [ -z "${QUIVERAI_API_KEY:-}" ]; then
  echo "Error: QUIVERAI_API_KEY is not set." >&2
  echo "Get a key at https://app.quiver.ai/settings/api-keys" >&2
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Usage: vectorize.sh \"image-url-or-file\" [output-file] [--model MODEL] [--auto-crop]" >&2
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
MODEL="arrow-preview"
AUTO_CROP=false

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --model)     MODEL="$2"; shift 2 ;;
    --auto-crop) AUTO_CROP=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Default output filename
if [ -z "$OUTPUT_FILE" ]; then
  BASENAME=$(basename "$IMAGE_INPUT" | sed 's/\.[^.]*$//')
  OUTPUT_FILE="${BASENAME}-vector.svg"
fi

# Build image reference: URL or base64 local file
if [[ "$IMAGE_INPUT" =~ ^https?:// ]]; then
  IMAGE_JSON=$(jq -n --arg url "$IMAGE_INPUT" '{url: $url}')
  echo "Vectorizing from URL: $IMAGE_INPUT" >&2
else
  if [ ! -f "$IMAGE_INPUT" ]; then
    echo "Error: File not found: $IMAGE_INPUT" >&2
    exit 1
  fi
  B64=$(base64 < "$IMAGE_INPUT")
  IMAGE_JSON=$(jq -n --arg b64 "$B64" '{base64: $b64}')
  echo "Vectorizing local file: $IMAGE_INPUT" >&2
fi

# Build payload
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --argjson image "$IMAGE_JSON" \
  --argjson auto_crop "$AUTO_CROP" \
  '{model: $model, image: $image, stream: false, auto_crop: $auto_crop}')

echo "Model: $MODEL | Auto-crop: $AUTO_CROP" >&2

RESPONSE=$(curl -s -X POST "$API_BASE/svgs/vectorizations" \
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

SVG=$(echo "$RESPONSE" | jq -r '.data[0].svg')

if [ -z "$SVG" ] || [ "$SVG" = "null" ]; then
  echo "Error: No SVG returned." >&2
  exit 1
fi

echo "$SVG" > "$OUTPUT_FILE"
echo "Saved: $OUTPUT_FILE" >&2

jq -n --arg path "$OUTPUT_FILE" '{saved: [$path]}'
