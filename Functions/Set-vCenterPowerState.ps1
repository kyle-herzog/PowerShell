Function Set-vCenterPowerState {

<#
.SYNOPSIS 
Sets the power state of all virtual machines. 

.DESCRIPTION
The cmdlet will set the power state of all virtual machines on a vCenter Server System. 
 
The cmdlet requires VMware vSphere PowerCLI to import the module Vim.VMwareAutomation.Core (supported version of 6.5.0.234).

.PARAMETER VIServer
Specify the IP address or DNS name of the vCenter Server System to which you want to connect. 

.PARAMETER Action
Specify the power state action you wish to perform on each virtual machine. The valid input parameters are 'Start' and 'Stop'. 

.EXAMPLE 
PS C:> Set-vCenterPowerState -VIServer vcsa01.dean.local -Action Start

The command will power on all virtual machines on a vCenter Server System vcsa01.dean.local. 

.EXAMPLE 
PS C:> Set-vCenterPowerState -VIServer vcsa01.dean.local -Action Stop 

The command will power off all virtual machines on the vCenter Server System vcsa01.dean.local.

.NOTES
    Author: Dean Grant (Twitter: @dean1609)
    Date: Thursday, 26th January 2017
    Version: 1.0.0
    Change Log: 1.0.0 - Sets the power state of all virtual machines on a vCenter Server System.

.LINK 
Online Version: https://github.com/dean1609/PowerShell/blob/master/Functions/Set-vCenterServerPowerState.ps1

#>

[CmdletBinding()]
Param ( 
    [Parameter(Mandatory=$True)]
        [String] $VIServer,
    [Parameter(Mandatory=$True)]
        [ValidateSet('Start','Stop')] 
        [String] $Action
)

Begin{

Write-Output ('[' + (Get-Date -Format g) + '] Initialising script to ' + $Action.toLower() + ' all VMs on the vCenter Server ' + $VIServer)

# Evaluates if the module Vmware.VimAutomation.Core has been imported into the current session. 
If (!(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue)){
    Import-Module VMware.VimAutomation.Core
    Write-Output ('[' + (Get-Date -Format g) + '] Imported the module Vmware.VimAutomation.Core to the current session')
} # If (!(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue))

# Establishes a connection to the vCenter Server System. 
Connect-VIServer $VIServer | Out-Null 
Write-Output ('[' + (Get-Date -Format g) + '] Established a connection to the vCenter Server '  + $VIServer)
} # Begin

Process{


# Switch statement to determine the power state action specified and the execution plan to invoke. 
Switch ($Action){
    'Start'{
        # Retrieves a collection of virtual machines where the power state is equal to 'PoweredOff'.
        $VMs = Get-VM -Server $VIServer | Where-Object {$_.PowerState -eq 'PoweredOff'}
        # If the collection contains objects performs the following actions. 
        If ($VMs){
            # Powers on each virtual machine returned in the collection. 
            Start-VM $VMs | Out-Null
            Write-Output ('[' + (Get-Date -Format g) + '] Powering on the virtual machines ' + ($VMS -join ', '))
        } # If ($VMs.count -ge 1)
        # Returns informaton message if no virtual machines are reporting the power state 'PoweredOff'.
        Else{
            Write-Output ('[' + (Get-Date -Format g) + '] No virtual machines in a powered off state, no further action required')
        } # Else
    } # Start 
    'Stop'{
        # Retrieves a collection of virtual machines where the power state is equal to 'PoweredOn'.
        $VMs = Get-VM -Server $VIServer | Where-Object {$_.PowerState -eq 'PoweredOn'}
        # If the collection contains objects performs the following actions. 
        If ($VMs){
            # Evaluates if VMware Tools is installed for the virtual machines and determines the execution path to power off the virtual machine. 
            ForEach ($VM in $VMs){
                If ($VM.ExtensionData.Guest.ToolsStatus -eq 'toolsNotInstalled'){
                    # Powers off the virtual machine.
                    Write-Output ('[' + (Get-Date -Format g) + '] VMware Tools is not installed on ' + $VM.Name + ' the virtual machine will be powered off')
                    Stop-VM -VM $VM -Confirm:$False | Out-Null
                } # If ($VM.ExtensionData.Guest.ToolsStatus -eq 'toolsNotInstalled')
                ElseIf ($VM.ExtensionData.Guest.ToolsStatus -eq 'toolsOK'){
                    # Shuts down the guest operating system of the virtual machine. 
                    Shutdown-VMGuest -VM $VM -Confirm:$False | Out-Null
                    Write-Output ('[' + (Get-Date -Format g) + '] VMware Tools is installed on ' + $VM.Name + ' the virtual machine guest operating system will be shutdown')
                } # ElseIf
            } # ForEach ($VM in $VMs)
            Write-Output ('[' + (Get-Date -Format g) + '] Waiting for all virtual machines to be powered off')
            # Evaluates the power state to determine when all virtual machines have been powered off successfully. 
            Do {
                If ($RetryAttempt -gt 0){
                    Start-Sleep -Seconds 10
                } # If ($RetryAttempt -gt 0)
                $PoweredOnVMs = Get-VM | Where-Object {$_.PowerState -eq 'PoweredOn'}
                $RetryAttempt = $RetryAttempt + 1 
            } Until ($PoweredOnVMs.Count -eq 0)
            Write-Output ('[' + (Get-Date -Format g) + '] Powered off the virtual machines ' + ($VMS -join ', ') + ' successfully')
        } # If ($VMs)
        # Returns informaton message if no virtual machines are reporting the power state 'PoweredOff'.
        Else{
            Write-Output ('[' + (Get-Date -Format g) + '] No virtual machines in a powered on state, no further action required')
        }
    } # Stop 
} # Switch ($Action) 

} # Process 

End {

# Closes the connection to the vCenter Server System. 
Disconnect-VIServer -Server $VIServer -Confirm:$False | Out-Null 
Write-Output ('[' + (Get-Date -Format g) + '] Closed the connection to the vCenter Server System ' + $VIServer)

} # End 

} # Function 