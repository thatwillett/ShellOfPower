function Get-ManagerHierarchy($SamAccountName){
    $Level = 1
    $Hierarchy = @()
    $ADUser = Get-ADUser $SamAccountName -Properties SamAccountName, EmailAddress, Title | select SamAccountName, EmailAddress, Title, Enabled
    $ADUser | Add-Member -MemberType NoteProperty -Name Level -Value 0 -Force
    $Hierarchy += $ADUser
    Do{
        $ManagerCheck = Get-Manager $SamAccountName
        $ManagerCheck | Add-Member -MemberType NoteProperty -Name Level -Value $Level -Force
        if($ManagerCheck.Manager){
            #Make sure the manager doesn't report to themselves - weirdos
            if($ManagerCheck.SamAccountName -eq $SamAccountName){
                $Stop = $true
            }
            else{
                $Hierarchy += $ManagerCheck | select SamAccountName, EmailAddress, Title, Enabled, Level
                #Keep Going with the next Manager
                $SamAccountName = $ManagerCheck.SamAccountName
                $Level++
            }
        }
        else{
            #Stop
            Write-Host "This user has no manager: $ManagerCheck"
            $Stop = $true
        }
    }
    Until($Stop)
    rv Stop
    $Hierarchy
}
