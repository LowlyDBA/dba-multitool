﻿using namespace System.IO.Path

param( 
    [Parameter()] 
    $LocalTest = $false,
    $SqlInstance = $env:DB_INSTANCE,
    $Database = $env:TARGET_DB,
    $TrustedConnection = "yes",
    $ConnString = "server=$SqlInstance;initial catalog=$Database;Trusted_Connection=$TrustedConnection",
    $ReportDest = $PSSCriptRoot,
    $CoverageXML = $env:COV_REPORT,
    $Color = "Green"
    )

# Setup files
$NugetPath = (Get-Package GOEddie.SQLCover).Source | Convert-Path
$SQLCoverRoot = Split-Path $NugetPath
$SQLCoverPath = Join-Path $SQLCoverRoot "lib"
$SQLCoverDllFullPath = Join-Path $SQLCoverPath "SQLCover.dll"

# Add DLL
Add-Type -Path $SQLCoverDllFullPath

# Start covering
Write-Host "Starting SQLCover..." -ForegroundColor $Color
$SQLCover = new-object SQLCover.CodeCoverage($ConnString, $Database)
$IsCoverStarted = $SQLCover.Start()

If ($IsCoverStarted) {
    # Run Tests
    . .\appveyor\run_tsqlt_tests.ps1 -SqlInstance $SqlInstance -Database $Database

    # Stop covering 
    Write-Host "Stopping SQLCover..." -ForegroundColor $Color
    $coverageResults = $SQLCover.Stop()

    # Export results
    Write-Host "Generating code coverage report..." -ForegroundColor $Color
    If (!($LocalTest)) {
        $xmlPath = Join-Path -Path $ReportDest -ChildPath $CoverageXML
        $coverageResults.OpenCoverXml() | Out-File $xmlPath -Encoding utf8
        $coverageResults.SaveSourceFiles($ReportDest)    
    }
    Else { # Don't save any files and bring up html report for review
        $tmpFile = Join-Path $env:TEMP "Coverage.html"
        Set-Content -Path $tmpFile -Value $coverageResults.Html2() -Force
        Invoke-Item $tmpFile
        Start-Sleep -Seconds 1
        Remove-Item $tmpFile
    }
}
Else {
    Write-Error "Could not start SQLCover - investigate issue."
}