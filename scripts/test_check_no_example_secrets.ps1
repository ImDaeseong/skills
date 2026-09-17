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

# Regression (found live 2026-09-18 in ai_prompt's identical copy of this
# guard): Get-Content returns a bare String, not an array, for a single-line
# file. Indexing a String returns one character, not the whole line -- the
# guard silently never checked single-line files at all. Plant a real secret
# in a single-line file and confirm the real guard, end-to-end, catches it.
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("secret-guard-singleline-" + [guid]::NewGuid())
try {
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "scripts") | Out-Null
    & git -C $tempRoot init --quiet
    Set-Content -LiteralPath (Join-Path $tempRoot "creds.py") `
        -Value ('TOKEN = "sk-proj-' + ("A" * 40) + '"') -Encoding ascii  # qa:allow CWE-798 - planted test fixture proving the secrets guard catches it, not a real secret
    Copy-Item -LiteralPath $guardAbs -Destination (Join-Path $tempRoot "scripts/check_no_example_secrets.ps1")
    & git -C $tempRoot add -A | Out-Null

    & powershell.exe -NoProfile -File (Join-Path $tempRoot "scripts/check_no_example_secrets.ps1") | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $failures.Add("Regression case: guard exited 0 against a single-line file containing a planted secret (single-line files were silently unscanned).")
    }
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: check_no_example_secrets pattern set catches a planted secret and stays quiet on clean text (4 case(s))."
