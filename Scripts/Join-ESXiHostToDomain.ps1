<#
	.NOTES
     Author:         Dean Grant 
     Date:           Tuesday, 2nd December 2014 
     Version:        1.0

    .SYNOPSIS 
	 Joins ESXi hosts to a specific domain. 
      
	  
    .PARAMETERS
      -vCenter  				Hostname or IP address of the vCenter server(s).
	  
	  -Datacenter 				Specify datacenter filter to retrive a collection of HostSystems.
	  
	  -Cluster 					Specify cluster filter to retrive a collection of HostSystems.
	  
	  -VMHosts 					Specify filter to retrive a collection of HostSystems.
	  
	  -Domain					The canonical name of the organisational unit object where the computer object will be created for the HostSystem.
	  
	  -User 					The username provided to join the HostSystems to the domain
	  
	  -Password 				The password provided to join the HostSystems to the domain 
	  
    .EXAMPLE
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and joins each HostSystem to the domain 'domain.local/Servers/ESXi'.
	 ./Join-ESXiHostToDomain.ps1  -vCenter vcenter.domain.local -Domain domain.local/Servers/ESXi -User DOMAIN\Administrator -Password ASAS767681!*&
	
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and joins each HostSystem in the Datacenter 'Manchester' to the domain 'domain.local/Servers/ESXi'.
	 ./Join-ESXiHostToDomain.ps1  -vCenter vcenter.domain.local -Datacenter Manchester -Domain domain.local/Servers/ESXi -User DOMAIN\Administrator -Password ASAS767681!*&
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and joins each HostSystem in the Cluster 'Production' to the domain 'domain.local/Servers/ESXi'.
	 ./Join-ESXiHostToDomain.ps1  -vCenter vcenter.domain.local -Datacenter Manchester -Domain domain.local/Servers/ESXi -User DOMAIN\Administrator -Password ASAS767681!*&
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and joins each HostSystems esxi1.domain.local and esx2.domain.local to the domain 'domain.local/Servers/ESXi'.
	 ./Join-ESXiHostToDomain.ps1  -vCenter vcenter.domain.local -Datacenter Manchester -Domain domain.local/Servers/ESXi -User DOMAIN\Administrator -Password ASAS767681!*&
 
#>

# Specifies  parameters required for the powershell session.
Param ([Parameter(Mandatory=$true)][String] $vCenter,[String[]] $Datacenter,[String[]] $Cluster,[String[]] $VMHosts,[Parameter(Mandatory=$true)][String] $Domain,[Parameter(Mandatory=$true)][String] $User,
[Parameter(Mandatory=$true)][String] $Password)

# Adds VMware.VimAutomation.Core snap-in to current Windows PowerShell session.
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Adding VMware.VimAutomation.Core snap-in to current Windows PowerShell session."
If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}

# Establishing connection to the vCenter Server. 
Try 
	{
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Establishing a connection to the vCenter server " + $VIServer + "."
	Connect-VIServer $VIServer | Out-Null 
	}
Catch
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: Failed to establish a connection to the vCenter Server " + $VIServer + " with the message: " + $_.Exception.Message + "."
	} 
Finally
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Established a connection to the vCenter server " + $VIServer + "."
	}
	
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Retrieving collection of HostSystems."

# Retrieves a collection of HostSystems. 
If($Datacenter -ne $null -and $Cluster -ne $null)
    { 
    $HostSystems = Get-Datacenter | Where-Object {$Datacenter -match $_.Name}| Get-VMHost 
	} 
ElseIf($Datacenter -ne $null)
    { 
	$HostSystems = Get-Datacenter | Where-Object {$Datacenter -match $_.Name} | Get-VMHost 
    } 
ElseIf ($Cluster -ne $null) 
	{ 
	$HostSystems = Get-Cluster | Where-Object {$Cluster -match $_.Name} | Get-VMHost 
	} 
Else
	{ 
	$HostSystems = Get-VMHost $VMHosts 
	} 
	
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: The following HostSystems " + ($HostSystems.Name -join ",") + " have been retrieved."

ForEach ($HostSystem in $HostSystems)

	{ 
	Try 
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Attempting to join " + $HostSystem.Name + " to the domain " + $Domain + "."
		Get-VMHostAuthentication -VMHost $HostSystem.Name | Set-VMHostAuthentication -JoinDomain -Domain $Domain -User $User -Password $Password -Confirm:$False
		} 
	Catch 	
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: Failed to join " + $HostSystem.Name + " to the domain " + $Domain + " with the message: " + $_.Exception.Message + "."
		} 
	Finally
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Successfully joined " + $HostSystem.Name + " to the domain " + $Domain + "."
		} 
		
	} 