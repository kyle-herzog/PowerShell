<# 
.NOTES
    Author:   	Dean Grant
	Date:     	Thursday, 20th August 2015     
    Version:  	1.0 
	Keywords:	PowerCLI, VMware, vRanger, ConsolidateVMDisk 
	
.NAME 
	Invoke-ConsolidateVMDisks.ps1 
  
.SYNOPSIS 
	Consolidates virtual machine hard disks. 
  
.SYNTAX   
	Invoke-ConsolidateVMDisks.ps1  [[-VIServer]] <String[]> [[-ComputerName]] <String[]>

.DESCRIPTION
 	Establishes a connection to the backup server and removes virtual machine hard disks which are Independent Non Persistent and consolidates virtual machine hard disks.
	
	Requires VMware vSphere PowerCLI (compiled using 5.8R1). 
 
.PARAMETERS 
	-VIServer 
		Establishes a connection to the specified vCenter Server System. 
		
	-ComputerName 
		Specify the backup server. By default retrieves local host name.  
	
.EXAMPLE 
 	PS C:\> Invoke-ConsolidateVMDisks.ps1 -VIServer vc1.dean.local -ComputerName bkp1
 
 	This command establishes a connection to the vCenter Server System vc1.dean.local and specifies the computer name bkp1 as the backup server.
#> 

Param ([Parameter(Mandatory=$true)][String] $VIServer, [String] $ComputerName = $env:COMPUTERNAME, $ErrorActionPreference = "Stop" ) 

# Adds the snap-in VMware.VimAutomation.Core to the current Windows PowerShell session. 
If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {Add-PSSnapin VMware.VimAutomation.Core | Out-Null}

# Establishes a connection to the vCenter Server System. 
Try 
	{ 
	Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Establishing a connection to the vCenter Server " + $VIServer + ".") -ForegroundColor White
	Connect-VIServer $VIServer | Out-Null 
	} 
Catch 
	{ 
	Write-Host ("" + (Get-Date -Format s) + ": ERROR: Failed to establish a connection to the vCenter Server " + $VIServer + " with the following exception message:") -ForegroundColor Red
	Write-Host  $Error[0].Exception.Message -ForegroundColor Red 
	} 
Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Successfully established a connection to the vCenter Server " + $VIServer + ".") -ForegroundColor Green

# Retrieves a collection of virtual machines requiring consolidation, removes the attached hard disks and performs virtual machine hardisk consolidation. 
Try
	{
	Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Retrieving collection of virtual machines requiring consolidation.") -ForegroundColor White
	$VMs = Get-View -ViewType VirtualMachine -Property Name, RunTime | Where-Object {$_.RunTime.ConsolidationNeeded -eq $True}
	If ($VMs) 
		{ 
		$HardDisks = Get-VM $ComputerName | Get-HardDisk | Where-Object {$_.Persistence -eq 'IndependentNonPersistent'} 
		If ($HardDisks) 
			{ 
			Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Removing the following virtual machine hard disks.") -ForegroundColor White
			ForEach ($HardDisk in $HardDisks){Write-Host ($HardDisk.FileName) -ForegroundColor White}
			Get-HardDisk -VM $ComputerName -Name $HardDisks.Name | Remove-HardDisk -Confirm:$False | Out-Null 
			}
			ForEach ($VM in $VMs)
			{ 
			Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Consolidating virtual machine disks for " + $VM.Name + ".") -ForegroundColor White
			(Get-VM $VM.Name).ExtensionData.ConsolidateVMDisks() | Out-Null 
			Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: Successfully consolidated virtual machine disks for  " + $VM.Name + ".") -ForegroundColor Green
			}
		}
	Else {Write-Host ("" + (Get-Date -Format s) + ": INFORMATION: No virtual machines requiring consolidation.") -ForegroundColor White} 
	$returncode = "0" 
	} 
Catch 
	{ 
	Write-Host ("" + (Get-Date -Format s) + ": ERROR: Failed to consolidate virtual machine disks for " + $VM.Name + " with the following exception message:") -ForegroundColor Red
	Write-Host  $Error[0].Exception.Message -ForegroundColor Red 
	$returncode = "1" 
	} 
	
exit $returncode 