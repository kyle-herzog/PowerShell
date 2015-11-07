Function Get-RSSFeed  {

<#
.SYNOPSIS 
Retrieves most recent articles for an RSS feed(s).
.DESCRIPTION
Retrieves most recent articles for an RSS feed(s). By default, this will return the article headline. Optional parameters will retrive the link and description of the article.
This function requires Windows PowerShell 3.0 to in order to retrieve Uniform Resource Identifier (URI) using the Invoke-WebRequest cmdlet. 
.PARAMETER Uri 
Specify the Uniform Resource Identifier (URI) to send a request to the web page of the RSS feed(s). 
.PARAMETER Link 
Parameter switch to include the link to the RSS article(s). 
.PARAMETER Description 
Parameter switch to include the description if available of the RSS article(s). 
.EXAMPLE
Get-RSSFeed -Uri https://deangrant.wordpress.com/feed 
This command retrieves the headline of recently published items for the feed 'https://deangrant.wordpress.com/feed'.
.EXAMPLE 
Get-RSSFeed -Uri https://deangrant.wordpress.com/feed -Link -Description
This command retrieves the headline, link and description if available of recently publised items for feed 'https://deangrant.wordpress.com/feed'.
.EXAMPLE 
"https://deangrant.wordpress.com/feed", "http://feeds.feedburner.com/VmwareBlogsFeed?format=xml" | Get-RSSFeed -Link 
This command retrieves the headline and link if available of recently publised items for feeds 'https://deangrant.wordpress.com/feed' and 'http://feeds.feedburner.com/VmwareBlogsFeed?format=xml'.
.EXAMPLE 
"https://deangrant.wordpress.com/feed", "http://feeds.feedburner.com/VmwareBlogsFeed?format=xml" | Get-RSSFeed -Link | Export-CSV -Path C:\Output\RSSFeed.csv -NoTypeInformation
This command retrieves the headline and link if available of recently publised items for feeds 'https://deangrant.wordpress.com/feed' and 'http://feeds.feedburner.com/VmwareBlogsFeed?format=xml' and exports to a CSV file at C:\Output\RSSFeed.csv.
.NOTES 
Author:     Dean Grant
Date:       Monday, 5th October 2015 
Version:    1.0
.LINK
http://powershell.org/wp/2015/10/03/october-2015-scripting-games-puzzle/
https://gist.github.com/dean1609/a7858118ba573975b5ff 
#>

[CmdletBinding()]
Param ( 
      [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
      [String[]]$Uri,
      [Switch] $Link,
      [Switch] $Description 
      ) 

Begin 
    {
    If ($PSVersionTable.PSVersion.Major -lt 3) 
        {
        Write-Host ("The function requires Windows PowerShell 3.0 or greater.") -ForegroundColor Red 
        Break 
        } 
    } #Begin

Process 
    { 
    ForEach ($RSS in $Uri)
        {
        Try 
            {
            # Sends request to the specified Uniform Resource Identifier (URI). 
            Write-Verbose ("Establishing a connection to the Uri " + $RSS + ".")
            [Xml]$WebRequest = Invoke-WebRequest -Uri $RSS -ErrorAction SilentlyContinue 
            } # Try 
        Catch 
            {
            # On error returns output to the console session. 
            Write-Host ("Unable to connect to the URI - " + $RSS + ".") -ForegroundColor Red 
            } # Catch
        # Creates array to store data elements.
        [Array]$Output=@()
        # Performs action against each iteam (article) returned for the RSS feed. 
        ForEach ($Item in $WebRequest.rss.channel.item)
            { 
            # Creates a custom object and adds properties to the instance. 
            $PSObject = New-Object PSObject 
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name Headline -Value $Item.title
            # Conditional logic to determine if the link and/or Description parameter switch has been specified. 
            If($Link){Add-Member -InputObject $PSObject -MemberType NoteProperty -Name "Link" -Value $Item.Link}
            If($Description){Add-Member -InputObject $PSObject -MemberType NoteProperty -Name "Description" -Value $Item.description.innertext}
            $Output += $PSObject
            } # ForEach 
        # Returns the specified output of the RSS feed request. 
        $Output
        } #ForEach 
    } # Process 

End{} # End 

} # Function
