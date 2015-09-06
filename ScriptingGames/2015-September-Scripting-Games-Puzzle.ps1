# Single line using one pair of curly brackets. 
Import-Csv -Path C:\Test\ScriptingGames\Input.csv | ForEach-Object {$_ | Add-Member -MemberType NoteProperty -Name OSVERSION -Value (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_.MACHINENAME).Caption -PassThru}

# Single line using no semicolons or curly brackets if host names are specified in the CSV file to import. 
Get-WmiObject -Class Win32_OperatingSystem -ComputerName (Import-Csv .\Input.csv).MachineName | Select-Object PSComputerName,Caption | ConvertTo-Csv -NoTypeInformation | Select -Skip 1 | ConvertFrom-Csv -Header MACHINENAME, OSVERSION | Export-Csv .\Output.csv -NoTypeInformation