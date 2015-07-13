<#
.SYNOPSIS
    This function will return an RSACryptoServiceProvider object for use with PowerCredential cmdlets.  

.DESCRIPTION
    The Get-RSAPowerCredential will return an RSACryptoServiceProvider object for use with PowerCredential cmdlets.
#>

Function Get-RSAPowerCredentialProvider
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$false )]
        [ValidateCount(32,32)]
        [Byte[]]$StaticKey = (0x50,0x6f,0x77,0x65,0x72,0x43,0x72,0x65,
                              0x64,0x65,0x6e,0x74,0x69,0x61,0x6c,0x20,
                              0x62,0x79,0x3a,0x20,0x56,0x69,0x6e,0x63,
                              0x65,0x20,0x52,0x69,0x6d,0x6b,0x75,0x73)
    )

    $Param = @{
        ArgumentList = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    }
    $CurrentUser = New-Object -TypeName System.Security.Principal.WindowsPrincipal @Param

    if (-not $? -or -not $CurrentUser.IsInRole("Administrators")) 
    {
        $Param = @{
            ArgumentList = 'Access denied, this function can only be run with Administrator privileges.'
        }
        throw New-Object -TypeName System.UnauthorizedAccessException @Param
    }

    # Create Machine Key Container "PowerCredential" if it does not already exist
    $Csp = New-Object -TypeName System.Security.Cryptography.CspParameters
    $Csp.KeyContainerName = "PowerCredential"
    $Csp.Flags = [System.Security.Cryptography.CspProviderFlags]::UseMachineKeyStore

    $RSA = New-Object -TypeName System.Security.Cryptography.RSACryptoServiceProvider -ArgumentList 4096,$Csp
    $RSA.PersistKeyInCsp = $true         
    $RSA | Add-Member -MemberType NoteProperty -Name StaticKey -Value $StaticKey

    $RSA
}