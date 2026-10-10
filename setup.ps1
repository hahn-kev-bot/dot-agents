<#
.SYNOPSIS
  Windows setup for dot-agents, the PowerShell counterpart of cloud/setup.sh.

.DESCRIPTION
  Clones this repo into ~/.agents (or pulls if it's already there), links
  ~/.claude/skills and ~/.claude/agents to it, imports AGENTS.md from
  ~/.claude/CLAUDE.md, and merges settings/skill-overrides.json into
  ~/.claude/settings.json. Overrides the machine already has are kept, so each
  machine can hide or change skills for itself.

  Idempotent: re-run it any time to update. Works in Windows PowerShell 5.1 and
  PowerShell 7. Set $env:DOT_AGENTS_REPO to clone a fork.

.EXAMPLE
  irm https://raw.githubusercontent.com/hahn-kev-bot/dot-agents/main/setup.ps1 | iex

.EXAMPLE
  ~\.agents\setup.ps1
#>
$ErrorActionPreference = 'Stop'

$repo = if ($env:DOT_AGENTS_REPO) { $env:DOT_AGENTS_REPO } else { 'https://github.com/hahn-kev-bot/dot-agents.git' }
$dest = Join-Path $HOME '.agents'
$claude = Join-Path $HOME '.claude'
# $IsWindows doesn't exist in Windows PowerShell 5.1, which only runs on Windows.
$onWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows

function Get-FullPath([string]$Path) {
    [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

# 1. Clone or update the repo.
if (Test-Path (Join-Path $dest '.git')) {
    git -C $dest pull --ff-only --quiet
} elseif (Test-Path $dest) {
    throw "$dest exists but isn't a git clone. Move it aside, then run this again."
} else {
    git clone --quiet $repo $dest
}
if ($LASTEXITCODE) { throw "git failed with exit code $LASTEXITCODE" }

# 2. Link ~/.claude/skills and ~/.claude/agents to the repo.
New-Item -ItemType Directory -Force -Path $claude | Out-Null
foreach ($dir in 'skills', 'agents') {
    $target = Join-Path $dest $dir
    $link = Join-Path $claude $dir
    $item = Get-Item $link -Force -ErrorAction SilentlyContinue

    if ($item -and $item.LinkType) {
        if ((Get-FullPath @($item.Target)[0]) -eq (Get-FullPath $target)) { continue }
        $item.Delete()  # A link pointing somewhere else. Removes the link, not its target.
    } elseif ($item) {
        # A real folder. If it holds links into ~/.agents, the `skills` CLI manages it
        # with per-skill links (the original machine's setup), which already works.
        $managed = Get-ChildItem $link -Force |
            Where-Object { $_.LinkType -and (Get-FullPath @($_.Target)[0]).StartsWith((Get-FullPath $dest)) }
        if ($managed) {
            Write-Host "dot-agents: keeping $link (per-skill links managed by the skills CLI)"
            continue
        }
        Move-Item $link "$link.pre-dot-agents"
    }

    if ($onWindows) {
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    }
}

# 3. Import the global guidance.
$claudeMd = Join-Path $claude 'CLAUDE.md'
$importLine = '@~/.agents/AGENTS.md'
if (-not ((Test-Path $claudeMd) -and ((Get-Content $claudeMd) -contains $importLine))) {
    Add-Content -Path $claudeMd -Value $importLine
}

# 4. Merge the shared skill overrides. Existing entries win. Settings, unlike
#    SKILL.md frontmatter, survive `npx skills update`.
$sharedPath = Join-Path $dest 'settings/skill-overrides.json'
$settingsPath = Join-Path $claude 'settings.json'
$added = 0
if (Test-Path $sharedPath) {
    $shared = (Get-Content $sharedPath -Raw | ConvertFrom-Json).skillOverrides
    if ((Test-Path $settingsPath) -and (Get-Item $settingsPath).Length -gt 0) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    } else {
        $settings = New-Object PSObject
    }
    if (-not $settings.PSObject.Properties['skillOverrides']) {
        $settings | Add-Member -NotePropertyName skillOverrides -NotePropertyValue (New-Object PSObject)
    }
    foreach ($p in $shared.PSObject.Properties) {
        if (-not $settings.skillOverrides.PSObject.Properties[$p.Name]) {
            $settings.skillOverrides | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value
            $added++
        }
    }
    if ($added) {
        # UTF-8 without a BOM; Windows PowerShell's Set-Content -Encoding UTF8 would add one.
        $json = ($settings | ConvertTo-Json -Depth 32) + "`n"
        [IO.File]::WriteAllText($settingsPath, $json, (New-Object Text.UTF8Encoding $false))
    }
}

$skills = @(Get-ChildItem (Join-Path $dest 'skills') -Directory).Count
$agents = @(Get-ChildItem (Join-Path $dest 'agents') -File).Count
Write-Host "dot-agents: $skills skills, $agents agents linked into $claude; $added skill override(s) added"
