#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="conversation-handoff"
REPO_ZIP="https://github.com/gildaltar/conversation-handoff/archive/refs/heads/main.zip"
PLUGIN_DEST="$HOME/.codex/plugins/conversation-handoff"
MARKETPLACE="$HOME/.agents/plugins/marketplace.json"
CACHE_ROOT="$HOME/.codex/plugins/cache"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[Conversation Handoff] Downloading the latest plugin from GitHub..."
curl -fsSL "$REPO_ZIP" -o "$TMP_DIR/repo.zip"
unzip -q "$TMP_DIR/repo.zip" -d "$TMP_DIR/repo"
SRC="$TMP_DIR/repo/conversation-handoff-main/plugins/conversation-handoff"

if [[ ! -f "$SRC/.codex-plugin/plugin.json" ]]; then
  echo "Downloaded repository does not contain the plugin manifest." >&2
  exit 1
fi

echo "[Conversation Handoff] Installing into your personal ChatGPT/Codex plugin directory..."
mkdir -p "$(dirname "$PLUGIN_DEST")"
rm -rf "$PLUGIN_DEST"
cp -R "$SRC" "$PLUGIN_DEST"

mkdir -p "$(dirname "$MARKETPLACE")"
export CH_MARKETPLACE="$MARKETPLACE"
python3 <<'PY'
import json
import os
import shutil
import time
from pathlib import Path

path = Path(os.environ["CH_MARKETPLACE"])
market = None
if path.exists():
    try:
        market = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        backup = path.with_name(path.name + f".backup-{time.strftime('%Y%m%d-%H%M%S')}")
        shutil.copy2(path, backup)
        print(f"[Conversation Handoff] Existing marketplace JSON was invalid; backed it up to {backup}")

if not isinstance(market, dict):
    market = {
        "name": "personal-plugins",
        "interface": {"displayName": "Personal Plugins"},
        "plugins": [],
    }

market.setdefault("name", "personal-plugins")
market.setdefault("interface", {"displayName": "Personal Plugins"})
plugins = market.get("plugins")
if not isinstance(plugins, list):
    plugins = []
plugins = [p for p in plugins if not isinstance(p, dict) or p.get("name") != "conversation-handoff"]
plugins.append({
    "name": "conversation-handoff",
    "source": {
        "source": "local",
        "path": "./.codex/plugins/conversation-handoff",
    },
    "policy": {
        "installation": "INSTALLED_BY_DEFAULT",
        "authentication": "ON_INSTALL",
    },
    "category": "Productivity",
})
market["plugins"] = plugins
path.write_text(json.dumps(market, indent=2) + "\n", encoding="utf-8")
PY

if [[ -d "$CACHE_ROOT" ]]; then
  find "$CACHE_ROOT" -type d -name "$PLUGIN_NAME" -prune -exec rm -rf {} + 2>/dev/null || true
fi

[[ -f "$PLUGIN_DEST/.codex-plugin/plugin.json" ]]
[[ -f "$PLUGIN_DEST/skills/conversation-handoff/SKILL.md" ]]
[[ -f "$PLUGIN_DEST/MOBILE.md" ]]

echo
echo "Conversation Handoff is installed in your personal plugin marketplace."
echo "Plugin:      $PLUGIN_DEST"
echo "Marketplace: $MARKETPLACE"
echo
echo "NEXT: Completely quit ChatGPT Desktop, reopen it, then use @conversation-handoff in a chat."
echo "If it is not immediately visible, open Plugins and select the Personal Plugins source once."
