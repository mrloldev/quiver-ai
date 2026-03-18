---
name: quiver
description: Generate SVGs, logos, icons, and design assets using QuiverAI. Use when asked to create logos, icons, illustrations, badges, or any vector graphics from text descriptions. Also use to vectorize/convert raster images (PNG, JPG) to SVG. Triggers on requests like "create a logo", "generate an icon", "make an SVG", "design a badge", "vectorize this image to SVG".
argument-hint: <prompt or image-url>
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/generate.sh), Bash(${CLAUDE_SKILL_DIR}/scripts/vectorize.sh)
---

You have access to QuiverAI's SVG generation API. Use it to create production-ready SVG graphics.

## Prerequisites

The `QUIVERAI_API_KEY` environment variable must be set. If it's missing, tell the user to:

1. Get an API key at https://app.quiver.ai/settings/api-keys
2. Add to their shell: `export QUIVERAI_API_KEY=your_key_here`

## Commands

### Generate SVG from a text prompt

```bash
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "PROMPT" [OUTPUT_FILE] [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--model MODEL` | `arrow-preview` | Model to use |
| `--n N` | `1` | Number of variants (1–16, costs N credits each) |
| `--instructions "STYLE"` | — | Style/formatting guidance |

Examples:

```bash
# Basic logo
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "minimalist rocket ship logo for a tech startup" logo.svg

# With style instructions
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "coffee shop badge with steam" badge.svg \
  --instructions "flat design, two colors, circular badge shape"

# Multiple variants
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "abstract wave icon" wave.svg --n 3
# Saves: wave_1.svg, wave_2.svg, wave_3.svg
```

### Vectorize an image to SVG

```bash
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" "IMAGE_URL_OR_LOCAL_FILE" [OUTPUT_FILE] [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--model MODEL` | `arrow-preview` | Model to use |
| `--auto-crop` | off | Auto-crop to dominant subject before vectorizing |

Examples:

```bash
# From URL
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" "https://example.com/logo.png" logo-vector.svg

# Local file with auto-crop
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" ./photo.png portrait.svg --auto-crop
```

## Workflow

1. **Understand the request** — logo, icon, illustration, badge, etc.
2. **Write a specific prompt** — include the subject, use case, and key visual elements
3. **Add `--instructions`** to control style — e.g. `"flat monochrome, rounded corners, minimal detail"` or `"colorful, playful, thick strokes"`
4. **Run the script** and report where the SVG was saved
5. For multiple variants (`--n 2+`), files are saved as `name_1.svg`, `name_2.svg`, etc.

## Prompt tips

- Be specific: `"a fox holding a magnifying glass, side profile"` beats `"a fox"`
- State the use case: `"for a mobile app icon"`, `"for a company logo"`, `"for a loading spinner"`
- Style keywords that work well: `flat design`, `line art`, `monochrome`, `gradient`, `outlined`, `filled`, `geometric`, `organic`

## Billing

1 credit per SVG. `--n N` costs N credits. Default to `--n 1` unless the user explicitly wants variants.
