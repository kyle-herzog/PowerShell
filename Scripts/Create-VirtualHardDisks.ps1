
<#
	.NOTES
     Author:         Dean Grant 
     Date:           Sunday, 14th December 2014
     Version:        1.0

    .SYNOPSIS 
      Creates virtual machine hard disks.
	  
    .PARAMETERS
	
      -VIServer  			Hostname or IP address of the vCenter server(s)
	  
	  -VM					Specify virtual machine to invoke the script text in the guest operating system.
	  
	  -Number 				Specify number of virtual machine hard disks to create. 
	  
	  -CapacityGB			Specify capacity of virtual machine hard disk in GB. 
	  
    .EXAMPLE
 
	Create-VirtualHardDisks -VIServer vcenter.domain.local -VM vm1 -Number 3 -CapacityGB 20

#>


# Adds VMware.VimAutomation.Core snap-in to current Windows PowerShell session.
"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Adding VMware.VimAutomation.Core snap-in to current Windows PowerShell session."
If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	}

# Establishing a connection to the vCenter server.
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


Function Create-VirtualHardDisks { 

# Specifies mandatory parameters required for the function. 
Param ([Parameter(Mandatory=$true)][int] $VM,[Parameter(Mandatory=$true)][int] $Number, [Parameter(Mandatory=$true)][int] $CapacityGB)

# Statement to repeat the action a specific number of times.
ForEach ($HardDisk in (1..$Number))
    { 
	Try
		{ 
		# Creates a new virtual machine hard disk. 
		$Output = (New-HardDisk -VM $VM -CapacityGB $CapacityGB -StorageFormat EagerZeroedThick).Name 
		}
	Catch 
		{
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: " + $_.Exception.Message + "."
		} 
	Finally
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Successfully created " + $Output + "."
		} 
	}
	Try
		{ 
		# Retrieves virtual machine hard disks and attaches to a new ParaVirtual SCSI Controller. 
		$HardDisks = Get-HardDisk -VM $VM | Select -Last $Number
		$Output = New-ScsiController -Type ParaVirtual -HardDisk $HardDisks	
		}
	Catch 
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: " + $_.Exception.Message + "."
		} 
	Finally
		{ 
		"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Successfully created " + $Output.Name  + " (" + $Output.Type + ") and attached " + ($HardDisks -join ",") + "."
		}
	} 
