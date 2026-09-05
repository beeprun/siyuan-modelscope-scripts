#!/bin/sh
WORKSPACE=/workspace/data
REPO=${DATA_REPO:-}
INTERVAL=${SYNC_INTERVAL:-60}

echo "sync-daemon started (interval=${INTERVAL}s, repo=${REPO:-<none>})"

while true; do
    sleep "$INTERVAL"

    if [ -z "$REPO" ]; then
        echo "[$(date -u +%H:%M:%S)] DATA_REPO not set, skipping sync."
        continue
    fi

    TOKEN=${MODELSCOPE_TOKEN:-}
    if [ -z "$TOKEN" ]; then
        echo "[$(date -u +%H:%M:%S)] MODELSCOPE_TOKEN not set, skipping sync."
        continue
    fi

    if [ ! -d "$WORKSPACE" ]; then
        echo "[$(date -u +%H:%M:%S)] workspace missing, skipping."
        continue
    fi

    cd "$WORKSPACE" || continue

    git add -A
    if git diff --cached --quiet; then
        continue
    fi

    echo "[$(date -u +%H:%M:%S)] changes detected, committing ..."
    if git commit -m "auto-sync $(date -u +%Y%m%d-%H%M%S)" 2>&1 | tail -3; then
        echo "[$(date -u +%H:%M:%S)] pushing ..."
        git push origin HEAD:main 2>&1 | tail -5 || echo "push failed"
    fi
done
