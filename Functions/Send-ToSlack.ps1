Function Send-ToSlack { 

<#
.SYNOPSIS
Posts message to slack channel. 
.DESCRIPTION 
Posts a message to a public channel, private group or IM channel using the Slack Web API method. The Web API consists of HTTP RPC-style methods as described at https://api.slack.com/methods/chat.postMessage. 
All methods must be called using HTTPS In order to post a messate an authentication token, channel and text are required arguements for POST parameters. 
The response contains a JSON object containing a top level boolean property (ok) to determine success or failure, error messages contain a short readable error code.  
This cmdlet requires Windows PowerShell 3.0 in order to send an HTTPS request to the Slack Web API service.
.PARAMETER Channel
Specify the channel, private group or IM channel to send the messages to. This can be an encoded ID, or a name. 
.PARAMETER Text
Specify the text of the message to send to the channel.
.PARAMETER Token
Specify the authentication token to send the message.
.PARAMETER TokenEncrypt
Specify the location of the encrypted authentication token string. 
.PARAMETER TokenKey 
Specify the location of the encryption key to decrypt the encrypted authentication token string.
.PARAMETER Username 
Specify the username to for the security credentials of the authentication token string.
.PARAMETER Bot
Specify the name of the bot to post the message. 
.PARAMETER Icon 
Specify a Uniform Resource Identifier (URI) to the image to be used as the icon for the message sender.
.PARAMETER Uri
Specify the Uniform Resource Identifier (URI) to send the web request. By default, the web request is sent to https://slack.com/api/chat.postMessage.
.EXAMPLE
PS C:\ Send-ToSlack -Channel "#sales" -Text "This is a test message" -Token "xoxp-17822671332-9811436111-15776151506-a5a9c38550" -Bot PowerShell 
This command posts a message to the channel '#sales' with the message text 'This is a test message' with the name of the bot 'PowerShell. 
The authentication token 'xoxp-17822671332-9811436111-15776151506-a5a9c3855' is specified to connect to the channel.
.EXAMPLE 
PS C:\ Send-ToSlack -Channel "#sales" -Text "This is a test message" -Bot PowerShell -TokenEncrypt C:\Passwords\slackapi.txt -TokenKey C:\Keys\slackapi.txt
This command posts a message to the channel '#sales' with the message test 'This is a test message' with the name of the bot 'PowerShell'. 
The authentication token is read from the encrypted token string located at C:\Passwords\slackapi.txt and decrypted with the key C:\Keys\slackapi.txt. 
.NOTES
Author:               Dean Grant
Date:                 Tuesday, 5th January 2015
Version:              1.0
.LINK 
Online Version: 
Slack Web API: https://api.slack.com/web. 
#> 

[CmdletBinding()]
Param
    ( 
    [Parameter(Mandatory=$True,Position=0,HelpMessage="Input the encoded ID or name of the channel, private group or IM")][ValidateNotNullorEmpty()][String]$Channel,
    [Parameter(Mandatory=$True,Position=1,HelpMessage="Input the text of the message to send to the channel")][ValidateNotNullorEmpty()][String]$Text,
    [Parameter(Mandatory=$False,Position=2,HelpMessage="Input the authentication token to send the message")][String]$Token,
    [Parameter(Mandatory=$False,Position=3,HelpMessage="Input the location of the encrypted token string")][ValidateScript({Get-Item $_})][String]$TokenEncrypted,
    [Parameter(Mandatory=$False,Position=4,HelpMessage="Input the location of the encryprion key for the token string")][ValidateScript({Get-Item $_})][String]$TokenKey,
    [Parameter(Mandatory=$False,Position=5,HelpMessage="Input the username for the token authentication")][String] $Username = "slackapi",
    [Parameter(Mandatory=$False,Position=6,HelpMessage="Input the name of the bot to post the message")][ValidateNotNullorEmpty()][String]$Bot,
    [Parameter(Mandatory=$False,Position=7,HelpMessage="Input the URI to the image to be used as the icon for the message")][String]$Icon,
    [Parameter(Mandatory=$False,Position=8,HelpMessage="Input the URI to send the web request")][ValidateNotNullorEmpty()][String]$Uri="https://slack.com/api/chat.postMessage"
    )

Begin 
    {
    # Conditional logic to determine version of Windows PowerShell.
    If ($PSVersionTable.PSVersion.Major -lt "3")
        {
        # Terminates with error if the minimum version of Windows PowerShell is not installed and stops processing of the command. 
        Throw ("The cmdlet requires a minimum of Windows PowerShell 3.0")
        } # If 
    # Conditional logic to determine if the authentication token has been specified as a string or an encrypted credential object. 
    If ((!($Token)) -and ((!($TokenEncrypted)) -or (!($TokenKey))))
        {
        # Terminates with error if no authentication token information is submitted and stops processing of the command.
        Throw ("No token string or location to the encrypted token string and/or encryption key has been specified.")
        } # If 
    # Conditional logic to determine if the authentication token has been specified as an encrypted file. 
    If ($TokenEncrypted)
        {
        # 
        Try 
            {
            # Decrypts encrypted string for the authentication token using the specificed encryption key.
            $Password= Get-Content $TokenEncrypted | ConvertTo-SecureString -Key (Get-Content $TokenKey)
           	$Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password
	        $Token = $Credentials.GetNetworkCredential().Password
            } # Try 
        Catch
            {
            # Terminates with error if the authentication token is unable to be decrypted and stops processing of the command. 
            Throw ("Unable to decrypt the authentication token with the following exception message " + $Error[0].Exception.Message + ".")
            } # Catch 
        } # If 
    # Generates POST message to be sent to the slack channel. 
    $PostMessage = @{token="$Token";channel="$Channel";text="$Text";username="$Bot";icon_url="$Icon"}
    } # Begin 

Process
    {
    Try 
        {
        # Sends HTTPS request to the Slack Web API service. 
        $WebRequest = Invoke-WebRequest -Uri $Uri  -Body $PostMessage 
        # Conditional logic to generate custom error message if JSON object response contains a top-level error property. 
        If ($WebRequest.Content -like '*"ok":false*')
            {
            # Terminates with error if the response contains an error property, parses the error code and stops processing of the command. 
            Throw ($WebRequest.Content -split '"error":"')[1] -replace '"}',''
            } # If 
        } # Try 
    Catch 
        {
        # Terminates with error and stops processing of the command. 
        Throw ("Unable to send request to the web service with the following exception: " + $Error[0].Exception.Message )
        } # Catch 
    } # Process 

End 
    {
    # Conditional logic to generate custom information message if JSON object repsonse contains a top-level success property.
    If ($WebRequest.Content -like '*"ok":true*')
        {
        # Outputs informational message to the console session.  
        Write-Host ("Successfully sent the message to the slack channel " + $Channel + ".")
        } # If 
    } # End 

} # Function 
