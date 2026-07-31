# fstack repository agent contract

## Purpose

fstack is a portable collection of Agent Skills. Keep it small, readable, agent-agnostic, and safe to install in other repositories.

The interactive skills intentionally stop at human decision points. `fstack-run` is the continuous cloud-agent path. Do not remove either mode or silently make one behave like the other.

## Source of truth

Before changing the repository:

1. Confirm the repository root, current branch, HEAD, and working-tree state.
2. Read this file, `README.md`, and every skill or document affected by the task.
3. Inspect recent history when the task changes established behavior.
4. Treat repository files and command output as authoritative. Do not substitute conversation memory for current state.
5. Preserve unrelated or pre-existing changes. Never reset, clean, overwrite, or force-push them away.

## Change rules

- Make the smallest complete change that satisfies the request.
- Keep one job per skill.
- Keep `SKILL.md` concise. The hard limit is 500 lines; prefer roughly 150 or fewer.
- Keep skill names lowercase and hyphenated. The frontmatter `name` must match the containing directory.
- Put activation conditions in the frontmatter `description` so agents can discover the skill correctly.
- Prefer plain Markdown. Add scripts, references, or assets only when they improve repeatability or correctness.
- Do not hardcode one vendor's tool names into a generally portable skill unless the skill is explicitly vendor-specific.
- Do not add dependencies or generated files for validation that POSIX shell can handle.
- Update `README.md` whenever a skill is added, renamed, removed, or materially changes behavior.

## Continuous cloud-agent behavior

When a user asks for autonomous, end-to-end, unattended, cloud-agent, or "finish it" execution, use `fstack-run`.

Proceed without routine approval stops. Ask only when the missing answer changes the safe action and cannot be resolved from repository evidence. Ordinary implementation choices should use the smallest reversible option consistent with existing conventions.

A cloud run is not complete after planning, editing, one passing test, or opening a pull request. It is complete only after implementation, verification, final diff review, and a durable delivery artifact exist, or after a concrete external blocker is proven.

## Verification

Run all applicable checks. For this repository, the minimum gate is:

```sh
sh -n scripts/validate.sh
sh -n scripts/test-validate.sh
sh -n scripts/install-cursor-cloud-skills.sh
sh scripts/test-validate.sh
sh scripts/validate.sh
git diff --check
```

Then inspect the final diff and confirm:

- every changed file belongs to the task;
- all skill frontmatter is valid and discoverable;
- the README and routing tables match the skills on disk;
- no secret, credential, local path, or generated artifact was added;
- no interactive behavior was accidentally converted into autonomous behavior, or vice versa.

Never claim a command passed unless its output was observed.

## Git and delivery

- Work on a task branch, not directly on `main`.
- Commit only task-owned files.
- Do not skip hooks, force-push, or amend published commits.
- Push the task branch and open a pull request when the environment supports it.
- Do not merge or deploy unless the user explicitly requests it and repository policy permits it.

## Completion receipt

End substantial work with:

```text
PROVEN
- implemented files and behavior
- commands run and observed results
- branch, commit, and pull request

MISSING EVIDENCE
- checks that could not be run and the exact reason

POSSIBLY WRONG OR OVERSTATED
- remaining assumptions, or none

EXACT NEXT ACTION
- the one smallest action needed next, or none

WHAT DOES NOT COUNT AS COMPLETION
- planning, unverified edits, or a PR with failing/unknown checks

CONTEXT
- safe to continue here, or why a fresh context is required
```
