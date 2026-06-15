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
- You are working on the `main` branch, because the workflow publishes only from `main`
