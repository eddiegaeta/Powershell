##Ed Gaeta
##20210506
##Pull *example.com certs

##Looks for IIS, exits script if not installed
$IISInstalled = (Get-WindowsFeature -Name "Web-Server").installed

If ($IISInstalled -ieq $false){
Write-Output "IIS not installed"
exit
}

##Import IIS Module
Import-Module -Name WebAdministration
$hostname = hostname.exe
$date = (get-date).ToString("yyyyMMdd")

## Get IIS Bingings and pull *info for sites matching *example.com certs thubmbprint
Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process `
{
    if ($_.Sites)
    {
        $certificate = Get-ChildItem -Path CERT:LocalMachine/My | 
           Where-Object -Property Thumbprint -EQ -Value "XXXXXXXXXXXXXXXXXXXX"

       $myObject = [PsCustomObject]@{
            Hostname                               = $hostname
            Sites                                  = (@($_.Sites.Value) -join ",")
            LocalStoreCertificateFriendlyName      = ($certificate.FriendlyName | Out-String).Trim()
            LocalStoreCertificateDnsNameList       = (@($certificate.DnsNameList) -join ",")
            LocalStoreCertificateNotAfter          = ($certificate.NotAfter | Out-String).Trim()
            LocalStoreCertificateIssuer            = ($certificate.Issuer | Out-String).Trim()
            LocalStoreCertThumbprint               = ($certificate.Thumbprint | Out-String).Trim()
            #IIS_CertStoreThumbprint                = ($_.Thumbprint | Out-String).Trim()
            
            
        }
        ##Change UNC path below to on that the script admin has access to
       $myObject #| export-csv -path \\server\share\"WebCerts_$date.csv" -Append -NoTypeInformation
    }
}

#Quick variation of script above--->
#$GetBindings = Get-WebBinding | Select-Object -Property * | Where-Object -Property certificateHash -EQ XXXXXXXXXXXXXXXXXXXX

#Testing how to set new binding with the new cert
#$GetBindings | ForEach-Object($_){ Set-WebBinding -Name $_.name -WhatIf}