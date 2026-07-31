# Cloud-agent setup

`fstack-run` is the end-to-end mode for remote coding agents. It preserves fstack's small-change discipline while removing routine approval pauses between inspection, planning, implementation, testing, review, and delivery.

The original skills remain interactive. Use them when you want to drive each stage manually.

## 1. Review before installing

Agent skills are executable instructions. Inspect this repository and the selected `SKILL.md` before giving an agent write access to an important repository.

List the available skills without installing them:

```sh
npx skills@latest add naytewilson/fstack --list
```

## 2. Install

Install only the continuous runner into the current project:

```sh
npx skills@latest add naytewilson/fstack --skill fstack-run -y
```

Install it globally for supported agents detected on the machine:

```sh
npx skills@latest add naytewilson/fstack --skill fstack-run -g -y
```

Install it globally for named clients:

```sh
npx skills@latest add naytewilson/fstack --skill fstack-run -g -a codex -a claude-code -a opencode -y
```

Install the complete interactive and continuous collection:

```sh
npx skills@latest add naytewilson/fstack --all
```

Project installation is better when a team should share the same version. Global installation is better for a personal default across repositories.

## 3. Give the cloud agent the right repository access

A full run needs:

- repository read access;
- permission to create and push a task branch;
- permission to open or update a pull request;
- permission to read CI results;
- the repository's normal build and test environment.

It does not need permission to force-push, merge, deploy, edit repository settings, or read production secrets for ordinary coding tasks. Keep those permissions disabled unless a specific task requires them.

## 4. Start a run

A compact task is enough:

```text
Use /fstack-run. Fix the reported issue end to end. Inspect source truth first, preserve unrelated work, implement the smallest complete change, run the applicable checks, fix review findings, and deliver a task branch plus pull request. Stop only for a proven external blocker or a decision that changes the safe action.
```

Include acceptance criteria, issue links, screenshots, or failing commands when they exist. Do not restate repository facts that the agent can inspect.

## 5. Expected lifecycle

A compliant cloud run performs this loop:

```text
inspect -> isolate -> plan briefly -> implement -> test -> review -> fix -> retest -> commit -> push -> pull request -> verify checks
```

The agent may repeat implementation, testing, and review. It should not stop merely because one phase completed.

## 6. Repository instruction files

This repository includes:

- `AGENTS.md` as the canonical cross-agent contract;
- `CLAUDE.md` as a Claude Code entrypoint;
- `.github/copilot-instructions.md` as a GitHub Copilot coding-agent entrypoint;
- `skills/fstack-run/SKILL.md` as the portable continuous workflow.

When installing fstack into another repository, that repository's own instructions remain authoritative. The skill must adapt to them rather than overwrite them.

## 7. Verification and delivery

A successful run must provide observed evidence for:

- the requested behavior;
- targeted tests or checks;
- a reasonable broader regression check;
- final diff review;
- branch and commit identity;
- pull-request identity and check status.

Unavailable checks belong under `MISSING EVIDENCE`. They are not silently converted into a pass.

By default, `fstack-run` stops after a verified pull request. Merging and deployment require an explicit request and repository permission.

## 8. Safe automation defaults

Use these defaults for unattended cloud execution:

- task branch, never direct-to-`main`;
- no force-push;
- no destructive cleanup or reset;
- no broad `git add .` in a dirty repository;
- no secret files, credentials, or private local paths in commits;
- no dependency addition when the existing toolchain can solve the task;
- no merge or deployment merely because tests passed;
- no claim of success without observed output.

## 9. Repository settings worth enabling

For repositories where cloud agents routinely open pull requests, enable:

- required status checks for the real test and lint workflows;
- branch protection or rulesets for `main`;
- blocked force-pushes and deletions;
- pull requests before merge;
- automatic branch deletion after merge, when appropriate;
- least-privilege tokens or GitHub App permissions.

These are host-level controls. Installing a skill does not configure them automatically.

## 10. Update and audit

Review upstream changes before updating a trusted automation environment.

Check installed skills and update through the skills CLI:

```sh
npx skills list
npx skills update
```

For stricter environments, pin the repository source to a reviewed commit in the surrounding automation and update that pin deliberately.

## 11. Troubleshooting

### The agent stops after planning

Confirm that `fstack-run` was selected rather than `fstack-plan` or the interactive `/fstack` route.

### The agent edits directly on `main`

The repository or cloud platform did not enforce task-branch behavior. Stop the run, preserve the diff, create a branch, and continue there. Add a host-level branch rule so this cannot recur.

### The agent opens a pull request without tests

The run is incomplete. Resume it with the missing verification requirement and require observed output before final review.

### The client cannot find the skill

Run the list command, verify the selected agent and installation scope, and confirm that the installed folder contains `fstack-run/SKILL.md` with intact YAML frontmatter.
