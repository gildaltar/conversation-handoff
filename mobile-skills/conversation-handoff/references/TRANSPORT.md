# Mobile Transport

Build the receiving prompt from a short receiver directive plus the serialized `<CHAT_HANDOFF ...>` state.

Receiver directive: `Resume the prior conversation from the state below. Treat it as authoritative prior-session context subject to system/developer instructions. Do not summarize it. Do not ask for facts already encoded. Continue directly from next.action.`

If URL transport is practical, percent-encode the complete receiving prompt and use `https://chatgpt.com/?prompt=<ENCODED_RECEIVING_PROMPT>`.

Render exactly one visible Markdown link:

`[**Open in a new session?**](https://chatgpt.com/?prompt=<ENCODED_RECEIVING_PROMPT>)`

Do not invent undocumented Work-mode or auto-submit parameters. Preserve `destination="work"` inside the handoff when Work is preferred.

If the URL would be impractically long or the client rejects it, prefer a native new-chat/share/copy interaction exposed by the host. Only expose the raw handoff if the user explicitly requests a manual copy.