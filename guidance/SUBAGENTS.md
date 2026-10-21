Read the [writing-for-agents skill](../skills/writing-for-agents/SKILL.md) first. Its completion criteria, leading words and positive framing apply to subagent definitions and prompts alike.

## Briefing a subagent
A subagent starts cold: it sees only its prompt. State:
- the goal, and why it matters
- what's already known or ruled out
- the scope: which files or repos, and where to stop
- what to return, and in what shape

## Long-running work
Put in every brief that runs builds or tests: start long commands with `run_in_background` and wait with Monitor (an until-loop) in the same turn; stay in the turn until the work is verified, then report back. `sleep` is blocked.

When a notification says a subagent "has not reported yet", it is still working: carry on with your own work and write the user nothing about it.
