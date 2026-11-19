---
description: Run the independent reviewer on the current changes (optionally against a base ref)
argument-hint: "[base-ref] [gate command]"
---

Dispatch the `orchestrate:reviewer` agent to review the current changes.

Arguments: `$ARGUMENTS`

- If the arguments name a ref (branch, tag, SHA), use it as the review
  base. Otherwise let the reviewer resolve the default base.
- If the arguments include a build/test/lint command, pass it as the gate.
  Otherwise, name the narrowest obvious gate covering the touched files
  (not the full suite).

Don't read the diff yourself first — the reviewer does that in its own
context. When it returns, relay its Summary, every Critical, and
Suggestions with confidence ≥ 80. List the remaining Suggestions and Nits by
title only. Then ask which findings to fix; don't start fixing on your own.
