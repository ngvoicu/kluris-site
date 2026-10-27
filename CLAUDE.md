# CLAUDE.md

Guidance for AI agents working in **kluris-site** — the marketing/tutorial site for kluris.ngvoicu.dev.

## Knowledge base

Read and write to the **ngvoicu-sme** brain through kluris (never edit brain
files by hand). Use the `/kluris-ngvoicu-sme` skill — search, learn, remember,
create.

Topics relevant to this repo: kluris-site overview (sections, SEO, assets), deployment (GitHub Pages + custom-domain DNS).

## What this repo is

A static site of three hand-written pages hosted on GitHub Pages at **kluris.ngvoicu.dev**: the landing page (`index.html`, ~2,310 lines, 15 sections), a slide-style guided tour (`presentation.html`, 10 slides, ~1,980 lines) and a screenshot walkthrough (`walkthrough.html`, 22 screenshots in `walkthrough/`, ~1,090 lines). Inline CSS + Tailwind via CDN; vanilla JS for the hero brain canvas and the tour's slide navigation. **No build step** — `open index.html` to preview locally.

Tagline used on the site: *"The SME your team never had."*

## Editing

The landing page is one file, and so are the tour and the walkthrough. In-file banner comments in `index.html` (`HERO`, `COMPARISON`, `BEAT 1 — SET UP` … `BEAT 7 — CAPTURE SESSION`, with `PAIR — KLURIS × SPECMINT` after Beat 4, then `TOGETHER — ONE BRAIN, MANY PEOPLE`, `REFERENCE`, `APPENDIX`, `CTA + AGENTS + FOOTER`) make navigation easy. Tailwind config + custom CSS variables sit at the top of `<head>` on each page.

