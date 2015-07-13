# Initialize module scope variables
$DefaultDomain = 'SAMUELS'
$CredentialDirectory = 'PowerCred'
$CredentialDirectoryPath = "$env:USERPROFILE\$CredentialDirectory"

# Dot Source script files
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath *.ps1) | ForEach { . $_.FullName}