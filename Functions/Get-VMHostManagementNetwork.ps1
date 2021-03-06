
Function Get-VMHostManagementNetwork { 

<# 
.NOTES
    Author:   	Dean Grant   
	Date:     	Wednesday, 19th August 2015      
    Version:  	1.0 
	Keywords:	PowerCLI, VMware, HostSystem, Management Network
	
.NAME 
	Get-VMHostManagementNetwork
  
.SYNOPSIS 
	Gets the IP address of the Management Network. 
  
.SYNTAX   
	Get-VMHostManagementNetwork [[-VIServer]] <String[]> [[-Datacenter]] <String[]> [[-Cluster]] <String[]> [[-VMHosts]] <String[]>

.DESCRIPTION
 	The Get-VMHostManagementNetwork function retrieves the IP address assgined to the management network for an ESXi host system. 
 
 	You can direct Get-VMHostManagementNetwork to retrieve a filtered list of ESXi host system based on Datacenter, Cluster or particular ESXi host systems. 
	
.PARAMETERS 
	-VIServer 
		Establishes a connection to the specified vCenter Server System. 
		
	-Datacenter 
		Retrieves all ESXi host systems in the specified Datacenter. 
	
	-Cluster 
		Retrieves all ESXi host systems in the specified Datacenter. 
	
	-VMHosts 
		Retrieves all specifeid ESXi host systems.
	
.EXAMPLE 
 	PS C:\> Get-VMHostManagementNetwork -VIServer vcenter1 -Cluster Edinburgh
 
 	This command establishes a connection to the vCenter Server System vcenter1 and retrieves the management network IP address for all ESXi host systems in the Edinburgh cluster. 
 	
#> 
Param ([Parameter(Mandatory=$true)][String[]] $VIServer,[String[]] $Datacenter,[String[]] $Cluster,[String[]] $VMHost) 

If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {Add-PSSnapin VMware.VimAutomation.Core | Out-Null}

Connect-VIServer $VIServer | Out-Null 

If ($Datacenter){$VMHosts = Get-Datacenter $Datacenter | Get-VMHost} 
ElseIf ($Cluster) {$VMHosts = Get-Cluster $Cluster | Get-VMHost} 
ElseIf ($VMHost) {$VMHosts = Get-VMHost $VMHost} 
Else {$VMHosts = Get-VMHost}

$VMHosts | Select-Object @{N="Name";E={$_.Name}},@{N="Management Network";E={(Get-VMHostNetworkAdapter -VMHost $_.Name  | Where-Object {$_.Name -eq "vmk0"}).IP }}
} 

Get-VMHostManagementNetwork -VIServer colprdvc1 