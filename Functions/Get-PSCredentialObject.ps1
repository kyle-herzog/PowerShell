Function Get-PSCredentialObject { 

<#
.SYNOPSIS
Creates PSCredential object.

.DESCRIPTION
The Get-PSCredentialObject cmdlet converts an encrypted standard string from content in a file using a specified encryption key to a secure string. 

The cmdlet creates a PSCredential object from the specified username and the returned secure string content and returns the password value. 

The cmdlet requires Windows PowerShell 3.0. 

.PARAMETER Username
Specify the username for the PSCredential object. 

.PARAMETER KeyFile
Specify the location of the encryption key to convert the secure string.

.PARAMETER PasswordFile
Specify the location of the file containing the encrypted standard string to convert the secure string.

.EXAMPLE
PS C:> Get-PSCredentialObject -Username administrator -KeyFile D:\Output\Key\mykeys.key -PasswordFile D:\Output\Passwords\mypassword.txt

This command uses the Get-PSCredentialObject cmdlet to convert the encrypted standard string in the file D:\Output\Password\mypassword.txt to a secure string using the encryption key D:\Output\Keys\mykey.key for the credential object 'administrator'.

.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the Get-PSCredentialObject cmdlet. 

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/Get-PSCredentialObject.ps1
#> 

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][String] $Username,
    [Parameter(Mandatory=$True)][ValidateScript({Get-Item $_ })][String] $KeyFile,
    [Parameter(Mandatory=$True)][ValidateScript({Get-Item $_ })][String] $PasswordFile
)

Begin 
    {
    } # Begin 

Process
    {
    Try
        {
        # Retrieves the content of the encrypted standard string and converts to a secure string using the specified encryption key.
        Write-Verbose ("Retrieving the encrypted standard string content from the file " + $PasswordFile + " and converting to a secure string using the encryption key " + $KeyFile + ".")
        $Password = Get-Content $PasswordFile | ConvertTo-SecureString -Key (Get-Content $KeyFile)
        # Creates PSCredential object from the specified username and converted secure string.
        Write-Verbose ("Creating a PSCredential object for the username " + $Username + ".")
        $Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password
        # Returns the password value for the PSCredential object.
        return $Credentials 
        } # Try 
    Catch
        {
        Write-Error ("Failed to create a PSCredential object with the following exception " + $_.Exception.Message + ".")
        Break 
        } # Catch 
    } # Process 

End 
    {
    } # End 

} # Function 

