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
TRANSPORT = PLUGIN_ROOT / "MOBILE.md"
WINDOWS_INSTALLER = ROOT / "install-windows.ps1"


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

    policy = entry.get("policy", {})
    require(
        policy.get("installation") in {"AVAILABLE", "INSTALLED_BY_DEFAULT", "NOT_AVAILABLE"},
        "marketplace installation policy is invalid",
    )
    require(policy.get("authentication") == "ON_INSTALL", "marketplace authentication policy must be ON_INSTALL")

    for path in (SKILL, SCHEMA, EVALS, TRANSPORT, WINDOWS_INSTALLER):
        require(path.exists(), f"missing {path.relative_to(ROOT)}")

    skill_text = SKILL.read_text(encoding="utf-8")
    require(skill_text.startswith("---\n"), "SKILL.md must start with YAML frontmatter")
    require("name: conversation-handoff" in skill_text, "SKILL.md frontmatter name is missing")
    require("description:" in skill_text, "SKILL.md frontmatter description is missing")
    require("Open in a new session?" in skill_text, "handoff prompt text is missing")

    transport_text = TRANSPORT.read_text(encoding="utf-8")
    require("skills/conversation-handoff/SKILL.md" in transport_text, "bundled transport must point to the bundled skill")
    require("HANDOFF_SCHEMA.md" in transport_text, "bundled transport must point to the bundled schema")

    installer_text = WINDOWS_INSTALLER.read_text(encoding="utf-8")
    require(".codex\\plugins\\conversation-handoff" in installer_text, "Windows installer plugin destination is incorrect")
    require(".agents\\plugins\\marketplace.json" in installer_text, "Windows installer marketplace destination is incorrect")
    require("INSTALLED_BY_DEFAULT" in installer_text, "Windows installer should install plugin by default")

    forbidden = [
        PLUGIN_ROOT / ".mcp.json",
        PLUGIN_ROOT / "mcp.json",
    ]
    require(not any(path.exists() for path in forbidden), "MCP config detected; this plugin is intentionally skill-only")

    print("Conversation Handoff plugin validation passed.")


if __name__ == "__main__":
    main()
