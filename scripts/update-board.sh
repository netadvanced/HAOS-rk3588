#!/usr/bin/env bash
# One-command update for an out-of-tree board (default: orangepi5plus).
#
#   1. fast-forward the fork's `dev` to home-assistant/operating-system `dev`
#   2. merge REF (default: dev, or a release tag like 18.4) into the board branch,
#      resolving the buildroot submodule to the nyok92 fork when it already
#      contains upstream's buildroot bump
#   3. sync the merged tree into the Docker build volume
#   4. if Go was bumped, drop the stale Go toolchain and Go packages
#   5. build in a fresh container (restarting an old one fails in entry.sh)
#   6. copy the .img.xz and .raucb to $OUT_DIR
#
#   --from-nyok92 also merges nyok92/HAOS-rock5b rock5b-dev (RK3588 work) and
#   stops if it touched rock5b-only config that needs porting (--allow-unported)
#
# Usage: scripts/update-board.sh [-b board] [-r ref] [--from-nyok92] [--push] [--no-sync-dev]
set -euo pipefail

BOARD="orangepi5plus"
REF="dev"
PUSH=0
SYNC_DEV=1
FROM_NYOK92=0
ALLOW_UNPORTED=0
NYOK92_REPO="https://github.com/nyok92/HAOS-rock5b.git"
NYOK92_BRANCH="rock5b-dev"
UPSTREAM="https://github.com/home-assistant/operating-system.git"
OUT_DIR="${OUT_DIR:-$HOME/Projects/HAOS-images}"
BUILDER_IMAGE="${BUILDER_IMAGE:-hassos:local}"

while [ $# -gt 0 ]; do
    case "$1" in
        -b|--board) BOARD="$2"; shift 2 ;;
        -r|--ref) REF="$2"; shift 2 ;;
        --push) PUSH=1; shift ;;
        --no-sync-dev) SYNC_DEV=0; shift ;;
        --from-nyok92) FROM_NYOK92=1; shift ;;
        --allow-unported) ALLOW_UNPORTED=1; shift ;;
        -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Existing volumes for the Orange Pi use the short "opi5plus" name
case "$BOARD" in
    orangepi5plus) PREFIX="${PREFIX:-haos-opi5plus}" ;;
    *) PREFIX="${PREFIX:-haos-$BOARD}" ;;
esac
SRC_VOL="$PREFIX-src"
CACHE_VOL="$PREFIX-cache"
CONTAINER="$PREFIX-build"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

log() { printf '\n==> %s\n' "$*"; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

[ -z "$(git status --porcelain --ignore-submodules --untracked-files=no)" ] || die "working tree not clean, commit or stash first"
docker image inspect "$BUILDER_IMAGE" >/dev/null 2>&1 || die "builder image $BUILDER_IMAGE missing (docker build -t $BUILDER_IMAGE .)"

# 1. Sync fork dev ------------------------------------------------------------
log "Fetching upstream and origin"
git fetch -q origin
git fetch -q "$UPSTREAM" "+refs/heads/dev:refs/remotes/upstream/dev" "+refs/tags/*:refs/tags/*"

if [ "$SYNC_DEV" = 1 ]; then
    if git merge-base --is-ancestor origin/dev upstream/dev; then
        if [ "$(git rev-parse origin/dev)" != "$(git rev-parse upstream/dev)" ]; then
            log "Fast-forwarding origin/dev to upstream"
            git push -q origin upstream/dev:refs/heads/dev
            git fetch -q origin
        fi
    else
        die "origin/dev has commits that are not upstream, refusing to sync"
    fi
fi

case "$REF" in
    dev) MERGE_REF="upstream/dev" ;;
    *) MERGE_REF="refs/tags/$REF" ;;
esac
git rev-parse -q --verify "$MERGE_REF^{commit}" >/dev/null || die "unknown ref $REF"

# 2. Merge into the board branch ----------------------------------------------
log "Merging $REF into $BOARD"
if git show-ref -q --verify "refs/heads/$BOARD"; then
    git checkout -q "$BOARD"
else
    git checkout -q -b "$BOARD" "origin/$BOARD"
fi

merge_into_board() {
    local ref="$1"
    git merge -q --no-edit "$ref" && return 0

    conflicts="$(git diff --name-only --diff-filter=U)"
    [ "$conflicts" = "buildroot" ] || { git merge --abort; die "merge conflicts beyond buildroot: $conflicts"; }

    # Both sides moved the buildroot submodule (upstream points at
    # home-assistant/buildroot, we track the nyok92 fork). Take the fork tip
    # only if it already contains the incoming commit.
    theirs="$(git ls-files -u buildroot | awk '$3 == 3 {print $2}')"
    br_url="$(git config -f .gitmodules submodule.buildroot.url)"
    br_branch="$(git config -f .gitmodules submodule.buildroot.branch)"
    tmp="$(mktemp -d)"
    git init -q --bare "$tmp"
    git -C "$tmp" fetch -q --filter=blob:none "$br_url" "$br_branch:fork"
    git -C "$tmp" cat-file -e "$theirs^{commit}" 2>/dev/null ||
        git -C "$tmp" fetch -q --filter=blob:none https://github.com/home-assistant/buildroot.git "$theirs" ||
        { rm -rf "$tmp"; git merge --abort; die "cannot fetch buildroot $theirs"; }
    fork_tip="$(git -C "$tmp" rev-parse fork)"
    if ! git -C "$tmp" merge-base --is-ancestor "$theirs" "$fork_tip"; then
        rm -rf "$tmp"
        git merge --abort
        die "$br_url $br_branch does not contain buildroot $theirs yet, merge it there first"
    fi
    rm -rf "$tmp"
    log "Resolving buildroot submodule to $br_branch $fork_tip"
    git update-index --cacheinfo "160000,$fork_tip,buildroot"
    git commit -q --no-edit
}

