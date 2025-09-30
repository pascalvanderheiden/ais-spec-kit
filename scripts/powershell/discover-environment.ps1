#!/usr/bin/env pwsh
# Discover cloud environment resources
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$TagFilter
)
$ErrorActionPreference = 'Stop'

$tagFilterStr = ($TagFilter -join ' ').Trim()

# Function to find the repository root by searching for existing project markers
function Find-RepositoryRoot {
    param(
        [string]$StartDir,
        [string[]]$Markers = @('.git', '.specify')
    )
    $current = Resolve-Path $StartDir
    while ($true) {
        foreach ($marker in $Markers) {
            if (Test-Path (Join-Path $current $marker)) {
                return $current
            }
        }
        $parent = Split-Path $current -Parent
        if ($parent -eq $current) {
            return $null
        }
        $current = $parent
    }
}

$fallbackRoot = (Find-RepositoryRoot -StartDir $PSScriptRoot)
if (-not $fallbackRoot) {
    Write-Error "Error: Could not determine repository root. Please run this script from within the repository."
    exit 1
}

try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0) {
        $hasGit = $true
    } else {
        throw "Git not available"
    }
} catch {
    $repoRoot = $fallbackRoot
    $hasGit = $false
}

Set-Location $repoRoot

# Check for cloud provider configuration
$cloudProvider = $env:SPECIFY_CLOUD_PROVIDER
if (-not $cloudProvider) {
    # Try to read from .specify/config if exists
    $configFile = Join-Path $repoRoot '.specify/config'
    if (Test-Path $configFile) {
        $configContent = Get-Content $configFile
        $cloudLine = $configContent | Where-Object { $_ -match '^CLOUD_PROVIDER=' }
        if ($cloudLine) {
            $cloudProvider = ($cloudLine -split '=', 2)[1]
        }
    }
}

if (-not $cloudProvider) {
    Write-Error "Error: Cloud provider not configured.`nSet SPECIFY_CLOUD_PROVIDER environment variable or run 'specify init' to configure."
    exit 1
}

# Validate cloud provider
switch ($cloudProvider.ToLower()) {
    { $_ -in 'azure', 'Azure', 'AZURE' } { 
        $cloudProvider = 'Azure' 
    }
    { $_ -in 'aws', 'AWS' } {
        Write-Error "Error: AWS support coming soon."
        exit 1
    }
    { $_ -in 'gcp', 'GCP', 'google', 'Google' } {
        Write-Error "Error: Google Cloud support coming soon."
        exit 1
    }
    default {
        Write-Error "Error: Unknown cloud provider '$cloudProvider'. Supported: azure (aws and gcp coming soon)"
        exit 1
    }
}

# Create specs directory if it doesn't exist
$specsDir = Join-Path $repoRoot 'specs'
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null

# Find highest numbered spec directory
$highest = 0
if (Test-Path $specsDir) {
    Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
        if ($_.Name -match '^(\d{3})') {
            $num = [int]$matches[1]
            if ($num -gt $highest) { $highest = $num }
        }
    }
}
$next = $highest + 1
$discoveryNum = ('{0:000}' -f $next)

# Create discovery session name
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$sessionName = "discovery-$($cloudProvider.ToLower())-$timestamp"
$branchName = "$discoveryNum-$sessionName"

# Create new branch if using git
if ($hasGit) {
    try {
        git checkout -b $branchName | Out-Null
    } catch {
        Write-Warning "Failed to create git branch: $branchName"
    }
} else {
    Write-Warning "[specify] Warning: Git repository not detected; skipped branch creation for $branchName"
}

# Create discovery directory
$discoveryDir = Join-Path $specsDir $branchName
New-Item -ItemType Directory -Path $discoveryDir -Force | Out-Null

# Copy discovery template
$template = Join-Path $repoRoot '.specify/templates/discovery-template.md'
$discoveryFile = Join-Path $discoveryDir 'discovery.md'
if (Test-Path $template) { 
    Copy-Item $template $discoveryFile -Force 
} else { 
    New-Item -ItemType File -Path $discoveryFile | Out-Null
    Write-Warning "Discovery template not found at $template"
}

# Set environment variables for current session
$env:SPECIFY_DISCOVERY = $branchName
$env:SPECIFY_CLOUD_PROVIDER = $cloudProvider

# Output results
if ($Json) {
    $obj = [PSCustomObject]@{ 
        BRANCH_NAME = $branchName
        DISCOVERY_FILE = $discoveryFile
        DISCOVERY_DIR = $discoveryDir
        CLOUD_PROVIDER = $cloudProvider
        TAG_FILTER = $tagFilterStr
        DISCOVERY_NUM = $discoveryNum
        SESSION_NAME = $sessionName
        HAS_GIT = $hasGit
    }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "DISCOVERY_FILE: $discoveryFile"
    Write-Output "DISCOVERY_DIR: $discoveryDir"
    Write-Output "CLOUD_PROVIDER: $cloudProvider"
    Write-Output "TAG_FILTER: $(if ($tagFilterStr) { $tagFilterStr } else { '<none - discover all>' })"
    Write-Output "DISCOVERY_NUM: $discoveryNum"
    Write-Output "SESSION_NAME: $sessionName"
    Write-Output "HAS_GIT: $hasGit"
    Write-Output "SPECIFY_DISCOVERY environment variable set to: $branchName"
}
