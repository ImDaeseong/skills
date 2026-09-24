param([string]$Root = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$errors = [System.Collections.Generic.List[string]]::new()
$allowedTypes = @('positive', 'ambiguous', 'negative')

function Read-JsonFile([string]$RelativePath) {
    $path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $errors.Add("[MISSING-FILE] $RelativePath"); return $null }
    try { return Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { $errors.Add("[INVALID-JSON] ${RelativePath}: $($_.Exception.Message)"); return $null }
}

$contracts = Read-JsonFile 'evaluations\behavior-contracts.json'
$lock = Read-JsonFile 'runtime-dependencies.lock.json'
$ids = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$targetTypes = @{}

if ($contracts) {
    foreach ($evaluation in @($contracts.evaluations)) {
        foreach ($field in @('id','target','type','userRequest','expectedSkill')) {
            if ([string]::IsNullOrWhiteSpace([string]$evaluation.$field)) { $errors.Add("[EVAL-MISSING-FIELD] evaluation '$($evaluation.id)' is missing '$field'") }
        }
        if (-not $ids.Add([string]$evaluation.id)) { $errors.Add("[EVAL-DUPLICATE-ID] $($evaluation.id)") }
        if ($evaluation.type -notin $allowedTypes) { $errors.Add("[EVAL-BAD-TYPE] $($evaluation.id): $($evaluation.type)") }
        if (@($evaluation.requiredBehavior).Count -eq 0 -or @($evaluation.forbiddenBehavior).Count -eq 0) { $errors.Add("[EVAL-MISSING-ASSERTION] $($evaluation.id)") }
        if (-not (Test-Path -LiteralPath (Join-Path $Root ([string]$evaluation.target)) -PathType Leaf)) { $errors.Add("[EVAL-MISSING-TARGET] $($evaluation.id): $($evaluation.target)") }
        if (-not $targetTypes.ContainsKey([string]$evaluation.target)) { $targetTypes[[string]$evaluation.target] = [System.Collections.Generic.HashSet[string]]::new() }
        [void]$targetTypes[[string]$evaluation.target].Add([string]$evaluation.type)
    }
    foreach ($target in $targetTypes.Keys) {
        foreach ($type in $allowedTypes) { if (-not $targetTypes[$target].Contains($type)) { $errors.Add("[EVAL-MISSING-TYPE] ${target}: $type") } }
    }
}

$lockedUrls = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
if ($lock) {
    foreach ($dependency in @($lock.dependencies)) {
        if (-not $lockedUrls.Add([string]$dependency.url)) { $errors.Add("[LOCK-DUPLICATE-URL] $($dependency.url)") }
        if ([string]$dependency.commit -notmatch '^[0-9a-f]{40}$') { $errors.Add("[LOCK-BAD-COMMIT] $($dependency.url)") }
        if ([string]::IsNullOrWhiteSpace([string]$dependency.license)) { $errors.Add("[LOCK-MISSING-LICENSE] $($dependency.url)") }
    }
}

$cloneUrls = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$skillTextsByUrl = @{}
foreach ($skillDirectory in Get-ChildItem -LiteralPath $Root -Directory) {
    $skillFile = Get-Item -LiteralPath (Join-Path $skillDirectory.FullName 'SKILL.md') -ErrorAction SilentlyContinue
    if (-not $skillFile) { continue }
    $text = Get-Content -LiteralPath $skillFile.FullName -Raw -Encoding UTF8
    foreach ($match in [regex]::Matches($text, 'git clone(?:\s+--depth\s+1)?\s+(https://github\.com/[^\s]+?\.git)(?:\s|$)')) {
        $url = $match.Groups[1].Value
        [void]$cloneUrls.Add($url)
        $skillTextsByUrl[$url] = $text
    }
}
foreach ($url in $cloneUrls) { if (-not $lockedUrls.Contains($url)) { $errors.Add("[LOCK-MISSING-CLONE] $url") } }
foreach ($url in $lockedUrls) { if (-not $cloneUrls.Contains($url)) { $errors.Add("[LOCK-ORPHAN-ENTRY] $url") } }
if ($lock) {
    foreach ($dependency in @($lock.dependencies)) {
        if ($skillTextsByUrl.ContainsKey([string]$dependency.url) -and -not $skillTextsByUrl[[string]$dependency.url].Contains([string]$dependency.commit)) {
            $errors.Add("[LOCK-COMMIT-NOT-ENFORCED] $($dependency.url)")
        }
    }
}

$distributionPath = Join-Path $Root 'distribution\SKILL.md'
if ((Test-Path -LiteralPath $distributionPath) -and (Get-Content -LiteralPath $distributionPath -Raw -Encoding UTF8) -match 'raw\.githubusercontent\.com.+(?:/main/|main branch)') {
    $errors.Add('[LOCK-MUTABLE-FALLBACK] distribution uses a mutable main-branch runtime source')
}
$diagramPath = Join-Path $Root 'diagram-forge\SKILL.md'
if ((Test-Path -LiteralPath $diagramPath) -and (Get-Content -LiteralPath $diagramPath -Raw -Encoding UTF8) -match 'npx skills add tt-a1i/archify') {
    $errors.Add('[LOCK-MUTABLE-INSTALLER] diagram-forge bypasses the reviewed commit lock')
}

$routePath = Join-Path $Root '_shared\ROUTING.md'
if (Test-Path -LiteralPath $routePath) {
    $phrases = @{}
    foreach ($line in Get-Content -LiteralPath $routePath -Encoding UTF8) {
        if ($line -notmatch '^\| `([^`]+)` ') { continue }
        $skill = $Matches[1]
        foreach ($quoted in [regex]::Matches($line, '"([^"]+)"')) {
            $phrase = $quoted.Groups[1].Value.Trim().ToLowerInvariant()
            if ($phrases.ContainsKey($phrase) -and $phrases[$phrase] -ne $skill) { $errors.Add("[ROUTE-DUPLICATE-TRIGGER] '$phrase': $($phrases[$phrase]), $skill") }
            else { $phrases[$phrase] = $skill }
        }
    }
}

if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "PASS: $($ids.Count) behavior contracts, $($lockedUrls.Count) pinned runtime dependencies, and route triggers are valid."
