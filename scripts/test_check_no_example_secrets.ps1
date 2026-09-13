# Regression test for check_no_example_secrets.ps1: proves the pattern set
# actually catches a real-looking secret and stays quiet on ordinary prose,
# then confirms the guard itself exits clean against this repo's own tracked
# files (known clean, since the guard already passes standalone).

$ErrorActionPreference = "Stop"
$failures = [System.Collections.Generic.List[string]]::new()

$repoRoot = Split-Path -Parent $PSScriptRoot
$guardAbs = Join-Path $repoRoot "scripts/check_no_example_secrets.ps1"

# Mirrors check_no_example_secrets.ps1's own pattern list -- kept in sync by
# hand since PowerShell 5.1 has no lightweight way to import a sibling
# script's data without also executing its top-level scan.
$secretPatterns = @(
    'sk-or-v1-[A-Za-z0-9]{20,}'
    'moltbook_sk__[A-Za-z0-9]{20,}'
    '\b\d{8,10}:[A-Za-z0-9_-]{30,}\b'
    'sk-ant-[A-Za-z0-9_-]{20,}'
    'sk-proj-[A-Za-z0-9_-]{20,}'
    '\bsk-[A-Za-z0-9]{20,}\b'
    '\bAIza[0-9A-Za-z_-]{35}\b'
    '\bgh[pousr]_[A-Za-z0-9]{36,}\b'
    '\bAKIA[0-9A-Z]{16}\b'
    '\bxox[baprs]-[0-9A-Za-z-]{10,}\b'
)

# Positive case: a planted OpenAI-shaped key must be matched by the pattern set.
$planted = "sk-proj-" + ("A" * 40)
$matched = $false
foreach ($pattern in $secretPatterns) {
    if ($planted -match $pattern) { $matched = $true; break }
}
if (-not $matched) {
    $failures.Add("Positive case: planted secret 'sk-proj-...' was not matched by any pattern.")
}

# Negative case: ordinary prose must not match any pattern.
$clean = "This is a normal sentence about an example skill with no secrets in it."
foreach ($pattern in $secretPatterns) {
    if ($clean -match $pattern) {
        $failures.Add("Negative case: clean prose falsely matched pattern '$pattern'.")
    }
}

# End-to-end case: the real guard, run against this repo's own tracked files,
# must exit 0.
& powershell.exe -NoProfile -File $guardAbs | Out-Null
if ($LASTEXITCODE -ne 0) {
    $failures.Add("End-to-end case: guard exited $LASTEXITCODE against this repo's own clean tracked files.")
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: check_no_example_secrets pattern set catches a planted secret and stays quiet on clean text (3 case(s))."
