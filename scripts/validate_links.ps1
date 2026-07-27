$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

# Exclude gitignored runtime-dependency clones (e.g. last30days/, marketingskills/) - these
# are third-party repos cloned on demand per README, not this workspace's own content.
$gitignorePath = Join-Path $root '.gitignore'
$ignoredTopLevelDirs = @()
if (Test-Path -LiteralPath $gitignorePath) {
    $ignoredTopLevelDirs = Get-Content -LiteralPath $gitignorePath |
        Where-Object { $_ -match '^\S+/$' } |
        ForEach-Object { $_.TrimEnd('/') }
}

# Scoped enumeration: skip ignored top-level dirs (e.g. last30days/) entirely rather than
# recursing into them and filtering afterward - avoids ever touching inaccessible nested paths.
function Get-ScopedFiles {
    param([string]$Root, [string[]]$IgnoredTopLevelDirs, [string]$Filter)
    $results = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($item in Get-ChildItem -LiteralPath $Root -Force) {
        if ($item.PSIsContainer) {
            if ($item.Name -in $IgnoredTopLevelDirs) { continue }
            Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter $Filter |
                ForEach-Object { $results.Add($_) }
        } elseif ($item.Name -like $Filter) {
            $results.Add($item)
        }
    }
    return $results
}

Get-ScopedFiles -Root $root -IgnoredTopLevelDirs $ignoredTopLevelDirs -Filter '*.md' | ForEach-Object {
    $base = $_.DirectoryName
    $text = Get-Content -LiteralPath $_.FullName -Raw
    foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value
        if ($target -match '^https?://') { continue }
        $targetPath = $target -replace '#.*$', ''
        if ($targetPath -eq '') { continue }
        if (-not (Test-Path -LiteralPath (Join-Path $base $targetPath))) {
            $errors.Add("broken local link: $($_.FullName) -> $target")
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'PASS: local Markdown links are valid.'
