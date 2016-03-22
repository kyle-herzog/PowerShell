Function New-EncryptedString {

<#
.SYNOPSIS
Creates a encrypted standard string file.

.DESCRIPTION 
The New-Encrypted String cmdlet converts the secure string for a credential object password using the specified encryption key and sends the output to a password file. 

The cmdlet requires Windows PowerShell 3.0. 

.PARAMETER KeyFile
Specify the location of the encryption key to convert the secure string.

.PARAMETER Output
Specify the location to create the file containing the converted encrypted standard string. 

.EXAMPLE 
PS C:\> New-EncryptedString -KeyFile D:\Output\Keys\mykey.key -Output D:\Output\Passwords\mypassword.txt

This command uses the New-EncryptedString cmdlet to create an encrypted standard string with the encryption key D:\Output\Keys\mykey.key and send the output to D:\Output\Passwords\mypassword.txt.

.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the New-EncryptedString cmdlet. 

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/New-EncryptedString.ps1
#> 

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][ValidateScript({Get-Item $_})][String] $KeyFile,
    [Parameter(Mandatory=$True)][ValidateScript({Get-Item (Split-Path $_ -Parent)})][String] $Output
)

Begin
    {
    } # Begin 

Process
    {
    Try
        {
        # Retrieves the content of the specified encryption file. 
        Write-Verbose ("Retrieving the content of the encryption file " + $KeyFile + ".")
        $Key = Get-Content $KeyFile 
        # Creates credential object for the specified username and password. 
        $Credentials = Get-Credential 
        # Converts the secure string of the password to an encrypted standard string using the specified encryption key and sends output to the specified location. 
        Write-Verbose ("Converting the secure string to an encrypted standard string at the location " + $Output + ".")
        $Credentials.Password | ConvertFrom-SecureString -Key $Key | Set-Content $Output
        } # Try 
    Catch
        {
        Write-Error ("Failed to create encrypted standard string file with the following exception " + $_.Exception.Message + ".")
        Break 
        } # Catch 
    } # Process

End
    {
    Write-Verbose ("Removing the contents of the encryption key from the current session.")
    $Key.Clear()
    } # End 

} # Function 