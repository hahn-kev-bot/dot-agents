# dot-agents

Kevin's agent setup in one repo: global agent guidance (`AGENTS.md` + `guidance/`), skills, and Claude Code subagents. It is meant to live at `~/.agents` and serve every place an agent runs:

| Where | How it reads this repo |
|---|---|
| Claude Code on this machine | `~/.claude/CLAUDE.md` imports `@~/.agents/AGENTS.md`; `~/.claude/skills/*` and `~/.claude/agents` link here |
| Other agents that read `~/.agents/skills` (the `skills` CLI's shared "universal" location) | read `~/.agents/skills` directly; the CLI links it into agent-specific folders such as `~/.kiro/skills` |
| Claude Code cloud sessions (claude.ai/code) | the environment setup script clones this repo and links it in (see [Cloud](#cloud)) |

## Layout

```text
~/.agents/
├── AGENTS.md            # global guidance, pointers only
├── guidance/            # PR, CI, web and Windows-shell rules AGENTS.md points at
├── skills/              # one folder per skill (SKILL.md + resources)
├── agents/              # Claude Code subagents (<name>.md)
├── .skill-lock.json     # where each upstream skill came from (managed by the `skills` CLI)
├── settings/            # skill-overrides.json, merged into ~/.claude/settings.json by the setup scripts
├── cloud/setup.sh       # cloud (and macOS/Linux) setup script
├── setup.ps1            # Windows setup script
└── licenses/            # upstream licenses for the skills copied in here
```

## Why not plugins?

Claude Code cloud sessions don't load anything from your machine's `~/.claude`, and they don't install plugins, even ones a repository enables. Skills that only exist as plugins never reach the cloud. Keeping plain skill folders here means one copy works locally, for other agents, and in the cloud.

## Local setup (Windows)

Run in PowerShell (Windows PowerShell 5.1 or PowerShell 7):

```powershell
irm https://raw.githubusercontent.com/hahn-kev-bot/dot-agents/main/setup.ps1 | iex
```

Or, from an existing clone, `~\.agents\setup.ps1`. It does the same as the cloud script: clones or pulls `~/.agents`, junctions `~/.claude/skills` and `~/.claude/agents` to it, imports `AGENTS.md`, and merges the [skill overrides](#skill-overrides). Re-run it to update.

If `~/.claude/skills` is a real folder, the script moves it to `skills.pre-dot-agents`, unless it holds links into `~/.agents`. That means the `skills` CLI manages per-skill links there (`npx skills add ... -g -a claude-code codex` puts the skill here and links it into `~/.claude/skills`), which is how the original machine is set up, so the script leaves it alone.

On macOS or Linux, run `cloud/setup.sh` with `DOT_AGENTS_REPO` unset; it does the same thing.

## Cloud

Cloud sessions run on Ubuntu and start from a clean home directory. In claude.ai/code, open the environment's settings and set its setup script to:

```bash
curl -fsSL https://raw.githubusercontent.com/hahn-kev-bot/dot-agents/main/cloud/setup.sh | bash
```

The setup script belongs to the environment, not to a repository, so every repo you open in that environment gets the same skills, agents and guidance. The script:

1. Clones this repo to `~/.agents` (or pulls if it is already there).
2. Links `~/.claude/skills` and `~/.claude/agents` to it, moving any existing folder to `*.pre-dot-agents`.
3. Adds `@~/.agents/AGENTS.md` to `~/.claude/CLAUDE.md`.
4. Merges the [skill overrides](#skill-overrides) into `~/.claude/settings.json` (needs `jq` or `python3`).

The environment's network access must allow GitHub (the default "Trusted" level does). To check it worked, start a session and run `/skills` or ask which skills are available.

Set `DOT_AGENTS_REPO` to use a fork.

## Skill overrides

Claude Code gives the list of skill descriptions about 1% of the context window. With this many skills the descriptions don't all fit, and the ones past the cutoff are listed by name only, wherever they fall alphabetically. `settings/skill-overrides.json` sets skills to `name-only` (listed without a description) when their name says when to use them, so the rest keep their descriptions. Skills whose siblings overlap, such as the test-quality and build-performance families, keep their descriptions so Claude can pick the right one.

The setup scripts merge the file into `~/.claude/settings.json`, but **an override the machine already has always wins**. A machine can hide skills that can't run there with `"user-invocable-only"` (still available as `/name`), without changing this repo. For example, a Linux box can hide the MAUI and crash-symbolication skills. Because a machine's existing entry wins, a later change to a skill already in its settings doesn't reach it; edit that machine's settings by hand.

Overrides live in settings, not in SKILL.md frontmatter, so `npx skills update` doesn't undo them.

## Updating

- **Upstream skills:** `npx skills update -g`, review the diff, commit.
- **Adding a skill:** `npx skills add <owner/repo> -g -a claude-code codex -y -s <name>`. Naming `codex` (a universal agent) makes the CLI store the skill here and link it, instead of copying it into `~/.claude/skills`. Confirm the upstream license allows redistribution before committing it, and add the license to `licenses/`.
- **Your own skill:** create `skills/<name>/SKILL.md` and commit.
- **Manual-only skills:** add `disable-model-invocation: true` to the frontmatter of your own skills. The skill keeps working as `/name` but stops costing context in every session. For upstream skills, use the `skillOverrides` setting instead, because `skills update` overwrites frontmatter edits.
- **Agents** in `agents/` are copied from the `dotnet-test`, `dotnet-diag` and `dotnet-test-migration` plugins in [dotnet/skills](https://github.com/dotnet/skills) (plugin commit `aa3c4abca59a`). The `skills` CLI doesn't track agents, so refresh them by copying the plugin's `agents/*.agent.md` files here, dropping the `.agent` suffix.

## Local-only skills

Some skills on the original machine are excluded by `.gitignore`, so they don't reach the cloud:

- `arena`, `deslop`, `unslop`, `poteto-mode` come from [cursor/plugins](https://github.com/cursor/plugins), which has no license.
- `android-cli` and `devin-review` have no confirmed license or source yet.

## Licenses

Skills copied from upstream keep their original licenses; see `licenses/` and `.skill-lock.json` for each skill's source.

| Source | License | Skills |
|---|---|---|
| [dotnet/skills](https://github.com/dotnet/skills) | MIT | .NET, MAUI, Blazor, ASP.NET Core, diagnostics and testing skills, plus the agents |
| [mattpocock/skills](https://github.com/mattpocock/skills) | MIT | engineering workflow skills (tdd, grilling, wayfinder, retro, ...) |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | MIT | find-skills |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | MIT | dotnet-upgrade |
| [warpdotdev/common-skills](https://github.com/warpdotdev/common-skills) | MIT | pr-walkthrough |
| [stablyai/orca](https://github.com/stablyai/orca) | MIT | orchestration |
