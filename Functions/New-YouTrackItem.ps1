Function New-YouTrackItem {

<#
.SYNOPSIS
Creates a new item in a JetBrains YouTrack project. 

.DESCRIPTION 
TheNew-YouTrackItem cmdlet sends a PUT request method to create a new item for a specified project in YouTrack JetBrains, creating both a summary and description of the item. 

The cmdlet requires a web request session variable for authentication and returns the value of the project item issue number using a regular expression pattern match from the response header information.

The cmdlet uses the response object for HTML content without Document Object Model (DOM) parsing, this is required when Internet Explorer is not installed.

The cmdlet requires Windows PowerShell 3.0. 

.PARAMETER YouTrackUri
Specify the Uri of the JetBrains YouTrack web server.

.PARAMETER Project 
Specify the name of the project to create the item. 

.PARAMETER Summary
Specify the summary information for the item. 

.PARAMETER Description 
Specify the description information for the item.

.PARAMETER SessionState 
Specify the web request session value to use for authentication agaisnt the JetBrains YouTrack web server. 

.EXAMPLE 
PS C:> $SessionState = Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 
PS C:> New-YouTrackItem -YouTrackUri http://server1 -Project Incident -Summary "Item Summary" -Description "Item Description" -SessionState $SessionState 

This command creates a new item in the project 'Incident' for the JetBrains YouTrack web server 'http://server1' using the web request session object variable 'SessionState'. 

This command creates a new item with the summary information 'Item Summary' and description information 'Item Description'.


.EXAMPLE 
PS C:> $SessionState = Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 
PS C:> $NewItem = New-YouTrackItem -YouTrackUri http://server1 -Project Incident -Summary "Item Summary" -Description "Item Description" -SessionState $SessionState 

This command creates a new item in the project 'Incident' for the JetBrains YouTrack web server 'http://server1' using the web request session object variable 'SessionState'. 

This command creates a new item with the summary information 'Item Summary' and description information 'Item Description' and stores the project item issue number as the variable 'NewItem'.

.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the New-YouTrackItem cmdlet. 

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/New-YouTrackItem.ps1
#> 

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][String] $YouTrackUri,
    [Parameter(Mandatory=$True)][String] $Project,
    [Parameter(Mandatory=$True)][String] $Summary,
    [Parameter(Mandatory=$True)][String] $Description,
    [Parameter(Mandatory=$True)][Microsoft.PowerShell.Commands.WebRequestSession] $SessionState
    )

Begin
    {
    } # Begin

Process
    {
    Try
        {
        # Sends a PUT request method to the specified YouTrack URI to create a new item in the specified project, using the variable 'SessionState' web request session object for authentication.
        Write-Verbose ("Creating new item in the project " + $Project + " with the description '" + $Description + "' and summary '" + $Summary + "'.")
        $NewItem = Invoke-WebRequest -Method Put -Uri "$YouTrackURI/rest/issue?project=$Project&summary=$Summary&description=$Description" -WebSession $SessionState -UseBasicParsing
        # Regular expression pattern match from the response header information to return the project item issue number. 
        Write-Verbose ("Performing regular expression pattern match from the response header information to retrieve the project item issue number.")
        $Item = ([regex]::Matches($NewItem.Headers.Location,'[^/]+$')).Value 
        } # Try 
    Catch
        {
        Write-Error("Failed to create the JetBrains YouTrack item with the following exception " + $_.Exception.Message + ".")
        Break 
        } # Catch 
    } # Process 

End
    {
    # Returns the value of the project item issue number. 
    Write-Verbose ("Returning the project item issue number.")
    return $Item 
    } # End 

} # Function 