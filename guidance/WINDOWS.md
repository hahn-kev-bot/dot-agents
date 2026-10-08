# Windows shell (Kevin's Windows machine)

- The Bash tool is Git Bash and its cwd resets between calls: start each command with `cd /c/abs/path &&` and keep paths absolute.
- Write temp files to the session's scratchpad directory; `$TMPDIR` is unset here and `/tmp` is not the Windows temp dir.
- Write source files and commit or PR bodies with the Write/Edit tools; in Bash use quoted `<<'EOF'` heredocs. PowerShell syntax belongs in PowerShell only.
- Discard output with `>/dev/null`; in Git Bash `> nul` creates a real file named `nul` that Windows tools can't delete (`rm ./nul` in Git Bash removes it).
- Stop processes with `taskkill //PID <pid> //F` (`pkill` is absent). Search with `rg`.
- Files are often CRLF: check with `file <path>` before a sed or python text replacement.
- `pnpm` "not recognized" means the launcher dropped the User PATH: prefix the command with `PATH="$(cygpath "$PNPM_HOME")/bin:$PATH"` (the raw Windows path breaks on the `C:` colon).
