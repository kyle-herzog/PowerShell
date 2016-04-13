<#
  .SYNOPSIS
  Performs orchestrated installed of Windows updates. 

  .DESCRIPTION 
  Retrieves collection of virtual machines that return a property value match for the vCenter Server System tag 'Patch Schedule'. 

  This script provides an orchestrated workflow to create a virtual machine snapshot and then invoke the script text in the guest operating system to invoke the installation of windows updates using the WUIInstall CLI. 

  Depending on the property value match virtual machines will invoke the script text in either a asynchronous or synchronous operation.
 
  The script requires a minimum of Windows PowerShell 3.0 and VMware vSphere PowerCLI 5.5.0.6579

  .PARAMETER vCenter 
  Specify the vCenter Server System to establish a connection.

  .PARAMETER Environment 
  Specify the infrastructure environment to retrieve a collection of virtual machine objects.

  .PARAMETER UpdateSchedule 
  Specify the update schedule property value to compare to the vCenter Server System tag 'Patch Schedule'. By default, this is generated using the vCenter Server system tag 'Environment' name value and the current hour of the day. 

  .PARAMETER Date
  Specify the date value to append to the virtual machine snaphost name and log file. By default, the property value is in the format dd-MM-yyyy. 

  .PARAMETER LogFile
  Specify the location of the log file to generate event messages. 

  .PARAMETER Username 
  Specify the username you want to use for authenticating with the virtual machine guest operating system.

  .PARAMETER KeyFile

  Specify the location of the encryption key for decrypting credential objects stored as encrypted strings.

  .PARAMETER PasswordFile 
  Specify the location of the encrypted string file for retriving the password you want to use for authenticating with the virtual machine guest operating system.

  .EXAMPLE
  
  .NOTES 
  Author:          Dean Grant
  Date:            Wednesday, 2nd December 2015
  Version:         3.0
  Release Notes:   Restructed script to provide functionality to invoke script text to virtual machines in asynchronous/synchronus operation dependent on the vCenter Server System tag name property value. 
#> 

[CmdletBinding()]
Param ( 
    [String] $vCenter = '',
    [String] $Environment = '',
    [String] $UpdateSchedule = ($Environment + ':' + (Get-Date -UFormat %H)),
    [String] $Date = (Get-Date).toString('dd-MM-yyyy'),
    [String] $LogFile = ('C:\Program Files\WUInstall\wuinstall-server-' + $Date + '.log'),
    [String] $Username = '',
    [String] $KeyFile = '',
    [String] $PasswordFile = ''
) 

Begin
    {
    # Function to generate event messages to the current session and specifed logfile. 
    Function Write-Log($Event) { 
        Write-Host $Event 
        Write-Output $Event | Out-File -FilePath $LogFile -Append -Encoding ASCII # Specifies ASCII character encoding to be used in the log file. By default, the Out-File cmdlet uses Unicode character encoding.
        } # Function 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Starting the orchestrated installation of windows updates in the current session.')

    # Specifies username and converts encrypted standard string into secure password for guest operating system authentication.
    Try 
        {
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Retrieving security credentials for authenticating with the guest operating system.')
        $Key = Get-Content $KeyFile
        $Password = Get-Content $PasswordFile | ConvertTo-SecureString -Key $Key
        $Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password
        $Password = $Credentials.GetNetworkCredential().Password
        } # Try 
    Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to retrieve security credentials with the following exception ' + $Error[0].Exception.Message + '.')
        Break 
        } # Catch 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Successfully retrieved security credentials for authenticating with the guest operating system.')

     # Adds the registered snap-in VMware.VimAutomation.Core to the current sesssion.
     Try
        { 
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Registering VMware.VimAutomation.Core snap-in to the current session.')
        If (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) 
	        {
	        Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	        } # If
        } # Try 
     Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to register the snap-in with the following exception ' + $Error[0].Exception.Message + '.')
        Break
        } # Catch 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Successfully registered the VMware.VimAutomation.Core snap-in to the current session.')

    # Establishes a  connection to the vCenter Server system. 
    Try 
        {
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Establishing a connection to the vCenter Server system ' + $vCenter + '.')
        Connect-VIServer $vCenter | Out-Null 
        } # Try 
    Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to establish a connection to the vCenter Server system with the following exception ' + $Error[0].Exception.Message + '.')
        Break
        } # Catch 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Succesfully established a connection to the vCenter Server system ' + $vCenter + '.')
    } # Begin 

