#!/bin/bash
# The one-line installer for a room Mac, published as install.sh in the public download repo (packages only,
# never the source; deploy/release.sh keeps both up to date). As the Mac's admin, best over SSH from IT's own Mac
# (Remote Login on; setup's prompts come to that Terminal):
#
#   ssh -t <admin>@<address> 'curl -fsSL https://raw.githubusercontent.com/bgreenGM/roomctl-releases/main/install.sh | sudo bash -s -- --test-mac'
#
# or the same curl line in Terminal at the Mac.
# It downloads the newest package (with --test-mac the newest test release, else the newest final one), refuses
# it unless its roomctl is signed with the roomctl certificate, and starts that package's deploy/setup.sh with the
# same options. Run the same line again for setup's Part 2. The room keys come from the build Mac (provision.sh).
set -euo pipefail

main() {
    local repo=bgreenGM/roomctl-releases
    local requirement='identifier "co.generalmedicine.roomctl" and certificate leaf = H"bd83b7cc702130a30f63df1a88eaeb1db0dc0eb5"'
    [ "$(id -u)" = 0 ] || { echo "install.sh: run it with sudo: curl … | sudo bash -s -- [--test-mac]" >&2; exit 1; }
    local api="https://api.github.com/repos/$repo/releases/latest" option
    for option in "$@"; do [ "$option" != --test-mac ] || api="https://api.github.com/repos/$repo/releases?per_page=1"; done
    # The first tag_name is the newest release (any, for the test Mac) or the newest final one.
    local tag
    tag="$(curl -fsSL "$api" | grep -o '"tag_name": *"v[0-9.]*"' | head -1 | sed 's/.*"\(v[0-9.]*\)"/\1/')" || true
    [ -n "$tag" ] || { echo "install.sh: there's no release to install yet (a room needs a final one: deploy/release.sh --final)." >&2; exit 1; }
    local version="${tag#v}" dir=/var/tmp/roomctl-setup
    rm -rf "$dir"
    mkdir -m 700 "$dir"
    curl -fsSL "https://github.com/$repo/releases/download/$tag/roomctl-$version.tar.gz" | tar -xz -C "$dir"
    codesign --verify --strict -R="$requirement" "$dir/roomctl-$version/roomctl" 2>/dev/null ||
        { echo "install.sh: that package's roomctl isn't signed with the roomctl certificate, so it wasn't installed." >&2; exit 1; }
    echo "roomctl $version downloaded, and it's genuine. Starting setup."
    # Setup asks questions: give it the keyboard, not this script's pipe.
    exec "$dir/roomctl-$version/deploy/setup.sh" "$@" </dev/tty
}
# Inside a function, so a download cut off halfway runs nothing.
main "$@"
