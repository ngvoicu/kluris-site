#!/bin/sh
# Kluris 3 installer for macOS and Linux:
#
#     curl -fsSL https://kluris.ngvoicu.dev/install.sh | sh
#
# A thin pass-through: it downloads the installer published with the release
# on GitHub (kluris-installer.sh) and runs it, with this environment. That
# installer checks the archive's SHA-256, puts `kluris` in ~/.kluris/bin and
# adds that folder to PATH in your shell's startup files.
#
# KLURIS_VERSION=3.0.0   install that release instead of the latest
#                        (`v3.0.0` works too)
# KLURIS_RELEASES_URL    where the releases are, by default
#                        https://github.com/ngvoicu/kluris/releases (a mirror,
#                        or a local server in Kluris's own installer tests)
#
# The release installer's own settings pass through as they are: for example
# KLURIS_INSTALL_DIR, KLURIS_NO_MODIFY_PATH=1, KLURIS_GITHUB_TOKEN.
#
# The release installer checks the archive's SHA-256 with `sha256sum` and
# skips the check when there is none, as on macOS 14 and older (Apple added
# `sha256sum` in macOS 15). There this gives it one, `shasum -a 256` (whose
# `-b` output is the same `<hex> *<file>`), first on PATH for its run alone;
# with neither command it stops before downloading anything.
#
# Everything is inside main, called on the last line, so a download cut short
# runs nothing.

main() {
    set -eu

    releases="${KLURIS_RELEASES_URL:-https://github.com/ngvoicu/kluris/releases}"
    releases="${releases%/}"
    if [ -n "${KLURIS_VERSION:-}" ]; then
        version="${KLURIS_VERSION#v}"
        case "$version" in
            [0-9]*) ;;
            *) echo "kluris: KLURIS_VERSION must be a release number such as 3.0.0, not '$KLURIS_VERSION'" >&2; exit 2 ;;
        esac
        case "$version" in
            *[!0-9A-Za-z.+-]*) echo "kluris: KLURIS_VERSION must be a release number such as 3.0.0, not '$KLURIS_VERSION'" >&2; exit 2 ;;
        esac
        url="$releases/download/v$version/kluris-installer.sh"
    else
        url="$releases/latest/download/kluris-installer.sh"
    fi

    if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
        echo "kluris: neither sha256sum nor shasum is installed, so the download could not be verified; install one of them and run this again" >&2
        exit 1
    fi

    tmp=$(mktemp -d 2>/dev/null || mktemp -d -t kluris)
    trap 'rm -rf "$tmp"' EXIT INT TERM
    shim=""
    if ! command -v sha256sum >/dev/null 2>&1; then
        shim="$tmp/bin"
        mkdir "$shim"
        printf '#!/bin/sh\nexec shasum -a 256 "$@"\n' > "$shim/sha256sum"
        chmod +x "$shim/sha256sum"
    fi
    if command -v curl >/dev/null 2>&1; then
        if [ -n "${KLURIS_RELEASES_URL:-}" ]; then
            curl -fsSL "$url" -o "$tmp/kluris-installer.sh"
        else
            curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$tmp/kluris-installer.sh"
        fi
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$tmp/kluris-installer.sh" "$url"
    else
        echo "kluris: curl or wget is needed to download $url" >&2
        exit 1
    fi || {
        echo "kluris: could not download $url" >&2
        exit 1
    }
    if [ -n "$shim" ]; then
        PATH="$shim:$PATH" sh "$tmp/kluris-installer.sh" "$@"
    else
        sh "$tmp/kluris-installer.sh" "$@"
    fi
}

main "$@"
