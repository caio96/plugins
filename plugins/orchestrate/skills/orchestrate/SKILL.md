---
name: orchestrate
description: Playbook for running the current session as an orchestrator — decompose a larger task, dispatch subagents to do the parts, pick the right model for each, and synthesize the results. Use when asked to orchestrate, coordinate, delegate, fan out, parallelize, or break work into subtasks across agents, or when a task is large enough that one pass would be slower or less reliable than dividing it. Covers running code-changing units as parallel agents in isolated git worktrees. Pairs with the orchestrate:reviewer agent for independent review.
---

# Orchestrate

Run this session as an orchestrator: split the work, dispatch subagents, own
the synthesis. You stay the decision-maker — subagents do scoped work and
report back; you decide what it means and what happens next.

If the `terse` output style is active, keep your own talk terse and tell
each dispatched agent to report tersely too (subagents may not inherit the
output style).

## Two hard rules

1. **You are the orchestrator.** Keep the plan, dispatch, and synthesis
   here; hand out only scoped, self-contained units. Delegating the
   orchestration itself means nobody holds the whole picture.
2. **Protect your context.** Every subagent result stays in your context,
   so a long run decays as it fills. Don't read large files, diffs, or logs
   yourself — push that into the subagent and let conclusions, not dumps,
   cross back.

## Recursion cap

A dispatched agent may spawn its own subagents for a genuinely big unit,
but only one level deep: tell it that any subagent *it* spawns may not
spawn further (`orchestrate:implementer` already knows this). Without that
line, depth is unbounded and nested agents are invisible to you — no
supervision, no cleanup, unpredictable cost.

## Keep a durable ledger

Context-only state is lost to summarization and crashes; track it on disk
in `.notes/` instead. Before the first write, make sure `.notes/` is
ignored without touching tracked files: if `git check-ignore -q .notes`
fails, append `.notes/` to `.git/info/exclude`.

- **Session task list** — `pending → in_progress → completed`, one per
  unit; the harness re-surfaces it after compaction.
- **Ledger file** — `.notes/ledger-<topic>.md`, a distinct name per session
  so sessions never overwrite each other. Follow
  `references/ledger-template.md`. Keep it brief: you reread it to
  synthesize, so every redundant line costs context later. Update a unit's
  block in place instead of appending per status change, and record
  conclusions, not transcripts or diffs.
- **Frictions** — one shared `.notes/frictions.md` across all sessions,
  one line per friction. A recurring pain only becomes fixable once it's
  visible in one place.

## Pick the model per unit

Agents default to whatever model the environment configures (an
`ANTHROPIC_MODEL` override or a default subagent model), which is rarely
the right fit for every unit. Set the `model` parameter explicitly on each
dispatch, matched to the unit's difficulty:

| Unit | Model |
|------|-------|
| Read-only search, locating code, mechanical edits | `haiku` or `sonnet` |
| Well-specified, routine implementation slice; routine research | `sonnet` |
| Complex implementation (cross-cutting changes, subtle invariants, concurrency, perf-critical code), ambiguous design, hard debugging, independent review | `opus` |

Escalate on evidence: if a cheaper model returns thin or wrong work,
re-dispatch the unit one tier up rather than patching around it.

Known limits — check them, don't fight them:
- **Forks ignore `model`.** A `fork` always runs on your own model; use a
  fresh agent type when the model matters.
- **Aliases may be unavailable** on some providers or proxies. If a
  dispatch with `model` fails, note it in `.notes/frictions.md`, tell the
  user once, and continue on the default model.

## Parallel code changes in worktrees

When two or more units change code at the same time, run each with
`isolation: "worktree"` so they can't trample each other's working tree.

- **Start from existing work**, not a stale base (worktrees branch from
  `origin/<default>` and miss unpushed commits): merged locally → the new
  local base; merged on the remote → the latest remote base; continuing a
  remote PR → its stack (`gh stack checkout <PR>`).
