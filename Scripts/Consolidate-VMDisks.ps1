<#
	.NOTES
     Author:         	Dean Grant 
     Date:          	 Monday, 29th December 2014 
     Version:       	1.1

	.REVISION 
		Invokes Get-VM cmdlet to call ConsolidateVMDisks() action. 
		
    .SYNOPSIS 
      Consolidates virtual machine hard disks. 
	  
    .PARAMETERS
      -vCenter  				Hostname or IP address of the vCenter server(s)
	  
    .EXAMPLE
 
 	Establishes a connection to the vCenter server 'vcenter.domain.local' and consolidates virtual machine disks.
 	./Consolidate-VMDisks.ps1 -vCenter vcenter.domain.local
	
	Establishes a connection to the vCenter server 'vcenter1.domain.local' and 'vcenter2.domain.local'and consolidates virtual machine disks.
	./Consolidate-VMDisks.ps1 -vCenter vcenter1.domain.local,vcenter2.domain.local


#>

# Specifies mandatory parameters required for the powershell session.
Param ([Parameter(Mandatory=$true)][String[]] $vCenter) 

# Establishing a connection to the vCenter server.
ForEach ($VIServer in $vCenter)
	{ 
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
		
# Retrieves a collection of VirtualMachine view objects to which virtual machine disk consolisation is required. 
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Retrieving a collection of VirtualMachine view objects" 
$VMs = Get-View -ViewType VirtualMachine -Property Name, RunTime | Where-Object {$_.RunTime.ConsolidationNeeded -eq $True}

# Consolidates each virtual machine disk in the collection. 
If ($VMs -eq $null) 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: No virtual machine disks requiring disk consolidation." 
	} 
Else 
	{ 
	ForEach ($VM in $VMs)
		{ 
		Try
			{ 
			"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Consolidating virtual machine disks for " + $VM.Name + "."
			(Get-VM $VM.Name).ExtensionData.ConsolidateVMDisks()
			} 
		Catch 
			{ 
			"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: Consolidating virtual machine disks for " + $VM.Name + " with the message: " + $_.Exception.Message + "."
			} 
		Finally
			{ 
			"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Succesfully consolidated virtual machine disks for " + $VM.Name + "."
			} 
		} 
	} 

Else
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: No virtual machines require virtual machine disks to be consolidated."
	} 
	
	}


