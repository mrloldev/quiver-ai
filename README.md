# quiver-ai

> Agent skill for [QuiverAI](https://quiver.ai). Generates SVGs, logos, and icons from text prompts and reference images, or vectorizes raster images to SVG, right inside Claude Code.

## Install

```bash
npx skills add mrloldev/quiver-ai
```

Works with Claude Code, Cursor, Cline, GitHub Copilot, and [20+ other agents](https://skills.sh).

## Setup

Get an API key at [app.quiver.ai/settings/api-keys](https://app.quiver.ai/settings/api-keys), then:

```bash
export QUIVERAI_API_KEY=your_key_here
```

## Usage

The skill triggers automatically when you ask for SVGs, logos, icons, or illustrations. Or invoke it directly:

```
/quiver a minimalist fox logo for a fintech startup
/quiver a coffee shop badge with steam rising
/quiver vectorize this image: https://example.com/logo.png
/quiver generate 3 variants of an abstract wave icon
/quiver a fox mascot inspired by this image: ./ref.png
```

## Models

| Model ID | Name | Credits (generate) | Credits (vectorize) | Best for |
|----------|------|--------------------|---------------------|----------|
| `arrow-1.1` | Arrow 1.1 | 20 | 15 | Simple icons, logos, badges, flat/minimal designs |
| `arrow-1.1-max` | Arrow 1.1 Max | 25 | 20 | Detailed illustrations, complex designs |
| `arrow-1` | Arrow 1 | 30 | 30 | Highest quality, portraits, complex scenes |

All three models support both text and image input.

Default model is `arrow-1.1`. Pass `--model` to override.

## Commands

### Generate SVG from text

```bash
# Basic
/quiver a rocket ship icon for a SaaS dashboard

# With style guidance
/quiver a mountain silhouette logo, flat design, two colors, circular shape

# Multiple variants (costs N credits)
/quiver generate 4 variants of an abstract data visualization icon

# With a reference image
/quiver a fox mascot in the same style --image ./brand-reference.png

# With multiple reference images
/quiver a brand icon that blends these two styles --image ./ref1.png --image ./ref2.png
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--model MODEL` | `arrow-1.1` | `arrow-1`, `arrow-1.1`, or `arrow-1.1-max` |
| `--n N` | `1` | Variants to generate (1-16) |
| `--instructions "STYLE"` | | Style/formatting guidance |
| `--image FILE_OR_URL` | | Reference image (repeatable, up to 4 for `arrow-1.1`, 16 for `arrow-1.1-max`) |
| `--temperature N` | `1` | Output randomness (0-2); lower = more consistent |

### Vectorize an image to SVG

Traces a raster image and converts it to SVG. Output closely matches the input.

```bash
/quiver vectorize https://example.com/logo.png
/quiver convert ./photo.png to SVG and auto-crop to the subject
/quiver vectorize ./logo.png at 512px
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--model MODEL` | `arrow-1.1` | Model to use |
| `--auto-crop` | off | Auto-crop to dominant subject |
| `--target-size N` | | Resize image to N x N pixels before vectorizing (128-4096) |
| `--temperature N` | `1` | Output randomness (0-2) |

## How it works

The skill calls the [QuiverAI API](https://docs.quiver.ai/api-reference) and saves the output SVG to your working directory.

| API | Description |
|-----|-------------|
| `POST /v1/svgs/generations` | Text prompt (+ optional reference images) -> new SVG |
| `POST /v1/svgs/vectorizations` | Raster image -> traced SVG |

**Rate limits:** 20 requests / 60s per organization

## Billing

Credits are consumed per SVG. `--n N` costs N x model credits per call. See [quiver.ai](https://quiver.ai) for pricing.

## License

MIT