- **Split by files.** Give parallel units disjoint file sets and an
  explicit out-of-scope boundary each; overlapping edits become conflicts
  you resolve by hand. If units must share a file, run them sequentially.
- **Stacked PRs (`gh stack`)** suit units that build on each other. Agents
  can start or continue a stack locally (`gh stack init`, `add`, `checkout
  <PR>`) and stack new branches from their worktrees. Posting PRs
  (`push`, `submit`) always needs the user's authorization first. Run
  history-rewriting commands (`rebase`, `sync`, `modify`) one agent at a
  time.
- **Notes.** A worktree agent may be unable to write your main checkout's
  `.notes/`; have it write to its own worktree's `.notes/frictions.md` and
  fold that into the shared file before removing the worktree.

## Steps

1. **Decompose and record.** Independent units run in parallel; a unit
   needing another's output is a later stage, not a sibling. If the work
   is small and sequential, just do it — orchestration has overhead and
   only pays off when work actually divides. Investigate an uncertain
   unit with a read-only agent first. Code you write yourself
   follows the implementer's change standards: readable, minimal diff
   unless more is warranted, brief non-historical comments, tests and
   logging per repo precedent, narrow test runs, scratch in `/tmp/$USER/`.
2. **Pick the narrowest agent and the right model:** Explore (read-only
   fan-out), general-purpose (research), `orchestrate:implementer`
   (a code-changing unit — it already carries the change standards,
   recursion cap, commit rule, and report format), `orchestrate:reviewer`
   (independent diff review, step 5).
3. **Dispatch self-contained prompts.** A subagent sees only what you give
   it — state the goal, the context it needs to judge the work, the base
   and gate command. For agents other than the implementer, also include
   the recursion cap, the rule to commit before finishing (an uncommitted
   worktree is auto-cleaned and the work lost), and what to report back.

   Keep gates narrow — the build plus tests affected by the unit's
   changes — so the loop stays fast and failures point at the change. Run
   the full suite only when the user asks (or the repo requires it before
   merging).
4. **Supervise and update the ledger as results land.** Re-dispatch
   thin or off-target results rather than papering over them; out-of-scope
   discoveries become ledger notes, not silent expansions.
5. **Review after significant work.** Dispatch `orchestrate:reviewer` for
   an independent verdict before calling work done. Give it the base ref
   and the gate command.
6. **Address the review — when the work under review is yours.** If this
   session produced the changes (implementation units), the review is a
   gate, not a report: see "Acting on review findings" below. If the task
   itself is a review (someone's PR, an audit, a second opinion), deliver
   the findings and stop — fixing is the user's call.
7. **Commit at validated split points**, rather than letting reviewed,
   gate-passing work pile up uncommitted. Don't commit or merge into your
   branch past an open Critical or a failing gate.
8. **Synthesize from the ledger**, not your (possibly summarized) context —
   reread it when merging a long run.

## Acting on review findings

Triage each finding:

| Finding | Action |
|---------|--------|
| Critical (any confidence) | Fix, or rebut with evidence |
| Suggestion, confidence ≥ 80 | Fix, or rebut with a reason |
| Suggestion < 80, Nits | Your judgment — fix if cheap and clearly right, otherwise note and move on |

- **Fix through the implementer.** Dispatch `orchestrate:implementer` on
  the same branch with the findings quoted verbatim (file, line, evidence)
  so it doesn't have to rediscover them. Use `opus` for Critical fixes.
- **Rebut honestly.** A rebuttal is a concrete reason the finding is wrong
  or out of scope (e.g. "intended: callers validate input, see
  `api/handler.go:40`"), not a preference. Record it as one line in the
  ledger.
- **Re-verify.** After fixes, rerun the gate. If any Critical was fixed,
  re-dispatch the reviewer on just the fix commits to confirm the fix and
  catch regressions it introduced.
- **Cap the loop at two rounds.** If Criticals are still open after the
  second, stop and bring them to the user with the evidence — repeated
  failed fixes usually mean a misunderstood requirement, not a typo.
- Record each finding in the ledger's Review section as one line.
