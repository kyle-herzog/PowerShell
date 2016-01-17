<#
.SYNOPSIS
Creates secure credential object. 
.DESCRIPTION 
The script will create an AES 256-bt encryption key using the RNG cryptography service provider. The encryption key is then used to create a secure credential object that may be used in security operations.
The script will prompt the user for a password for the specified username provided. By default, an authentication dialog box appears to prompt the user.
The script requires Windows PowerShell 3.0 
.PARAMETER Username
Specify the username for the secure credential object. 
.PARAMETER KeyFile
Specify the location to create the encryption key item. 
.PARAMETER PasswordFile 
Specify the location to create the password item for the secure credential object. 
.PARAMETER Verify 
Verifies that the secure credential object that you have created may be decrypted. By default, this will return the password as a string to the current session.
.PARAMETER VerifyOnly 
Verifies an existing secure object may be decrypted. By default, this will return the password as a string to the current session.
.EXAMPLE
PS C:\> New-SecureCredentialObject.ps1 -Username user1 -KeyFile C:\Keys\user1.key -PasswordFile C:\Passwords\user1.password
The command creates the encryption key C:\Keys\user1.key and creates the secure object C:\Passwords\user1.password containing the password item. 
.EXAMPLE
PS C:\> New-SecureCredentialObject.ps1 -Username user1 -KeyFile C:\Keys\user1.key -PasswordFile C:\Passwords\user1.password -Verify
The command creates the encryption key C:\Keys\user1.key and creates the secure object C:\Passwords\user1.password containing the password item. 
By specifying the verify switch the secure object is decrypted using the encryption key and returns the content of the password item to the current session. 
.EXAMPLE
PS C:\> New-SecureCredentialObject.ps1 -Username user1 -KeyFile C:\Keys\user1.key -PasswordFile C:\Passwords\user1.password -VerifyOnly
This command attempts to decrypt the secure object item C:\Passwords\user1.password with the existing encryption key C:\Keys\user1.key and returns the content password item to the current session.
.NOTES
Author:  		Dean Grant, Sumerian Europe Ltd.
Date:           Wednesday, 1st July 2015
Version:        1.0
Release Notes:  1) CP-2777 - Initial commit of Windows PowerShell script 'New-SecureCredentialObject'. 
.LINK
#> 


[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$true)][String] $Username,
    [Parameter(Mandatory=$true)][String] $KeyFile,
    [Parameter(Mandatory=$true)][String] $PasswordFile,
    [Switch] $Verify,
    [Switch] $VerifyOnly
) 

Begin
    {

    # Function to log output to the current session.
    Function Write-Log($Event)
        {
        Write-Host $Event
        } # Function 

    } # Begin 

Process
    {

    # Conditional logic to determine if the verify only switch parameter has been specified.
    If (!($VerifyOnly))
        {
        # Creates AES 256-bt encryption key using the RNG cryptography service provider to the specified location. 
        Try
            {
            Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Creating AES 256-bt encryption key using the RNG cryptography service provider.")  
	        $Key = New-Object Byte[] 32
	        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
	        $Key | Out-File $KeyFile
            } # Try 
        Catch
            { 
            # Returns error exception message and exits.
            Write-Log ("" + (Get-Date -Format s) + ": ERROR: Failed to create encryption key with the following exception message: " + $Error[0].Exception.Message + ".")
            Break 
            } # Catch 
        Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Successfully created the encryption key at " + $KeyFile + ".") 

        # Creates secure credential object and encrypts password supplied with the encryption key. 
        Try
            {
            Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Retrieving content for the encryption key.") 
            $Key = Get-Content $KeyFile
	        $Credentials = Get-Credential -Credential $Username 
            Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Creating secure credential object for the password string provided.")
	        $Credentials.Password | ConvertFrom-SecureString -Key $Key | Set-Content $PasswordFile
            } # Try 
        Catch
            {
            # Returns error exception message and exits.
            Write-Log ("" + (Get-Date -Format s) + ": ERROR: Failed to create secure credential object with the following exception message: " + $Error[0].Exception.Message + ".")
            Break 
            } # Catch
        Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Successfully created secure credential object at " + $PasswordFile + ".") 
        } # If 

        # Conditional logic to determine if the verify switch has been provided. 
        If ($Verify -or $VerifyOnly)
            {
            Try
                {
                Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: The verify or verify only switch parameter has been specifed")
                Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Attempting to decrypt the secure object " + $PasswordFile + " with the encryption key " + $KeyFile + ".") 
                $Key = Get-Content $KeyFile
                $Password = Get-Content ($PasswordFile) | ConvertTo-SecureString -Key $Key
	            $Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password
	            $Password = $Credentials.GetNetworkCredential().Password
                } # Try 
            Catch
                {
                # Returns error exception message and exits.
                Write-Log ("" + (Get-Date -Format s) + ": ERROR: Failed to create secure credential object with the following exception message: " + $Error[0].Exception.Message + ".")
                Break 
                } # Catch 
            Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: The secure object has been successfully decrypted and contains the content: " + $Password + ".")
            } # If 

        # Removes variables from the current session from memory. 
        Write-Log ("" + (Get-Date -Format s) + ": INFORMATION: Removing variables used to create secure object in the current session from memory.") 
        Get-Variable | Where-Object {$SessionVariables -notcontains $_.Name} | ForEach-Object { Remove-Variable -Name $_.Name -Scope Global -Force -ErrorAction SilentlyContinue} 

    } # Process 

End {} # End 