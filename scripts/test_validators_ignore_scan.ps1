# Run in a disposable copy so existing runtime clones/caches are never modified.
$ErrorActionPreference = 'Stop'
$sourceRoot = Split-Path -Parent $PSScriptRoot
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('skills-regression-' + [guid]::NewGuid().ToString('N'))
$ignoredDirs = @(Get-Content -LiteralPath (Join-Path $sourceRoot '.gitignore') |
    Where-Object { $_ -match '^\S+/$' } | ForEach-Object { $_.TrimEnd('/') })
$blockedDirs = @()
$checks = 0

function Assert-Validator {
    param([string]$Script, [bool]$ShouldPass, [string]$Signal)
    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell.exe -NoProfile -File (Join-Path $fixture "scripts/$Script") 2>&1
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $savedPreference }
    $text = ($output | ForEach-Object { $_.ToString() }) -join "`n"
    if ($ShouldPass) {
        if ($code -ne 0 -or $text -notmatch '(?m)^PASS' -or $text -match 'UnauthorizedAccess|PermissionDenied') {
            throw "$Script failed positive control (exit $code): $text"
        }
    } elseif ($code -eq 0 -or $text -match '(?m)^PASS' -or $text -notmatch [regex]::Escape($Signal)) {
        throw "$Script missed negative control '$Signal' (exit $code): $text"
    }
    $script:checks++
}

try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    foreach ($item in Get-ChildItem -LiteralPath $sourceRoot -Force) {
        if ($item.Name -eq '.git' -or ($item.PSIsContainer -and $item.Name -in $ignoredDirs)) { continue }
        Copy-Item -LiteralPath $item.FullName -Destination $fixture -Recurse -Force
    }
    foreach ($name in @('marketingskills', '.pytest_cache')) {
        if ($name -notin $ignoredDirs) { throw "missing ignored regression directory: $name" }
        $blocked = Join-Path $fixture "$name/blocked"
        New-Item -ItemType Directory -Path $blocked -Force | Out-Null
        $blockedDirs += $blocked
        Set-Content -LiteralPath (Join-Path $blocked 'SKILL.md') -Value '[broken](missing.md)' -Encoding utf8
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls.exe $blocked /deny "${identity}:(RX)" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "could not establish denied-read fixture: $name" }
        $denied = $false
        try { Get-ChildItem -LiteralPath $blocked -ErrorAction Stop | Out-Null }
        catch [System.UnauthorizedAccessException] { $denied = $true }
        if (-not $denied) { throw "fixture is still readable: $name" }
    }
    Assert-Validator 'validate_workspace.ps1' $true ''
    Assert-Validator 'validate_links.ps1' $true ''

    $probe = Join-Path $fixture 'regression-link.md'
    Set-Content -LiteralPath $probe -Value '[`missing`](missing-target.md)' -Encoding utf8
    Assert-Validator 'validate_links.ps1' $false 'missing-target.md'
    Set-Content -LiteralPath $probe -Value @'
[`valid`](README.md)
`[literal](missing-target.md)`
```text
[example](missing-target.md)
```
'@ -Encoding utf8
    Assert-Validator 'validate_links.ps1' $true ''
    Remove-Item -LiteralPath $probe

    foreach ($case in @(
        @('USAGE.md', 'Planning, manufacturing, and literal ERP/SCM/CRM software-system integration', 'Planning, manufacturing, sales, and financial operations', 'still defers'),
        @('biz-ops/SKILL.md', 'founder-finance', 'deferred-finance', 'biz-ops must route'),
        @('founder-finance/SKILL.md', 'CHARLIE_DIR=~/Desktop/skills/charlie-cfo-skill', '', 'missing post-clone'),
        @('footage-editor/SKILL.md', 'VIDEOUSE_DIR=~/Desktop/skills/video-use', '', 'missing post-clone'),
        @('footage-editor/SKILL.md', 'never paste the key into chat', 'ask them to paste one', 'keep API keys out'),
        @('founder-finance/SKILL.md', 'Static instructions can still carry prompt injection;', 'No hidden trigger-and-payload possible;', 'static-text safety overclaim'),
        @('sales-desk/SKILL.md', 'SALES_SKILL_MD="$HOME/.claude/skills/sales/SKILL.md"', 'SALES_SKILL_MD=""', 'exact installed entrypoint'),
        @('diagram-forge/SKILL.md', 'rerun the resolver above to set ARCHIFY_DIR before Step 2', '', 'resolve its directory after installation'),
        @('footage-editor/SKILL.md', 'those boundaries retain precedence', 'its instructions take precedence over anything summarized here', 'must preserve host')
    )) {
        $path = Join-Path $fixture $case[0]
        $original = [IO.File]::ReadAllText($path)
        if (-not $original.Contains($case[1])) { throw "negative control input missing: $($case[0])" }
        try {
            [IO.File]::WriteAllText($path, $original.Replace($case[1], $case[2]))
            Assert-Validator 'validate_workspace.ps1' $false $case[3]
        } finally { [IO.File]::WriteAllText($path, $original) }
    }
    Write-Output "PASS: $checks controls; validators skip inaccessible runtime/cache directories and detect link/adoption/initialization/safety regressions."
} finally {
    # Only delete our GUID-named fixture under the resolved temporary directory.
    $resolved = [IO.Path]::GetFullPath($fixture)
    $tempPrefix = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if (-not $resolved.StartsWith($tempPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolved) -notmatch '^skills-regression-[a-f0-9]{32}$') {
        throw "unsafe fixture cleanup path: $resolved"
    }
    foreach ($blocked in $blockedDirs) {
        & icacls.exe $blocked /reset /T /C | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "could not restore fixture ACL: $blocked" }
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
