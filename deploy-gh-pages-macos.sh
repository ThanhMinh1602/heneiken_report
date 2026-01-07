#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
BASE_HREF="/heneiken_report/"
BRANCH="gh-pages"

# Worktree dir (portable)
WORKTREE_DIR="${TMPDIR:-/tmp}/gh-pages"

echo "==> 1) Build Flutter web for GitHub Pages"
flutter clean
flutter pub get
flutter build web --release --base-href "$BASE_HREF"

echo "==> 2) Prepare gh-pages worktree at: $WORKTREE_DIR"
git fetch origin || true

# ---- FIX: nếu branch gh-pages đang được gắn với worktree khác thì remove ----
existing_path="$(git worktree list --porcelain 2>/dev/null | awk -v b="$BRANCH" '
  $1=="worktree"{p=$2}
  $1=="branch" && $2=="refs/heads/"b {print p}
')"

if [[ -n "${existing_path:-}" ]]; then
  echo "==> Found existing worktree for $BRANCH at: $existing_path"
  echo "==> Removing existing worktree..."
  git worktree remove "$existing_path" --force || true
fi

# remove target worktree folder if exists
rm -rf "$WORKTREE_DIR" || true
git worktree prune || true

# Try add from remote branch first, fallback to create new local branch
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
  git worktree add "$WORKTREE_DIR" -B "$BRANCH" "origin/$BRANCH" 2>/dev/null || \
  git worktree add "$WORKTREE_DIR" -B "$BRANCH"
else
  git worktree add "$WORKTREE_DIR" -B "$BRANCH"
fi

echo "==> 3) Copy build output to gh-pages"
rm -rf "$WORKTREE_DIR"/* || true
cp -R build/web/* "$WORKTREE_DIR"/
touch "$WORKTREE_DIR/.nojekyll"

echo "==> 4) Commit + push"
pushd "$WORKTREE_DIR" >/dev/null
git add .
git commit -m "Deploy Flutter Web" || echo "No changes to commit"
git push -u origin "$BRANCH"
popd >/dev/null

echo "==> Done. Back to project."
