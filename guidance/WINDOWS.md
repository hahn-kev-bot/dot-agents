# Windows shell (Kevin's Windows machine)

- The Bash tool is Git Bash and its cwd resets between calls: start each command with `cd /c/abs/path &&` and keep paths absolute.
- Write temp files to the session's scratchpad directory; `$TMPDIR` is unset here and `/tmp` is not the Windows temp dir.
- Change files with the Edit tool and create them with Write, in every permission mode, auto included. This covers source, docs, config, and commit messages or PR bodies (write the file, pass it with `-F`). Edit keeps each file's line endings, which are often CRLF here. Shell text replacement (sed, python one-liners, heredoc rewrites) is not a fallback: it mangles CRLF and its quoting breaks the Bash tool. PowerShell syntax belongs in PowerShell only.
- Discard output with `>/dev/null`; in Git Bash `> nul` creates a real file named `nul` that Windows tools can't delete (`rm ./nul` in Git Bash removes it).
- Stop processes with `taskkill //PID <pid> //F` (`pkill` is absent). Search with `rg`.
- `pnpm` "not recognized" means the launcher dropped the User PATH: prefix the command with `PATH="$(cygpath "$PNPM_HOME")/bin:$PATH"` (the raw Windows path breaks on the `C:` colon).
