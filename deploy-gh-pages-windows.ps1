$ErrorActionPreference = "Stop"

# ===== Config =====
$BASE_HREF = "/heneiken_report/"
$BRANCH = "gh-pages"

# Worktree dir (portable)
$WORKTREE_DIR = Join-Path ([System.IO.Path]::GetTempPath()) "gh-pages"

Write-Host "==> 1) Build Flutter web for GitHub Pages"
flutter clean
flutter pub get
flutter build web --release --base-href $BASE_HREF

Write-Host "==> 2) Prepare gh-pages worktree at: $WORKTREE_DIR"
try { git fetch origin | Out-Null } catch {}

# remove old folder
if (Test-Path $WORKTREE_DIR) {
  Remove-Item $WORKTREE_DIR -Recurse -Force
}
try { git worktree prune | Out-Null } catch {}

# Check remote branch exists
$remoteExists = $false
try {
  git show-ref --verify --quiet ("refs/remotes/origin/" + $BRANCH)
  $remoteExists = $true
} catch {
  $remoteExists = $false
}

if ($remoteExists) {
  try {
    git worktree add $WORKTREE_DIR -B $BRANCH ("origin/" + $BRANCH) 2>$null
  } catch {
    git worktree add $WORKTREE_DIR -B $BRANCH
  }
} else {
  git worktree add $WORKTREE_DIR -B $BRANCH
}

Write-Host "==> 3) Copy build output to gh-pages"
Get-ChildItem -Path $WORKTREE_DIR -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "build\web\*" -Destination $WORKTREE_DIR -Recurse -Force
New-Item -Path (Join-Path $WORKTREE_DIR ".nojekyll") -ItemType File -Force | Out-Null

Write-Host "==> 4) Commit + push"
Push-Location $WORKTREE_DIR
git add .
try {
  git commit -m "Deploy Flutter Web"
} catch {
  Write-Host "No changes to commit"
}
git push -u origin $BRANCH
Pop-Location

Write-Host "==> Done. Back to project."
