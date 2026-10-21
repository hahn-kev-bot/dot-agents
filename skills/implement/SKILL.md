---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly and single test files regularly. At the end, run the repo's own verify command (its AGENTS.md names it; follow its rules on which suites to run locally). Run the full suite only where the repo says nothing.

Once done, call the Skill tool with "code-review" to review the work.

Commit your work to the current branch.
