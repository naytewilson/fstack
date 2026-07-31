---
name: fstack
description: The fstack front door. Invoke /fstack alone to list every interactive and continuous skill, or with a task to route it. Routes cloud-agent, autonomous, unattended, end-to-end, and finish-the-task requests to fstack-run.
---

# /fstack

The front door for fstack. Read what the user wants. Pick one skill and run it. Do not chain separate skills.

## Steps

1. Read the user's request.
2. **If there is no task** — the user typed `/fstack` alone or only asked what fstack can do — list the thirteen skills below with a one-line description each. Then stop and ask what they want to do.
3. **If there is a task** — match it to one of the thirteen skills below.
4. Say which skill you picked and why, in one sentence.
5. Run that skill. `fstack-run` owns its complete end-to-end loop; all other skills retain their own stopping rules.

## The skills

| Skill | What it does |
|---|---|
| `/fstack-run` | Completes a repository task continuously from inspection through verified pull request. |
| `/fstack-roast` | Stress-tests a product idea. Ends with a verdict and the smallest version worth building. |
| `/fstack-interview` | Asks about the product — demand, customer, pricing, risks — and records the answers in AGENTS.md. |
| `/fstack-nail` | Clarifies a vague task, nails down a 3-line summary, and gets your yes before planning. |
| `/fstack-plan` | Writes a one-page plan with a mandatory "what we're NOT doing" section. |
| `/fstack-build` | Implements the plan one small step at a time, asking at real choices. |
| `/fstack-simplify` | Audits unnecessary complexity and proposes deletions — one file or the whole codebase. |
| `/fstack-design` | Makes UI match the project's existing styles and cleans up design slop. |
| `/fstack-counselors` | Asks three capable models the same question and synthesizes one verdict. |
| `/fstack-check` | Reviews finished work: does it work, does it match the plan, is it simple. |
| `/fstack-document` | Writes or updates project documentation from ELI5 to deep. |
| `/fstack-learn` | Captures one lesson in three lines so future sessions start smarter. |
| `/fstack-push` | Commits the current task's changes and pushes them. It does not test or deploy. |

## Routing map

| Situation | Skill |
|---|---|
| Cloud agent, autonomous, unattended, end-to-end, or "keep going until done" | `/fstack-run` |
| Product idea, not sure it is worth building | `/fstack-roast` |
| New project, agent lacks business context | `/fstack-interview` |
| Vague or unclear task, user wants an approval gate | `/fstack-nail` |
| Idea is clear, no plan exists, user wants planning only | `/fstack-plan` |
| Approved plan exists, user wants implementation only | `/fstack-build` |
| Feels bloated or sloppy | `/fstack-simplify` |
| UI looks off or inconsistent | `/fstack-design` |
| Big decision, one opinion is not enough | `/fstack-counselors` |
| Work is done and needs a report-only review | `/fstack-check` |
| Project needs docs or docs are stale | `/fstack-document` |
| A non-obvious lesson is worth preserving | `/fstack-learn` |
| User explicitly wants only commit and push | `/fstack-push` |

## Ambiguity

If you truly cannot tell which skill fits, ask one clarifying question. If ambiguity remains, route to `/fstack-nail` for interactive work or `/fstack-run` when the user clearly requested continuous execution.

## Must NOT

- Route when there is no task. List the skills instead.
- Chain separate skills in the front door.
- Ask more than one routing question.
- Route a continuous cloud request into the stop-and-wait loop.
- Route a request for review-only or push-only into autonomous code changes.

## Examples

> User: `/fstack`
>
> Agent: *(lists the thirteen skills)* "What do you want to do?"

> User: `/fstack fix issue 42 and keep going until the PR is verified`
>
> Agent: "This is end-to-end repository work, so I am using `/fstack-run`." *(runs fstack-run continuously)*

> User: `/fstack write a plan for dark mode but do not implement it`
>
> Agent: "This is planning-only work, so I am using `/fstack-plan`." *(runs fstack-plan)*
