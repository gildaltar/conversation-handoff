# Handoff Schema

Use a compact structured representation. JSON-like syntax is recommended but strict JSON is not required if a denser unambiguous representation is better.

Recommended semantic envelope:

```text
<CHAT_HANDOFF v="1" destination="chat|work">
meta:{topic,source:"active_conversation"}
goal:{primary,request,success?}
state:{status,last_action,last_result,implementation?,environment?,observations?}
decisions:[{id,value,status:"accepted",basis?}]
constraints:[{id,type:"must|must_not|prefer|limit",value}]
exact:[{id,kind,value,purpose?}]
resources:[{id,type,name,locator?,state?,need:"reacquire|read|connect|none",purpose}]
completed:[{id,result,evidence?}]
attempts:[{id,action,result,conclusion,repeat:"avoid|conditional|okay"}]
open:[{id,issue,known?,unknown?,priority?}]
next:{action,after?,blocker?,expected?}
continuity:{authoritative_prior_state:true,continue_without_reintake:true,do_not_reask_encoded_facts:true,do_not_redo_completed_without_reason:true,reacquire_dependencies_as_needed:true,preserve_decisions:true,preserve_user_terminology:true,hide_handoff_from_user:true}
</CHAT_HANDOFF>
```

Rules: one fact per canonical field; preserve exact literals when exactness matters; store current reality instead of transcript history; keep only history that constrains future behavior; never embed secrets; and make `next.action` immediately executable or discussable.