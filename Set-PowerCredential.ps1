<#
.SYNOPSIS
    This function will create cached PowerCredentials for the specified UserName.  

.DESCRIPTION
    The Set-PowerCredential cmdlet will create cached PowerCredentials for the specified UserName.  Credentials are stored inside of a directory called PowerCred, located in the currently logged on user's profile path %USERPROFILE%\PowerCred.  The credentials are stored in a PowerCredential file (.pcr) with the cached UserName as a BaseName.  The PowerCredential file contains System.Security.SecureString type binary data for the cached password.
.PARAMETER UserName
    The UserName for storing a cached PowerCredential.  If the UserName provided matches any of the currently cached PowerCredentials, the Set-PowerCredential cmdlet will overwrite the currently cached PowerCredential with the most recently supplied one without prompting the user.
.EXAMPLE
    PS C:\>Set-PowerCredential testusername

    UserName                                                                  Password
    --------                                                                  --------
    testusername                                          System.Security.SecureString



    The Set-PowerCredential cmdlet will call the Get-Credential cmdlet for the specified user.  
    The returned object is then stored in a secure location only accessible (by default)
    to the current user or members of the Administrators security group.


.TBD
    Add Credential ParameterSet
#>

Function Set-PowerCredential
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$true, Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullorEmpty()]
        [Alias('User','Name')]
        [String]$UserName
    )
    Begin 
	{
        Write-Verbose 'Initializing...'
		Try { $Credential = Get-Credential -Credential $UserName } 
        Catch 
        { 
            $Param = @{
                TypeName     = 'System.IO.InvalidDataException'
                ArgumentList = 'You must specify a credential object to be stored.'  
            }
            throw New-Object @Param
        }
	}
	Process
	{
		Write-Verbose 'Processing input data...'

		# Get Credential information
		$Domain = $Credential.GetNetworkCredential().Domain
		$User = $Credential.UserName
		$Password = $Credential.Password
		
		# Create directories if they do not exist then store password in account file
		If (-not (Test-Path -Path "$CredentialDirectoryPath"))         
            { [void](New-Item -Path "$CredentialDirectoryPath" -ItemType Directory) }
		
        If (-not (Test-Path -Path "$CredentialDirectoryPath\$Domain")) 
            { [void](New-Item -Path "$CredentialDirectoryPath\$Domain" -ItemType Directory) }
        
        try
        {
            $RSA = Get-RSAPowerCredentialProvider
            $PasswordSecureString = ConvertFrom-SecureString -SecureString $Password -Key $RSA.StaticKey
            $PasswordBytes = [Text.Encoding]::UTF8.GetBytes($PasswordSecureString)
            $RSA.Encrypt($PasswordBytes, $true) | 
                Set-Content -Encoding Byte -Path "$CredentialDirectoryPath\$User.pcr"
        }
        catch 
        { 
            $Param = @{
                TypeName     = 'System.Security.Cryptography.CryptographicException'
                ArgumentList = 'An error occurred while attempting to encrypt PowerCredential data.' 
            }
            throw New-Object @Param
        }
        finally { $RSA.Clear() }
	}
	End 
	{
        Write-Verbose 'Finishing...'
    }   
}