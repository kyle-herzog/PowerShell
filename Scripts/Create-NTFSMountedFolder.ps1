<#
	.NOTES
     Author:         Dean Grant 
     Date:           Sunday, 14th December 2014
     Version:        1.0

    .SYNOPSIS 
      Creates NTFS mounted folder. 
	  
    .PARAMETERS
	
      -VIServer  			Hostname or IP address of the vCenter server(s)
	  
	  -VM					Specify virtual machine to invoke the script text in the guest operating system.
	  
	  -Folder				Specify the path of the empty folder. 
	  
	  -SCSIPort				Specify the SCSI Port filter for the disk. 
	  
	  -SCSITargetID			Specify the SCSI TargetID filter for the disk. 
	  
    .EXAMPLE
 
	Create-NTFSMountedFolder -VIServer vcenter.domain.local -VM vm1 -Folder D:\Databases1 -SCSIPort 4 -SCSITargetID 3

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


Function Create-NTFSMountedFolder { 

# Specifies mandatory parameters required for the function. 
Param ([Parameter(Mandatory=$true)][String] $VM,[Parameter(Mandatory=$true)][String] $Folder,[Parameter(Mandatory=$true)][String] $SCSIPort,[Parameter(Mandatory=$true)][String] $SCSITargetID)

Try 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Initilizing disk, creating partition, formatting volume and adding partition access path for $Folder"
`	
	# Creates script text function to create empty folder, initialize disk, create new partition and access path and perform a full format of the volume.
	$ScriptText = "New-Item -ItemType Directory -Path $Folder;
	`$Disk = Get-Disk -Number (Get-WmiObject -Class Win32_DiskDrive | Where-Object {`$_.SCSIPort -eq $SCSIPort -and `$_.SCSITargetID -eq $SCSITargetID}).Index;
	Initialize-Disk -Number `$Disk.Number -PartitionStyle GPT -PassThru;
	New-Partition -DiskNumber `$Disk.Number -UseMaximumSize;
	Add-PartitionAccessPath -DiskNumber `$Disk.Number -PartitionNumber 2 -AccessPath $Folder\;
	Get-Partition -DiskNumber `$Disk.Number -PartitionNumber 2 | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536  -Full -NewFileSystemLabel $Folder -Confirm:`$False"
	
	# Invokes script text in the guest operating system. 
	Invoke-VMScript -VM $VM -ScriptText $ScriptText | Out-Null
	} 

Catch 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: " + $_.Exception.Message + "."
	} 
Finally 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Succesfully Initilized disk, created partition, formatted volume and added partition access path for $Folder"
	} 
} 