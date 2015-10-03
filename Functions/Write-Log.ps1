Function Write-Log { 

<#
   .SYNOPSIS 
   Generates an event message.
   .DESCRIPTION
   This command generates an event message to either both a log file location and Windows PowerShell session or to a Windows PowerShell session only.
   The event level generation supports Info (Information), Warning and Error severity levels.
   The Date and Time of the generated event is logged in SortableDateTimePattern (based on ISO 8601) format. For Example, 2015-09-24T17:12:41. 
   .PARAMETER LogFile
   Specify the location to create or append to an existing log file. If no log file is specified events are generated in the current Windows PowerShell session only. 
   .PARAMETER Message 
   Specify a description of the event message. 
   .PARAMETER Level 
   Specify the severity of the event message, valid set of values are Info, Warning and Error. 
   .EXAMPLE
   Write-Log -LogFile C:\Logs\output.log -Messages "This is a test!" -Level Info 
   2015-09-24T17:06:40: INFORMATION: This is a test!.
   Creates an information message with the description 'This is a test!' and generates the event in both the log file C:\Logs\output.log and the current Windows PowerShell session.
   .EXAMPLE 
   PS C:\> Write-Log -Message "This is an error!" -Level Error 
   2015-09-24T17:06:40: ERROR: This is an error!.
   Creates an error message with the description 'This is an error!' and generates the event in the current Windows PowerShell session only.
   .NOTES
   Author:     Dean Grant
   Date:       Thursday, 24th September 2015
   Version:    1.0
   .LINK
   https://deangrant.wordpress.com/2015/10/03/generating-log-output-using-windows-powershell/
#>

    [CmdletBinding()]
    Param ( 
        [ValidateScript({Get-Item (Get-Item $_).DirectoryName})] 
        [String]$LogFile = "", 
        [Parameter(Mandatory=$True)]
        [String]$Message,
        [ValidateSet('Info','Error','Warning')]
        [String]$Level = "Info"
    ) 
    
    # Conidtional statement to generate event message text. 
    Switch ($Level)
        {
        'Info' {$Event = ("" + (Get-Date -Format s) + ": INFORMATION: " + $Message  + ".")}
        'Warning' {$Event = ("" + (Get-Date -Format s) + ": WARNING: " + $Message  + ".")}
        'Error' {$Event =  ("" + (Get-Date -Format s) + ": ERROR: " + $Message  + ".")}
        }

    # Conditional logic to determine event generation method. 
    If ($LogFile)
        {
        # Conditional logic to determine if the log file current exists in the location specified. 
        If (!(Get-Item $LogFile -ErrorAction SilentlyContinue))
            {
            # Creates the log file in the location specified. 
            New-Item $LogFile -Force -ItemType File | Out-Null 
            }
        # Generates events in the current Windows PowerShell session specified and the log file specified. 
        Write-Host $Event 
        Write-Output $Event | Out-File -FilePath $LogFile -Append
        }
    Else
        {
        # Generates events in the current Windows PowerShell session. 
        Write-Host $Event 
        }
} 

