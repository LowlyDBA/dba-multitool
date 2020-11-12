param( 
    [Parameter()] 
    $Color = "Green"
)

Write-Host "Installing dependencies..." -ForegroundColor $Color

# TSQLLinter
# Try/Catch to stop appveyor unnecessary errors
$result = npm list -g --depth=0
If (-Not ($result -Match "tsqllint")) {
    npm install tsqllint -g | Out-Null 
}

# DbaTools Module
if (!(Get-Module -ListAvailable -Name DbaTools)) {
    Install-Module DbaTools -Force -AllowClobber
}

# Pester Module
Install-Module Pester -Force -AllowClobber -WarningAction SilentlyContinue