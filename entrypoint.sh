#!/bin/sh
set -e

WORKSPACE=/workspace/data
AUTH=${SIYUAN_ACCESS_AUTH_CODE:-123456}
LANG_CODE=${SIYUAN_LANG:-zh-CN}
REPO=${DATA_REPO:-}

mkdir -p "$WORKSPACE"

git config --global user.email "studio@modelscope.cn"
git config --global user.name "Studio Sync"
git config --global init.defaultBranch main

echo "=== SiYuan Studio entrypoint ==="
echo "workspace: $WORKSPACE"
echo "lang: $LANG_CODE"
echo "data_repo: ${REPO:-<not set, running without sync>}" 

if [ -n "$REPO" ]; then
    TOKEN=${MODELSCOPE_TOKEN:-}
    if [ -z "$TOKEN" ]; then
        echo "WARNING: DATA_REPO set but MODELSCOPE_TOKEN missing - sync disabled"
    else
        REPO_URL="https://${TOKEN}@www.modelscope.cn/studios/${REPO}.git"

        if [ ! -d "$WORKSPACE/.git" ]; then
            echo "Cloning data repo $REPO into $WORKSPACE ..."
            if ! git clone "$REPO_URL" "$WORKSPACE" 2>&1 | tail -3; then
                echo "Clone failed (repo empty or first run?). Initializing local git."
                cd "$WORKSPACE"
                git init
                git remote add origin "$REPO_URL"
            fi
        else
            echo "Pulling latest data ..."
            cd "$WORKSPACE"
            git pull --rebase 2>&1 | tail -3 || echo "Pull skipped (offline or no remote)."
            cd /
        fi
    fi
fi

echo "Starting sync-daemon ..."
/sync-daemon.sh &

echo "Starting SiYuan kernel on port 6806 ..."
/opt/siyuan/entrypoint.sh serve \
    --workspace="$WORKSPACE" \
    --accessAuthCode="$AUTH" \
    --lang="$LANG_CODE" &

echo "Waiting 8s for SiYuan to boot ..."
sleep 8

echo "Starting port forward 7860 -> 6806 ..."
exec socat TCP-LISTEN:7860,fork,reuseaddr TCP:localhost:6806
