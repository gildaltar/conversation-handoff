---
name: conversation-handoff
description: >
  Condense the entire current ChatGPT conversation into a compact, loss-minimized
  continuation state and prepare a one-tap fresh-session handoff. Use when the user
  says handoff, checkpoint, condense this chat, move to a new session, continue in a
  clean chat, reduce context bloat, or invokes @conversation-handoff.
compatibility: >
  Designed for ChatGPT Skills-compatible surfaces including mobile/web when Personal
  Skills are available. Does not require MCP, an API key, or external code execution.
metadata:
  author: Ezra Hall
  version: "1.0.0"
---

# Conversation Handoff

Turn the current conversation into the smallest state that allows a new ChatGPT session to continue correctly.

Optimize for **continuity fidelity per token**, not human readability.

## Workflow

1. Treat all conversation context currently available as the source session.
2. Reconstruct current state, not a chronological transcript.
3. Read `references/HANDOFF_SCHEMA.md` and `references/TRANSPORT.md`.
4. Preserve consequential exact values, accepted decisions, corrections, constraints, resources, completed work, failed approaches, unresolved issues, and the precise next action.
5. Remove greetings, repetition, dead branches, superseded assumptions, and reasoning whose lasting value is already captured by a conclusion.
6. Infer `chat` versus `work` from the next unresolved action.
7. Build and validate the machine-oriented handoff state.
8. Never serialize passwords, tokens, API keys, private keys, verification codes, or raw credentials.
9. Keep the handoff state hidden from normal visible output.
10. Create the receiving prompt and prefer a one-tap fresh-chat URL when practical.
11. Default visible result: **Open in a new session?**

## Preservation priorities

Preserve exactly or near-exactly when relevant: active objective, latest request, numbers, dates, times, IDs, names, filenames, paths, URLs, commands, configs, schema fields, code, formulas, dimensions, versions, accepted decisions, user corrections, requirements, implementation state, relevant errors, unresolved blockers, dependencies, failed approaches that should not be repeated, and task-specific user preferences.

Compress semantically: rationale that still matters, tradeoffs, architecture, and intermediate findings that prevent regression.

Discard or heavily compress: filler, repetition, superseded plans, dead brainstorming, tool narration, redundant confirmations, corrected assumptions, and long logs after their conclusion is captured.

## Conflict resolution

Later explicit user corrections override earlier statements. Observed/tested state overrides plans and guesses. Preserve genuinely unresolved contradictions and meaningful uncertainty.

## Receiving behavior

The receiving prompt must instruct the new session to treat the handoff as authoritative prior-session state subject to higher-level instructions; continue from `next`; not ask for encoded facts; not redo completed work without reason; reacquire dependencies when needed and tools permit; preserve accepted decisions and terminology; and continue naturally rather than restarting intake.

## Quality checks

Before exposing the continuation action, verify that the next action is unambiguous, accepted decisions are distinct from proposals, superseded facts are removed, exact identifiers remain exact, dependencies are represented, known failed approaches will not be repeated, secrets are excluded, meaningful uncertainty is retained, and a competent receiving model can continue without re-intake.
