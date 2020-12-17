#PSScriptAnalyzer rule excludes
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]

param(
    [Parameter()]
    [switch]$CodeCoverage,
    $Color = "Green"
)

Write-Host "Installing dependencies..." -ForegroundColor $Color

# DbaTools
if (!(Get-Module -ListAvailable -Name DbaTools)) {
    $DbaToolsJob = Start-Job -ScriptBlock { Install-Module DbaTools -Force -AllowClobber }
}

# Pester
if (!(Get-InstalledModule -Name Pester -MaximumVersion 5.0.9 -ErrorAction SilentlyContinue)) {
    Install-Module Pester -Force -AllowClobber -WarningAction SilentlyContinue -SkipPublisherCheck -MaximumVersion 5.0.9
}

if (!(Get-Module -Name Pester | Where-Object { $PSItem.Version -lt 5.0.0 })) {
    if (Get-Module -Name Pester) {
        Remove-Module Pester -Force
    }
    Import-Module Pester -MaximumVersion 5.0.9
}

# GoEddie SQLCover
If ($CodeCoverage.IsPresent) {
    # Install code coverage tool
    If (!(Get-Package -Name GOEddie.SQLCover -ErrorAction SilentlyContinue)) {
        Install-Package GOEddie.SQLCover -Force | Out-Null
    }

    # Install codecov tracker
    choco install codecov --no-progress --limit-output | Out-Null
}

If ($DbaToolsJob) {
    Wait-Job $DbaToolsJob.Id | Out-Null
}
