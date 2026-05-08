# Repository Guidelines

Guidance for AI agents working in **kluris-site** — the marketing/tutorial site for kluris.io.

## Knowledge base

Read and write to the **ngvoicu-sme** brain through kluris (never edit brain files by hand). Use the `/kluris-ngvoicu-sme` skill — search, learn, remember, create.

Topics relevant to this repo: kluris-site overview (sections, SEO, assets), deployment (GitHub Pages + custom-domain DNS).

## What this repo is

A single static landing page (`index.html`, ~1400 lines, 12 sections) hosted on GitHub Pages at **kluris.io**. Inline CSS + Tailwind via CDN; vanilla JS for the hero brain canvas. **No build step, no framework, no bundler** — `open index.html` to preview locally.

Tagline used on the site: *"The SME your team never had."*

## Editing

The whole site is one file. In-file section markers (e.g. `SECTION 4 — YOUR FIRST BRAIN`) make navigation easy. Tailwind config + custom CSS variables sit at the top of `<head>`.

## Notable assets

| File | Purpose |
|------|---------|
| `index.html` | The full single-page site |
| `logo.png` / `logo.webp` / `logo.pxd` | Brand logo (Pixelmator source) |
| `mri-ngvoicu.png` | Real `kluris mri` output, embedded in section 8 |
| `og-image.png` | Open Graph / Twitter Card image (1200×630) — keep under 200 KB or WhatsApp falls back to apple-touch-icon |
| `favicon-*.png`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png` | Browser/PWA icons |
| `site.webmanifest` | PWA manifest |
| `CNAME` | GitHub Pages custom domain (`kluris.io`) |
| `robots.txt`, `sitemap.xml` | SEO |

## SEO

- Title, description, keywords, canonical URL
- Open Graph + Twitter Card tags
- Three JSON-LD blocks: `SoftwareApplication`, `Organization`, `WebSite`
- Theme color, Apple touch icon, web manifest
- Semantic HTML, image alt attributes, anchor IDs

## Deploy

Push to `main`. GitHub Pages rebuilds automatically — no CI workflow. DNS: four `A` records at the apex pointing to GitHub Pages (`185.199.108.153`–`185.199.111.153`), plus `CNAME www → ngvoicu.github.io`.

## License

MIT for code. Brand assets (`logo.png`, `logo.webp`) are © Gabriel Voicu — not for derivative or competing products.
