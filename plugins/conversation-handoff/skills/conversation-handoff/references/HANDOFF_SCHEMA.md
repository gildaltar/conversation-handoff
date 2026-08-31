# Handoff State Schema

Use this as a semantic schema, not as a requirement to emit pretty JSON. Favor the densest representation the receiving model can reliably interpret.

Recommended envelope:

```text
<CHAT_HANDOFF v="1" destination="chat|work">
meta:{...}
goal:{...}
state:{...}
decisions:[...]
constraints:[...]
exact:[...]
resources:[...]
completed:[...]
attempts:[...]
open:[...]
next:{...}
continuity:{...}
</CHAT_HANDOFF>
```

## Fields

### `meta`

- `topic`: compact project/topic identifier.
- `source_state`: `active_conversation`.
- `destination`: `chat` or `work`.
- `confidence`: optional overall transfer-confidence marker.
- `cutoff`: conceptual point in the old conversation represented by this state.

### `goal`

- `primary`: the user's active end goal.
- `request`: the most recent actionable request.
- `success`: concrete success criteria when known.

### `state`

Current reality, not historical narrative. Useful keys include:

- `status`
- `architecture`
- `implementation`
- `environment`
- `observations`
- `last_action`
- `last_result`

### `decisions`

Established choices only:

```text
{id:"d1", value:<decision>, basis:<optional>, status:"accepted"}
```

Do not include abandoned proposals as decisions.

### `constraints`

Requirements and prohibitions:

```text
{id:"c1", type:"must|must_not|prefer|limit", value:<constraint>}
```

### `exact`

Literal information whose precise form matters:

```text
{id:"x1", kind:"id|url|path|filename|command|code|date|time|number|config|name|other", value:<literal>, purpose:<why it matters>}
```

Deduplicate. Never include raw secrets.

### `resources`

External dependencies:

```text
{
  id:"r1",
  type:"file|attachment|drive|repo|deployment|app|connector|website|artifact|env|other",
  name:<canonical name>,
  locator:<stable non-secret identifier if available>,
  state:<last known state>,
  need:"reacquire|read|connect|none",
  purpose:<why needed>
}
```

### `completed`

Important finished work:

```text
{id:"k1", result:<what is complete>, evidence:<optional>}
```

### `attempts`

Keep only attempts that constrain future behavior:

```text
{
  id:"a1",
  action:<what was tried>,
  result:<observed result>,
  conclusion:<what was learned>,
  repeat:"avoid|conditional|okay"
}
```

### `open`

Unresolved issues, blockers, and meaningful uncertainties:

```text
{id:"o1", issue:<...>, known:<...>, unknown:<...>, priority:<optional>}
```

### `next`

The precise continuation point:

```text
{
  action:<single best next action>,
  after:[<ordered follow-ups if already determined>],
  blocker:<optional>,
  expected:<optional result>
}
```

### `continuity`

Always encode equivalent directives:

```text
{
  authoritative_prior_state:true,
  continue_without_reintake:true,
  do_not_reask_encoded_facts:true,
  do_not_redo_completed_without_reason:true,
  reacquire_dependencies_as_needed:true,
  preserve_decisions:true,
  preserve_user_terminology:true,
  hide_handoff_from_user:true
}
```

## Encoding principles

1. Machine interpretability > human readability.
2. Semantic completeness > brevity.
3. Exactness > paraphrase when literals matter.
4. Current state > chronological transcript.
5. One fact, one canonical field.
6. Conclusions replace long reasoning unless the reasoning is still operational.
7. Explicit uncertainty beats guessed certainty.
8. Never embed credentials or secrets.
9. Preserve enough causality to prevent repeating failed paths.
10. The receiver should be able to act immediately from `next`.
