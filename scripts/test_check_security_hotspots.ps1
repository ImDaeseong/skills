# Regression test for check_security_hotspots.ps1's pattern rules and
# qa:allow suppression. Dot-sources the guard (its top-level scan is guarded
# by $MyInvocation.InvocationName -ne '.') to call Get-SecurityHotspotFindings
# directly against a disposable temp git repo, rather than duplicating its
# pattern list by hand.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$guardPath = Join-Path $repoRoot 'scripts/check_security_hotspots.ps1'
. $guardPath

$failures = [System.Collections.Generic.List[string]]::new()

function Test-Case {
    param(
        [string]$Name,
        [string]$FileName,
        [string]$Content,
        [bool]$ExpectFinding
    )
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hotspot-test-" + [guid]::NewGuid())
    try {
        New-Item -ItemType Directory -Path $tempRoot | Out-Null
        & git -C $tempRoot init --quiet
        Set-Content -LiteralPath (Join-Path $tempRoot $FileName) -Value $Content -Encoding utf8
        & git -C $tempRoot add -A
        & git -C $tempRoot -c user.email=t@t -c user.name=t commit --quiet -m init

        $findings = Get-SecurityHotspotFindings -Root $tempRoot
        $gotFinding = $findings.Count -gt 0
        if ($gotFinding -ne $ExpectFinding) {
            $script:failures.Add("${Name}: expected finding=$ExpectFinding, got=$gotFinding ($($findings -join '; '))")
        }
    } finally {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Test-Case -Name 'hardcoded credential detected' -FileName 'app.ps1' `
    -Content '$ApiKey = "zz9f8a7b6c5d4e3f2a1b0c"' -ExpectFinding $true

Test-Case -Name 'placeholder credential not flagged' -FileName 'app.ps1' `
    -Content '$ApiKey = "your_key_here"' -ExpectFinding $false

Test-Case -Name 'Invoke-Expression detected' -FileName 'run.ps1' `
    -Content 'Invoke-Expression $userInput' -ExpectFinding $true

Test-Case -Name 'qa:allow suppresses Invoke-Expression finding' -FileName 'run.ps1' `
    -Content 'Invoke-Expression $cmd  # qa:allow CWE-78 - cmd is a fixed constant' -ExpectFinding $false

Test-Case -Name 'TLS verification bypass detected' -FileName 'client.ps1' `
    -Content 'Invoke-RestMethod -Uri $url -SkipCertificateCheck' -ExpectFinding $true

Test-Case -Name 'cleartext external http detected' -FileName 'client.ps1' `
    -Content '$BaseUrl = "http://api.example.org.kr/v1"' -ExpectFinding $true

Test-Case -Name 'localhost http not flagged' -FileName 'client.ps1' `
    -Content '$BaseUrl = "http://localhost:8000"' -ExpectFinding $false

Test-Case -Name 'example.com not flagged' -FileName 'client.ps1' `
    -Content '$BaseUrl = "http://example.com/path"' -ExpectFinding $false

Test-Case -Name 'w3.org XML namespace not flagged' -FileName 'view.ps1' `
    -Content '$Svg = ''<svg xmlns="http://www.w3.org/2000/svg">''' -ExpectFinding $false

Test-Case -Name 'scanner self-excludes own filename' -FileName 'check_security_hotspots.ps1' `
    -Content 'Invoke-Expression $userInput' -ExpectFinding $false

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: check_security_hotspots rules and qa:allow suppression behave as pinned (10 case(s))."
exit 0
