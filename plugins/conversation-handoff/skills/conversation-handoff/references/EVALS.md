# Evaluation Prompts

Use these to test activation and behavior.

## Should activate

1. "This chat is getting huge. Condense everything important and move us to a fresh chat."
2. "Can you checkpoint this conversation so I can continue without all the old context?"
3. "Transfer this whole project into a new Work session without losing where we are."
4. "I want a clean session, but I don't want to explain all of this again."
5. "Compact the current conversation and continue in a new session."
6. "We're hitting context bloat. Preserve the actual state and hand it off."
7. "Move this troubleshooting session to a fresh chat and don't make me repeat anything."
8. "Create a continuation state from this entire thread."

## Should not activate

1. "Summarize this article in three bullets."
2. "Make this email shorter."
3. "What did we decide about the paint color?"
4. "Give me a meeting recap."
5. "Compress this JSON file."
6. "Explain context windows."
7. "Start a new chat about quantum mechanics."
8. "Turn these notes into a prompt for Midjourney."

## Behavioral checks

A successful run should:

- preserve exact operative values and identifiers;
- exclude raw secrets;
- represent the latest correction instead of superseded facts;
- preserve meaningful failed attempts;
- select destination based on the next action;
- avoid showing the payload by default;
- present only `Open in a new session?` after the payload is ready;
- never falsely claim a new session was opened if no supported host action exists.

## Regression scenarios

### Latest correction wins

Conversation contains:
- initial server port `3000`;
- later correction: "No, use 4318 instead.";
- several later references to the server without restating the port.

Expected handoff: `4318` is authoritative; `3000` is omitted unless the change itself remains relevant.

### Failed approach survives compression

Conversation contains a long debugging attempt that proves disabling IPv6 did not fix the issue.

Expected handoff: preserve a terse guardrail such as `disable_ipv6 -> no change -> avoid repeating as primary fix`, not the entire command transcript.

### Resource must be reacquired

Conversation depends on a Google Sheet and an uploaded PDF.

Expected handoff: record both as resources with stable names/identifiers when available and mark them for reacquisition in the receiving session rather than pretending their live contents were transferred.

### Secret exclusion

Conversation includes an API key while configuring an environment variable.

Expected handoff: preserve the variable name and that it is configured/required; omit the secret value.
