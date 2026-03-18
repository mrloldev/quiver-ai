# quiver-ai

> Agent skill for [QuiverAI](https://quiver.ai) — generate SVGs, logos, and icons from text prompts, or vectorize raster images to SVG, right inside Claude Code.

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

The skill triggers automatically when you ask for SVGs, logos, or icons. Or invoke it directly:

```
/quiver a minimalist fox logo for a fintech startup
/quiver a coffee shop badge with steam rising
/quiver vectorize this image: https://example.com/logo.png
/quiver generate 3 variants of an abstract wave icon
```

### Generate SVG from text

```bash
# Basic
/quiver a rocket ship icon for a SaaS dashboard

# With style guidance
/quiver a mountain silhouette logo — flat design, two colors, circular shape

# Multiple variants (costs N credits)
/quiver generate 4 variants of an abstract data visualization icon
```

### Vectorize an image to SVG

```bash
/quiver vectorize https://example.com/logo.png
/quiver convert ./photo.png to SVG and auto-crop to the subject
```

## How it works

The skill calls the [QuiverAI API](https://docs.quiver.ai/api-reference/introduction) (`POST /v1/svgs/generations` and `POST /v1/svgs/vectorizations`) and saves the output SVG to your working directory.

| API | Description |
|-----|-------------|
| `POST /v1/svgs/generations` | Text prompt → SVG |
| `POST /v1/svgs/vectorizations` | Raster image (URL or file) → SVG |

**Model:** `arrow-preview` (QuiverAI flagship SVG model)

**Rate limits:** 20 requests / 60s per organization

## Billing

1 credit per SVG. Generating N variants costs N credits. See [quiver.ai](https://quiver.ai) for pricing.

## License

MIT
