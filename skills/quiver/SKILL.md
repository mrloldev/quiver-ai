---
name: quiver
description: Generate SVGs, logos, icons, and design assets using QuiverAI. Use when asked to create logos, icons, illustrations, badges, or any vector graphics from text descriptions. Also use to vectorize/convert raster images (PNG, JPG) to SVG, or to create a new SVG illustration inspired by a reference image. Triggers on requests like "create a logo", "generate an icon", "make an SVG", "design a badge", "vectorize this image to SVG", "illustrate this image as SVG", "turn this photo into an illustration".
argument-hint: <prompt or image-url>
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/generate.sh), Bash(${CLAUDE_SKILL_DIR}/scripts/vectorize.sh), Bash(${CLAUDE_SKILL_DIR}/scripts/illustrate.sh)
---

You have access to QuiverAI's SVG generation API. Use it to create production-ready SVG graphics.

## Prerequisites

The `QUIVERAI_API_KEY` environment variable must be set. If it's missing, tell the user to:

1. Get an API key at https://app.quiver.ai/settings/api-keys
2. Add to their shell: `export QUIVERAI_API_KEY=your_key_here`

## Models

| Model | Credits (generate) | Credits (vectorize) | Best for |
|-------|-------------------|---------------------|----------|
| `arrow-1.1` | 20 | 15 | Simple icons, logos, badges, flat/minimal designs |
| `arrow-1.1-max` | 25 | 20 | Detailed illustrations, general-purpose (default) |
| `arrow-1` | 30 | 30 | Highest quality, portraits, complex scenes |

All three models accept both text and image input.

### Model selection

Default is `arrow-1.1`. Choose based on the request:

- **`arrow-1.1`** — default; icons, logos, badges, flat/minimal designs
- **`arrow-1.1-max`** — more detail and polish when the user asks for higher quality or the design is complex
- **`arrow-1`** — flagship; portraits, detailed illustrations, complex scenes, or when the user explicitly wants the best quality

## Commands

### Generate SVG from a text prompt

```bash
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "PROMPT" [OUTPUT_FILE] [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--model MODEL` | `arrow-1.1` | Model to use (`arrow-1`, `arrow-1.1`, `arrow-1.1-max`) |
| `--n N` | `1` | Number of variants (1–16, costs N credits each) |
| `--instructions "STYLE"` | — | Style/formatting guidance |
| `--image IMAGE_URL_OR_FILE` | — | Reference image (repeatable; up to 4 for `arrow-1.1`, 16 for `arrow-1.1-max`) |
| `--temperature N` | `1` | Output randomness (0–2); lower = more consistent results |

Examples:

```bash
# Basic logo (auto-selects arrow-1.1 for "logo" keyword)
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "minimalist rocket ship logo for a tech startup" logo.svg

# With style instructions
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "coffee shop badge with steam" badge.svg \
  --instructions "flat design, two colors, circular badge shape"

# Multiple variants
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "abstract wave icon" wave.svg --n 3
# Saves: wave_1.svg, wave_2.svg, wave_3.svg

# With reference image (URL)
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "a fox mascot in the same style" mascot.svg \
  --image "https://example.com/brand-reference.png"

# With reference image (local file)
"${CLAUDE_SKILL_DIR}/scripts/generate.sh" "modern rebrand of this logo" new-logo.svg \
  --image ./old-logo.png --model arrow-1
```

### Vectorize an image to SVG (trace/convert)

Converts a raster image into an SVG by tracing its shapes — output closely matches the input.

```bash
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" "IMAGE_URL_OR_LOCAL_FILE" [OUTPUT_FILE] [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--model MODEL` | `arrow-1.1-max` | Model to use |
| `--auto-crop` | off | Auto-crop to dominant subject before vectorizing |
| `--target-size N` | — | Resize image to N×N pixels before vectorizing (128–4096) |
| `--temperature N` | `1` | Output randomness (0–2) |

Examples:

```bash
# From URL
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" "https://example.com/logo.png" logo-vector.svg

# Local file with auto-crop
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" ./photo.png portrait.svg --auto-crop

# Use flagship model for best quality
"${CLAUDE_SKILL_DIR}/scripts/vectorize.sh" ./complex-art.png art.svg --model arrow-1
```

### Image-to-illustration (create new SVG inspired by an image)

Generates a **brand-new SVG illustration** inspired by a reference image — NOT a trace. Uses the generate endpoint with the image as a reference, so the output is a creative reinterpretation, not a copy.

```bash
"${CLAUDE_SKILL_DIR}/scripts/illustrate.sh" "IMAGE_URL_OR_LOCAL_FILE" [OUTPUT_FILE] [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--prompt "DESCRIPTION"` | auto | What to generate, informed by the image |
| `--model MODEL` | `arrow-1.1` | Model to use |
| `--instructions "STYLE"` | — | Style/formatting guidance |
| `--n N` | `1` | Number of variants |
| `--image IMAGE_URL_OR_FILE` | — | Additional reference images (repeatable) |
| `--temperature N` | `1` | Output randomness (0–2) |

Examples:

```bash
# Turn a photo into an SVG illustration
"${CLAUDE_SKILL_DIR}/scripts/illustrate.sh" ./cat-photo.jpg cat-illustration.svg \
  --prompt "a playful cartoon cat illustration"

# From URL with style guidance
"${CLAUDE_SKILL_DIR}/scripts/illustrate.sh" "https://example.com/cityscape.jpg" city.svg \
  --prompt "minimalist city skyline illustration" \
  --instructions "flat colors, geometric shapes, no gradients"

# Flagship model for portrait illustration
"${CLAUDE_SKILL_DIR}/scripts/illustrate.sh" ./portrait.jpg portrait.svg \
  --prompt "stylized portrait illustration" \
  --model arrow-1

# Multiple variants
"${CLAUDE_SKILL_DIR}/scripts/illustrate.sh" ./logo.png logo-reimagined.svg \
  --prompt "modern reimagining of this brand logo" --n 3
```

## Choosing the right command

| Goal | Command |
|------|---------|
| Create SVG from text description | `generate.sh` |
| Convert/trace an existing image to SVG | `vectorize.sh` |
| Generate a new illustration inspired by an image | `illustrate.sh` |

## Workflow

1. **Understand the request** — logo, icon, illustration, badge, trace, or image-inspired illustration
2. **Pick the right script** — generate for text, vectorize for tracing, illustrate for image-inspired creation
3. **Write a specific prompt** — include the subject, use case, and key visual elements
4. **Add `--instructions`** to control style — e.g. `"flat monochrome, rounded corners, minimal detail"`
5. **Run the script** and report where the SVG was saved
6. For multiple variants (`--n 2+`), files are saved as `name_1.svg`, `name_2.svg`, etc.

## Prompt tips

- Be specific: `"a fox holding a magnifying glass, side profile"` beats `"a fox"`
- State the use case: `"for a mobile app icon"`, `"for a company logo"`, `"for a loading spinner"`
- Style keywords that work well: `flat design`, `line art`, `monochrome`, `gradient`, `outlined`, `filled`, `geometric`, `organic`

## Billing

Credits are consumed per SVG generated. `--n N` costs N × model credits. Default to `--n 1` unless the user explicitly wants variants.
