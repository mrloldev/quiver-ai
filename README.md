# quiver-ai

Agent skills for [QuiverAI](https://quiver.ai) — generate SVGs, logos, and icons from text prompts, or vectorize raster images to SVG.

## Install

```bash
npx skills add <your-github-username>/quiver-ai
```

## Skills

### `/quiver`

Generate production-ready SVGs using the [QuiverAI API](https://docs.quiver.ai).

**Triggers automatically when you ask for:**
- Logo or icon generation
- SVG creation from a description
- Vectorizing a PNG/JPG to SVG

**Or invoke directly:**

```
/quiver a minimalist fox logo for a tech company
```

## Setup

Set your QuiverAI API key as an environment variable:

```bash
export QUIVERAI_API_KEY=your_key_here
```

Get a key at [app.quiver.ai/settings/api-keys](https://app.quiver.ai/settings/api-keys).

## Usage examples

```
/quiver a coffee shop badge with steam rising
/quiver vectorize this image: https://example.com/logo.png
/quiver generate 3 variants of an abstract wave icon
```

## Billing

1 credit per SVG generated or vectorized. See [QuiverAI pricing](https://quiver.ai).
