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
    # -Encoding utf8: PowerShell 5.1's Get-Content default encoding for a
    # BOM-less file falls back to the system locale codepage (cp949 on
    # Korean Windows), which garbles non-ASCII (Korean) filenames extracted
    # from link text so they no longer match the real Unicode path on disk.
    # (Found live in a sibling repo's copy of this script, 2026-08-03.)
    $text = Get-Content -LiteralPath $_.FullName -Raw -Encoding utf8
    # Strip fenced code blocks and inline code spans before matching links.
    # Without this, a "[label](field list)" notation inside backticks -- used
    # as a literal output-format spec, not a real link -- still matches the
    # link regex and gets treated as a broken link to a nonexistent file.
    # (Found live via an independent validator's report on a sibling repo's
    # music_skills_trot/메모리.md, 2026-08-03 -- the content was already
    # correctly backtick-wrapped by its author; the bug was in this script.)
    $codeless = $text -replace '(?s)```.*?```', '' -replace '`[^`]*`', ''
    # [^)\n]+ (not [^)]+): a target must not span a newline. Without this, a
    # literal "](" appearing inside a fenced code block (e.g. a shell command
    # that greps for markdown link syntax) makes the capture run away across
    # unrelated paragraphs hunting for the next ")", producing a multi-line
    # garbage "path" that crashes Test-Path with "illegal characters in path".
    # (Found live in a sibling repo's validate_links.ps1 copy, 2026-08-03.)
    foreach ($match in [regex]::Matches($codeless, '\[[^\]]+\]\(([^)\n]+)\)')) {
        $target = $match.Groups[1].Value
        if ($target -match '^https?://') { continue }
        $targetPath = $target -replace '#.*$', ''
        if ($targetPath -eq '') { continue }
        try {
            $exists = Test-Path -LiteralPath (Join-Path $base $targetPath)
        } catch {
            $errors.Add("unresolvable link target (invalid path characters): $($_.FullName) -> $target")
            continue
        }
        if (-not $exists) {
            $errors.Add("broken local link: $($_.FullName) -> $target")
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'PASS: local Markdown links are valid.'
