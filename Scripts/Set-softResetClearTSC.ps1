<#
	.NOTES
     Author:         Dean Grant 
     Date:           Tuesday, 17th February 2014
	 Version:        1.0

    .SYNOPSIS 
      Sets the key value pair for each virtual machine in the collection. 
	  
    .PARAMETERS
        
        -VIServer    Specify the vCenter Server System to establish a connection.
        
        -LogFile     Specify a filename for the log file. 
        
        -VMs         Specify virtual machines to include in the collection  
     				
	  
    .EXAMPLE

    ./Set-softResetClearTSC.ps1 -VIServer deanvc1.dean.local -LogFile softResetClearTSC.log -VMS "deanvm1","deanvm2",deanvm3"
 

#>
# Specifies mandatory paramters required for the current session. 
Param ([Parameter(Mandatory=$true)][string] $VIServer, [Parameter(Mandatory=$true)][string] $LogFile, [Parameter(Mandatory=$true)][string[]] $VMs)

#  Creates function to write progress to console session and log file. 
$Path = [System.IO.Path]::Combine($env:USERPROFILE,$LogFile)
$FileMode = [System.IO.FileMode]::Append
$FileAccess = [System.IO.FileAccess]::Write
$FileShare = [IO.FileShare]::Read
$FileStream = New-Object IO.FileStream($Path, $FileMode, $FileAccess, $FileShare)
$StreamWriter = New-Object System.IO.StreamWriter($FileStream)

Function Log($Event)
{
   Write-Host $Event
   $StreamWriter.WriteLine($Event)
}

# Establishes a connection to the vCenter Server System 
Try 
    { 
    Log ("" + (Get-Date -Format s) + ": INFORMATION: Establishing a connection to the vCenter Server System.") 
    Connect-VIServer $VIServer 
    } 
Catch [System.Exception]
    { 
    Log ("" + (Get-Date -Format s) + ": ERROR: Failed to establish a connection to the vCenter Server System - " + $VIServer + ".") 
    Log $Error.Exception
	$Error.Clear() 
	Break
    } 
Log ("" + (Get-Date -Format s) + ": INFORMATION: Successfully established a connection to the vCenter Server System - " + $VIServer + ".") 
    
# Performs an action on each object in the collection.
ForEach ($VM in $VMS) 
    { 
    # Prepares the guest operating system for shutdown and waits until the power state is returned as 'PoweredOff'.
    Try
        { 
        Log ("" + (Get-Date -Format s) + ": INFORMATION: Preparing guest operating system for shutdown for virtual machine " + $VM + ".") 
        Shutdown-VMGuest $VM -Confirm:$False | Out-Null 
        Do 
            { 
            Start-Sleep -Seconds 5 
            } 
        Until ((Get-VM $VM).PowerState -eq "PoweredOff")
        } 
    Catch [System.Exception]
        { 
        Log ("" + (Get-Date -Format s) + ": ERROR: Failed to shutdown the virtual machine " + $VM + ".") 
        Log $Error.Exception
	    $Error.Clear() 
	    Break
        } 
    Log ("" + (Get-Date -Format s) + ": INFORMATION: Successfully shutdown virtual machine " + $VM + ".") 
    
    # Adds the key value pair 'monitor_control.enable_softResetClearTSC = "TRUE"' to the virtual machine configuration file. 
    Try
        { 
        Log ("" + (Get-Date -Format s) + ": INFORMATION: Modifying configuration file for the virtual machine " + $VM + ".") 
        $View = Get-VM $VM | Get-View
        $Config = New-Object VMware.Vim.VirtualMachineConfigSpec
        $Config.ExtraConfig += New-Object VMware.Vim.OptionValue
        $Config.extraConfig[0].key = "monitor_control.enable_softResetClearTSC"
        $Config.extraConfig[0].value = "TRUE"
        ($View).ReconfigVM_Task($Config) | Out-Null
        } 
    Catch [System.Exception]
        {
        Log ("" + (Get-Date -Format s) + ": ERROR: Failed to modify the configuration file for the virtual machine " + $VM + ".") 
        Log $Error.Exception
	    $Error.Clear() 
	    Break
        }
    Log ("" + (Get-Date -Format s) + ": INFORMATION: Successfully added the key monitor_control.enable_softResetClearTSC to the virtual machine " + $VM + ".") 
    
    # Starts the virtual machine.
    Try
        {
        Log ("" + (Get-Date -Format s) + ": INFORMATION: Powering on the virtual machine " + $VM + ".") 
        Start-VM $VM -Confirm:$False | Out-Null 
        }
    Catch [System.Exception] 
        {
        Log ("" + (Get-Date -Format s) + ": ERROR: Failed to power on the virtual machine " + $VM + ".") 
        Log $Error.Exception
	    $Error.Clear() 
	    Break
        }
    Log ("" + (Get-Date -Format s) + ": INFORMATION: Succesfully powered on the virtual machine " + $VM + ".") 
    } 

# Closes the underlying stream and releases the log file. 
$StreamWriter.Dispose()
$FileStream.Dispose()