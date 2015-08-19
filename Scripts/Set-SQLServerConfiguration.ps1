<#
	.NOTES
     Author:         Dean Grant 
     Date:           Saturday, 21st February 2015
	 Version:        1.1 

    .SYNOPSIS 
        Configures SQL Server Maximum Memory and Max Degree of Parallelism for SQL Server Instance.  
	  
    .PARAMETERS

        -Instance  Specify the instance name of the SQL Server. 
	  
    .EXAMPLE

      ./Set-SQLServerConfiguration.ps1 -Insance DEAN1\SQL2012 
 
#>

# Specify mandatory parameters required for the current session. 
Param ([Parameter(Mandatory=$true)][string] $Instance) 

[hashtable]$ReturnValue = @{}
$ReturnValue.State = 0
$ReturnValue.Message = ""
$DebugPreference = "Continue"

# Adds SQLPS module to the current session and suppresses the warning. 
Import-Module SQLPS -DisableNameChecking

# Retrieves the total amount of physical memory (MB) on the host. 
$TotalPhysicalMemory = [Math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1MB)

# Conditional logic to determine the amount of total physical memory and the calculation for configuring SQL Server maximum memory.
If ($TotalPhysicalMemory -ge  "16384")
    { 
	$MaximumMemory  = [Math]::Round(($TotalPhysicalMemory  - (($TotalPhysicalMemory  / 16384) * 1024)) - 2048)
	} 
Else 
	{ 
	$MaximumMemory  = ($TotalPhysicalMemory  - 2048)
	} 

# Configures the SQL server maximum meory value.
Try
	{
    Write-Debug "Configuring Maximum Memory for SQL Server" 
    Invoke-SQLCmd -ServerInstance $Instance -Query ("EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE")
    Invoke-SQLCmd -ServerInstance $Instance -Query ("EXEC sys.sp_configure N'max server memory (MB)', N'" + [math]::truncate($MaximumMemory) + "'")
    }
Catch [System.Exception]
    { 
    $ReturnValue.State = 1
    $ReturnValue.Message = "Configuring Maximum Memory for SQL Server failed: " + $error[0]
    return $ReturnValue
    } 

Write-Debug "Completed configuring Maximum Memory for SQL Server"


# Retrieves the number of cores on the host.
$MaxDegreeOfParallelism = (Get-WmiObject Win32_Processor).NumberOfCores / 2

# Confiugres the Max Degree of Parrallelism value on the SQL Server instance. 
Try
	{
    # Conditional logic to determine the number of cores and the calculation for Max Degree of Parrallelism value. 
    If ($MaxDegreeOfParallelism -ge 2)
		{ 
		$Query = "EXEC sys.sp_configure N'max degree of parallelism', N'" + [int]$MaxDegreeOfParallelism + "'"
		Invoke-Sqlcmd -ServerInstance ($VM + "\SQL08")-Database master -Query $Query
		}
    Write-Debug "Configuring Max Degree of Parallelism for SQL Server" 
    Invoke-SQLCmd -ServerInstance $Instance -Query ("EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE")
    Invoke-SQLCmd -ServerInstance $Instance -Query ("EXEC sys.sp_configure N'max degree of parallelism', N'" + $DOP + "'")
	}
Catch [System.Exception]
    { 
    $ReturnValue.State = 1
    $ReturnValue.Message = "Configuring Max Degree of Parallelism for SQL Server failed: " + $error[0]
    return $ReturnValue
    } 

Write-Debug "Completed configuring Max Degree of Parallelism for SQL Server"
