# GitHub Auto Publish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a local one-command publish flow that commits site changes to GitHub and lets the existing GitHub Pages workflow deploy automatically.

**Architecture:** Keep the website itself unchanged. Add a small PowerShell publish script that stages changes, creates a commit, and pushes the current branch to `origin`, plus a thin `.bat` wrapper for double-click use. Document the workflow in a short markdown guide so the repository explains both the local publish step and the GitHub Actions deployment already in place.

**Tech Stack:** PowerShell, Windows batch, Git, GitHub Actions

---

### Task 1: Add a local publish script

**Files:**
- Create: `publish.ps1`

- [ ] **Step 1: Write the script**

```powershell
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

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed or is not available on PATH.'
}

$repoRoot = & git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
    throw 'Run this script from inside a Git repository.'
}

Set-Location $repoRoot

$changes = & git status --porcelain
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to inspect the working tree.'
}

if (-not $changes) {
    Write-Host 'No changes to publish.'
    exit 0
}

if (-not $Message) {
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

$branch = & git branch --show-current
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw 'Unable to determine the current branch.'
}

$branch = $branch.Trim()
if ($branch -ne 'main') {
    throw "Current branch is '$branch'. This repository publishes automatically only from 'main'. Switch to main and run the script again."
}

$upstream = & git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
    Write-Host "Pushing $branch to origin with upstream tracking..."
    Invoke-Git -Arguments @('push', '-u', 'origin', $branch)
} else {
    Write-Host "Pushing $branch..."
    Invoke-Git -Arguments @('push')
}

Write-Host 'Done. GitHub Actions will deploy the site automatically.'
```

- [ ] **Step 2: Verify the script syntax**

Run: `powershell -NoProfile -Command "$null = [scriptblock]::Create((Get-Content -Raw '.\publish.ps1'))"`
Expected: no parser errors

- [ ] **Step 3: Commit**

```bash
git add publish.ps1
git commit -m "feat: add local publish script"
```

### Task 2: Add a batch wrapper for double-click publishing

**Files:**
- Create: `publish.bat`

- [ ] **Step 1: Write the wrapper**

```bat
@echo off
setlocal

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" %*
if errorlevel 1 exit /b %errorlevel%
```

- [ ] **Step 2: Verify the wrapper content**

Run: `Get-Content .\publish.bat`
Expected: the wrapper forwards arguments to `publish.ps1`

- [ ] **Step 3: Commit**

```bash
git add publish.bat
git commit -m "feat: add publish batch wrapper"
```

### Task 3: Document the publish flow

**Files:**
- Create: `PUBLISH.md`

- [ ] **Step 1: Write the guide**

```markdown
# Local Publish Guide

## What this does

Run `publish.ps1` after you finish editing the site. The script commits your changes to the current Git branch and pushes them to GitHub. The repository already has a GitHub Actions workflow at `.github/workflows/pages.yml`, so every push to `main` is deployed to GitHub Pages automatically.

## Usage

```powershell
.\publish.ps1
```

You can also pass a commit message:

```powershell
.\publish.ps1 -Message "feat: update content"
```

If you prefer double-clicking from Windows Explorer, use:

```bat
publish.bat
```

## Requirements

- Git installed and available on `PATH`
- A GitHub remote named `origin`
- The repository Pages source set to GitHub Actions
```

- [ ] **Step 2: Verify the guide against the workflow**

Check that the guide matches `.github/workflows/pages.yml` and mentions the `main` push trigger.

- [ ] **Step 3: Commit**

```bash
git add PUBLISH.md
git commit -m "docs: add publish guide"
```

### Task 4: Final verification

**Files:**
- Review: `publish.ps1`
- Review: `publish.bat`
- Review: `PUBLISH.md`
- Review: `.github/workflows/pages.yml`

- [ ] **Step 1: Re-read the final files**

Confirm the script stages, commits, and pushes changes; the wrapper invokes the script; and the docs explain that GitHub Actions performs the Pages deployment.

- [ ] **Step 2: Finish**

No code changes are expected in this step. Verify there are no placeholders or contradictions left in the plan.
