<#
.SYNOPSIS
    Extended Get-Credential function that retrieves cached PowerCredentials for secure script automation.  
.DESCRIPTION
    The Get-PowerCredential cmdlet is an extended Get-Credential function that retrieves cached PowerCredentials for secure script automation.  Executing Get-PowerCredential without an parameters will list all of the currently cached PowerCredentials and allow selection of desired PowerCredential.
.PARAMETER UserName
    The UserName for retrieving a cached PowerCredential.  If the UserName provided does not match any of the currently cached PowerCredentials, the Get-PowerCredential cmdlet will prompt the user as to whether they would like to create cached credentials or temporarily use a credential (the default response is to create a new cached PowerCredential).
.EXAMPLE
    PS C:\>Get-PowerCredential testusername

    UserName                                                                  Password
    --------                                                                  --------
    testusername                                          System.Security.SecureString



    If there is cached PowerCredential on the machine matching the specified UserName, 
    this command returns a System.Management.Automation.PsCredential object for the 
    cached UserName & Password combination. 
.EXAMPLE
    PS C:\>Get-PowerCredential testusername

    There are no cached credentials for testusername
    Would you like to cache credentials now?
    [Y] Yes  [N] No - to use temporary credentials (default is "Y"): 


        
    If there is not a cached PowerCredential on the machine matching the specified UserName, 
    this command will prompt the user to select whether to create a new cached PowerCredential 
    or to enter a password and temporarily use the returned System.Management.Automation.PsCredential 
    in the current command or pipeline. If the user chooses Yes, the Set-PowerCredential cmdlet
    is called with the previously supplied UserName as input.
.EXAMPLE
    PS C:\>Get-PowerCredential -ListAvailable

    Record Domain UserName  
    ------ ------ --------  
         1        storeadmin


    Select a credential record from the list:



    If the ListAvaible flag parameter is supplied, the function will display any cached PowerCredentials that exist on the machine, 
    and allow the user to select the desired one for use in a command or pipeline.
.TBD
    Add Credential ParameterSet
#>

Function Get-PowerCredential
{
    [CmdletBinding(DefaultParametersetName="Default")]
    Param(
        [Parameter( Mandatory=$True, 
                    ParameterSetName="Default", Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()] 
        [Alias('User','Name')]
        [string]$UserName,

        [Parameter( Mandatory=$True, ParameterSetName="List")]
        [Alias('l')]
        [switch]$ListAvailable
    )
	Begin 
	{
        Write-Verbose 'Initializing...'
		$ErrorActionPreference = 'SilentlyContinue'
	}
	Process 
	{
	    If ($ListAvailable) 
        {
            Write-Verbose 'Listing avaiable PowerCredentials...'
            $RecordIndex = 1
			# List all cached credentials if no UserName is specified
			If ((Get-ChildItem -Path ("$CredentialDirectoryPath") | Measure-Object).Count -gt 0) 
			{
				Get-ChildItem -Path "$CredentialDirectoryPath" -Recurse | 
                Where {-not $_.PSIsContainer} | 
				ForEach { 
					$Domain = Split-Path (Split-Path $_.FullName -Parent) -Leaf
					If ($Domain -eq "$CredentialDirectory") { $Domain = $null }

					New-Object -TypeName PSObject -Property @{
						'Record'   = $RecordIndex
						'UserName' = $_.BaseName 
						'Domain'   = $Domain
					}
                    $RecordIndex++
				} | Tee-Object -Variable Results | Format-Table -Property 'Record', 'Domain', 'UserName' -AutoSize
			}
		} 
		Else 
		{
            Write-Verbose 'Processing input UserName...'

			# Username was supplied so retreive credential
			$CredentialFile = "$CredentialDirectoryPath\$UserName.pcr"

			If (-not (Test-Path -Path $CredentialFile)) 
			{ 
                # Double check DefaultDomain directory to catch omitted default domain credentials
                if (Test-Path -Path "$CredentialDirectoryPath\$DefaultDomain\$UserName.pcr")
                {
                    $CredentialFile = "$CredentialDirectoryPath\$DefaultDomain\$UserName.pcr"
                }
                else
                {
				    # Present options for storing credential, or using temporary
				    Write-Output "There are no cached credentials for $UserName"
				
				    While ($true)
				    {
                        # Have to use Write-Host for the Foreground color
                        # TBD Create ProxyCommand with custom confirmation
					    Write-Host 'Would you like to cache credentials now?'
					    Write-Host '[Y] Yes  ' -ForegroundColor Yellow -NoNewline
					    Write-Host '[N] No - to use temporary credentials (default is "Y"): ' -NoNewline
					    $Option = Read-Host
                        
                        #Default or 'y'
					    If (([String]::IsNullOrEmpty($Option.ToLower())) -or ($Option.ToLower() -eq 'y')) 
					    { 
						    $Credential = Set-PowerCredential -UserName $UserName 
						    Break
					    }
					    ElseIf ($Option.ToLower() -eq "n") 
					    { 
						    $Credential = Get-Credential -Credential $UserName 
						    Break
					    }
				    }
                }
			}
		
			# Retest for cached credentials
			If (Test-Path -Path $CredentialFile) 
			{ 
                try
                {
                    $RSA = Get-RSAPowerCredentialProvider
                    $EncryptedPassword = Get-Content -Encoding Byte -Path $CredentialFile
                    $Password = [Text.Encoding]::UTF8.GetString($RSA.Decrypt($EncryptedPassword, $true)) | 
                                    ConvertTo-SecureString -Key $RSA.StaticKey
                }
                catch 
                { 
                    $Param = @{
                        TypeName = 'System.Security.Cryptography.CryptographicException'
                        ArgumentList = 'An error occurred while attempting to decrypt PowerCredential data.' 
                    } 
                    throw New-Object @Param
                }
                finally { $RSA.Clear() }
			} 
			Else 
			{ 
				$Password = New-Object -TypeName System.Security.SecureString 
			}

			If (-not $Credential) 
            {
                $Param = @{
                    ArgumentList = @()
                }

                $UserData = $UserName -split '\\'
                if ($UserData.Count -gt 1)
                {
                    # User supplied domain in UserName Parameter
                    $Domain     = $UserData[0]
                    $UserName   = $UserData[1]
                    $Param.ArgumentList = @("$Domain\$UserName",$Password)
                }
                else
                {
                    # User did not supply domain, catch default domain credentialfile
                    $Domain = Split-Path -Path (Split-Path -Path $CredentialFile) -Leaf 
                    If ($Domain -ne $CredentialDirectory)
                        { $Param.ArgumentList = @("$Domain\$UserName",$Password) }
                    else
                        { $Param.ArgumentList =  @($UserName,$Password) }
                }
                $Credential = New-Object -TypeName System.Management.Automation.PsCredential @Param
            }

            # Return Credential Object
            $Credential
		}
	}
	End 
	{
        Write-Verbose 'Finishing...'
    }    
}