<#
	.NOTES
     Author:         Dean Grant 
     Date:           Friday, 28th November 2014
     Version:        1.0

    .SYNOPSIS 
      Configures guest network interface on a virtual machine.
	  
    .PARAMETERS
      -vCenter  				Hostname or IP address of the vCenter server(s).
	  
	  -VM						Specifiies virtual machine name. 
	  
	  -Interace					Specifies the network interface to modify.
	  
	  -IPAddress				Specifies the IP address for the network interface. 
	  
	  -Prefix 					Specifies the CIDR for the network interface.
	  
	  -DefaultGateway 			Specifies the default gateway for the network interface.
	  
	  -DNSServers 				Specifies the DNS servers for the network interface.
	  
	  -GuestUser				Specify the username to run the the script inside the guest operating system.
	  
	  -GuestPassword 			Specify the password to run the the script inside the guest operating system.
	  
    .EXAMPLE
 
 	Configures the network interface Ethernet0 on virtual machine server 1 with the IP Address 10.0.0.5/24, Default Gateway 10.0.0.254 and DNS servers 10.0.0.1, 10.0.0.2
 	./Set-GuestNetworkInterface.ps1 -vCenter vcenter.domain.local -VM server1 -Interface Ethernet0 -IPAddress 10.0.0.5 -Prefix 24 -DefaultGateway 10.0.0.254 -DNSServers 10.0.0.1,10.0.0.2 -GuestUser DOMAIN\Administrator -GuestPassword ASD123£$!987

 	Configures the network interface Ethernet0 on virtual machine server 1 with the IP Address 10.0.0.5/24, Default Gateway 10.0.0.254
 	./Set-GuestNetworkInterface.ps1 -vCenter vcenter.domain.local -VM server1 -Interface Ethernet0 -IPAddress 10.0.0.5 -Prefix 24 -DefaultGateway 10.0.0.254 -GuestUser DOMAIN\Administrator -GuestPassword ASD123£$!987

	 Configures the network interface Ethernet0 on virtual machine server 1 with the DNS servers 10.0.0.1, 10.0.0.2
 	./Set-GuestNetworkInterface.ps1 -vCenter vcenter.domain.local -VM server1 -Interface Ethernet0 -DNSServers 10.0.0.1,10.0.0.2 -GuestUser DOMAIN\Administrator -GuestPassword ASD123£$!987
#>

# Specifies  parameters required for the powershell session.
Param ([Parameter(Mandatory=$true)][String[]] $vCenter, [Parameter(Mandatory=$true)][String[]] $VM, [Parameter(Mandatory=$true)][string] $Interface, [string] $IPAddress, [string] $SubnetMask, [string] $DefaultGateway, [string] $DNSServers, [string] $GuestUser, [string] $GuestPassword) 

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

# Conditional logic to determine if DNS server addresses are required to be modified. 
If ($DNSServers -eq $null)
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying IPv4 address settings for " + $Interface + "."
	$ScriptText = "New-NetIPAddress –InterfaceAlias `$Interface –IPAddress `$IPAddress -AddressFamily IPv4 –PrefixLength `$Prefix -DefaultGateway `$DefaultGateway"
	} 
ElseIf ($IPAddress -eq $null)
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying DNS server addresses for " + $Interface + "."
	$ScriptText = "New-NetIPAddress –InterfaceAlias `$Interface –IPAddress `$IPAddress -AddressFamily IPv4 –PrefixLength `$Prefix -DefaultGateway `$DefaultGateway;
	Set-DnsClientServerAddress -InterfaceAlias `$Interface -ServerAddresses `$DNSServers"
	} 
Else
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Modifying IPv4 address settings and DNS server addresses for " + $Interface + "."
	$ScriptText = "New-NetIPAddress –InterfaceAlias `$Interface –IPAddress `$IPAddress -AddressFamily IPv4 –PrefixLength `$Prefix -DefaultGateway `$DefaultGateway;
	Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DNSServers"
	} 

# Modifies the IP address settings and DNS server addresses for the interface. 
Try
	{ 
	Invoke-VMScript -VM $VM -ScriptText $ScriptText -GuestUser $GuestUser -GuestPassword $GuestPassword | Out-Null 
	} 
Catch 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": ERROR: Failed to modify " +  $Interface +  " with the message: " + $_.Exception.Message + "."
	} 
Finally 
	{ 
	"" + (Get-Date).toString('dd/MM/yyyy HH:mm:ss') + ": INFORMATION: Succesfully modified " + $Interface + "."
	} 

