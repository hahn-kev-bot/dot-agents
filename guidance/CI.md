when adding a new github action ensure you use the latest version of that action.
use [actionlint](https://github.com/rhysd/actionlint) already installed to verify before pushing

## Watching CI
- First check `gh pr view <n> --json mergeable,statusCheckRollup`: a `CONFLICTING` PR schedules no checks, so resolve the conflict before waiting.
- Wait with one `gh run watch <run-id> --exit-status` in the background, which fires once on completion. Sleep loops hit the 10-minute Bash timeout and periodic wakeups burn turns.

## Reading CI logs
- Use the repo's CI log script when it has one (LexBox: `.github/scripts/ci-logs.sh <run-id>`).
- Otherwise fetch `gh api repos/<owner>/<repo>/actions/jobs/<job-id>/logs --allow-escape-sequences`, strip ANSI with `sed 's/\x1b\[[0-9;]*m//g'`, save it to the scratchpad, and grep it. This works while the run is in progress; `gh run view --log-failed` does not.
- A `startup_failure` run has no logs: the workflow YAML is invalid, so run actionlint on it.
