

Function Get-GeoIP { 

<#
   .SYNOPSIS 
   Retrieves IP geolocation data. 
   .DESCRIPTION
   Connects to GeoIP REST API (www.telize.com/geoip) and retrieves JSON-encoded IP geolocation data and converts to custom objects.
   .PARAMETER IP Address
   Specify IP address or addresses to retrieve IP geolocation data. 
   .PARAMETER Protocol
   Specify protocol used for the web request. By default, https is used.
   .EXAMPLE
   Get-GeoIP -IPAddress 8.8.8.8
   Returns IP geolocation data for the IP address 8.8.8.8
   .EXAMPLE
   Get-GeoIP -IPAddress 8.8.8.8,8.8.6.6 -Protocol http 
   Returns IP geolocation data for the IP addresses 8.8.8.8 and 8.8.6.6 using the protocol http. 
   .NOTES
   Author: Dean Grant
   Date: Friday, 28th August 2015
   Version: 1.0
   Keywords: PowerShell.org, Scripting Games, August 2015
   .LINK
   http://powershell.org/wp/2015/08/01/august-2015-scripting-games-puzzle/
   https://github.com/dean1609/PowerShell/blob/master/ScriptingGames/Get-GeoIP.ps1
   https://deangrant.wordpress.com/2015/08/28/powershell-org-scripting-games-puzzle-august-2015/
#>
[CmdletBinding()]
Param (
	# Specify IP addresses to return IP geolocation data. 
	[Parameter(Position=0)]
	[String[]]
	[ValidateScript({$_ -match [IPAddress]$_ })]  
	$IPAddress = "",
	# Specify protocol for web request.
	[Parameter(Position=1)]
	[ValidateSet('https','http')]
	[String]
	$Protocol = "https"
)

# Specifies the Uniform Resource Identifier (URI) of the internet resource to which the web request is sent.
$Uri = ($Protocol + "://www.telize.com/geoip")
Write-Verbose ("Sending web requests to " + $Uri + ".")
Try
	{ 
	# Conditional logic to determine if a IP address has been specified.
	If ($IPAddress)
		{ 
		# Performs an action on each item in the collection. 
		ForEach ($IP in $IPAddress)
			{ 
			Write-Verbose ("Retrieving IP geolocation data for " + $IPAddress + ".")
			# Retrieves content from the URI specified and converts JSON-formatted string.
			$WebRequest = Invoke-WebRequest -Uri ($Uri + "/" + $IP) | ConvertFrom-Json
			} 
		} 
	Else	
		{
		# Retrieves content from the URI specified and converts JSON-formatted string.
		Write-Verbose "No IP address sepcified, retrieving IP geolocation data from host"
		$WebRequest = Invoke-WebRequest -Uri $Uri | ConvertFrom-Json 
		}
	# Selects objects from the speficied property and creates calculated properties.  
	$WebRequest | Select-Object -Property @{N="Longitude";E={$_.longitude}},@{N="Latitude";E={$_.latitude}},@{N="ASN";E={$_.asn}},@{N="Offset";E={$_.Offset}},@{N="IP";E={$_.ip}},
	@{N="Area Code";E={$_.area_code}},@{N="Continent Code";E={$_.continent_code}},@{N="DMA Code";E={$_.dma_code}},@{N="City";E={$_.City}},@{N="Timezone";E={$_.Timezone}},@{N="ISP";E={$_.isp}},
	@{N="Country";E={$_.country}},@{N="Country Code";E={$_.country_code}}
	}
Catch
	{
	Write-Host ("ERROR: Failed to retrieve IP geolocation data with the error: " + $Error.Exception.Message[0] + ".") -ForegroundColor Red 
	}
} 