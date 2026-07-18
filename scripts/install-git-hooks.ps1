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

# Git for Windows spawns hooks via its bundled sh, which refuses to run a script without the
# POSIX executable bit -- Set-Content alone does not set it. bash.exe (shipped with Git for
# Windows) is the reliable way to set it from PowerShell.
$bash = Get-Command bash.exe -ErrorAction SilentlyContinue
if (-not $bash) {
    Write-Warning "bash.exe not found on PATH -- could not set the executable bit. Run 'chmod +x .git/hooks/pre-commit' manually (e.g. from Git Bash)."
} else {
    & $bash.Source -c "chmod +x '$($hookPath -replace '\\','/')'"
}

Write-Host "Installed pre-commit hook at $hookPath"
Write-Host "Verify: powershell.exe -NoProfile -File scripts/validate_workspace.ps1"
