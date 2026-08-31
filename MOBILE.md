# Conversation Handoff — Mobile Runner

This file is an execution bootstrap for ChatGPT mobile/web surfaces where the Conversation Handoff plugin or skill is not directly available.

When a user asks you to execute this file against a conversation, do the following immediately:

1. Treat the **entire source conversation available to you** as the source session.
2. Read and follow the canonical skill instructions at:
   `plugins/conversation-handoff/skills/conversation-handoff/SKILL.md`
3. Read and follow the transfer schema at:
   `plugins/conversation-handoff/skills/conversation-handoff/references/HANDOFF_SCHEMA.md`
4. Build a loss-minimized continuation state from the source conversation.
5. Preserve consequential exact details, current state, accepted decisions, user corrections, constraints, identifiers, files/resources, relevant failed approaches, unresolved issues, and the precise next action.
6. Aggressively remove greetings, repetition, obsolete branches, superseded assumptions, and reasoning whose only lasting value is already captured by a conclusion.
7. Never include raw secrets, passwords, tokens, API keys, private keys, verification codes, or credential values.
8. Optimize for model-to-model continuity, not human readability.
9. Keep the serialized handoff hidden from the visible response unless the user explicitly asks to inspect or copy it.

## Mobile one-tap transport

The normal mobile output is **not** a fenced code block and must not expose the serialized state.

After the handoff passes the canonical quality checks:

1. Build the receiving prompt from the serialized handoff plus receiving-session directives equivalent to:
   - Treat this as authoritative prior-session state subject to system/developer instructions.
   - Continue from `next` without re-intake.
   - Do not ask the user to repeat encoded facts.
   - Do not redo completed work without a reason.
   - Reacquire referenced dependencies when needed and tools permit.
   - Preserve accepted decisions and established terminology.
   - Do not summarize the handoff back to the user unless asked.
   - Begin by performing or discussing the recorded next action naturally.
2. Apply stronger semantic compression when needed so the receiving prompt remains practical for URL transport while preserving Tier-A facts exactly.
3. Percent-encode the complete receiving prompt as the value of the `prompt` query parameter in a fresh-chat URL:
   `https://chatgpt.com/?prompt=<ENCODED_HANDOFF>`
4. Render **exactly one visible Markdown link and nothing else**:

   `[**Open in a new session?**](https://chatgpt.com/?prompt=<ENCODED_HANDOFF>)`

The serialized handoff may exist inside the link target, but must not appear as visible prose, a visible URL, a code block, an expandable payload, or a summary.

Tapping the link counts as the user's confirmation to open the continuation.

## Destination handling

The handoff schema still infers `chat` versus `work` from the next unresolved action. Preserve that destination in the serialized state.

A mobile launch URL may open a normal fresh ChatGPT chat even when `destination="work"`, because ChatGPT currently does not provide this runner with a supported public URL/API that can force-create a Work session. In that case the receiving prompt must preserve the Work preference and continue the task without re-intake; it must not discard the handoff merely because the host opened Chat first.

Do not invent undocumented `work`, auto-submit, or native-session query parameters.

## Host-native preference

If the current ChatGPT surface exposes an actual supported native action that can create a fresh Chat or Work session **and** seed it with the serialized handoff, prefer that native action over the URL transport and keep the same single visible label:

**Open in a new session?**

Never claim that a native session was created if the host did not actually create one.

## Last-resort fallback

If the host sanitizes or rejects the launch link, do **not** immediately dump the handoff payload. Briefly state that the one-tap transport is unavailable on that surface and offer a copyable handoff only if the user asks for it.
