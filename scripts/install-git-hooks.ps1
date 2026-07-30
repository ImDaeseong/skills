# Installs this repo's local git hooks. Not run automatically (hooks in .git/hooks/
# are never tracked by git), so run this once after cloning.

$ErrorActionPreference = "Stop"

# Marker identifying a hook installed by this script, so a re-run can safely overwrite
# its own prior install without destroying an unrelated hook a user wrote by hand.
$marker = "# installed-by: skills/scripts/install-git-hooks.ps1"

# `git rev-parse --git-path hooks/pre-commit` (not a hardcoded ".git/hooks/pre-commit")
# resolves the real hook location per Git's own rules: a linked worktree's `.git` is a
# file, not a directory, pointing at a shared gitdir elsewhere, and `core.hooksPath` can
# redirect hooks entirely. A hardcoded path silently installs into the wrong place (or a
# nonexistent one) in either case.
$hookPath = git rev-parse --git-path hooks/pre-commit
if ($LASTEXITCODE -ne 0 -or -not $hookPath) {
    throw "Could not resolve the pre-commit hook path via 'git rev-parse --git-path hooks/pre-commit'."
}

if (Test-Path -LiteralPath $hookPath) {
    $existing = Get-Content -LiteralPath $hookPath -Raw
    if ($existing -notlike "*$marker*") {
        throw "An existing pre-commit hook at '$hookPath' was not installed by this script and would be destroyed by continuing. Back it up or merge its contents manually, then re-run this script."
    }
}

$hookContent = @"
#!/bin/sh
$marker
# Regression guard: block commits that reintroduce future-dated evidence labels,
# broken CORE-LAWS references, unrouted skills, or permission mismatches
# (see scripts/validate_workspace.ps1 -- caught 47 future-dated "checked" labels once already).
powershell.exe -NoProfile -File scripts/validate_workspace.ps1
if [ `$? -ne 0 ]; then
    echo ""
    echo "pre-commit: workspace validation failed (see above). Fix the flagged entries before committing."
    exit 1
fi

powershell.exe -NoProfile -File scripts/validate_links.ps1
if [ `$? -ne 0 ]; then
    echo ""
    echo "pre-commit: link validation failed (see above). Fix the flagged links before committing."
    exit 1
fi
"@

# -Encoding utf8 (Windows PowerShell 5.1) writes a UTF-8 BOM by default. A BOM before the
# "#!/bin/sh" shebang breaks it -- git then fails with a misleading "cannot spawn ... No such
# file or directory" that looks like a missing-executable-bit problem but isn't. Use ascii (the
# hook content is pure ASCII) to guarantee no BOM.
Set-Content -Path $hookPath -Value $hookContent -Encoding ascii -NoNewline

# Validate through Git itself. Looking up bash.exe can select Windows' WSL app alias instead
# of Git for Windows' bundled shell and falsely report success without a usable hook.
git hook run pre-commit
if ($LASTEXITCODE -ne 0) {
    throw "Installed pre-commit hook failed its validation run."
}

Write-Host "Installed pre-commit hook at $hookPath"
Write-Host "Verify: powershell.exe -NoProfile -File scripts/validate_workspace.ps1"
