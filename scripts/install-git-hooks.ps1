# Installs this repo's local git hooks. Not run automatically (hooks in .git/hooks/
# are never tracked by git), so run this once after cloning.

$ErrorActionPreference = "Stop"
$repoRoot = git rev-parse --show-toplevel
$hookPath = Join-Path $repoRoot ".git/hooks/pre-commit"

$hookContent = @'
#!/bin/sh
# Regression guard: block commits that reintroduce future-dated evidence labels,
# broken CORE-LAWS references, unrouted skills, or permission mismatches
# (see scripts/validate_workspace.ps1 -- caught 47 future-dated "checked" labels once already).
powershell.exe -NoProfile -File scripts/validate_workspace.ps1
if [ $? -ne 0 ]; then
    echo ""
    echo "pre-commit: workspace validation failed (see above). Fix the flagged entries before committing."
    exit 1
fi
'@

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
