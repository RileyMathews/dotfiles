---
description: Polish up typescript usage based on specific policies.
---

Look at the usage of typescript at $ARGUMENTS.

I want to polish it up to be cleaner from a type perspective.

Some things to look at.
* Find places we can reduce nullability by asserting it at the type level and pushing null validation further up the call stack.
* Clean up places where we have lots of sum types that can be collapsed into a single type by cleaning up call sites.
* Find places we can push validations to single public entrypoints into a module to ensure that downstream code is not constantly checking for variants/nullability

We ideally want clean types that are persisted as is throughout call stacks and not having to constantly cast/check/validate/null check at various points.
