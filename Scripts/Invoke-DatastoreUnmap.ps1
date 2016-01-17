
Function Invoke-DatastoreUnmap { 

<#
#>

[CmdletBinding()]
Param ( 
    [String] $vCenter = "colprdvc1",
    [String[]] $Datacenters,
    [String[]] $Clusters,
    [String[]] $HostSystems,
    [String[]] $Datastores,
    [Switch] $SendToSlack,
    [Int] $ReclaimSize
)


Begin
    {
    Try
        {
        # Registers VMware.VimAutomation.Core snap-in to the current session.
        If (-not (Get-PSSnapin VMware.VimAutomation.Core)) 
	        {
	        Add-PSSnapin VMware.VimAutomation.Core | Out-Null 
	        } # If 
        } # Try 
    Catch
        {
        Throw ""
        } # Catch 

    } # Begin 

Process
    {
    # Establishes a connection to the vCenter Server system.
    Try
        {
        Connect-VIServer $vCenter | Out-Null 
        } # Try 
    Catch
        {
        } # Catch 
    
    # Retrieves vSphere view objects based on specified search critera.
    Try 
        {
        # 
         If ($Datacenters -ne $null)
            {
            $SearchRoots = ForEach ($Datacenter in $Datacenters) {Get-View -ViewType Datacenter -Property Name | Where-Object {$_.Name -eq $Datacenter}}
            $DatastoreObjects = ForEach ($SearchRoot in $SearchRoots) {Get-View -ViewType Datastore -SearchRoot $SearchRoot.MoRef -Filter @{"Summary.Accessible" = "True"}} -Property Name,Info,Host,Summary
            $HostSystemObjects = ForEach ($SearchRoot in $SearchRoots) {Get-View -ViewType HostSystem -SearchRoot $SearchRoot.MoRef -Property Name}
            } # If  
        <#
        ElseIf ($Clusters -ne $null)
            {
            $SearchRoots = ForEach ($Cluster in $Clusters) {Get-View -ViewType ClusterComputeResource -Property Name, Configuration, ConfigurationEx  | Where-Object {$_.Name -eq $Cluster}}
            $DatastoreObjects = ForEach ($SearchRoot in $SearchRoots){Get-View -Id (Get-Cluster $SearchRoot.Name | Get-Datastore).Id -Filter @{"Summary.Accessible" = "True"}} -Property Name,Info,Host,Summary
            $HostSystemObjects = ForEach ($SearchRoot in $SearchRoots){Get-View -ViewType HostSystem -SearchRoot $SearchRoot.MoRef -Property Name}
            } # ElseIf
        #>
        ElseIf ($HostSystems)
            {
            $HostSystemObjects = ForEach ($SearchRoot in $HostSystems) {}
            $DatastoreObjects = ForEach ($SearchRoot in $HostSystems){} 
            } # ElseIf 
        <#
        ElseIf ($Datastores)
            {
            
            } # ElseIf
        #>
        Else
            {
            $HostSystems = Get-View -ViewType HostSystem -Property Name
            $Datastores = Get-View -ViewType Datastore -Filter @{"Summary.Accessible" = "True"} -Property Name, Info, Host
            } # Else
        
        # Creates hashtable for hostsystem objects to enumerate the name from the MoRef property value.
        $HostSystemObjectsHash = @{}
        $HostSystemObjects | ForEach {$HostSystemObjectsHash.Add($_.MoRef,$_.Name)} 
        
        } # Try 
    Catch
        {

        } # Catch 

    Try
        {
        # Performs an action on the collection of items. 
        ForEach ($DatastoreObject in $DatastoreObjects)
            {
            # Returns the first host system connected to the device and enumerates the name from the hashtable where the MoRef property value is the key. 
            $HostSystem = ($HostSystemsObjectsHash.GetEnumerator() | Where-Object { $_.Key -eq ($DatastoreObject.Host[0].Key.ToString() )}).Value
            # Exposes the ESXCLI functionality for the specified host system. 
            $ESXCli = Get-EsxCli -VMHost $HostSystem 
            # Invokes command to determine if the device VAAI status supports SCSI UNMAP commands. 
            $VAAIDeleteStatus = ($ESXCli.storage.core.device.vaai.status.get($DatastoreObject.Info.VMfs.Extent.DiskName)).DeleteStatus
            # Conditional logic based on VAAI status of the device. 
            If ($VAAIDeleteStatus -eq "supported")
                {
                # Conditional logic to determine if the ReclaimSize paramter has been specified.
                If (!($ReclaimSize))
                    {
                    # Statement to check the reclaim size based on the file system block size.
                    Switch ($DatastoreObject.Info.Vmfs.BlockSizeMB)
                        {
                        '1' {$ReclaimSize = "200"} # 200MB for 1MB block VMFS3/VMFS5
                        '4' {$ReclaimSize = "800"} # 800MB for 4MB block VMFS3
                        '8' {$ReclaimSize = "1600"} # 1600MB for 4MB block VMFS3
                        } # Switch
                    } # If 
                Try
                    {
                    # Performs action to reclaim unused storage blocks on a device. 
                    $ESXCli.storage.vmfs.unmap($ReclaimSize,$DatastoreObject.Name,$null)
                    Write-Host ("The device " + ($DatastoreObject.Name) + " supports SCSI UNMAP commands.")
                    } # Try 
                Catch
                    {

                    } # Catch 
                } # If 
            Else
                {
                # Returns message that the device is not supported and continues.
                Write-Host ("The device " + ($DatastoreObject.Name) + " does not support SCSI UNMAP commands, no further actions will be performed.")
                } # Else 
            } # ForEach  
        } # Try
    Catch
        {
        } # Catch 

    } # Process  

End 
    {
    } # End 

} # Function 