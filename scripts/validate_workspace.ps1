param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [datetime]$AsOfDate = (Get-Date).Date
)

$errors = [System.Collections.Generic.List[string]]::new()
$skillFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter 'SKILL.md'

foreach ($file in $skillFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $name = [regex]::Match($text, '(?m)^name:\s*([^\r\n]+)').Groups[1].Value.Trim()
    if ($name -ne $file.Directory.Name) { $errors.Add("name/folder mismatch: $($file.FullName)") }
    if ($text -notmatch '\.\./_shared/CORE-LAWS\.md') { $errors.Add("missing CORE-LAWS reference: $($file.FullName)") }
    if ($text -notmatch '(?m)^Follow `\.\./_shared/CORE-LAWS\.md` in full\.') { $errors.Add("CORE-LAWS must be followed in full: $($file.FullName)") }
}

$laws = Get-Content -LiteralPath (Join-Path $Root '_shared\CORE-LAWS.md') -Raw
foreach ($token in @('LAW 3', 'LAW 4', '[LOOP-START]', '[LOOP-END]', 'max iterations', 'regression', 'HOLD')) {
    if ($laws -notmatch [regex]::Escape($token)) { $errors.Add("CORE-LAWS missing verification token: $token") }
}

$requiredTools = @{
    'agent-builder'   = @('Read', 'Write', 'Bash', 'WebFetch', 'AskUserQuestion')
    'biz-council'     = @('Read', 'Write', 'Bash', 'WebSearch', 'WebFetch', 'AskUserQuestion', 'Task')
    'curator'         = @('Read', 'Write', 'Bash', 'WebFetch', 'AskUserQuestion')
    'design-report'   = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'distribution'    = @('Read', 'Bash', 'WebSearch', 'WebFetch', 'AskUserQuestion')
    'game-dev'        = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'genie'           = @('Read', 'AskUserQuestion')
    'personal-memory' = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'vibe-coder'      = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'video-producer'  = @('Read', 'Write', 'Bash', 'AskUserQuestion')
}
foreach ($file in $skillFiles) {
    $lines = Get-Content -LiteralPath $file.FullName
    $allowedTools = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $inAllowedTools = $false
    foreach ($line in $lines) {
        if ($line -eq 'allowed-tools:') { $inAllowedTools = $true; continue }
        if ($inAllowedTools -and $line -eq '---') { break }
        if ($inAllowedTools -and $line -match '^\s*-\s+(.+?)\s*$') { [void]$allowedTools.Add($Matches[1]) }
    }
    if (-not $requiredTools.ContainsKey($file.Directory.Name)) { $errors.Add("required-tools policy missing for skill: $($file.Directory.Name)") }
    foreach ($tool in $requiredTools[$file.Directory.Name]) {
        if (-not $allowedTools.Contains($tool)) {
            $errors.Add("missing required tool ${tool}: $($file.FullName)")
        }
    }
}

$bizCouncil = Get-Content -LiteralPath (Join-Path $Root 'biz-council\SKILL.md') -Raw
foreach ($token in @('Claim-quality gate', 'self-reported', 'counterevidence', 'comparison baseline', 'A/B test', 'stop condition')) {
    if ($bizCouncil -notmatch [regex]::Escape($token)) { $errors.Add("biz-council missing claim-validation guard: $token") }
}

$routeFile = Join-Path $Root '_shared\ROUTING.md'
$routeMatches = Select-String -LiteralPath $routeFile -Pattern '^\| `([^`]+)` \| `([^`]+)` \|'
$routes = $routeMatches | ForEach-Object { $_.Matches[0].Groups[1].Value }
foreach ($duplicate in $routes | Group-Object | Where-Object Count -gt 1) {
    $errors.Add("duplicate route: $($duplicate.Name)")
}
foreach ($match in $routeMatches) {
    $relativePath = $match.Matches[0].Groups[2].Value
    $resolvedPath = [IO.Path]::GetFullPath((Join-Path (Split-Path $routeFile) $relativePath))
    if (-not (Test-Path -LiteralPath $resolvedPath)) { $errors.Add("route path does not exist: $relativePath") }
}
$specialists = $skillFiles.Directory.Name | Where-Object { $_ -ne 'genie' }
foreach ($skill in $specialists) {
    if ($skill -notin $routes) { $errors.Add("unrouted specialist: $skill") }
}
foreach ($route in $routes) {
    if ($route -notin $specialists) { $errors.Add("orphan route: $route") }
}

$datePattern = '(?<!\d)(20\d{2}-\d{2}-\d{2})(?!\d)'
foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md') {
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $file.FullName) {
        $lineNumber++
        foreach ($match in [regex]::Matches($line, $datePattern)) {
            $date = [datetime]::ParseExact($match.Groups[1].Value, 'yyyy-MM-dd', $null)
            if ($date.Date -gt $AsOfDate.Date) { $errors.Add("future evidence date: $($file.FullName):$lineNumber ($($match.Value))") }
        }
    }
}

