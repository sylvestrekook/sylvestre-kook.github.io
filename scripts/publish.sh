#!/usr/bin/env bash
# Hermie publish helper — the ONLY command Hermie runs to add/update a post.
# Usage: ./scripts/publish.sh <slug> "<Title>" ["Category"] ["tag1,tag2"]
#   Category is one of: Finance | Technology | Christianity
# Creates content/blog/<slug>.md with front matter, then commits + pushes.
# CI (GitHub Actions) rebuilds and deploys to Pages automatically.
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SITE_DIR"

SLUG="${1:?usage: publish.sh <slug> <Title> [Category] [tags]}"
TITLE="${2:?Title required}"
CATEGORY="${3:-General}"
TAGS="${4:-}"
DATE="$(date -u +%Y-%m-%dT%H:%M:%S%z)"

FILE="content/blog/${SLUG}.md"
if [[ -f "$FILE" ]]; then echo "exists: $FILE (edit it directly, then: git add -A && git commit -m \"update: $SLUG\" && git push)"; exit 1; fi

# Build tags array line
TAGLINE=""
if [[ -n "$TAGS" ]]; then
  TAGLINE=$(echo "$TAGS" | sed 's/, */, "/g; s/^/tags = ["/; s/$/"]/')
fi

cat > "$FILE" <<EOF
---
title: "${TITLE}"
date: ${DATE}
categories: ["${CATEGORY}"]
${TAGLINE}
draft: false
---

<!-- Hermie: write the post body here in markdown. -->

EOF

git add "$FILE"
git commit -m "post: ${SLUG} (${CATEGORY})" >/dev/null
git push origin HEAD 2>/dev/null || git push 2>/dev/null || echo "WARN: no remote configured yet — commit is local, push after gh repo setup."
echo "PUBLISHED: $FILE"
echo "Pages will deploy automatically on push (see .github/workflows/build.yml)."
