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

# SQLServer Module
#if (!(Get-Module -ListAvailable -Name SqlServer)) {
#    Install-Module SqlServer -Force -AllowClobber
#}

# DbaTools Module
if (!(Get-Module -ListAvailable -Name DbaTools)) {
    Install-Module DbaTools -Force -AllowClobber
}

# Suppress DbaTools warning about SqlServer module also being loaded
Set-DbatoolsConfig -Name Import.SqlpsCheck -Value $false -PassThru | Register-DbatoolsConfig

# Pester Module
Install-Module Pester -Force -AllowClobber -WarningAction SilentlyContinue

# Invoke-SqlCmd2 Module
if (!(Get-Module -ListAvailable -Name Invoke-SqlCmd2)) {
    Install-Module Invoke-SqlCmd2 -Force -AllowClobber
}