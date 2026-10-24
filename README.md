# kluris-site

The marketing and tutorial site for [Kluris](https://github.com/ngvoicu/kluris) — *the SME your team never had.*

Lives at **[https://kluris.ngvoicu.dev/](https://kluris.ngvoicu.dev/)**.

## Stack

- Three static pages — `index.html`, `presentation.html`, `walkthrough.html` (no build step, no framework, no bundler)
- Inline CSS + Tailwind via CDN
- Vanilla JS for the hero brain canvas and the tour's slide navigation
- Hosted on **GitHub Pages** with custom domain

## Files

| File | Purpose |
|---|---|
| `index.html` | The landing page (14 sections, ~2,150 lines) |
| `presentation.html` | The guided tour: ten slides, keyboard navigation |
| `walkthrough.html` | The screenshot-by-screenshot walkthrough |
| `walkthrough/01.png`–`22.png` | The 22 screenshots `walkthrough.html` shows (`01` is the current `kluris create` wizard for `acme`; `07` is the C4-style MRI drilled into Projects › Kluris) |
| `logo.png` | Brand logo (used in nav, hero, footer) |
| `logo.webp` | Source brand image (kept as reference; no page loads it) |
| `specmint-logo.webp` | Specmint logo in the Kluris × Specmint sections (`specmint-logo-with-text.png` is on disk, unreferenced) |
| `mri-overview.png`, `mri-inspector.png` | `kluris mri` renders of the ngvoicu-sme brain, embedded in `index.html` and `presentation.html`, from the current C4-style viewer: the root view (lobes as boxes with synapse counts, file tree, Find/Recent) and a neuron modal (the Deprecation neuron). The product README embeds `mri-overview.png` by its kluris.ngvoicu.dev URL |
| `mri-ngvoicu.png` | Older `kluris mri` render, on disk but not referenced by any page |
| `favicon-16x16.png`, `favicon-32x32.png`, `favicon.ico` | Browser tab favicons (`favicon.ico` answers the implicit `/favicon.ico` request) |
| `apple-touch-icon.png` | iOS home screen icon (180×180) |
| `icon-192.png`, `icon-512.png` | PWA / Android icons |
| `og-image.png` | Open Graph / Twitter Card image (1200×630) |
| `site.webmanifest` | PWA manifest |
| `robots.txt` | Search engine directives |
| `sitemap.xml` | URL list for crawlers (the three pages) |
| `CNAME` | GitHub Pages custom domain (`kluris.ngvoicu.dev`) |

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
- Four JSON-LD structured data blocks on `index.html`: `SoftwareApplication`, `Organization`, `WebSite`, `VideoObject`
- `robots.txt` + `sitemap.xml`
- Semantic HTML with proper heading hierarchy
- Image alt attributes everywhere
- All internal links use anchor IDs

## GitHub Pages deployment

This folder is designed to deploy to GitHub Pages with a custom domain (`kluris.ngvoicu.dev`).

### One-time setup

1. **Push the folder to a GitHub repo** (for example `ngvoicu/kluris-site` — separate repo, or as a subfolder of `kluris` with Pages source set to that subfolder).

2. **Enable GitHub Pages:**
   - Repo → **Settings** → **Pages**
   - **Source:** Deploy from a branch
   - **Branch:** `main` / `/ (root)`
   - Save.

3. **Custom domain:**
   - Same Settings → Pages page
   - **Custom domain:** `kluris.ngvoicu.dev`
   - Save. GitHub will detect the `CNAME` file in this folder automatically.
   - Tick **Enforce HTTPS** once the cert is issued (a few minutes).

4. **DNS record** in the Cloudflare-managed `ngvoicu.dev` zone. `kluris.ngvoicu.dev` is a subdomain, not an apex domain, so one `CNAME` record points it at GitHub Pages:

   ```
   CNAME    kluris    ngvoicu.github.io
   ```

   No `A` records and no `www` record are needed.

5. **Wait for propagation** (DNS: minutes to hours · GitHub cert issuance: minutes).

### Subsequent deploys

Push `main` to both remotes. `origin` is the NAS; the push to `upstream` (GitHub) is what GitHub Pages builds and serves. No CI workflow needed — Pages handles a static site directly.

```bash
git add -A
git commit -m "site: copy tweak"
git push origin main
git push upstream main
```

For a build stuck in "building", see the Deploying section below.

## Editing

The landing page is one file, and so are the tour and the walkthrough. To change a section of the landing page, search for its section comment marker (e.g. `BEAT 1 — SET UP`) in `index.html` and edit inline.

What lives where: the install step (restart the terminal after `pipx ensurepath`) is in `BEAT 1 — SET UP` and on tour slide 2; `REFERENCE` holds the CLI and agent tables plus the agent-bootstrap (`kluris wake-up`) and `kluris pack` cards; `APPENDIX` holds the multi-brain rules (`--brain NAME`, the picker, `--brain all`, non-interactive runs).

Agent claims stay exact. Kluris installs a `kluris-<name>` `SKILL.md` into the nine agents in the product's `AGENT_REGISTRY` plus the universal `~/.agents/skills/` folder; any other agent that loads `SKILL.md` skills from one of those folders and can run a shell can use it (OpenCode reads `~/.claude/skills/` and `~/.agents/skills/`, per https://opencode.ai/docs/skills/). Do not write that it works with "every" agent.

The Tailwind classes are configured inline at the top of `<head>` on each page. Custom CSS variables and components live in the `<style>` block right after.

## License

The site itself follows the same MIT license as Kluris. The brand assets (`logo.png`, `logo.webp`) are © Gabriel Voicu — please do not reuse for derivative or competing products.

## Deploying (read this — Pages builds get stuck)

Push `main` to both remotes (`origin`, the NAS, and `upstream`, GitHub). The push to `upstream` is what makes Pages build automatically and goes live, so it is the owner's call — but builds **regularly hang in `"building"`**. After every push to `upstream`:

```bash
gh api repos/ngvoicu/kluris-site/pages/builds/latest --jq .status   # expect "built" within ~1 min
gh api -X POST repos/ngvoicu/kluris-site/pages/builds               # re-queue if it sits in "building"
```

Then confirm the change is actually live: `curl -s https://kluris.ngvoicu.dev/ | grep '<something-from-your-change>'`.
