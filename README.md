# kluris-site

The marketing and tutorial site for [Kluris](https://github.com/ngvoicu/kluris-cli) — *the SME your team never had.*

Lives at **[https://kluris.io/](https://kluris.io/)**.

## Stack

- Single static `index.html` (no build step, no framework, no bundler)
- Inline CSS + Tailwind via CDN
- Vanilla JS for the hero brain canvas
- Hosted on **GitHub Pages** with custom domain

## Files

| File | Purpose |
|---|---|
| `index.html` | The full single-page site (12 sections, ~1400 lines) |
| `logo.png` | Brand logo (used in nav, hero, footer) |
| `logo.webp` | Source brand image (kept as reference) |
| `mri-ngvoicu.png` | Real `kluris mri` output, embedded in section 8 |
| `favicon-16x16.png`, `favicon-32x32.png` | Browser tab favicons |
| `apple-touch-icon.png` | iOS home screen icon (180×180) |
| `icon-192.png`, `icon-512.png` | PWA / Android icons |
| `og-image.png` | Open Graph / Twitter Card image (1200×630) |
| `site.webmanifest` | PWA manifest |
| `robots.txt` | Search engine directives |
| `sitemap.xml` | URL list for crawlers |
| `CNAME` | GitHub Pages custom domain (`kluris.io`) |

## Local preview

```bash
open index.html
```

That is it. No dev server, no build, no install. Open the file directly.

## SEO

The site has a complete SEO setup:

- Title, description, keywords, canonical URL
- Open Graph tags for Facebook / LinkedIn / Discord
- Twitter Card tags for X
- Theme color for mobile browsers
- Apple touch icon + web manifest for PWA install
- Three JSON-LD structured data blocks: `SoftwareApplication`, `Organization`, `WebSite`
- `robots.txt` + `sitemap.xml`
- Semantic HTML with proper heading hierarchy
- Image alt attributes everywhere
- All internal links use anchor IDs

## GitHub Pages deployment

This folder is designed to deploy to GitHub Pages with a custom domain (`kluris.io`).

### One-time setup

1. **Push the folder to a GitHub repo** (for example `ngvoicu/kluris-site` — separate repo, or as a subfolder of `kluris-cli` with Pages source set to that subfolder).

2. **Enable GitHub Pages:**
   - Repo → **Settings** → **Pages**
   - **Source:** Deploy from a branch
   - **Branch:** `main` / `/ (root)`
   - Save.

3. **Custom domain:**
   - Same Settings → Pages page
   - **Custom domain:** `kluris.io`
   - Save. GitHub will detect the `CNAME` file in this folder automatically.
   - Tick **Enforce HTTPS** once the cert is issued (a few minutes).

4. **DNS records** at your domain registrar (Cloudflare, Namecheap, Porkbun, etc.):

   For an apex domain (`kluris.io`), add four `A` records pointing to GitHub Pages:

   ```
   A    @    185.199.108.153
   A    @    185.199.109.153
   A    @    185.199.110.153
   A    @    185.199.111.153
   ```

   Plus a `CNAME` for the `www` subdomain so `www.kluris.io` redirects:

   ```
   CNAME    www    ngvoicu.github.io
   ```

   (Replace `ngvoicu` with the actual GitHub username/org that owns the repo.)

5. **Wait for propagation** (DNS: minutes to hours · GitHub cert issuance: minutes).

### Subsequent deploys

Just push to `main`. GitHub Pages rebuilds automatically. No CI workflow needed — Pages handles a static site directly.

```bash
git add -A
git commit -m "site: copy tweak"
git push origin main
```

## Editing

The whole site is one file. To change a section, search for the section comment marker (e.g. `SECTION 4 — YOUR FIRST BRAIN`) in `index.html` and edit inline.

The Tailwind classes are configured inline at the top of `<head>`. Custom CSS variables and components live in the `<style>` block right after.

## License

The site itself follows the same MIT license as Kluris. The brand assets (`logo.png`, `logo.webp`) are © Gabriel Voicu — please do not reuse for derivative or competing products.