What lives where: install, update and uninstall (`curl -fsSL https://kluris.ngvoicu.dev/install.sh | sh`, `irm https://kluris.ngvoicu.dev/install.ps1 | iex` plus the cmd.exe form, then open a new terminal; `kluris self-update`, `kluris self-uninstall`, `KLURIS_VERSION=3.0.0` to pin a release) are in `BEAT 1 — SET UP`, on tour slide 2 and in walkthrough phase 1. Ranked search (a question in the user's words, the `kluris search` it becomes, the scored results) is in `BEAT 4 — USE` and on tour slide 5. `REFERENCE` holds the CLI table (the order and wording of `kluris help`: `help`, then `commit`, `sync` and `resolve`, then `self-update` and `self-uninstall`), the agent-pattern table, the agent-bootstrap (`kluris wake-up`) card and the "Where the skill goes" card (skill folders per agent); `APPENDIX` holds the multi-brain rules (`--brain NAME`, the picker, `--brain all` for `dream`, `status`, `mri`, `sync` and the `companion` commands, non-interactive runs). Working together on one brain is `TOGETHER — ONE BRAIN, MANY PEOPLE` (`#together`, between Beat 7 and `REFERENCE`): the agent's write flow in a user's words (sync before writing, `kluris commit` of the approved files after approval, then `kluris sync`), a merge that settles itself, a same-line conflict settled with `kluris resolve`, what merges on its own and what goes to a person, reads that fetch and `kluris sync --watch` / `--install-service`; its terminal output comes from the binary, a two-person sandbox (a bare remote, two HOMEs). Tour slide 7 carries a short version, and the walkthrough's "the loop closes" card shows the same flow.

Agent claims stay exact; check them against the product README's Agents table and the binary (`kluris doctor` lists every folder it writes). Kluris writes one `kluris-<name>` `SKILL.md` per brain into the shared `~/.agents/skills/`, which Cursor, Codex, Gemini CLI, Devin, OpenCode, Kilo Code, Junie and others read. Four agents get their own copy: Claude Code (`~/.claude/skills/`), Hermes Agent (`~/.hermes/skills/` and every `~/.hermes/profiles/*/skills/`), Antigravity (`~/.gemini/config/skills/`) and GitHub Copilot (`$COPILOT_HOME/skills/`, only when `COPILOT_HOME` is set). Any other agent that loads `SKILL.md` skills from one of those folders and can run a shell can use it. Do not write that it works with "every" agent.

## Notable assets

| File | Purpose |
|------|---------|
| `index.html` | The landing page |
| `presentation.html` | The guided tour: ten slides, keyboard navigation |
| `walkthrough.html` + `walkthrough/01.png`–`22.png` | The screenshot-by-screenshot walkthrough. `01` is the current `kluris create` wizard for `acme` (7-option companion prompt, `Agent skill installed: kluris-acme`); `07` is the C4-style MRI drilled into Projects › Kluris, with red highlights on the breadcrumb, back/forward buttons and the folder's boxes, taken like the MRI renders below. The other screenshots are agent sessions, plus `06` (the brain picker and `kluris mri` output) |
| `logo.png` / `logo.webp` / `logo.pxd` | Brand logo. `logo.webp` is a reference copy no page loads; the Pixelmator source `logo.pxd` is gitignored (local only) |
| `specmint-logo.webp` | Specmint logo in the Kluris × Specmint sections (`specmint-logo-with-text.png` is on disk, unreferenced) |
| `mri-overview.png` / `mri-inspector.png` | `kluris mri` renders of the ngvoicu-sme brain, embedded in `index.html` and `presentation.html` (29 neurons, 242 synapses; the pages quote those counts and `42 nodes, 242 edges`): the root view (lobes as boxes with synapse counts, file tree, Find/Recent) at 1500×1105, and a neuron modal (ngvoicu-site's Design neuron, chosen because its text carries no version history) at 2276×1292. The product `README.md` embeds `mri-overview.png` by its kluris.ngvoicu.dev URL. Retake them with the `kluris` binary from a scratch copy of the brain with a sandbox `HOME`/`KLURIS_CONFIG`, never the real brain (`kluris mri` runs a dream preflight that writes into it), and leave out of the scratch copy any neuron about a feature the product does not have, so its name stays out of the file tree |
| `og-image.png` | Open Graph / Twitter Card image (1200×630): the logo, "kluris", the tagline and `kluris.ngvoicu.dev` — keep under 200 KB or WhatsApp falls back to apple-touch-icon |
| `favicon-*.png`, `favicon.ico`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png` | Browser/PWA icons (`favicon.ico` answers the implicit `/favicon.ico` request; no page links it) |
| `site.webmanifest` | PWA manifest |
| `install.sh` / `install.ps1` | Kluris 3's one-line installers: `curl -fsSL https://kluris.ngvoicu.dev/install.sh \| sh` and `powershell -ExecutionPolicy ByPass -c "irm https://kluris.ngvoicu.dev/install.ps1 \| iex"`. Thin pass-throughs to the release's own `kluris-installer.sh` / `.ps1` on GitHub (`releases/latest/download/`, or `releases/download/v<KLURIS_VERSION>/` when `KLURIS_VERSION` pins one; `KLURIS_RELEASES_URL` points them elsewhere, for the tests). The `.ps1` sets the execution policy to Bypass for its own process first and reports errors with `throw`, never `exit` (which would close the window under `iex`). The kluris repo tests them (`scripts/release/installer-smoke.sh` / `.ps1`; its ci.yml checks this repo out), so a change here goes with a run there. `BEAT 1`, tour slide 2 and walkthrough phase 1 show both commands |
| `CNAME` | GitHub Pages custom domain (`kluris.ngvoicu.dev`) |
| `robots.txt`, `sitemap.xml` | SEO (the sitemap lists the three pages) |

## SEO

- Title, description, keywords, canonical URL
- Open Graph + Twitter Card tags
- Four JSON-LD blocks on `index.html`: `SoftwareApplication`, `Organization`, `WebSite`, `VideoObject`
- Theme color, Apple touch icon, web manifest

## Deploy

Push `main` to both remotes: `origin` (the NAS) and `upstream` (GitHub). The push to `upstream` is what GitHub Pages builds and serves, so it goes live: the owner's call, so prepare and show the change first and push when the owner says so. Pages rebuilds automatically — no CI workflow. DNS: `kluris.ngvoicu.dev` is a subdomain: one `CNAME kluris → ngvoicu.github.io` in the Cloudflare-managed `ngvoicu.dev` zone; no `A` records, no `www` record.

## License

MIT for code. Brand assets (`logo.png`, `logo.webp`) are © Gabriel Voicu — not for derivative or competing products.
