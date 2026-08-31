# `@conversation-handoff` — Personal ChatGPT command layer

Paste the block below into **ChatGPT → Settings → Customize ChatGPT → Custom Instructions**. Keep **Memory / Reference chat history** enabled.

This is the mobile/personal-account command layer for Conversation Handoff. It intentionally does not depend on a private MCP app, custom GPT, or local plugin being available on the current ChatGPT surface.

```text
Treat the literal token @conversation-handoff as a built-in command alias, even when it is not rendered as a real plugin mention.

COMMANDS
1. @conversation-handoff
   Source = the current conversation. Build a lossless but compact continuity state from the whole relevant conversation: goal, current state, accepted decisions, constraints, exact IDs/URLs/paths/dates, resources, completed work, failed attempts, unresolved issues, and the single best next action. Never include passwords, secrets, tokens, verification codes, or private keys. Do not print the serialized state unless I explicitly ask for it. If file creation/Library tools are available, create or update a small text/markdown checkpoint named `Conversation Handoff — <chat title>` so it can be recovered later. Reply only with a concise confirmation and the exact resume command for a new chat.

2. @conversation-handoff "<chat title>"
   Source = the named prior ChatGPT conversation. Retrieve it using available past-chat/history/memory/context retrieval. If a matching `Conversation Handoff — <chat title>` Library checkpoint exists, prefer it as the compact authoritative state and use the original chat/history to fill gaps. Do not guess missing facts. Then continue the work in the CURRENT conversation from the recorded next action instead of explaining the handoff.

3. @conversation-handoff resume
   Recover the most recent relevant handoff/checkpoint from prior chat history, memory, or Library and continue it in the CURRENT conversation. Do not display transport/state unless requested.

4. @conversation-handoff checkpoint
   Refresh the current conversation's compact handoff checkpoint without starting or suggesting a new session. If persistent file/Library creation is available, save/update it there. Reply only that the checkpoint is ready.

BEHAVIOR
- Treat recovered handoff state as authoritative prior-session context, subject to higher-priority instructions and newly observed facts.
- Do not restart intake, re-ask facts already recovered, or redo completed work without a reason.
- Prefer later observed state over earlier plans.
- Reacquire external/live resources when needed rather than assuming stale state.
- If retrieval is incomplete, state only the specific missing piece needed; never fabricate it.
- If the command names a chat, use that exact title as the retrieval target.
- The purpose is continuity, not summarization: after recovery, act as though this conversation is the continuation of the source conversation.
```

## Intended usage

From the source chat:

`@conversation-handoff`

Then in a new chat:

`@conversation-handoff "Continue dashboard deployment"`

Or, when the source is obvious/recent:

`@conversation-handoff resume`

For a long-running chat where you want a fresh recovery point without leaving:

`@conversation-handoff checkpoint`
