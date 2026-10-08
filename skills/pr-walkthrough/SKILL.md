---
name: pr-walkthrough
description: Walkthrough of a PR or local diff in priority order, with snippets and file links.
disable-model-invocation: true
---

# PR Walkthrough

A **walkthrough** explains what changed and the order to read it. Describe
intent and structure; the reader judges quality.

## Steps

### 1. Resolve the diff

Pick the branch that matches the ask:

| Ask | Gather with |
| --- | --- |
| PR URL or number | `gh pr view <n> --json title,body,url,baseRefName,headRefName,files` and `gh pr diff <n>` |
| Current branch vs base | `git log <base>..HEAD --oneline` and `git diff <base>...HEAD` |
| Uncommitted only | `git diff` and `git diff --cached` |

Base defaults to the repo default branch, or the PR's `baseRefName`. Prefer
`gh` over checkout when the walkthrough does not need a local branch.

If checkout is required and Git reports the branch is already checked out in
another worktree, follow [worktree-lock.md](worktree-lock.md) and stop.

**Done when:** PR title/body (or inferred intent) and the complete changed-file
list are in hand.

### 2. Name the core change

Write one sentence: the single thing this change fundamentally does.

Source order: PR title and body → commit messages → central diff hunks. If the
description is missing or vague, say so and state the inference.

**Done when:** that sentence is written and will lead the walkthrough.

### 3. Tier every file

Assign each changed file to exactly one tier in [tiers.md](tiers.md). Order
sections high → low; within a section, most central file first.

**Done when:** every changed file sits in exactly one tier; empty tiers will be
omitted from the output.

### 4. Write the walkthrough

Emit the structure below. For each non-empty tier: one-line section summary,
then per file (or tiny-file cluster) — plain-language what changed, one
illustrative snippet (~5–20 lines of the new behavior or key signature), and a
file link ([link formats](links.md)).

````markdown
# [PR title or branch summary]

**Core change:** [one sentence]

[PR description in 2–4 sentences, or "No PR description — inferred from commits."]

**Scope:** [N files, +X/−Y] · [PR link or branch vs base]

---

## 1. Core change
[section summary]

### [filename](link)
[explanation]

```start:end:path
[snippet]
```

---

## 2. …
[only non-empty tiers, in priority order]

---

## Suggested reading order
1. [file or section] — start here
…
N. [file or section] — skim last
````

**Done when:** every changed file appears once under its tier with explanation,
snippet, and link; suggested reading order runs high → low priority.
