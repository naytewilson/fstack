---
name: fstack-run
description: Take a repository task from source-truth inspection through implementation, verification, review, commit, push, and pull request in one continuous run. Use for cloud agents, autonomous execution, unattended coding, end-to-end fixes, or requests to keep working until a proven result exists.
---

# /fstack-run

Complete one repository task end to end. Keep fstack's preference for small, simple changes, but do not inherit the interactive skills' routine approval stops.

## Execution contract

Continue until one of these outcomes exists:

1. the requested result is implemented, verified, reviewed, and delivered on a task branch;
2. a concrete external blocker is proven with preserved work and an exact unblocking action; or
3. the user explicitly stops the run.

Planning, editing, one passing check, a commit, or an open pull request is not completion by itself.

## Steps

### 1. Establish source truth

- Confirm the repository root, current branch, HEAD, dirty state, remotes, and other worktrees when available.
- Read repository instructions from broadest to most specific scope.
- Read the relevant implementation, tests, manifests, CI, and recent history.
- Separate observed facts from assumptions. Never invent repository state, paths, commands, or results.

### 2. Protect existing work

- Preserve unrelated changes exactly as found.
- Use a task branch or isolated worktree when supported.
- Never reset, clean, overwrite, force-push, or broadly stage a dirty tree.
- If isolation is unavailable, touch only task-owned files and report the constraint.

### 3. Resolve the task

Infer ordinary implementation details from repository conventions and choose the smallest reversible option.

Ask only when the missing answer changes the safe action and cannot be resolved from evidence. Valid stops include:

- a real risk of irreversible data or code loss;
- credentials, permissions, billing, or private data the agent cannot obtain safely;
- a merge conflict whose correct resolution changes product behavior;
- mutually exclusive public behavior with no repository-defined default.

Do not stop for routine naming, library, formatting, or implementation choices when the repository already supplies a reasonable convention.

### 4. Plan briefly

Keep a short outcome-based plan with one active step. Write `PLAN.md` only when the repository already uses it or the task needs a durable handoff.

State what is deliberately out of scope. Do not turn the plan into ceremony or wait for approval unless the user requested an approval gate.

### 5. Implement and observe

- Make the smallest complete change.
- Avoid unrelated refactors and speculative abstractions.
- Verify each meaningful step with the closest available behavior check.
- Interpret every command result before continuing.
- Recover from ordinary failures by changing a relevant condition; do not repeat the same failed action blindly.
- Keep the user updated during long runs without stopping execution.

### 6. Run the completion gate

Run the repository's documented test, lint, build, format, and validation commands that apply to the change.

At minimum:

- run a targeted behavior check;
- run a reasonable broader regression check;
- inspect the final diff and repository state;
- check for secrets, credentials, generated files, accidental scope expansion, and stale documentation;
- map every explicit requirement to observed evidence.

If no automated test surface exists, perform the strongest available static and behavioral checks and label the missing evidence. Never replace an unavailable test with confidence language.

### 7. Review and fix

Review the complete diff against the request, repository conventions, and the "can this be less?" rule.

Fix correctness, scope, validation, documentation, and unnecessary-complexity findings that are within the task. Rerun affected checks after every fix. Do not merely report fixable findings and stop.

### 8. Deliver durably

- Stage only task-owned files.
- Commit with a plain message describing the outcome.
- Push the current task branch without force.
- Open or update a pull request when supported.
- Do not merge, release, or deploy unless the user explicitly requested it and repository policy allows it.
- Confirm final branch, commit, diff, and check status after delivery.

Do not delegate final delivery to a push-only routine that skips verification.

## Final receipt

Report:

```text
PROVEN
- files and behavior implemented
- exact checks run and observed results
- branch, commit, and pull request

MISSING EVIDENCE
- unavailable checks and exact reasons, or none

POSSIBLY WRONG OR OVERSTATED
- remaining assumptions, or none

EXACT NEXT ACTION
- smallest remaining action, or none

WHAT DOES NOT COUNT AS COMPLETION
- any unverified or undelivered part of this task

CONTEXT
- safe to continue here, or why a fresh context is required
```
