Function New-EncryptionKey { 

<#
.SYNOPSIS
Creates an encryption key. 

.DESCRIPTION
The New-EncryptionKey cmdlet creates an Advanced Encryption Standard (AES) encryption key to retrieve encrypted standard strings and convert to a secure string.

The cmdlet creates a random byte array using the Security.Cryptogtaphy.RNGCryptoServiceProvider class and sends output to the encryption key file. 

The cmdlet supports 128-bit, 192-bit and 256-bit (default) AES encryption lengths. 

.PARAMETER Bytes
Specify the number of bytes to support the encryption length, 128-bit (16), 192-bit (24) and 256 (32) . By default, a random 32-byte array is generated. 

.PARAMETER Output 
Specify the location to create the AES encryption key item. 

.EXAMPLE 
PS C:\> New-EncryptionKey -Output D:\Output\Keys\mykey.key 

This command uses the New-EncryptionKey cmdlet to create the encryption key D:\Output\Keys\mykey.key with the default AES 256-bit encryption length.

.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the New-EncryptionKey cmdlet. 

.LINK 

#> 

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][ValidateScript({Get-Item (Split-Path $_ -Parent)})][String] $Output,
    [ValidateSet("16","24","32")][Int] $Bytes = "32"
)


Begin
    {
    # Switch statement to determine encryption length from specified number of bytes.
    Switch ($Bytes)
        {
        '16' {$Encryption = "128"} # AES 128-bit
        '24' {$Encryption = "192"} # AES 192-bit
        '32' {$Encryption = "256"} # AES 256-bit
        } 
    } # Begin 

Process
    {
    Try
        {
        # Creates instance of a .NET Framework object
        Write-Verbose ("Creating byte array with " + $Bytes + " bytes to support AES " + $Encryption + "-bit encryption length.")
        $Key = New-Object Byte[] $Bytes
        # Generates a random byte array using the Security.Cryptogtaphy.RNGCryptoServiceProvider class.
        Write-Verbose ("Generating random " + $Bytes + "-byte array.")
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        # Sends output to the specified location of the encryption key. 
        Write-Verbose ("Creating encryption key at the location " + $Output + ".")
        $Key | Out-File $Output 
        } # Try 
    Catch
        {
        Write-Error ("Failed to create encryption key with the following exception " + $_.Exception.Message + ".")
        Break 
        } # Catch 
    } # Process 

End
    {
    # Removes the contents of the random byte array from the current session.
    If ($Key)
        {
        Write-Verbose ("Removing contents of the random byte array from the current session.")
        $Key.Clear()
        } # If 
    } # End 

} # Function 