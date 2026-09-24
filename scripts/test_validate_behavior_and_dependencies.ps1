$ErrorActionPreference = 'Stop'
$validator = Join-Path $PSScriptRoot 'validate_behavior_and_dependencies.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('skills-contract-test-' + [guid]::NewGuid())

function Write-Fixture([string]$Root) {
    New-Item -ItemType Directory -Path (Join-Path $Root 'evaluations') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Root 'example') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Root '_shared') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Root 'example\SKILL.md') -Value "git clone https://github.com/example/tool.git ./tool`ngit -C ./tool checkout --detach $('a' * 40)" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $Root '_shared\ROUTING.md') -Value '| `example` | `../example/SKILL.md` | Example | "do example" |' -Encoding UTF8
    [ordered]@{version=1;evaluations=@(
        [ordered]@{id='p';target='example/SKILL.md';type='positive';userRequest='do';expectedSkill='example';requiredBehavior=@('do');forbiddenBehavior=@('guess');humanReview=$false},
        [ordered]@{id='a';target='example/SKILL.md';type='ambiguous';userRequest='maybe';expectedSkill='clarify';requiredBehavior=@('ask');forbiddenBehavior=@('assume');humanReview=$false},
        [ordered]@{id='n';target='example/SKILL.md';type='negative';userRequest='other';expectedSkill='none';requiredBehavior=@('skip');forbiddenBehavior=@('route');humanReview=$false}
    )} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $Root 'evaluations\behavior-contracts.json') -Encoding UTF8
    [ordered]@{version=1;verifiedAt='2026-09-24';dependencies=@([ordered]@{url='https://github.com/example/tool.git';commit=('a' * 40);license='MIT'})} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $Root 'runtime-dependencies.lock.json') -Encoding UTF8
}

function Invoke-Validator([string]$Root) {
    $previousPreference = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $output = & powershell.exe -NoProfile -File $validator -Root $Root 2>&1 | Out-String; return @{ExitCode=$LASTEXITCODE;Output=$output} }
    finally { $ErrorActionPreference = $previousPreference }
}

try {
    Write-Fixture $tempRoot
    $pass = Invoke-Validator $tempRoot
    if ($pass.ExitCode -ne 0 -or $pass.Output -notmatch 'PASS: 3 behavior contracts') { throw "valid fixture failed: $($pass.Output)" }
    $lockPath = Join-Path $tempRoot 'runtime-dependencies.lock.json'
    $lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json
    $lock.dependencies[0].commit = 'main'
    $lock | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $lockPath -Encoding UTF8
    $failure = Invoke-Validator $tempRoot
    if ($failure.ExitCode -eq 0 -or $failure.Output -notmatch 'LOCK-BAD-COMMIT') { throw "bad-commit fixture did not fail for the intended reason: $($failure.Output)" }

    Write-Fixture $tempRoot
    Set-Content -LiteralPath (Join-Path $tempRoot 'example\SKILL.md') -Value 'git clone https://github.com/example/tool.git ./tool' -Encoding UTF8
    $unenforced = Invoke-Validator $tempRoot
    if ($unenforced.ExitCode -eq 0 -or $unenforced.Output -notmatch 'LOCK-COMMIT-NOT' -or $unenforced.Output -notmatch 'example/tool.git') { throw "unenforced-lock fixture did not fail for the intended reason: $($unenforced.Output)" }

    Write-Fixture $tempRoot
    New-Item -ItemType Directory -Path (Join-Path $tempRoot 'diagram-forge') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $tempRoot 'diagram-forge\SKILL.md') -Value 'npx skills add tt-a1i/archify -g' -Encoding UTF8
    $mutableInstaller = Invoke-Validator $tempRoot
    if ($mutableInstaller.ExitCode -eq 0 -or $mutableInstaller.Output -notmatch 'LOCK-MUTABLE-INSTALLER') { throw "mutable-installer fixture did not fail for the intended reason: $($mutableInstaller.Output)" }

    Write-Output 'PASS: behavior/dependency validator accepts a valid fixture and rejects bad, unenforced, or bypassed pins for the intended reasons.'
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

exit 0
