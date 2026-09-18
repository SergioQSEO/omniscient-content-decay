#!/usr/bin/env bash
# One-shot: create the GitHub repo, push this folder, turn on Pages, print the live URL.
# Run from inside this folder:  bash setup.sh
set -euo pipefail

OWNER="${OWNER:-SergioQSEO}"
REPO="${REPO:-omniscient-content-decay}"

command -v git >/dev/null || { echo "git not found."; exit 1; }
if ! command -v gh >/dev/null; then
  cat <<'EOF'
GitHub CLI (gh) not found. Either install it:

  brew install gh && gh auth login

...or do it by hand: create an empty PUBLIC repo named omniscient-content-decay
at https://github.com/new (no README, no .gitignore, no licence), then:

  git remote add origin https://github.com/SergioQSEO/omniscient-content-decay.git
  git push -u origin main

...and turn on Pages at Settings -> Pages -> Source: "Deploy from a branch",
branch main, folder / (root).
EOF
  exit 1
fi

gh auth status >/dev/null 2>&1 || { echo "Not signed in. Run: gh auth login"; exit 1; }

[ -d .git ] || { git init -b main && git add -A && git commit -m "Content decay dashboard"; }
git rev-parse HEAD >/dev/null 2>&1 || { git add -A && git commit -m "Content decay dashboard"; }

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "Repo already exists, pushing to it."
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -u origin main
else
  gh repo create "$OWNER/$REPO" --public --source=. --remote=origin --push \
    --description "Static dashboard for content-decay-finder results. One snapshot per run, per client."
fi

echo "Enabling GitHub Pages..."
gh api -X POST "repos/$OWNER/$REPO/pages" \
  -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
  || gh api -X PUT "repos/$OWNER/$REPO/pages" \
       -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
  || echo "  (couldn't set Pages via API - turn it on at Settings -> Pages, branch main, folder /)"

echo
echo "Done. First build takes a minute or two, then:"
echo "  https://sergioqseo.github.io/$REPO/?client=beomniscient"
