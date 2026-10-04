#!/usr/bin/env bash

# Install or update the user environment from a GitHub release archive.
# No GitHub account and no git are needed, only curl (or wget) and tar.
#
#   curl -fsSL https://raw.githubusercontent.com/DK6v/.env/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/DK6v/.env/main/install.sh | bash -s -- --version v0.1.0
#
# Every installed file is recorded with its sha256 in <dir>/.install-manifest.
# On update:
#   - nothing changed locally -> the directory is replaced with the new release
#   - any file changed, removed or added locally -> the directory is moved to
#     <dir>.<timestamp> and the new release is installed from scratch
# bashrc.user is carried over in both cases. A git checkout is not updated,
# use `git pull` there.

set -euo pipefail

REPO="DK6v/.env"
DEST="${HOME}/.env"
VERSION=""
ARCHIVE=""
BASHRC=1
MANIFEST=".install-manifest"
USER_FILE="bashrc.user"

usage() {
    cat <<EOF
Usage: install.sh [options]

Install or update the user environment from a GitHub release.

Options:
  -d, --dir DIR        install directory (default: ~/.env)
  -v, --version TAG    release tag, e.g. v0.1.0 (default: latest release)
  -a, --archive FILE   install from a local archive instead of downloading
  -n, --no-bashrc      do not add the source line to ~/.bashrc
  -h, --help           show this help
EOF
}

info() { printf '%s\n' "$*"; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
die()  { printf 'Error: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------

has() { command -v "$1" >/dev/null 2>&1; }

# Download <url> to <file>
fetch() {
    if has curl; then
        curl -fsSL -o "$2" "$1"
    elif has wget; then
        wget -qO "$2" "$1"
    else
        die "curl or wget is required"
    fi
}

# Print the tag of the latest release (follows the /releases/latest redirect,
# no GitHub API and no rate limits)
latest_tag() {
    local url="https://github.com/${REPO}/releases/latest" location
    if has curl; then
        location=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$url")
    elif has wget; then
        location=$(wget -q -S --spider "$url" 2>&1 | awk '/^ *Location:/ { l = $2 } END { print l }')
    else
        die "curl or wget is required"
    fi
    location="${location%$'\r'}"
    [[ "$location" == */tag/* ]] || die "cannot resolve the latest release of ${REPO}"
    printf '%s\n' "${location##*/}"
}

hash_file() {
    if has sha256sum; then
        sha256sum "$1" | cut -d' ' -f1
    else
        shasum -a 256 "$1" | cut -d' ' -f1
    fi
}

# List regular files of a directory, relative to it, sorted
list_files() {
    (cd "$1" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)
}

# Print files that differ from the manifest of directory <dir>:
# changed, removed, or not from the release (except bashrc.user)
local_changes() {
    local dir="$1" h f
    declare -A known=()
    while read -r h f; do
        [ -n "$f" ] || continue
        known["$f"]=1
        if [ ! -f "$dir/$f" ]; then
            echo "removed: $f"
        elif [ "$(hash_file "$dir/$f")" != "$h" ]; then
            echo "changed: $f"
        fi
    done < <(sed '/^#/d' "$dir/$MANIFEST")
    while IFS= read -r f; do
        case "$f" in "$MANIFEST"|"$USER_FILE") continue ;; esac
        [ -n "${known[$f]:-}" ] || echo "added:   $f"
    done < <(list_files "$dir")
}

add_to_bashrc() {
    local bashrc="${HOME}/.bashrc"
    if [ -f "$bashrc" ] && grep -qF "${DEST}/bashrc.common" "$bashrc"; then
        return 0
    fi
    cat >>"$bashrc" <<EOF

# Common environment
if [ -f "${DEST}/bashrc.common" ]; then
  . "${DEST}/bashrc.common"
fi
EOF
    info "Added ${DEST}/bashrc.common to ${bashrc}"
}

# ---------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--dir)       [ $# -ge 2 ] || die "$1 requires a value"; DEST="$2"; shift 2 ;;
        -v|--version)   [ $# -ge 2 ] || die "$1 requires a value"; VERSION="$2"; shift 2 ;;
        -a|--archive)   [ $# -ge 2 ] || die "$1 requires a value"; ARCHIVE="$2"; shift 2 ;;
        -n|--no-bashrc) BASHRC=0; shift ;;
        -h|--help)      usage; exit 0 ;;
        *)              usage >&2; die "unknown option: $1" ;;
    esac
