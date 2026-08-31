# Conversation Handoff

Conversation Handoff is a skill-only ChatGPT plugin that distills a long conversation into a compact continuation state so a fresh session can continue with the important context and without most of the accumulated conversational noise.

## What it preserves

The handoff prioritizes the state that can change the next answer: the active objective, accepted decisions, constraints, exact values and identifiers, current implementation state, relevant resources, completed work, failed approaches that should not be repeated, unresolved issues, and the next action.

Ordinary discussion, repetition, superseded ideas, and diagnostic transcripts are compressed aggressively once their lasting conclusions are captured.

## User experience

The intended visible interaction is deliberately minimal:

**Open in a new session?**

The serialized continuation state is model-oriented and stays hidden unless the user explicitly asks to inspect it.

The plugin also infers whether the next unresolved action is better suited to ordinary Chat or ChatGPT Work.

## Platform boundary

The plugin can prepare a loss-minimized handoff and request a supported new-session action when the current ChatGPT surface exposes one. It must never claim that it opened a new session when the host does not provide such an action.

This repository intentionally does **not** bundle an MCP server. OpenAI currently marks imported plugins that declare MCP servers as desktop-only, which would work against the mobile-use goal.

## Repository layout

```text
.
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── .github/
│   └── workflows/
│       └── validate-plugin.yml
├── plugins/
│   └── conversation-handoff/
│       ├── .codex-plugin/
│       │   └── plugin.json
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

## Install / test

The repository includes a repo-scoped plugin marketplace. On a supported development surface, add this repository as a marketplace source and install **Conversation Handoff** from that source.

For Codex CLI, the repository can be added as a marketplace source with:

```bash
codex plugin marketplace add gildaltar/conversation-handoff
```

OpenAI currently documents repo/local marketplace authoring primarily for ChatGPT desktop and Codex. Availability of custom or repo-sourced plugins can vary by plan, workspace, account rollout, and product surface. Publishing to the universal Plugin Directory is a separate review process.

## Invocation

Examples:

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
