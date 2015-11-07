
<#
.SYNOPSIS 
Creates concatenated certificate container file.
.DESCRIPTION
Creates a concatenated certfificate container file by retrieving the content from certificate files specified in a correct order by adding the content retrieved to an output file. 
.PARAMETER Certificates 
Specify the location of each certificate file to be added to the concatenated certificate container file. 
.PARAMETER Output 
Specify the location to create the concatenated certificate container file. By default, the file is created in the users profile with the filename 'container_file.pem'. 
.EXAMPLE
PS C:> ConvertTo-CertificateContainer -Certificates "C:\Certificates\SSL.crt", "C:\Certificates\IntermediateCA.crt", "C:\Certificates\RootCA.crt" -Output C:\Certificates\chain.pem
This command combines the primary certificate (SSL.crt), intermediate certificate (IntermediateCA.crt) and the root certificate (RootCA.crt) to the concatenated certificate container file C:\Certificates\chain.pem. 
.EXAMPLE
PS C:> ConvertTo-CertificateContainer -Certificates "C:\Certificates\private.key","C:\Certificates\SSL.crt", "C:\Certificate\Intermediate.crt", "C:\Certificate\Root.crt"
This command combines the private key (private.key), primary certificate (SSL.crt), intermediate certificate (IntermediateCA.crt) and the root certificate (RootCA.crt) to the concatenated certificate container file using the output location of users profile.
.NOTES 
Author:         Dean Grant
Date:           Saturday, 7th November 2015
Version:        1.0
Keywords:       SSL, Certificate 
.LINK
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)][ValidateScript({Get-Item $_})][String[]] $Certificates,
    [String] $Output = ([Environment]::GetEnvironmentVariable("UserProfile")) + "\container_file.pem"
    ) 

Begin
    {
    Write-Verbose "A concatenated certificate container file will be created using certificates in the following order:" 
    ForEach ($Certificate in $Certificates)
        {
        $Counter++
        Write-Verbose ( "" + $Counter  + " - " + $Certificate)
        } # ForEach 
    } # Begin

Process
    {
    Try 
        {
        # Retrieves and adds the content of each certificate from the specified location to a concatenated certificate container file. 
        ForEach ($Certificate in $Certificates)
            { 
            Get-Content $Certificate | Add-Content $Output 
            } 
        } # Try 
    Catch
        {
        Write-Host ("The creation of the concatenated certificate container file failed with the following exception message: " + $Error[0].Exception.Message) -ForegroundColor Red 
        Break 
        } # Catch 
    } # Process

End 
    {
    Write-Verbose ("A concatenated certiticate file has been created at " + $Output + ".")
    } # End 
} # Function 

