##Upgrading DKIM from 1024bit to 2048bit
##https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email?view=o365-worldwide
##Script by EdGaeta

Connect-ExchangeOnline

##log file below : $File =  C:\temp\DKIM\Get-DkimDomainsStatus.txt
$path = "C:\temp\DKIM"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

function Get-DkimDomainsStatus

{
$O365Domains = (Get-DkimSigningConfig).domain

    Foreach ($Domain in $O365Domains)
    {
        Get-DkimSigningConfig -Identity $Domain | fl Domain, Enabled, IsDefault, Selector1KeySize, Selector1CNAME, WhenCreated, WhenChanged
   
    }
}

Get-DkimDomainsStatus | Out-File -FilePath "C:\temp\DKIM\Get-DkimDomainsStatus.txt"

#$File =  C:\temp\DKIM\Get-DkimDomainsStatus.txt

Write-Host "Would you like to manually upgrade your 1024bit DKIM keys to 2048bits?"

$confirmation = Read-Host "Yes or No [y/n]"
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') {exit}
    $confirmation = Read-Host "Ready? [y/n]"
}

Write-Host "Current domains:"
""
$O365Domains

$DomainChoice = Read-Host -prompt "Please type the domain"

Rotate-DkimSigningConfig -KeySize 2048 -Identity $DomainChoice

Get-DkimSigningConfig -Identity $DomainChoice | Format-List Domain, Enabled, Algorithm, Selector1KeySize, Selector1CNAME, Selector1PublicKey, Selector2KeySize, Selector2CNAME, Selector2PublicKey, KeyCreationTime, LastChecked, RotateOnDate


##Options below if the domain does not have DKIM on.....
##New-DkimSigningConfig -DomainName taxcaddy.com -KeySize 2048 -Enabled $True
##Set-DkimSigningConfig -Identity taxcaddy.com -Enabled $true

Write-Host "Here are the encryption key bit sizes per domain"

function Get-DkimDomainsStatusKeyBits

{
$O365Domains = (Get-DkimSigningConfig).domain

    Foreach ($Domain in $O365Domains)
    {
        Get-DkimSigningConfig -Identity $Domain | fl Domain, Enabled, IsDefault, Selector1KeySize, Selector2KeySize, RotateOnDate
   
    }
}

Get-DkimDomainsStatusKeyBits

