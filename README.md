# Conversation Handoff

Conversation Handoff is a skill-only ChatGPT plugin plus a mobile bootstrap that distills a long conversation into a compact continuation state so a fresh session can continue with the important context and without most of the accumulated conversational noise.

## What it preserves

The handoff prioritizes the state that can change the next answer: the active objective, accepted decisions, constraints, exact values and identifiers, current implementation state, relevant resources, completed work, failed approaches that should not be repeated, unresolved issues, and the next action.

Ordinary discussion, repetition, superseded ideas, and diagnostic transcripts are compressed aggressively once their lasting conclusions are captured.

## User experience

The intended visible interaction is deliberately minimal:

**Open in a new session?**

The serialized continuation state is model-oriented and stays hidden unless the user explicitly asks to inspect it.

The plugin also infers whether the next unresolved action is better suited to ordinary Chat or ChatGPT Work.

## Install on ChatGPT Desktop

The repository contains a native `.codex-plugin/plugin.json` plugin plus a personal-marketplace installer. The installer copies the plugin to the personal ChatGPT/Codex plugin directory, merges a `conversation-handoff` entry into `~/.agents/plugins/marketplace.json`, removes stale cached copies of this plugin, and marks it `INSTALLED_BY_DEFAULT`.

### Windows

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/gildaltar/conversation-handoff/main/install-windows.ps1 | iex
```

Then completely quit ChatGPT Desktop and reopen it. Invoke the plugin in a chat with:

```text
@conversation-handoff
```

If it is not immediately visible, open the Plugins Directory once and select the **Personal Plugins** source.

### macOS

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/gildaltar/conversation-handoff/main/install-macos.sh | bash
```

Then completely quit ChatGPT Desktop and reopen it, and invoke:

```text
@conversation-handoff
```

### Codex CLI alternative

The repo also exposes a repo marketplace, so Codex can add it directly:

```bash
codex plugin marketplace add gildaltar/conversation-handoff --ref main
```

Use ChatGPT Desktop to install and test repo/local plugins.

## Mobile bootstrap

`MOBILE.md` at the repository root remains a fallback entry point for iOS/mobile/web surfaces where the installed local plugin is not available.

The installed plugin also bundles its own `MOBILE.md` transport helper so the cached plugin package is self-contained.

The fallback transport constructs a fresh-chat URL whose `prompt` value contains the percent-encoded continuation state and renders only:

**Open in a new session?**

The payload remains hidden inside the link target rather than appearing in the conversation.

Because ChatGPT does not currently expose a supported public API/deep-link contract for arbitrary code to force-create a Chat or Work session and automatically submit arbitrary context, behavior after tapping can vary by surface. The handoff preserves the inferred `chat`/`work` destination and does not invent undocumented Work-mode or auto-submit parameters.

## Platform boundary

This repository intentionally does **not** bundle an MCP server. The handoff is fundamentally a conversation-context workflow, so a bundled MCP server would not improve access to the source chat and would make local/imported plugin availability more restrictive on some ChatGPT surfaces.

The plugin can prepare a loss-minimized handoff and use a supported native seeded-session action if ChatGPT exposes one. Otherwise it uses its one-tap fallback transport. It must never claim that it opened a new session when the host did not actually do so.

## Repository layout

```text
.
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── .github/
│   └── workflows/
│       └── validate-plugin.yml
├── install-windows.ps1
├── install-macos.sh
├── MOBILE.md
├── plugins/
│   └── conversation-handoff/
│       ├── .codex-plugin/
│       │   └── plugin.json
│       ├── MOBILE.md
│       └── skills/
│           └── conversation-handoff/
│               ├── SKILL.md
│               └── references/
│                   ├── HANDOFF_SCHEMA.md
│                   └── EVALS.md
├── scripts/
│   └── validate_plugin.py
└── LICENSE
```

## Invocation

Examples:

- `@conversation-handoff`
- `@conversation-handoff condense this chat`
- `@conversation-handoff checkpoint this conversation`
- `@conversation-handoff move this into a clean session`

The skill description also allows automatic selection when the host supports it.

## Validation

Run:

```bash
python scripts/validate_plugin.py
```

GitHub Actions runs the same validation on pushes and pull requests.

## Design principle

The optimization target is **continuity fidelity per token**, not maximum compression and not human-readable summaries.
