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

    tmp=$(mktemp -d 2>/dev/null || mktemp -d -t kluris)
    trap 'rm -rf "$tmp"' EXIT INT TERM
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
    sh "$tmp/kluris-installer.sh" "$@"
}

main "$@"
