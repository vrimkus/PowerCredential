@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'PowerCredential.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '4e359874-a4d4-4e1a-99e9-92f2b118460b'

# Author of this module
Author = 'coolmacool'

# Company or vendor of this module
CompanyName = 'N3T Technologies'

# Copyright statement for this module
Copyright = 'BSD 3-Clause'

# Description of the functionality provided by this module
Description = 'PowerCredential Secure Credential Handling Module'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module
AliasesToExport = ''

# List of all modules packaged with this module
ModuleList = @(@{ModuleName = 'PowerCredential'; ModuleVersion = '1.0.0.0'; GUID = '4e359874-a4d4-4e1a-99e9-92f2b118460b'})

# List of all files packaged with this module
FileList = 'PowerCredential.psm1', 'PowerCredential.psd1', 
           'Get-PowerCredential.ps1', 'Set-PowerCredential.ps1', 
           'Remove-PowerCredential.ps1', 'Get-RSAPowerCredentialProvider.ps1'

# Private data to pass to the module specified in ModuleToProcess
# PrivateData = ''

}

