# Static pattern scan for security/network hotspots (see qa_manager's
# SECURITY_NETWORK_QA_STANDARD.md for the OWASP/CWE sources). Ported from the
# Python version (hermes-agents/qa_manager/ai_agent/ai_test) but scoped to
# what's actually checkable in a pure-PowerShell repo: this repo has no
# SQL/pickle/yaml.load call sites, so those CWE-89/CWE-95/CWE-502 rules are
# left out rather than invented against nothing (AGENTS.md Commercial-Grade
# Baseline: "don't register a check with no real command behind it").
#
# A line carrying a same-line `qa:allow` comment is an acknowledged,
# documented risk and is not reported as a failure.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$allowMarker = 'qa:allow'
$selfExclude = @('check_security_hotspots.ps1', 'test_check_security_hotspots.ps1')

# Each rule: CWE id, title, suggestion, regex pattern (PowerShell -match, .NET regex).
$rules = @(
    @{
        Cwe        = 'CWE-798'
        Title      = 'hardcoded credential'
        Suggestion = 'remove the literal value and read it from an environment variable or secret store.'
        Pattern    = '(?i)\$?[A-Z0-9_]*(?:API[_-]?KEY|SECRET|PASSWORD|TOKEN|CREDENTIAL)[A-Z0-9_]*\s*[:=]\s*[''"](?!(?:xxx|changeme|your_|example|redacted|dummy|test|<|\$\{|\{\{))[A-Za-z0-9/+._-]{8,}[''"]'
    },
    @{
        Cwe        = 'CWE-78'
        Title      = 'Invoke-Expression on dynamic content'
        Suggestion = 'avoid Invoke-Expression/iex on anything not a trusted, operator-authored constant; use a direct cmdlet call instead.'
        Pattern    = '(?i)\b(?:Invoke-Expression|iex)\b'
    },
    @{
        Cwe        = 'CWE-295'
        Title      = 'TLS certificate verification disabled'
        Suggestion = 'remove -SkipCertificateCheck / the ServerCertificateValidationCallback override; keep default certificate validation.'
        Pattern    = '(?i)-SkipCertificateCheck|ServerCertificateValidationCallback\s*=\s*\{'
    },
    @{
        Cwe        = 'CWE-319'
        Title      = 'cleartext http to a non-local endpoint'
        Suggestion = 'switch to https://; localhost/127.0.0.1/0.0.0.0/example.com/example.org/example.net (RFC 2606) and www.w3.org (XML namespace URI) are excluded from this rule.'
        Pattern    = '[''"]http://(?!localhost|127\.0\.0\.1|0\.0\.0\.0|example\.(?:com|org|net)|www\.w3\.org)[A-Za-z0-9.-]+'
    },
    @{
        Cwe        = 'CWE-942'
        Title      = 'CORS wide open'
        Suggestion = 'allow-list explicit origins instead of a wildcard, especially with credentials.'
        Pattern    = 'Access-Control-Allow-Origin[''"]?\s*[:=]\s*[''"]\*|origin\s*:\s*[''"]\*[''"]'
    }
)

function Get-TrackedFiles {
    param([string]$Root)
    # -z: NUL-terminated, avoids git's default quoting of non-ASCII (Korean)
    # filenames, same reasoning as check_no_example_secrets.ps1.
    $raw = & git -C $Root ls-files -z
    if ($LASTEXITCODE -ne 0) { throw 'git ls-files failed' }
    return ($raw -split "`0") | Where-Object { $_ -ne '' }
}

function Get-SecurityHotspotFindings {
    param([string]$Root)
    $sourceExtensions = @('.ps1', '.py', '.js', '.ts', '.sh', '.bat', '.cmd')
    $findings = [System.Collections.Generic.List[string]]::new()
    foreach ($relPath in (Get-TrackedFiles -Root $Root)) {
        $name = Split-Path -Leaf $relPath
        if ($selfExclude -contains $name) { continue }
        $ext = [System.IO.Path]::GetExtension($relPath).ToLowerInvariant()
        if ($sourceExtensions -notcontains $ext) { continue }
        $fullPath = Join-Path $Root $relPath
        try {
            # @(...) forces an array even for a single-line file -- Get-Content
            # otherwise returns a bare String, and indexing a String returns a
            # single character, not the whole line (silently made every
            # single-line file's scan a no-op).
            $lines = @(Get-Content -LiteralPath $fullPath -Encoding utf8 -ErrorAction Stop)
        } catch {
            continue
        }
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line -like "*$allowMarker*") { continue }
            foreach ($rule in $rules) {
                if ($line -match $rule.Pattern) {
                    $findings.Add("${relPath}:$($i + 1): [$($rule.Cwe)] $($rule.Title) - $($rule.Suggestion)")
                    break
                }
            }
        }
    }
    return $findings
}

if ($MyInvocation.InvocationName -ne '.') {
    $findings = Get-SecurityHotspotFindings -Root $root
    if ($findings.Count -gt 0) {
        Write-Output "FAIL $($findings.Count) unacknowledged security/network hotspot(s):"
        $findings | ForEach-Object { Write-Output "  - $_" }
        Write-Output 'Acknowledge an accepted risk with a same-line `# qa:allow` comment, or fix it.'
        exit 1
    }
    Write-Output 'OK   no unacknowledged security/network hotspots found (static pattern scan only)'
}