Process
    {  
    # Retrieves collection of virtual machine objects based on the property value of the patch schedule tag name. 
    Try 
        {
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Retrieving collection of virtual machine objects to install windows updates.')
        $VirtualMachines = Get-TagAssignment -Category 'Patch Schedule' | Where-Object {$_.Tag.Name -like "$UpdateSchedule*"}
        } # Try 
    Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to retrieve a collection of virtual machines with the following exception ' + $Error[0].Exception.Message + '.')
        Break
        } # Catch 
    If (!($VirtualMachines))
        {
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: No virtual machines objects retrieved to install windows updates, the script will now exit.')
        Break 
        } # If 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Succesfully retrieved the virtual machine objects to install windows updates: ' + $VirtualMachines -join ',' + '.')

    # Creates a new snapshot for each virtual machine in the collection.
    Try
        {
        Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Creating virtual machine snapshots prior to installing windows updates.')
        New-Snapshot -VM $VirtualMachines.Entity.Name -Name "Windows Update on $Date" | Out-Null 
        } # Try 
    Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to create virtual machine snapshots with the following exception ' + $Error[0].Exception.Message + '.')
        Break 
        } # Catch 
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Successfully created virtual machine snapshots.')

    Try
        {
        # Text of the script to invoke on the guest operating system of the virtual machine. 
        $ScriptText = "C:\PROGRA~1\WUInstall\WUInstall.exe /install /autoaccepteula /reboot_if_needed /logfile C:\PROGRA~1\WUInstall\wuinstall_$Date.log"

        # Selects virtual machines where the tag name category property value specifies 
        $RunAsyncVirtualMachines = $VirtualMachines | Where-Object {$_.Tag.Name -eq "$UpdateSchedule"} # Selects virtual machine objects which are equal to the update schedule property value, these are categorised for asynchronous script invocation.
        # Performs an operation on each item in the collection.
        $RunAsyncVirtualMachines | ForEach-Object { 
            Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Invoking guest operating system script (asynchronous) for the installation of windows updates for the virtual machine ' + $_.Entity.Name + '.')
            # Invokes a script in the guest operating system of the virtual machine object.
            Invoke-VMScript -VM $_.Entity.Name -ScriptText $ScriptText -ScriptType Bat -RunAsync -GuestUser $Username -GuestPassword $Password| Out-Null 
            } # ForEach-Object

        # Selects virtual machines where the tag name category property value specifies 
        $RunSyncVirtualMachines = $VirtualMachines | Where-Object {$_.Tag.Name -like "$UpdateSchedule`:*"} # Selects virtual machine objects which are like (begins with) the update schedule property value, these are categorised for synchronous script invocation.
        $Groups = $RunSyncVirtualMachines | Group-Object {$_.Tag.Name.SubString(7,3)} # Retrives substring of the tag name to determine multi-tier architecture grouping. 
        # Performs an operation on each item in the collection.
        $Groups | ForEach-Object { 
            # Performs an operation on each item in the collection.
            $_.Group | Sort-Object Tag | ForEach-Object { 
                Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Invoking guest operating system script (synchronous) for the installation of windows updates for the virtual machine ' + $_.Entity.Name + '.')
                # Invokes a script in the guest operating system of the virtual machine object.
                Invoke-VMScript -VM $_.Entity.Name -ScriptText $ScriptText -ScriptType Bat -GuestUser $Username -GuestPassword $Password | Out-Null 
                Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Suspending activity to wait on guest operating system state (required for restart) for the virtual machine ' + $_.Entity.Name + '.')
                Start-Sleep -Seconds 60 # Suspends activity during invocation of a virtual machine restart.
                # Runs a statement list until the guest operating system state is returned as running. 
                Do 	
	                {
	                $GuestState = (Get-View (Get-VM $_.Entity.Name).Id).Guest.GuestState	            
                    Start-Sleep -Seconds 5
	                } # Do 
                Until ($GuestState -eq 'running')
                Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Successfully completed installation of windows updates for the virtual machine ' + $_.Entity.Name + " and the guest operating state is 'running'")
                } # ForEach-Object
            } # ForEach-Object
        } # Try 
    Catch
        {
        # Returns error exception message and exits.
        Write-Log ('' + (Get-Date -Format s)  + ' ERROR: Failed to complete installation of windows updates with the following exception message ' + $Error[0].Exception.Message + '.')
        } # Catch 
    } # Process 

End 
    {
    Write-Log ('' + (Get-Date -Format s)  + ' INFORMATION: Successfully completed orchestrated installation of windows updates, the script will now exit.')
    } # End 
