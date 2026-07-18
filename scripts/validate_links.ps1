$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.md' | ForEach-Object {
    $base = $_.DirectoryName
    $text = Get-Content -LiteralPath $_.FullName -Raw
    foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?://|#)') { continue }
        if (-not (Test-Path -LiteralPath (Join-Path $base $target))) {
            $errors.Add("broken local link: $($_.FullName) -> $target")
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'PASS: local Markdown links are valid.'
