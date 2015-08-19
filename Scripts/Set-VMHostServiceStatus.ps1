<#
	.NOTES
     Author:         Dean Grant 
     Date:           Tuesday, 2nd December 2014 
     Version:        1.0

    .SYNOPSIS 
	 Performs bulk actions on VMHostServices by specifying the key value to perform a stop or start action.  
      
	  
    .PARAMETERS
      -vCenter  				Hostname or IP address of the vCenter server(s).
	  
	  -Datacenter 				Specify datacenter filter to retrive a collection of HostSystems.
	  
	  -Cluster 					Specify cluster filter to retrive a collection of HostSystems.
	  
	  -VMHosts 					Specify filter to retrive a collection of HostSystems.
	  
	  -Service 					Specify a mandatory service to perform an action. 
	  
	  -Action					Specify mandatory action to stop or start the service. 
	  
    .EXAMPLE
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and starts the SSH service on each HostSystem. 
	 ./Set-VMHostServiceStatus.ps1 -vCenter vcenter.domain.local -Service TSM-SSH -Action Start 
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and stops the SSH service on each HostSystem. 
	 ./Set-VMHostServiceStatus.ps1 -vCenter vcenter.domain.local -Service TSM-SSH -Action Stop
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and stops the SSH service on each HostSystem in the Datacenter 'Manchester'.
	 ./Set-VMHostServiceStatus.ps1 -vCenter vcenter.domain.local -Datacenter Manchester -Service TSM-SSH -Action Start 
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and stops the SSH service on each HostSystem in the Cluster 'Production'.
	 ./Set-VMHostServiceStatus.ps1 -vCenter vcenter.domain.local -Cluster Production -Service TSM-SSH -Action Start 
	 
	 Establishes a connection to the vCenter server 'vcenter.domain.local' and stops the SSH service on each HostSystems 'esxi1.domain.local,esxi2.domain.local'.
	 ./Set-VMHostServiceStatus.ps1 -vCenter vcenter.domain.local -VMHosts esxi1.domain.local,esxi2.domain.local -Service TSM-SSH -Action Start 
	 
#>

# Specifies  parameters required for the powershell session.
Param ([Parameter(Mandatory=$true)][String] $vCenter,[String[]] $Datacenter,[String[]] $Cluster,[String[]] $VMHosts,[Parameter(Mandatory=$true)][String] $Service,[Parameter(Mandatory=$true)][String] $Action)

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

# Performs an action on each HostSystem returned in the collection. 
ForEach ($HostSystem in $HostSystems)
	{ 
	Try 
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Attempting to " + $Action + " VMHostService with the key " + $Service + " on " + $HostSystem.Name + "."
		If ($Action -eq "Start"){Start-VMHostService -HostService (Get-VMHostService -VMHost $HostSystem.Name | Where-Object {$_.Key -eq $Service}) -Confirm:$False} 
		ElseIf ($Action -eq "Stop"){Stop-VMHostService -HostService (Get-VMHostService -VMHost $HostSystem.Name | Where-Object {$_.Key -eq $Service}) -Confirm:$False} 
		} 
	Catch
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: Failed to " + $Action + " VMHostService with the key " + $Service + " on " + $HostSystem.Name + " with the message: " + $_.Exception.Message + "."
		} 
	Finally	
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Succesfully performed " + $Action + " message on VMHostService with the key " + $Service + " on " + $HostSystem.Name + "."
		} 
	} 
	 