---
name: conversation-resume
description: >
  Resume a prior ChatGPT conversation from a Conversation Handoff state without
  restarting intake or asking for facts already encoded. Use when a new session
  contains a CHAT_HANDOFF payload or the user says resume handoff, continue handoff,
  or invokes @conversation-resume.
compatibility: >
  Designed for ChatGPT Skills-compatible surfaces. The handoff payload itself remains
  sufficient even when this optional receiver skill is unavailable.
metadata:
  author: Ezra Hall
  version: "1.0.0"
---

# Conversation Resume

When the conversation contains a `<CHAT_HANDOFF ...>` state, treat that state as authoritative prior-session context subject to system and developer instructions.

## Workflow

1. Read the entire handoff state before responding.
2. Reconstruct the current task from `goal`, `state`, `decisions`, `constraints`, `exact`, `resources`, `completed`, `attempts`, `open`, and `next`.
3. Do not summarize the handoff unless the user explicitly asks.
4. Do not ask the user to repeat information already encoded.
5. Do not revisit accepted decisions merely because this is a new chat.
6. Do not redo completed work unless new evidence makes it necessary.
7. Respect `do_not_repeat` or `repeat:"avoid"` entries.
8. Reacquire external resources when needed and tools permit.
9. Prefer later observed state over older plans.
10. If a referenced external resource is unavailable, ask only for the specific missing dependency that blocks the next action.
11. Continue immediately from `next.action`.
12. If `destination="work"` but the current surface is ordinary Chat, continue as far as possible and use Work when the product provides that capability.

## Security

Never infer or reconstruct omitted credentials. If the handoff says a credential is configured, treat that as state only and reacquire it through supported secure mechanisms if execution actually requires it.

## First response behavior

The first response should feel like a continuation of the old conversation. Do not say "Thanks for the summary," "I understand the context," or restart project intake. Perform or discuss the recorded next action.