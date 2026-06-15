param(
    [string]$Message,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Fail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "Publish failed: $Message" -ForegroundColor Red
    exit 1
}

try {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Fail 'Git is not installed or is not available on PATH.'
    }

    $repoRoot = & git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
        Fail 'This folder is not a Git repository. Please run the script from a cloned copy of the repo.'
    }

    Set-Location $repoRoot

    $branch = & git branch --show-current
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        Fail 'Unable to determine the current branch.'
    }

    $branch = $branch.Trim()
    if ($branch -ne 'main') {
        Fail "Current branch is '$branch'. This repository publishes automatically only from 'main'. Switch to main and run the script again."
    }

    $changes = & git status --porcelain
    if ($LASTEXITCODE -ne 0) {
        Fail 'Failed to inspect the working tree.'
    }

    if (-not $changes) {
        Write-Host 'No changes to publish.'
        exit 0
    }

    if (-not $Message -and -not $DryRun) {
        $Message = Read-Host 'Commit message'
    }

    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = 'chore: publish site update'
    }

    if ($DryRun) {
        Write-Host "[DryRun] Would stage, commit, and push with message: $Message"
        exit 0
    }

    Write-Host 'Staging changes...'
    Invoke-Git -Arguments @('add', '-A')

    Write-Host 'Committing...'
    Invoke-Git -Arguments @('commit', '-m', $Message)

    $upstream = & git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
        Write-Host "Pushing $branch to origin with upstream tracking..."
        Invoke-Git -Arguments @('push', '-u', 'origin', $branch)
    } else {
        Write-Host "Pushing $branch..."
        Invoke-Git -Arguments @('push')
    }

    Write-Host 'Done. GitHub Actions will deploy the site automatically.'
}
catch {
    Fail $_.Exception.Message
}
