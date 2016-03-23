Function Update-YouTrackItem { 

<#
.SYNOPSIS
Updates and existing item in a JetBrains YouTrack project.

.DESCRIPTION 
The Update-YouTrack item cmdlet sends a POST request method to update an existing item for a specified project in YouTrack JetBrains using the execute command REST API method. 

The cmdlet requires a web request session variable for authentication.

The cmdlet uses the response object for HTML content without Document Object Model (DOM) parsing, this is required when Internet Explorer is not installed

The cmdlet requires Windows PowerShell 3.0. 

.PARAMETER YouTrackUri
Specify the Uri of the JetBrains YouTrack web server.

.PARAMETER Item 
Specify the project item issue number to perform an update.

.PARAMETER ExecuteCommand 
Specify the execute command to issue to the REST API to perform an update on the item. 

.PARAMETER SessionState
Specify the web request session value to use for authentication agaisnt the JetBrains YouTrack web server. 

.EXAMPLE
PS C:> $SessionState = Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 
PS C:> Update-YouTrackItem -YouTrackUri http://server1 -Item IM-123 -ExecuteCommand "priority P1 Type Incident Category Support" -SessionState $SessionState  

This command updates the project item issue number IM-123 for the JetBrains YouTrack web server 'http://server1' using the web request session object variable 'SessionState'. 

The command updates the priority as 'P1', type as 'Incident' and Category as 'Support'.

.EXAMPLE 
PS C:> $SessionState = Connect-YouTrack -YouTrackUri http://server1 -Username administrator -Password P@55Word! 
PS C:> $NewItem = New-YouTrackItem -YouTrackUri http://server1 -Project Incident -Summary "Item Summary" -Description "Item Description" -SessionState $SessionState 
PS C:> Update-YouTrackItem -YouTrackUri http://server1 -Item $NewItem -ExecuteCommand "priority P1 Type Incident Category Support" -SessionState $SessionState

This command updates the project item issue created for the variable 'NewItem' for the JetBrains YouTrack web server 'http://server1' using the web request session object variable 'SessionState'. 

The command updates the priority as 'P1', type as 'Incident' and Category as 'Support'.


.NOTES 
Author:          Dean Grant
Date:            Tuesday, 22nd March 2016
Version:         1.0
Release Notes:   Initial commit of the Update-YouTrackItem cmdlet.

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/Update-YouTrackItem.ps1
#>

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)][String] $YouTrackUri,
    [Parameter(Mandatory=$True)][String] $Item,
    [Parameter(Mandatory=$True)][String] $ExecuteCommand,
    [Parameter(Mandatory=$True)][Microsoft.PowerShell.Commands.WebRequestSession] $SessionState
    )

Begin
    {
    } # Begin

Process
    {
    Try
        {
        # Sends a POST request method to the specified YouTrack URI to update an existing specified project item using the variable 'SessionState' web request session object for authentication.
        Write-Verbose ("Updating project issue item number " + $Item + ".") 
        Invoke-WebRequest -Method Post -Uri "$YouTrackURI/rest/issue/$Item/execute?command=$ExecuteCommand" -WebSession $SessionState -UseBasicParsing
        } # Try 
    Catch
        {
        Write-Error ("Failed to update the item " + $Item + " with the following exception " + $_.Exception.Message + ".")
        Break 
        } # Catch 
    } # Process 

End
    {
    } # End 

} # Function 