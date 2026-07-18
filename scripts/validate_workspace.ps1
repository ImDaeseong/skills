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
    'genie'           = @('Read', 'AskUserQuestion')
    'personal-memory' = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'vibe-coder'      = @('Read', 'Write', 'Bash', 'AskUserQuestion')
    'video-producer'  = @('Read', 'Write', 'Bash', 'AskUserQuestion')
}
foreach ($file in $skillFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $allowedBlock = [regex]::Match($text, '(?ms)^allowed-tools:\s*(.*?)^---$').Groups[1].Value
    if (-not $requiredTools.ContainsKey($file.Directory.Name)) { $errors.Add("required-tools policy missing for skill: $($file.Directory.Name)") }
    foreach ($tool in $requiredTools[$file.Directory.Name]) {
        if ($allowedBlock -notmatch "(?m)^\s*-\s+$([regex]::Escape($tool))\s*$") {
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

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: $($skillFiles.Count) skills; core laws, tools, routing, names, and dates are valid as of $($AsOfDate.ToString('yyyy-MM-dd'))."
