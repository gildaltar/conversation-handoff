#!/usr/bin/env python3

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MARKETPLACE = ROOT / ".agents" / "plugins" / "marketplace.json"
PLUGIN_ROOT = ROOT / "plugins" / "conversation-handoff"
MANIFEST = PLUGIN_ROOT / ".codex-plugin" / "plugin.json"
SKILL = PLUGIN_ROOT / "skills" / "conversation-handoff" / "SKILL.md"
SCHEMA = PLUGIN_ROOT / "skills" / "conversation-handoff" / "references" / "HANDOFF_SCHEMA.md"
EVALS = PLUGIN_ROOT / "skills" / "conversation-handoff" / "references" / "EVALS.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"Validation failed: {message}")


def load_json(path: Path):
    require(path.exists(), f"missing {path.relative_to(ROOT)}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Validation failed: invalid JSON in {path.relative_to(ROOT)}: {exc}")


def main() -> None:
    marketplace = load_json(MARKETPLACE)
    manifest = load_json(MANIFEST)

    require(manifest.get("name") == "conversation-handoff", "manifest name must be conversation-handoff")
    require(manifest.get("version"), "manifest version is required")
    require(manifest.get("description"), "manifest description is required")
    require(manifest.get("skills") == "./skills/", "manifest skills path must be ./skills/")

    plugins = marketplace.get("plugins")
    require(isinstance(plugins, list) and plugins, "marketplace must contain at least one plugin")

    entry = next((p for p in plugins if p.get("name") == "conversation-handoff"), None)
    require(entry is not None, "marketplace must expose conversation-handoff")
    source = entry.get("source", {})
    require(source.get("source") == "local", "marketplace source must be local for repo-scoped plugin")
    require(source.get("path") == "./plugins/conversation-handoff", "marketplace source path is incorrect")

    for path in (SKILL, SCHEMA, EVALS):
        require(path.exists(), f"missing {path.relative_to(ROOT)}")

    skill_text = SKILL.read_text(encoding="utf-8")
    require(skill_text.startswith("---\n"), "SKILL.md must start with YAML frontmatter")
    require("name: conversation-handoff" in skill_text, "SKILL.md frontmatter name is missing")
    require("description:" in skill_text, "SKILL.md frontmatter description is missing")
    require("Open in a new session?" in skill_text, "handoff prompt text is missing")

    forbidden = [
        PLUGIN_ROOT / ".mcp.json",
        PLUGIN_ROOT / "mcp.json",
    ]
    require(not any(path.exists() for path in forbidden), "MCP config detected; this plugin is intentionally skill-only")

    print("Conversation Handoff plugin validation passed.")


if __name__ == "__main__":
    main()
