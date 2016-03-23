Function Connect-YouTrack { 

<#
.SYNOPSIS 
Establishes a connection to the JetBrains YouTrack REST API. 

.DESCRIPTION 
The Connect-YouTrack cmdlet sends a POST request method to the YouTrack REST API to authenticate and returns the web request session object. 

The cmdlet can store the web request session object for use in subsequent web requests by specifing the session variable in the value of the WebSession parameter. 

The cmdlet uses the response object for HTML content without Document Object Model (DOM) parsing, this is required when Internet Explorer is not installed

The cmdlet requires Windows PowerShell 3.0. 

.PARAMETER YouTrackUri
Specify the Uri of the JetBrains YouTrack web server.

.PARAMETER Username
Specify the username to use for authenticating with JetBrains YouTrack REST API.

.PARAMETER Password 
Specify the password to use for authenticating with JetBrains YouTrack REST API.

.EXAMPLE 
PS C:\> Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 

This command uses the Connect-YouTrack cmdlet to establish a connection to the JetBrains YouTrack web server 'http://server1' and connects with the login credentials of the administrator account. 

.EXAMPLE 
PS C:\> $SessionState = Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 

This command uses the Connect-YouTrack cmdlet to establish a connection to the JetBrains YouTrack web server 'http://server1' and connects with the login credentials of the administrator account. 

The cmdlet stores the web request session object as the variable 'SessionState' for user in subsequent web requests. 

.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the Connect-YouTrack cmdlet. 

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/Connect-YouTrack.ps1
#> 

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][String] $YouTrackUri,
    [Parameter(Mandatory=$True)][String] $Username,
    [Parameter(Mandatory=$True)][String] $Password
    )

Begin
    {
    } # Begin 

Process
    {
    Try
        {
        # Sends a POST request method to the specified YouTrack URI specifying login credentials and stores  the web request session as the variable 'WebSession'. 
        Write-Verbose ("Establishing a connection to the JetBrains YouTrack REST API " + $YouTrackUri + " authenticating as the user " + $Username + ".")
        Invoke-WebRequest -Method Post -Uri "$YouTrackUri/rest/user/login?login=$Username&password=$Password" -SessionVariable WebSession -UseBasicParsing | Out-Null
        } # Try 
    Catch
        {
        Write-Error ("Failed to establish a connection to the REST API with the following exception message " + $_.Exception.Message + ".")
        Break 
        } # Catch
    } # Process

End
    {
    # Returns the web request session object value.
    Write-Verbose ("Returning the web request session value for the established connection.")
    return $WebSession 
    } # End 

} # Function 
