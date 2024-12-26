function Convert-StorageUnits {
    [CmdletBinding()]
    param (
        [double]$Value,
        [ValidateSet('B','KB','MB','GB','TB','PB','EP')]
        $InputUnit,
        [ValidateSet('B','KB','MB','GB','TB','PB','EP')]
        $OutputUnit,
        [double]$Round,
        [ValidateSet('2','10')]
        $Base = 2
    )
    begin{
        if($Base -eq '10'){
            $PrefixPower = @{
                B=0
                KB=3
                MB=6
                GB=9
                TB=12
                PB=15
                EB=18
            }
        }
        else{
            #Base -eq 2
            $PrefixPower = @{
                B=0
                KB=10
                MB=20
                GB=30
                TB=40
                PB=50
                EB=60
            }
        }
    }
    process{
        #determine how many steps between the input/output is
        $DifferenceExponent = $PrefixPower[$OutputUnit] - $PrefixPower[$InputUnit]
        $Multiplier = [math]::Pow($Base,$DifferenceExponent)
        if($Round){
            [math]::Round($Value/$Multiplier,$Round)
        }
        else{
            $Value/$Multiplier
        }
    }
}