$bizCouncilText = Get-Content -LiteralPath (Join-Path $Root 'biz-council\SKILL.md') -Raw
foreach ($token in @('AI earnings attribution guard', 'pre-existing assets', 'gross revenue', 'customer-acquisition cost', 'retention or renewal', 'tool created demand')) {
    if (-not $bizCouncilText.Contains($token)) { $errors.Add("biz-council missing AI earnings attribution guard: $token") }
}

$agentBuilderText = Get-Content -LiteralPath (Join-Path $Root 'agent-builder\SKILL.md') -Raw
foreach ($token in @('Third-party MCP safety guard', 'read-only access', 'least privilege', 'explicit human approval', 'prompt-injection')) {
    if (-not $agentBuilderText.Contains($token)) { $errors.Add("agent-builder missing MCP safety guard: $token") }
}

$curatorText = Get-Content -LiteralPath (Join-Path $Root 'curator\SKILL.md') -Raw
foreach ($token in @('Learning-content comprehension guard', 'primary source', 'closed-source active recall', 'counterexamples', 'Re-test after a delay', 'independent validation')) {
    if (-not $curatorText.Contains($token)) { $errors.Add("curator missing learning-comprehension guard: $token") }
}

$personalMemoryText = Get-Content -LiteralPath (Join-Path $Root 'personal-memory\SKILL.md') -Raw
foreach ($token in @('Durable-learning promotion guard', 'primary-source link', 'delayed active recall', 'fluent prose masquerade as mastery', 'application or decision')) {
    if (-not $personalMemoryText.Contains($token)) { $errors.Add("personal-memory missing durable-learning guard: $token") }
}

foreach ($token in @('Agent-architecture evidence guard', 'creator-authored terms unverified', 'measured baseline', 'evaluation set', 'retrieval quality', 'latency and cost budgets', 'self-modifying agent', 'isolated tests and human review')) {
    if (-not $agentBuilderText.Contains($token)) { $errors.Add("agent-builder missing architecture-evidence guard: $token") }
}

foreach ($token in @('Repeated-loop control guard', 'orchestration across repeated harnessed runs', 'idempotency keys', 'measurable progress signal', 'budget exhaustion', 'contradictory verifier results', 'aggregate budget', 'validated checkpoint', 'state transition and approval')) {
    if (-not $agentBuilderText.Contains($token)) { $errors.Add("agent-builder missing repeated-loop guard: $token") }
}

foreach ($token in @('Financial-action safety guard', 'self-reported', 'backtest percentage as money earned', 'buy-and-hold', 'walk-forward', 'out-of-sample', 'funding costs', 'leverage', 'parameter searches', 'When comparing models', 'effort setting', 'result variance', 'slippage', 'no withdrawal permission', 'daily-loss', 'circuit breaker', 'operator kill switch', 'immutable audit logs')) {
    if (-not $agentBuilderText.Contains($token)) { $errors.Add("agent-builder missing financial-action guard: $token") }
}

$readmeText = Get-Content -LiteralPath (Join-Path $Root 'README.md') -Raw
foreach ($token in @('NOTICE.md', 'scripts/install-git-hooks.ps1', 'scripts/validate_workspace.ps1', 'scripts/validate_links.ps1', 'all 10 skills', 'claim attribution', 'idempotency', 'financial actions', 'GitHub Actions')) {
    if (-not $readmeText.Contains($token)) { $errors.Add("README usage or safety documentation is stale: $token") }
}

$licenseText = Get-Content -LiteralPath (Join-Path $Root 'LICENSE') -Raw
if (-not $licenseText.StartsWith('MIT License')) { $errors.Add('LICENSE is not the standard MIT license') }
if ($licenseText.Contains('This license covers')) { $errors.Add('third-party notice must not be appended to LICENSE') }
if (-not (Test-Path -LiteralPath (Join-Path $Root 'NOTICE.md'))) { $errors.Add('missing NOTICE.md') }
$workflowPath = Join-Path $Root '.github\workflows\validate.yml'
if (-not (Test-Path -LiteralPath $workflowPath)) {
    $errors.Add('missing GitHub validation workflow')
} else {
    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    foreach ($token in @('actions/checkout@v5', 'shell: powershell', 'Korea Standard Time', '-AsOfDate $asOfDate', './scripts/validate_links.ps1')) {
        if (-not $workflowText.Contains($token)) { $errors.Add("GitHub validation workflow is stale: $token") }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object {
        $message = $_.Replace('%', '%25').Replace("`r", '%0D').Replace("`n", '%0A')
        Write-Output "::error title=Workspace validation::$message"
        Write-Error $_
    }
    exit 1
}

Write-Output "PASS: $($skillFiles.Count) skills; core laws, tools, routing, names, and dates are valid as of $($AsOfDate.ToString('yyyy-MM-dd'))."
