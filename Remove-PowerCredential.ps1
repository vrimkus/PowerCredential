<#
.SYNOPSIS
    This function will remove the cached PowerCredential (if it exists) for the specified UserNames.  

.DESCRIPTION
    The Remove-PowerCredential cmdlet will remove the cached PowerCredential (if it exists) for the specified UserNames.  The cmdlet can be used to remove one or multiple cached PowerCredentials.
.PARAMETER UserName
    The UserName for which to remove any cached PowerCredential that exists on the machine.  If an array of UserNames is provided, the Remove-PowerCredential cmdlet will remove any that exist on the machine.
.EXAMPLE
    PS C:\>Remove-PowerCredential testusername

    If there is a cached PowerCredential on the machine matching the specified UserName, 
    this command remove the PowerCrendtial file from the machine.

.TBD 
    Add Confirmation [switch] Paramater
#>

Function Remove-PowerCredential
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$true, Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [Alias('User','Name')]
        [String[]]$UserName
    )
	Begin 
	{
        Write-Verbose 'Initializing...'
	}
	Process
	{
		Write-Verbose 'Processing input data...'
		Foreach ($User in $UserName) 
		{
			# Loop through array of provided UserNames, removing each
			$CredentialFile = "$CredentialDirectoryPath\$User.pcr"
		
			If (-not (Test-Path -Path $CredentialFile)) 
			{ 
				Write-Output "There are no cached credentials for $User"
				Break
			}
		
			Remove-Item -Path $CredentialFile -Force
		}
	}
	End 
	{
        Write-Verbose 'Finishing...'
		# Remove Domain directory if it is empty
		$DomainDirectory = Split-Path -Path $CredentialFile
		$CredentialCount = (Get-ChildItem -Path $DomainDirectory | Measure-Object).Count
		If ($CredentialCount -eq 0) 
            { Remove-Item -Path $DomainDirectory | Where { $_.PSIsContainer } }
    }    
}