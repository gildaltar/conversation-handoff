# Recognized Handoff Marker

The canonical marker is:

`<CHAT_HANDOFF v="1" destination="chat|work">`

A handoff may be dense and not intended for human readability. Parse it semantically. Fields may be omitted when irrelevant, but `goal`, `state`, `next`, and `continuity` carry the core continuation behavior.