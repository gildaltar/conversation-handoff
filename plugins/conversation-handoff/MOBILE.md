# Conversation Handoff — Plugin Transport

This file is bundled inside the Conversation Handoff plugin so the installed plugin remains self-contained after ChatGPT copies it into the local plugin cache.

Use this transport only when the current ChatGPT host does not expose a supported native action that can create a fresh session and seed it with the hidden handoff state.

## Source and schema

The canonical workflow is bundled at:

`skills/conversation-handoff/SKILL.md`

The canonical transfer schema is bundled at:

`skills/conversation-handoff/references/HANDOFF_SCHEMA.md`

Treat the entire source conversation available to the active session as the source state.

## One-tap fallback transport

After the handoff passes the quality checks in the skill:

1. Build the receiving prompt from the serialized handoff plus directives equivalent to:
   - Treat this as authoritative prior-session state, subject to system and developer instructions.
   - Continue from the recorded `next` action without re-intake.
   - Do not ask the user to repeat encoded facts.
   - Do not redo completed work without a reason.
   - Reacquire referenced dependencies when needed and tools permit.
   - Preserve accepted decisions and established terminology.
   - Do not summarize the handoff back to the user unless asked.
   - Begin naturally from the recorded next action.
2. Preserve Tier-A details exactly while compressing lower-value context enough to keep transport practical.
3. Percent-encode the complete receiving prompt into the `prompt` query parameter of a fresh ChatGPT URL:

   `https://chatgpt.com/?prompt=<ENCODED_HANDOFF>`

4. Render exactly one visible Markdown link and nothing else:

   `[**Open in a new session?**](https://chatgpt.com/?prompt=<ENCODED_HANDOFF>)`

The serialized state must not appear visibly next to the link.

Tapping the link is the user's confirmation to continue.

## Destination handling

Preserve the inferred `chat` versus `work` destination inside the serialized handoff. Do not invent undocumented URL parameters to force Work mode or auto-submit a prompt.

If the host opens an ordinary Chat session even though the state prefers `work`, the receiving model should continue from the handoff without re-intake and may use Work when the supported surface makes it available.

## Native action preference

If ChatGPT exposes a supported native action that can both create a new session and seed the handoff, use that instead of URL transport and retain the same visible label:

**Open in a new session?**

Never claim a native session was created unless the host actually created it.

## Last-resort fallback

If the host rejects or sanitizes the launch link, do not automatically dump the hidden handoff into the conversation. State briefly that one-tap transport is unavailable and expose a copyable handoff only if the user requests it.
