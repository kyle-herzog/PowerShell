# http://powershell.org/wp/2015/12/05/december-2015-scripting-games-puzzle/

$List = @"
1 Partridge in a pear tree
2 Turtle Doves
3 French Hens
4 Calling Birds
5 Golden Rings
6 Geese a laying
7 Swans a swimming
8 Maids a milking
9 Ladies dancing
10 Lords a leaping
11 Pipers piping
12 Drummers drumming
"@

# Challenge 1 - Split $list into a collection of entries, as you typed them, and sort the results by length. As a bonus, see if you can sort the length without the number.
$Gifts = $List -Split "`n"
Write-Output "Challenge 1 - Sorting collection of entries by length.`n"
$Gifts | Sort-Object -Property Length 
Write-Output "`nChallenge 1 (Bonus) - Sorting collection of entries by length without the number.`n"
$Gifts -Replace "[0-9]" | Sort-Object -Property Length 

#Challenge 2 - Turn each line into a custom object with a properties for Count and Item.
$GiftObjects = ForEach ($Gift in $Gifts) 
    { 
    [PSCustomObject] @{
        Count = $Gift -Replace '[a-zA-Z]'
        Item = $Gift -Replace '[0-9]'
        } #PSCustomObject
    } # ForEach 
Write-Output "`nChallenge 2 - Create custom object for each line with count and item property."
$GiftObjects

# Challenge 3 - Using your custom objects, what is the total number of all bird-related items?
$Birds = "Partridge|Turtle Doves|French Hens|Calling Birds|Geese|Swans"
Write-Output ("`nChallenge 3 - The total number of bird related items: " + ($GiftObjects -match $Birds).Count + "`n")

# Challenge 4 - What is the total count of all items?
Write-Output ("Challenge 4 - The total number of gift items received: " + (Invoke-Expression (($Gifts -Replace '[a-zA-Z]') -join "+")))