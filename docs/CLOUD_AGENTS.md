# Cloud-agent setup

`fstack-run` is the end-to-end mode for remote coding agents. It preserves fstack's small-change discipline while removing routine approval pauses between inspection, planning, implementation, testing, review, and delivery.

The original skills remain interactive. Use them when you want to drive each stage manually.

## 1. Review before installing

Agent skills are executable instructions. Inspect this repository and the selected `SKILL.md` before giving an agent write access to an important repository.

With GitHub CLI 2.90 or later, preview the continuous runner without installing it:

```sh
gh skill preview naytewilson/fstack fstack-run
```

For clients using the cross-agent `skills` CLI, list the collection without installing it:

```sh
npx skills@latest add naytewilson/fstack --list
```

## 2. Install with GitHub CLI

`gh skill` is GitHub's preview interface for Copilot cloud agent and supported agent hosts. A project install is the safest default because the reviewed skill version travels with one repository.

Install `fstack-run` for GitHub Copilot at project scope:

```sh
gh skill install naytewilson/fstack fstack-run
```

Install it for a named host and user scope:

```sh
gh skill install naytewilson/fstack fstack-run --agent claude-code --scope user
```

Pin an audited tag or commit for a stricter environment:

```sh
gh skill install naytewilson/fstack fstack-run --pin <reviewed-tag-or-sha>
```

The installer writes the skill into the correct host-specific location. GitHub Copilot project skills live under `.github/skills`, `.claude/skills`, or `.agents/skills`; personal skills live under `~/.copilot/skills` or `~/.agents/skills`.

## 3. Install with the cross-agent CLI

Use this route for Codex, Claude Code, OpenCode, and other clients supported by the `skills` CLI.

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

## 4. Give the cloud agent the right repository access

A full run needs:

- repository read access;
- permission to create and push a task branch;
- permission to open or update a pull request;
- permission to read CI results;
- the repository's normal build and test environment.

It does not need permission to force-push, merge, deploy, edit repository settings, or read production secrets for ordinary coding tasks. Keep those permissions disabled unless a specific task requires them.

## 5. Start a run

A compact task is enough:

```text
Use /fstack-run. Fix the reported issue end to end. Inspect source truth first, preserve unrelated work, implement the smallest complete change, run the applicable checks, fix review findings, and deliver a task branch plus pull request. Stop only for a proven external blocker or a decision that changes the safe action.
```

Include acceptance criteria, issue links, screenshots, or failing commands when they exist. Do not restate repository facts that the agent can inspect.

## 6. Expected lifecycle

A compliant cloud run performs this loop:

```text
inspect -> isolate -> plan briefly -> implement -> test -> review -> fix -> retest -> commit -> push -> pull request -> verify checks
```

The agent may repeat implementation, testing, and review. It should not stop merely because one phase completed.

## 7. Repository instruction files

This repository includes:

- `AGENTS.md` as the canonical cross-agent contract;
- `CLAUDE.md` as a Claude Code entrypoint;
- `.github/copilot-instructions.md` as a GitHub Copilot coding-agent entrypoint;
- `skills/fstack-run/SKILL.md` as the portable continuous workflow.

When installing fstack into another repository, that repository's own instructions remain authoritative. The skill must adapt to them rather than overwrite them.

## 8. Verification and delivery

A successful run must provide observed evidence for:

- the requested behavior;
- targeted tests or checks;
- a reasonable broader regression check;
- final diff review;
- branch and commit identity;
- pull-request identity and check status.

Unavailable checks belong under `MISSING EVIDENCE`. They are not silently converted into a pass.

By default, `fstack-run` stops after a verified pull request. Merging and deployment require an explicit request and repository permission.

For this skills repository, run:

```sh
sh -n scripts/validate.sh
sh scripts/validate.sh
git diff --check
```

With GitHub CLI 2.90 or later, also validate against GitHub's current Agent Skills publishing checks:

```sh
gh skill publish --dry-run
```

The publish dry run validates the skills and reports relevant repository security settings without creating a release.

## 9. Safe automation defaults

Use these defaults for unattended cloud execution:

- task branch, never direct-to-`main`;
- no force-push;
- no destructive cleanup or reset;
- no broad `git add .` in a dirty repository;
- no secret files, credentials, or private local paths in commits;
- no dependency addition when the existing toolchain can solve the task;
- no merge or deployment merely because tests passed;
- no claim of success without observed output.

Do not add `allowed-tools: shell` or `allowed-tools: bash` merely to suppress prompts. Pre-approve terminal execution only after auditing the full skill and every referenced script.

## 10. Repository settings worth enabling

For repositories where cloud agents routinely open pull requests, enable:

- required status checks for the real test and lint workflows;
- branch protection or rulesets for `main`;
- blocked force-pushes and deletions;
- pull requests before merge;
- automatic branch deletion after merge, when appropriate;
- least-privilege tokens or GitHub App permissions;
- secret scanning and code scanning where the repository plan supports them.

These are host-level controls. Installing a skill does not configure them automatically.

## 11. Update and audit

Review upstream changes before updating a trusted automation environment.

For installations managed by GitHub CLI:

```sh
gh skill update
gh skill update --all
```

For installations managed by the cross-agent CLI:

```sh
npx skills list
npx skills update
```

Pinned GitHub CLI installations are skipped by normal updates. Reinstall them with a newly reviewed pin when you deliberately upgrade.

## 12. Troubleshooting

### The agent stops after planning

Confirm that `fstack-run` was selected rather than `fstack-plan` or the interactive `/fstack` route.

### The agent edits directly on `main`

The repository or cloud platform did not enforce task-branch behavior. Stop the run, preserve the diff, create a branch, and continue there. Add a host-level branch rule so this cannot recur.

### The agent opens a pull request without tests

The run is incomplete. Resume it with the missing verification requirement and require observed output before final review.

### The client cannot find the skill

Preview or list the repository, verify the selected agent and installation scope, and confirm that the installed folder contains `fstack-run/SKILL.md` with intact YAML frontmatter.
