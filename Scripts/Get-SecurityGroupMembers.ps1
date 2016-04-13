#========================================================================================================================================================================================================
# NAME:   		Get-SecurityGroupMembers.ps1
# AUTHOR:		Dean Grant
# DATE:     		26/10/2011
#
# VERSION:		1.0
#
# // COMMENTS:  	Retrieves the membership count and membership list of each security group within the domain and outputs to a Microsoft Excel worksheet.
#					
# // USAGE:     	Get-SecurityGroupMembers.ps1
# // EXAMPLE:   	Get-SecurityGroupMembers.ps1
#========================================================================================================================================================================================================

#$WhatIfPreference = $true

# Adds snap-ins to the cirrent powershell session for vSphere Power CLI and Quest Active Roles Active Directory Management
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) 
	{
	Add-PSSnapin Quest.ActiveRoles.ADManagement
	}


# Executes Microsoft Excel object to create a new worksheet in Microsoft Excel whre the process is visible
$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.workbooks.Add()
$Sheet = $Excel.worksheets.Item(1) 
$Sheet.Cells.Item(1,1) = 'Security Group' 
$Sheet.Cells.Item(1,2) = 'Creation Date'
$Sheet.Cells.Item(1,3) = 'Modification Date'
$Sheet.Cells.Item(1,4) = 'Count'
$Sheet.Cells.Item(1,5) = 'Members' 
$intRow = 2
$WorkBook = $Sheet.UsedRange

# Retrieves all security groups within the domain. 
Get-QADGroup -SizeLimit 0 -GroupType Security | Foreach-Object{

# Retrieves the members of the security group.
$QADGMembers = $_ | Get-QADGroupMember -SizeLimit 0 -Indirect

# Joins the output to include this on a single row in Microsoft Excel. Members are seperated by ';'.
$Members = ($QADGMembers | Select-Object -ExpandProperty Name) -join ';'

# Calculates the number of members for each security group.
$Count = ($QADGMembers | Measure-Object).Count

# Writes security group name to the row in Microsoft Excel.
$Sheet.Cells.Item($intRow, 1) = $_.Name

$Sheet.Cells.Item($intRow, 2) = $_.CreationDate

$Sheet.Cells.Item($intRow, 3) = $_.ModificationDate

# Writes security group membership count to the row in Microsoft Excel.
$Sheet.Cells.Item($intRow, 4) = $Count

# Writes security group members name to the row in Microsoft Excel.
$Sheet.Cells.Item($intRow, 5) = $Members

$intRow = $intRow + 1
}
