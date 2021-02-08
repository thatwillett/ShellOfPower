#Tales from the ForEach Loop

$ArrayOfNumbers = 1..200

$Multipliers = @(2,10,50,1000)

foreach($I in $ArrayOfNumbers){
    #Write-Host "$I) Robots, time travel, and alternatve universes..."
    Start-Sleep -Milliseconds 10

    $Percent = $I/($ArrayOfNumbers.Count)*100
    Write-Progress -Activity 'Magic' -PercentComplete $Percent -Status "$Percent% Complete" -CurrentOperation ArrayOfNumbers
    
    foreach($M in $Multipliers){
        $Product = $I * $M
        Start-Sleep -Milliseconds 50

        $Index = [array]::IndexOf($Multipliers, $M)
        $Percent2 = $Index/($Multipliers.count)*100

        Write-Progress -Activity 'Multi' -Id 2 -PercentComplete $Percent2 -Status "$Percent2% Complete" -CurrentOperation Multiplication
        If($Product -like "*6*"){
            Write-Host "$I * $M = $Product (contains a 6)"
        }
    }
}