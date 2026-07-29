# Regression test for the bug fixed in commit c4978aa: validate_workspace.ps1 and
# validate_links.ps1 used to recurse into ignored top-level dirs (e.g. last30days/) and filter
# afterward, so an inaccessible nested path there raised a non-terminating PermissionDenied that
# validate_workspace.ps1 silently swallowed while still printing PASS. This reproduces that
# scenario against the real scripts and asserts both still PASS instead of erroring or hanging.
$root = Split-Path -Parent $PSScriptRoot
$testDir = Join-Path $root 'marketingskills'
$blockedDir = Join-Path $testDir 'blocked'

if (Test-Path -LiteralPath $testDir) {
    throw "regression test aborted: $testDir already exists on disk - refusing to touch it"
}

$user = "$env:USERDOMAIN\$env:USERNAME"

try {
    New-Item -ItemType Directory -Path $blockedDir -Force -ErrorAction Stop | Out-Null
    Set-Content -LiteralPath (Join-Path $blockedDir 'file.md') -Value '# blocked' -Encoding utf8 -ErrorAction Stop
    icacls $blockedDir /deny "${user}:(RX)" /T /C 2>&1 | Out-Null

    # Merge stderr into the captured stream: the actual regression signal is that the old code
    # entered the ignored dir and emitted an Access-Denied error even though it still exited 0
    # with PASS - a bare exit-code/PASS-text check alone can't tell old and new behavior apart.
    $workspaceAll = & powershell -NoProfile -File (Join-Path $root 'scripts\validate_workspace.ps1') 2>&1
    $workspaceExit = $LASTEXITCODE
    $workspaceText = ($workspaceAll | ForEach-Object { $_.ToString() }) -join "`n"
    $linksAll = & powershell -NoProfile -File (Join-Path $root 'scripts\validate_links.ps1') 2>&1
    $linksExit = $LASTEXITCODE
    $linksText = ($linksAll | ForEach-Object { $_.ToString() }) -join "`n"

    $failures = [System.Collections.Generic.List[string]]::new()
    if ($workspaceExit -ne 0 -or $workspaceText -notmatch '(?m)^PASS') {
        $failures.Add("validate_workspace.ps1 did not PASS with an inaccessible file under an ignored dir (exit $workspaceExit):`n$workspaceText")
    }
    if ($workspaceText -match 'Access is denied|UnauthorizedAccess|PermissionDenied') {
        $failures.Add("validate_workspace.ps1 entered the ignored dir and hit the blocked item (should have skipped it entirely):`n$workspaceText")
    }
    if ($linksExit -ne 0 -or $linksText -notmatch '(?m)^PASS') {
        $failures.Add("validate_links.ps1 did not PASS with an inaccessible file under an ignored dir (exit $linksExit):`n$linksText")
    }
    if ($linksText -match 'Access is denied|UnauthorizedAccess|PermissionDenied') {
        $failures.Add("validate_links.ps1 entered the ignored dir and hit the blocked item (should have skipped it entirely):`n$linksText")
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ }
        exit 1
    }
    Write-Output 'PASS: validators skip inaccessible items under ignored top-level dirs.'
} finally {
    if (Test-Path -LiteralPath $blockedDir) {
        icacls $blockedDir /reset /T /C 2>&1 | Out-Null
    }
    Remove-Item -LiteralPath $testDir -Recurse -Force -ErrorAction SilentlyContinue
}
