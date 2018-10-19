#####FINAL FORM#####
$ImportPath = "C:\Users\star.killer\Desktop\EmpireUsers_EmpireOnly.csv"
$ExportPath = "C:\Users\star.killer\Desktop\TooManyUsers_WPwds.csv"

$Users = Import-Csv $ImportPath

#Function
#Randomize Passwords the hard way, Option4
function Get-RandomPassword{
    Param(
        [Parameter(mandatory=$true)]
        [int]$Length
    )
    Begin{
        if($Length -lt 4){
            End
        }
        $Numbers = 1..9
        $LettersLower = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
        $LettersUpper = 'ABCEDEFHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
        $Special = '!@#$%^&*()=+[{}]/?<>'.ToCharArray()

        #For the 4 character types (upper, lower, numerical, and special), let's do a little bit of math magic
        $N_Count = [math]::Round($Length*.2)
        $L_Count = [math]::Round($Length*.4)
        $U_Count = [math]::Round($Length*.2)
        $S_Count = [math]::Round($Length*.2)
    }
    Process{
        $Pwd = $LettersLower | Get-Random -Count $L_Count
        $Pwd += $Numbers | Get-Random -Count $N_Count
        $Pwd += $LettersUpper | Get-Random -Count $U_Count
        $Pwd += $Special | Get-Random -Count $S_Count
        #If the password length isn't long enough (due to rounding), add X special characters, where X is the difference between the desired length and the current length.
        if($Pwd.length -lt $Length){
            $Pwd += $Special | Get-Random -Count ($Length - $Pwd.length)
        }

        #Lastly, grab the $Pwd string and randomize the order
        $Pwd = ($Pwd | Get-Random -Count $Length) -join ""
    }
    End{
        $Pwd
    }
}

#Loop through each user from the CSV
Foreach($U in $Users){
    #Define Name variations and generate a random password
    $FirstDotLast = "$($U.First).$($U.Last)"
    $Display = "$($U.First) $($U.Last)"
    $UPN = "$FirstDotLast@empire.local"
    $Pwd = Get-RandomPassword -Length 8
    Write-Host "Working on $Display..." -ForegroundColor Cyan

    #Define Parameters
    $Parameters = @{
        Name = $FirstDotLast
        GivenName = $U.First
        Surname = $U.Last
        SamAccountName = $FirstDotLast
        DisplayName = $Display
        UserPrincipalName = $UPN
        AccountPassword = (ConvertTo-SecureString $Pwd -AsPlainText -Force)
        Enabled = $true
        ChangePasswordAtLogon = $true
        Title = $U.Title
        OtherAttributes = @{"Allegiance"=$U.Allegiance;"Species"=$U.Species}
    }

    #Create New User in AD with the Parameters defined above
    Try{
        New-ADUser @Parameters -ErrorAction Stop
        Write-Host "Successfully created $Display!" -ForegroundColor Green
        $U | Add-Member -MemberType NoteProperty -Name "Initial Password" -Value $Pwd -Force
    }
    Catch{
        Write-Host "Bro...something went horribly wrong. Does this user already exist?? $Display And did you run this as administrator?" -ForegroundColor Red
    }
}

#Export
$Users | Export-Csv $ExportPath -NoTypeInformation