done

has tar || die "tar is required"
has sha256sum || has shasum || die "sha256sum or shasum is required"

DEST="${DEST%/}"
[ -n "$DEST" ] && [ "$DEST" != "$HOME" ] || die "invalid install directory: '${DEST}'"
if [ -d "$DEST/.git" ]; then
    die "${DEST} is a git checkout, update it with: git -C ${DEST} pull"
fi

# ---------------------------------------------------------------------
# Get the release
# ---------------------------------------------------------------------

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

if [ -z "$ARCHIVE" ]; then
    [ -n "$VERSION" ] || VERSION=$(latest_tag)
    ARCHIVE="$TMP/env_${VERSION}.tar.gz"
    info "Downloading ${REPO} ${VERSION}..."
    fetch "https://github.com/${REPO}/releases/download/${VERSION}/env_${VERSION}.tar.gz" "$ARCHIVE" \
        || die "cannot download release ${VERSION}"
fi

# Stage the new installation next to DEST, so the final mv is a rename
STAGE="${DEST}.install.$$"
mkdir -p "$(dirname -- "$DEST")"
rm -rf -- "$STAGE"
mkdir -- "$STAGE"
trap 'rm -rf -- "$TMP" "$STAGE"' EXIT

tar -xzf "$ARCHIVE" -C "$STAGE" || die "cannot extract ${ARCHIVE}"
[ -f "$STAGE/bashrc.common" ] || die "${ARCHIVE} is not a user environment archive"
FILES=$(list_files "$STAGE") || die "cannot list release files"
NEW_VERSION=$(sed -n 's/^export ENV_VERSION="\(.*\)"$/\1/p' "$STAGE/version.env" 2>/dev/null || true)

{
    echo "# Installed by install.sh: version ${NEW_VERSION:-unknown}"
    while IFS= read -r f; do
        printf '%s  %s\n' "$(hash_file "$STAGE/$f")" "$f"
    done <<<"$FILES"
} >"$STAGE/$MANIFEST"

# ---------------------------------------------------------------------
# Replace the installation
# ---------------------------------------------------------------------

BACKUP=""
if [ -d "$DEST" ] && [ -n "$(ls -A -- "$DEST")" ]; then
    if [ -f "$DEST/$MANIFEST" ]; then
        changes=$(local_changes "$DEST")
    else
        changes="not installed by install.sh"
    fi

    [ -f "$DEST/$USER_FILE" ] && cp -p -- "$DEST/$USER_FILE" "$STAGE/$USER_FILE"

    if [ -n "$changes" ]; then
        BACKUP="${DEST}.$(date +%Y-%m-%d_%Hh%Mm%Ss)"
        warn "local changes in ${DEST}:"
        sed 's/^/  /' <<<"$changes" >&2
        mv -- "$DEST" "$BACKUP"
    else
        rm -rf -- "$DEST"
    fi
elif [ -d "$DEST" ]; then
    rmdir -- "$DEST"
fi

if [ ! -f "$STAGE/$USER_FILE" ] && [ -f "$STAGE/bashrc.user.template" ]; then
    cp -p -- "$STAGE/bashrc.user.template" "$STAGE/$USER_FILE"
    info "Created ${DEST}/${USER_FILE} from the template"
fi

mv -- "$STAGE" "$DEST"

if [ "$BASHRC" -eq 1 ]; then
    add_to_bashrc
fi

info "Installed version ${NEW_VERSION:-unknown} to ${DEST}"
if [ -n "$BACKUP" ]; then
    info "Previous installation saved to ${BACKUP}"
fi
info "Reload the shell: source ~/.bashrc"
