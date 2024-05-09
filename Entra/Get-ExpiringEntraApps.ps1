function Get-ExpiringEntraApps{
    [cmdletbinding()]
    Param(
        $DaysUntilExpiration
    )
    Begin{
        $AppRegistrations = Get-MgApplication
    }
    Process{
        $ExpiringApps = @()
        foreach($App in $AppRegistrations){
            
            #Check Expiring Certs
            $ExpiringCerts = @()
            foreach($Key in $App.KeyCredentials){
                $DaysLeft = ($Key.EndDateTime - (Get-Date)).Days
                if($DaysLeft -le $DaysUntilExpiration){
                    $ExpiringCerts += [PSCustomObject]@{
                        CertName = $Key.DisplayName
                        DaysLeft = $DaysLeft
                    }
                }
                rv DaysLeft -ErrorAction SilentlyContinue
            }
            $App | Add-Member -MemberType NoteProperty -Name 'ExpiringCerts' -Value $ExpiringCerts -Force

            #Check Expiring Secrets
            $ExpiringSecrets = @()
            foreach($Password in $App.PasswordCredentials){
                $DaysLeft = ($Password.EndDateTime - (Get-Date)).Days
                if($DaysLeft -le $DaysUntilExpiration){
                    $ExpiringSecrets += [PSCustomObject]@{
                        SecretName = $Password.DisplayName
                        SecretHint = $Password.Hint
                        DaysLeft = $DaysLeft
                    }
                }
                rv DaysLeft -ErrorAction SilentlyContinue
            }
            $App | Add-Member -MemberType NoteProperty -Name 'ExpiringSecrets' -Value $ExpiringSecrets -Force

            if($App.ExpiringSecrets -OR $App.ExpiringCerts){
                $ExpiringApps += $App
            }
            rv ExpiringCerts, ExpiringSecrets -ErrorAction SilentlyContinue
        }

        $ExpiringApps
    }
}
