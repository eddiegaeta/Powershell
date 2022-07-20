
  <#
   Ed Gaeta
   20220720
   [Net.HttpWebRequest] is being phased out of powershell 7.*
   Powershell 5.* should be used when running this script

   How to call function for the following list(powershell console 5.*):

   Run this scripts once:
   PS C:\WINDOWS\system32>.\GetCertInfo_Pwsh_v2.psl
   
   Example Path:
   $urls = Get-Content C:\Users\Ed.Gaeta\OneDrive\Powershell\dotcom_urls.txt

   Run
   PS C:\WINDOWS\system32> $urls = Get-Content C:\Users\Ed.Gaeta\OneDrive\Powershell\blahdotcom_urls.txt



   Then run
   PS C:\WINDOWS\system32> $urls | foreach($_){ Get-Certinfo -url $_ }



   To run Adhoc
   Example
   PS C:\WINDOWS\system32>Get-Certinfo -url google.com

   This will still route to the csv file mentioned in the script

 #>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }


 #$urls = Get-Content C:\Users\Ed.Gaeta\OneDrive\Powershell\blahdotcom_urls.txt

    ########################################################
 
    function Get-CertInfo
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $url

    )
    
    ########################################################

        $https = "https://" + $url
        $urlIpAddress = (Resolve-DnsName -Name $url)
        #$apiLookup = "https://ipapi.co/"
        #$apiLookupstring = $apiLookup + $urlIpAddress.IPAddress + "/json/"
        #$ReverseLookup = Invoke-RestMethod -Uri $apiLookupstring
        $req = [Net.HttpWebRequest]::Create($https)
        $StatusOK = 'OK'
        $timeoutMs = 60000 #1 minutes
        $req.Timeout = $timeoutMs
        $response = $timeoutMs
        $csvPath = 'C:\temp\GetCertInfo_' + (Get-date).ToString("yyyyMMdd") + '.csv'
        


    ########################################################
   
        
        try{
                $urlResults = [PSCustomObject]@{

                URL = $https
                IpAddress = (($urlIpAddress.Ip4address) -join ',')
                #IpOwner = $ReverseLookup.org #--->Not working in pwsh v5.*
                Response = $req.GetResponse().StatusCode #| Out-Null
                CertIssuer = $req.ServicePoint.Certificate.Issuer
                CertSubject = $req.ServicePoint.Certificate.Subject
                CertEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
                CertExperationDate = $req.ServicePoint.Certificate.GetExpirationDateString()
                CertHash = $req.ServicePoint.Certificate.GetCertHashString()
                CertSerialNumber = $req.ServicePoint.Certificate.GetSerialNumberString()
                }

                $urlResults | Export-Csv -Path $csvPath -NoTypeInformation -Append

            }catch{
            
                $err = $error[0]

                $urlResults = [PSCustomObject]@{
                URL = $https
                IpAddress = (($urlIpAddress.Ip4address) -join ',')
                #IpOwner = $ReverseLookup.org #--->Not working in pwsh v5.*
                Response = $err.Exception
                CertIssuer = $req.ServicePoint.Certificate.Issuer
                CertSubject = $req.ServicePoint.Certificate.Subject
                CertEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
                CertExperationDate = $req.ServicePoint.Certificate.GetExpirationDateString()
                CertHash = $req.ServicePoint.Certificate.GetCertHashString()
                CertSerialNumber = $req.ServicePoint.Certificate.GetSerialNumberString()
                }

                $urlResults | Export-Csv -Path $csvPath -NoTypeInformation -Append

            }

}
       
   