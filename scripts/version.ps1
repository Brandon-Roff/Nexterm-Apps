# Version management script for Nexterm Apps (PowerShell)

param(
    [Parameter(Position=0)]
    [string]$Command = "current",
    
    [Parameter(Position=1)]
    [string]$Type = "patch"
)

$VersionFile = ".version"
$CurrentVersion = if (Test-Path $VersionFile) { Get-Content $VersionFile } else { "1.0" }

function Show-Help {
    Write-Host "🚀 Nexterm Apps Version Manager" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\version.ps1 [command] [type]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Green
    Write-Host "  current              Show current version"
    Write-Host "  next                 Show next patch version"
    Write-Host "  bump [patch|minor|major]  Bump version (default: patch)"
    Write-Host "  set <version>        Set specific version"
    Write-Host "  release              Bump version and trigger release"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\scripts\version.ps1 current           # Shows: 1.0"
    Write-Host "  .\scripts\version.ps1 next             # Shows: 1.1"
    Write-Host "  .\scripts\version.ps1 bump             # 1.0 -> 1.1"
    Write-Host "  .\scripts\version.ps1 bump minor       # 1.0 -> 2.0"
    Write-Host "  .\scripts\version.ps1 set 1.5          # Sets version to 1.5"
    Write-Host "  .\scripts\version.ps1 release          # Bump version and commit"
}

function Get-NextVersion {
    param(
        [string]$Version,
        [string]$BumpType = "patch"
    )
    
    $parts = $Version -split '\.'
    $major = [int]($parts[0] ?? 1)
    $minor = [int]($parts[1] ?? 0)
    
    switch ($BumpType.ToLower()) {
        "patch" { $minor++ }
        "minor" { 
            $major++
            $minor = 0
        }
        "major" { 
            $major++
            $minor = 0
        }
        default {
            Write-Host "❌ Invalid bump type: $BumpType" -ForegroundColor Red
            Write-Host "   Use: patch, minor, or major" -ForegroundColor Yellow
            exit 1
        }
    }
    
    return "$major.$minor"
}

switch ($Command.ToLower()) {
    "current" {
        Write-Host "📍 Current version: $CurrentVersion" -ForegroundColor Green
    }
    
    "next" {
        $NextVersion = Get-NextVersion -Version $CurrentVersion -BumpType $Type
        Write-Host "⏭️  Next version: $NextVersion" -ForegroundColor Cyan
    }
    
    "bump" {
        $NewVersion = Get-NextVersion -Version $CurrentVersion -BumpType $Type
        $NewVersion | Out-File -FilePath $VersionFile -Encoding UTF8 -NoNewline
        Write-Host "🚀 Version bumped: $CurrentVersion -> $NewVersion" -ForegroundColor Green
        Write-Host "📝 Version file updated (.version)" -ForegroundColor Yellow
        Write-Host "💡 Commit and push to trigger release workflow" -ForegroundColor Cyan
    }
    
    "set" {
        if (-not $Type) {
            Write-Host "❌ Please specify version to set" -ForegroundColor Red
            Write-Host "   Example: .\scripts\version.ps1 set 1.5" -ForegroundColor Yellow
            exit 1
        }
        $Type | Out-File -FilePath $VersionFile -Encoding UTF8 -NoNewline
        Write-Host "🎯 Version set to: $Type" -ForegroundColor Green
        Write-Host "📝 Version file updated (.version)" -ForegroundColor Yellow
        Write-Host "💡 Commit and push to trigger release workflow" -ForegroundColor Cyan
    }
    
    "release" {
        $NewVersion = Get-NextVersion -Version $CurrentVersion -BumpType $Type
        $NewVersion | Out-File -FilePath $VersionFile -Encoding UTF8 -NoNewline
        
        Write-Host "🚀 Creating release for version $NewVersion..." -ForegroundColor Cyan
        
        # Add version file to git
        & git add .version
        & git commit -m "🔖 Bump version to $NewVersion

Release Notes:
- Version bumped from $CurrentVersion to $NewVersion
- Automated release creation
- Updated application packages"
        
        Write-Host "✅ Version committed: $NewVersion" -ForegroundColor Green
        Write-Host "🚀 Push to trigger release:" -ForegroundColor Cyan
        Write-Host "   git push origin main" -ForegroundColor Yellow
    }
    
    default {
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
        exit 1
    }
}