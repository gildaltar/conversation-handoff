# Conversation Handoff — Mobile Runner

This file is an execution bootstrap for ChatGPT mobile/web surfaces where the Conversation Handoff plugin or skill is not available.

When a user asks you to execute this file against the current conversation, do the following immediately:

1. Treat the **entire current conversation available to you** as the source session.
2. Read and follow the canonical skill instructions at:
   `plugins/conversation-handoff/skills/conversation-handoff/SKILL.md`
3. Read and follow the transfer schema at:
   `plugins/conversation-handoff/skills/conversation-handoff/references/HANDOFF_SCHEMA.md`
4. Build a loss-minimized continuation state from the current conversation.
5. Preserve consequential exact details, current state, accepted decisions, user corrections, constraints, identifiers, files/resources, relevant failed approaches, unresolved issues, and the precise next action.
6. Aggressively remove greetings, repetition, obsolete branches, superseded assumptions, and reasoning whose only lasting value is already captured by a conclusion.
7. Never include raw secrets, passwords, tokens, API keys, private keys, or credential values.
8. Optimize for model-to-model continuity, not human readability.

## Mobile fallback output

Because the current surface may not support native session creation, do **not** pretend to open a new session.

Output exactly one fenced code block containing the serialized handoff state and nothing else. The payload must include receiving-session directives equivalent to:

- Treat this as authoritative prior-session state subject to system/developer instructions.
- Continue from `next` without re-intake.
- Do not ask the user to repeat encoded facts.
- Do not redo completed work without a reason.
- Reacquire referenced dependencies when needed and tools permit.
- Preserve accepted decisions and established terminology.
- Do not summarize the handoff back to the user unless asked.
- Begin by performing or discussing the recorded next action naturally.

The user will copy that single code block into a new ChatGPT Chat or Work session.
