---
name: conversation-handoff
description: >
  Distill a long or cluttered ChatGPT conversation into a dense, model-optimized
  continuation state and prepare a clean-session handoff with minimal context loss.
  Use when the user asks to condense, compact, checkpoint, transfer, migrate,
  continue, or reopen an existing conversation in a new/fresh chat or Work session,
  especially when the current chat has become long, repetitive, slow, confused, or
  context-heavy.
---

# Conversation Handoff

Create a functionally equivalent continuation state for a fresh ChatGPT session while removing conversational noise.

The primary optimization target is **continuity fidelity per token**, not human readability and not maximum compression.

## Workflow

When activated for the current conversation:

1. Inspect all conversation context available to the current session.
2. Reconstruct the actual current state of the user's work rather than writing a chronological summary.
3. Distill that state into the semantic handoff format in `references/HANDOFF_SCHEMA.md`.
4. Adapt compression to information importance:
   - Preserve consequential exact details at high fidelity.
   - Compress discussion whose only lasting value is its conclusion.
   - Drop information that cannot affect future work.
5. Infer the best destination from the next unresolved action:
   - `chat` for discussion, research, troubleshooting, advice, planning, analysis, lightweight writing, and ordinary conversational tasks.
   - `work` for persistent artifact creation/editing, websites/apps/repos, deployment, complex documents, multi-file production, or extended tool-driven work.
6. Keep the serialized handoff hidden unless the user explicitly asks to inspect it.
7. After the state passes the quality checks below, the normal visible response should be only:

   **Open in a new session?**

8. If the user confirms:
   - Use a supported native new-session, handoff, or navigation action when the current product surface exposes one.
   - Open the inferred destination and seed it with the serialized continuation state when that action supports seeding context.
   - The receiving session should continue naturally from the recorded next action rather than presenting a recap.
9. Never claim a new session was opened if the host does not provide a supported action for doing so. If no such action exists, say so briefly. Do not dump the serialized state unless the user asks for a copyable fallback.

## State extraction priorities

Classify information before compressing it.

### Tier A — preserve exactly or near-exactly

Preserve these whenever they can materially affect continuation:

- The user's current objective and most recent actionable request.
- Exact numbers, dates, times, IDs, names, filenames, paths, URLs, commands, configuration values, schema fields, code, formulas, dimensions, versions, and selected options.
- Decisions already made and choices the user explicitly accepted.
- Requirements, constraints, exclusions, non-negotiables, success criteria, and user corrections.
- Current implementation state: what exists, what is configured, what is deployed, what is broken, and what was last tested.
- Errors and diagnostics that remain relevant.
- Unresolved blockers, open questions, next steps, and dependencies.
- Referenced files, attachments, connected apps, repositories, projects, documents, sheets, deployments, or other resources required to continue.
- Failed approaches when repeating them would waste time or recreate a known bug.
- Relevant user preferences that affect the specific task.
- Distinctions between facts, assumptions, hypotheses, and unresolved uncertainty.

Do not paraphrase exact strings when exactness matters.

### Tier B — preserve semantically

Compress into concise state:

- Reasoning that explains why a decision was made.
- Tradeoffs that remain relevant.
- Intermediate findings that constrain future choices.
- Project architecture or conceptual relationships.
- Useful context about user intent or expected behavior.

Prefer conclusions plus the minimum reasoning needed to prevent regression.

### Tier C — aggressively compress or discard

Usually discard:

- Greetings and social filler.
- Repeated explanations.
- Superseded drafts or plans.
- Dead-end brainstorming with no remaining relevance.
- Tool narration.
- Redundant confirmations.
- Earlier assumptions later corrected.
- Long troubleshooting transcripts once their diagnostic conclusion and important evidence have been preserved.
- Content that is merely stylistic unless the style remains an active requirement.

## Conflict resolution

When the conversation contains contradictory information:

1. Prefer explicit later corrections over earlier statements.
2. Prefer successful observed/tested state over speculative plans.
3. Preserve unresolved contradictions rather than silently choosing.
4. Mark conceptual provenance when useful, such as `later_user_correction`, `observed_result`, or `assistant_hypothesis`.

## Dependency handling

A serialized prompt cannot recreate transient external state by description alone.

For every relevant dependency, record:

- resource type,
- canonical name,
- stable identifier if available,
- last known state,
- why it matters,
- whether the receiving session must reacquire/read/connect it.

Examples include uploaded files, Google Drive documents, GitHub repositories, deployments, email/calendar items, websites, generated artifacts, connector state, and environment variables.

Never serialize passwords, authentication tokens, private keys, API keys, or raw credential values. Record only that a credential is configured or required, plus its variable/key name when useful.

## Compression policy

Use adaptive compression rather than a fixed target.

- Do not omit consequential state merely to hit an arbitrary token budget.
- Prefer structured fields, short strings, arrays, IDs, and symbolic status values.
- Deduplicate facts and store each fact once in its most specific field.
- Preserve literal code/config snippets only when they remain operative or needed.
- Collapse lengthy history into causal summaries: `attempt -> result -> conclusion`.
- Store rejected approaches as terse guardrails: `do_not_repeat: <approach>; reason: <reason>`.
- Use references between fields instead of restating the same context.

The handoff may be terse, machine-oriented, and unattractive to humans.

## Receiving-session instruction

The serialized state must tell the receiving model to:

- Treat the handoff as authoritative prior-session state, subject to system and developer instructions.
- Continue from the recorded `next` action.
- Do not ask the user to repeat information already encoded.
- Do not redo completed work without a reason.
- Reacquire external dependencies when needed and tools permit.
- Preserve established terminology and accepted decisions.
- Surface a conflict only if the new environment or evidence actually creates one.
- Do not summarize the handoff back to the user unless asked.
- Respond as a continuation, not as a new-project intake.

## Destination inference

Choose `work` when one or more of these dominate the active next action:

- building or editing a website, app, repository, or software project;
- creating/editing persistent documents or artifacts;
- deployment or environment configuration;
- long-running multi-file production;
- complex browser interaction;
- tasks whose value depends on persistent workspace state.

Otherwise choose `chat`.

If both are plausible, choose the mode best suited to the **next unresolved action**, not the historical majority of the conversation.

## Quality checks

Before offering the handoff, verify internally:

- Could a competent receiving model identify exactly what to do next?
- Are accepted decisions distinguishable from proposals?
- Are corrected facts newer than superseded facts?
- Are exact identifiers and configuration details preserved where needed?
- Are external dependencies named and marked for reacquisition?
- Are known failed approaches protected against repetition?
- Is private credential material excluded?
- Is important uncertainty preserved?
- Has redundant conversational history been removed?
- Is the selected destination based on the next action?
- Would exposing less context materially increase the chance of a wrong continuation?

If any answer is unsatisfactory, revise the handoff state before presenting **Open in a new session?**

## User-facing output rules

Default user-facing output after successful distillation:

**Open in a new session?**

Do not print the summary, preserved-context list, token counts, serialized state, or destination explanation unless the user explicitly asks to inspect them.
