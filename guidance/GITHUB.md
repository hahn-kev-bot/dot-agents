# GitHub access from agent sessions

`gh` runs as the bot account `hahn-kev-bot` (`gh api user --jq .login`). Git pushes go through Git Credential Manager as Kevin, not through `gh`. For anything marked "no", hand Kevin the exact command or the branch and PR body instead of retrying.

| Operation | Bot | Notes |
|---|---|---|
| Read runs, logs, artifacts, PRs, issues | yes | |
| Push a branch, open a PR, comment, review, reply on threads | yes | push goes as Kevin via GCM; a 403 push means the bot identity leaked in, so stop and ask |
| Edit a PR body or title it did not author (`gh pr edit`, `UpdatePullRequest`) | no | give Kevin the new body as a file |
| Enable auto-merge (`EnablePullRequestAutoMerge`, the app's auto-merge tool) | no | "merge once CI is green" means Kevin approves and merges; say so |
| Merge a PR | no | review required anyway |
| Close, edit or label issues (`CloseIssue`, `UpdateIssue`, `AddLabelsToLabelable`) | no | draft the comment, Kevin closes |
| `gh workflow run`, `gh run rerun` | no | 403 |
| GHCR packages API | no | no `read:packages` scope |
| PRs on sillsdev repos the bot isn't a collaborator on (e.g. chorus) | no | "must be a collaborator"; give Kevin the branch and PR body |

A repo may add rows in its own `AGENTS.md` or `AGENTS.local.md`.