merge_into_board "$MERGE_REF"

if [ "$FROM_NYOK92" = 1 ]; then
    log "Merging $NYOK92_REPO $NYOK92_BRANCH into $BOARD"
    git fetch -q "$NYOK92_REPO" "+refs/heads/$NYOK92_BRANCH:refs/remotes/nyok92/$NYOK92_BRANCH"
    before="$(git rev-parse HEAD)"
    merge_into_board "nyok92/$NYOK92_BRANCH"

    # The Orange Pi reuses the rock5b patches and armbian kernel config, but
    # has its own defconfig and kernel fragment: those changes need porting.
    rock5b_changes="$(git diff --stat "$before" HEAD -- \
        buildroot-external/configs/rock5b_defconfig \
        buildroot-external/board/radxa/rock5b/kernel.config \
        buildroot-external/board/radxa/rock5b/rootfs-overlay)"
    if [ -n "$rock5b_changes" ] && [ "$BOARD" != "rock5b" ]; then
        echo "$rock5b_changes"
        echo
        echo "nyok92 changed rock5b-only config, port it to $BOARD if relevant:"
        echo "  git diff $before HEAD -- buildroot-external/configs/rock5b_defconfig buildroot-external/board/radxa/rock5b"
        [ "$ALLOW_UNPORTED" = 1 ] || die "stopping before the build (rerun with --allow-unported to build anyway)"
    fi
fi
git log --oneline -1

# 3. Sync into the build volume -----------------------------------------------
log "Updating source in volume $SRC_VOL"
docker volume inspect "$SRC_VOL" >/dev/null 2>&1 || die "volume $SRC_VOL missing (first build must be set up by hand)"
docker run --rm -v "$SRC_VOL":/build -v "$REPO":/src:ro --entrypoint sh "$BUILDER_IMAGE" -c "
    set -e
    git config --global --add safe.directory '*'
    cd /build
    git fetch -q /src $BOARD
    git checkout -q -f -B $BOARD FETCH_HEAD
    git submodule sync -q
    git submodule update --init -q buildroot
    grep -E '^VERSION_(MAJOR|MINOR|SUFFIX)' buildroot-external/meta | tr '\n' ' '; echo

    # 4. A new Go installed over the old one leaves stale sources behind
    go_ver=\$(sed -n 's/^GO_VERSION = //p' buildroot/package/go/go.mk)
    if [ -d output/host/lib/go ] && [ ! -d output/build/host-go-\$go_ver ]; then
        echo \"Go bumped to \$go_ver, removing stale toolchain and Go packages\"
        rm -rf output/host/lib/go output/host/share/go-cache output/build/host-go-*
        for d in output/build/*/; do
            [ -f \"\$d/go.mod\" ] && echo \"  clean \$d\" && rm -rf \"\$d\"
        done
    fi

    for f in \$(ls -A | grep -v '^output\$'); do chown -R 1000:1000 \"\$f\"; done
"

# 5. Build ----------------------------------------------------------------------
log "Building $BOARD (logs: docker logs -f $CONTAINER)"
mkdir -p "$OUT_DIR"
build_log="$OUT_DIR/build-$BOARD.log"
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
start=$(date +%s)
docker run --name "$CONTAINER" --privileged \
    -e BUILDER_UID=1000 -e BUILDER_GID=1000 \
    -v "$CACHE_VOL":/cache -v "$SRC_VOL":/build -w /build \
    "$BUILDER_IMAGE" make "$BOARD" > "$build_log" 2>&1 ||
    { tail -30 "$build_log"; die "build failed, full log in $build_log"; }
log "Build finished in $(( ($(date +%s) - start) / 60 )) min"

# 6. Copy artifacts -------------------------------------------------------------
version="$(docker run --rm -v "$SRC_VOL":/build alpine sh -c \
    '. /build/buildroot-external/meta; echo "$VERSION_MAJOR.$VERSION_MINOR${VERSION_SUFFIX:+.$VERSION_SUFFIX}"')"
docker run --rm -v "$SRC_VOL":/build -v "$OUT_DIR":/out alpine sh -c \
    "cp /build/output/images/haos_$BOARD-$version.img.xz /build/output/images/haos_$BOARD-$version.raucb /out/"
log "Artifacts in $OUT_DIR"
(cd "$OUT_DIR" && shasum -a 256 "haos_$BOARD-$version".*)

if [ "$PUSH" = 1 ]; then
    log "Pushing $BOARD to origin"
    git push origin "$BOARD"
else
    echo
    echo "Branch $BOARD not pushed. After the image boots: git push origin $BOARD"
fi

cat <<EOF

Update the board without reflashing:
  copy haos_$BOARD-$version.raucb to a USB stick labelled CONFIG,
  plug it in (board up > 5 min) and it installs on the inactive A/B slot.
Fresh install: flash haos_$BOARD-$version.img.xz
EOF
