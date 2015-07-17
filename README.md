# PowerCredential
Module for secure storage/retreival of PSCredential objects


A set of PowerShell Cmdlets for encrypting/decrypting PSCredential objects that can then stored and retreived.  

Designed to be used in scripts to prevent hardcoded credentials.  
By utilizing the Machine-level RSA key container, any administrator on the machine containing the stored credentials can then have access to them.

Can even be called from other types of scripts, such as Batch files, that do not have any built-in functionality of storing credentials, other than in plaintext.  
*See included GetCredential.bat (can be placed in a location listed in PATH environment var and called as a command)
