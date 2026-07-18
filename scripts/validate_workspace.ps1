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
}

$laws = Get-Content -LiteralPath (Join-Path $Root '_shared\CORE-LAWS.md') -Raw
foreach ($token in @('LAW 3', '[LOOP-START]', '[LOOP-END]', 'max iterations', 'regression', 'HOLD')) {
    if ($laws -notmatch [regex]::Escape($token)) { $errors.Add("CORE-LAWS missing verification token: $token") }
}

$biz = Get-Content -LiteralPath (Join-Path $Root 'biz-council\SKILL.md') -Raw
if ($biz -match 'Spawn 5 sub-agents' -and $biz -notmatch '(?m)^\s*- Task\s*$') { $errors.Add('biz-council requires Task but does not allow it') }

$distribution = Get-Content -LiteralPath (Join-Path $Root 'distribution\SKILL.md') -Raw
if ($distribution -match 'WebSearch' -and $distribution -notmatch '(?m)^\s*- WebSearch\s*$') { $errors.Add('distribution references WebSearch but does not allow it') }

$routes = Select-String -LiteralPath (Join-Path $Root '_shared\ROUTING.md') -Pattern '^\| `([^`]+)` \|' | ForEach-Object { $_.Matches[0].Groups[1].Value }
$specialists = $skillFiles.Directory.Name | Where-Object { $_ -ne 'genie' }
foreach ($skill in $specialists) {
    if ($skill -notin $routes) { $errors.Add("unrouted specialist: $skill") }
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

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: $($skillFiles.Count) skills; core loop, permissions, routing, names, and dates are valid as of $($AsOfDate.ToString('yyyy-MM-dd'))."
