# Worktree lock

When checkout fails with the branch already checked out elsewhere
(e.g. `fatal: 'branch' is already checked out at '/path/to/worktree'`):

1. Stop. Do not stash, force-checkout, add a worktree, or continue the walkthrough.
2. Run `git worktree list` and name the blocking path.
3. Tell the user the branch is locked there; they must free it before retrying.
4. Optionally offer:

```bash
git -C <worktree-path> checkout --detach
```

Detaching frees the branch when they do not need to keep working on it in that
worktree.
