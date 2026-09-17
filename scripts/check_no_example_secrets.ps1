$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# Ported from hermes-agents/scripts/check_no_example_secrets.py (same pattern
# list) as part of raising this repo toward AGENTS.md's Commercial-Grade
# Baseline rule (OWASP ASVS Level 1). This repo is a public GitHub mirror
# (ImDaeseong/skills), so exposure risk is higher than a private repo's.
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
$imageExtensions = @('.png', '.jpg', '.jpeg', '.gif', '.webp')

function Get-TrackedFiles {
    param([string]$Root)
    # -z: NUL-terminated, avoids git's default quoting of non-ASCII (Korean)
    # filenames, same reasoning as the hermes-agents Python version.
    $raw = & git -C $Root ls-files -z
    if ($LASTEXITCODE -ne 0) { throw 'git ls-files failed' }
    return ($raw -split "`0") | Where-Object { $_ -ne '' }
}

$problems = [System.Collections.Generic.List[string]]::new()
foreach ($relPath in (Get-TrackedFiles -Root $root)) {
    $ext = [System.IO.Path]::GetExtension($relPath).ToLowerInvariant()
    if ($imageExtensions -contains $ext) { continue }
    $fullPath = Join-Path $root $relPath
    try {
        # @(...) forces an array even for a single-line file -- Get-Content
        # otherwise returns a bare String, and indexing a String returns a
        # single character, not the whole line, which silently made every
        # single-line file's scan a no-op (same defect class found live in
        # ai_prompt's identical copy of this guard, 2026-09-18).
        $lines = @(Get-Content -LiteralPath $fullPath -Encoding utf8 -ErrorAction Stop)
    } catch {
        continue
    }
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        foreach ($pattern in $secretPatterns) {
            if ($line -match $pattern) {
                $problems.Add("${relPath}:$($i + 1): real-looking secret")
                break
            }
        }
    }
}

if ($problems.Count -gt 0) {
    Write-Output 'FAIL tracked files contain real-looking secrets:'
    $problems | ForEach-Object { Write-Output "  - $_" }
    exit 1
}

Write-Output 'OK   no real-looking secrets in tracked files'
