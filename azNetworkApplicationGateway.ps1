##Ed Gaeta
###################################################################################
##The purpose of this script:
##Create Appgateway and populate it's settings from a csv file
###################################################################################

##Must log into az cli first
#az login

    # AppGateway script order
    # Create:
    # 	resource group
    # 	public ip
    # 	vnet
    # 	gateway
    # 	frontend-port
    # Create:
    # httpSettings
    # healthProbe

#Must delete any rules that arent needed 
#Must delete ports that arent needed

#List csv needs to have the following headers, HttpListener, Hostname, FrontendIP
$sites = Import-Csv -LiteralPath C:\Users\Ed.Gaeta\Documents\AppgatewaySettings.csv	

#Delare Vars
$subscription = "xxxx-xxxxx-xxxxx-xxxxxxxx"
$resourceGroup = "xx-xxx-xxxx"
$vnet = "xx-xxx-xxxx"
$gateway = "xx-xxx-xxxx"
$certLocation = "\\some\share\example_crt.pfx"
$certPassword = "XXxxxXXxxxxXx"
$publicIp = "xx-xxx-pip"
$pool1 = "XXXXXxxx"
$pool2 = "xxxXXXXX"
$frontendPrivIP = "xxx.xxx.xxx.xxx"

function CreateAppGateway {

    az group create -l westus2 -n $resourceGroup `
    --subscription $subscription

    az network public-ip create -g $resourceGroup -n $publicIp `
    --allocation-method Static `
    --sku Standard


    az network application-gateway create `
    --name $gateway `
    --resource-group $resourceGroup `
    --public-ip-address $publicIp `
    --sku WAF_v2 `
    --vnet-name $vnet `
    --subnet $gateway-subnet `
    --subscription $subscription 

    az network application-gateway frontend-port create `
    --port 443 `
    --gateway-name $gateway `
    --resource-group $resourceGroup `
    --name port_443   
    
    az network application-gateway frontend-port create `
    --port 80 `
    --gateway-name $gateway `
    --resource-group $resourceGroup `
    --name port_80   

    az network application-gateway ssl-cert create -g $resourceGroup `
    --gateway-name $gateway `
    -n SureprepCert `
    --cert-file $certLocation `
    --cert-password $certPassword 

    az network application-gateway frontend-ip create `
    --gateway-name $gateway `
    --name appGatewayPrivateFrontendIP `
    --private-ip-address $frontendPrivIP `
    --resource-group $resourceGroup `
    --subnet $gateway-subnet `
    --vnet-name $vnet

}

function CreateBackendPools {

    az network application-gateway address-pool create `
    --gateway-name $gateway `
    --name $pool1 `
    --resource-group $resourceGroup

    az network application-gateway address-pool create `
    --gateway-name $gateway `
    --name $pool2 `
    --resource-group $resourceGroup
                                                
}

function UpdateAppGatewaySettings {
    $Sites | foreach($_){

        ##update http-settings from csv
        az network application-gateway http-settings update -g $resourceGroup --gateway-name $gateway -n $_.HttpSettings --port 443 --protocol Https --cookie-based-affinity Enabled --timeout 30 --connection-draining-timeout 120 --host-name $_.Hostname
        
            ##update http-listener from csv
            az network application-gateway http-listener update -g $resourceGroup --gateway-name $gateway --frontend-port port_80 -n $_.HttpListener --frontend-ip $_.FrontendIP --host-name $_.Hostname
            az network application-gateway http-listener update -g $resourceGroup --gateway-name $gateway --frontend-port port_443 -n $_.HttpsListener --frontend-ip $_.FrontendIP --host-name $_.Hostname

             ##update healthprobe from csv
             az network application-gateway probe update -g $resourceGroup --gateway-name $gateway -n $_.Healthprobe --protocol https --host $_.Hostname --path "/"
    
    ##NOTE!! Had to manually update https listeners !! Why? couldn't I find the right commands
    
                ##update rule from csv
                az network application-gateway rule update -g $resourceGroup --gateway-name $gateway -n $_.Rule --http-listener $_.HttpsListener --rule-type Basic --address-pool $_.BackendPool --http-settings $_.HttpSettings
    
        }
}

    ##Make sure to update dns entries on your DNS Provider

function CreateAppGatewaySettings {
    $Sites | foreach($_){

        #Create http-settings
         az network application-gateway http-settings create `
         -g $resourceGroup `
         --gateway-name $gateway `
         -n $_.HttpSettings `
         --port 443 `
         --protocol Https `
         --cookie-based-affinity Enabled `
         --timeout 30 `
         --connection-draining-timeout 120 `
         --host-name $_.Hostname

           ##Create http(s)-listener -port_443
           az network application-gateway http-listener create `
           -g $resourceGroup `
           --gateway-name $gateway `
           --frontend-port port_443 `
           -n $_.HttpsListener `
           --frontend-ip $_.FrontendIP `
           --host-name $_.Hostname `
           --ssl-cert SureprepCert
        
            ##Create http-listener -port_80
            az network application-gateway http-listener create `
            -g $resourceGroup `
            --gateway-name $gateway `
            --frontend-port port_80 `
            -n $_.HttpListener `
            --frontend-ip $_.FrontendIP `
            --host-name $_.Hostname


             ##Create healthprobe
                az network application-gateway probe create `
                -g $resourceGroup `
                --gateway-name $gateway `
                -n $_.Healthprobe `
                --protocol https `
                --host $_.Hostname `
                --path "/"
    
            ##Create rule from csv
                az network application-gateway rule create `
                -g $resourceGroup `
                --gateway-name $gateway `
                -n $_.Rule `
                --http-listener $_.HttpsListener `
                --rule-type Basic `
                --address-pool $_.BackendPool `
                --http-settings $_.HttpSettings

            ##Updates Http-Settings with new healthprobe
                az network application-gateway http-settings update `
                -g $resourceGroup `
                --gateway-name $gateway `
                -n $_.HttpSettings `
                --probe $_.HealthProbe
       
        }
    
}

function CreateCert{
az network application-gateway ssl-cert create -g $resourceGroup `
    --gateway-name $gateway `
    -n SureprepCert `
    --cert-file $certLocation `
    --cert-password $certPassword 
    }

function CreatePort{
az network application-gateway frontend-port create -g $resourceGroup --gateway-name $gateway -n Port_443 --port 443
az network application-gateway frontend-port create -g $resourceGroup --gateway-name $gateway -n Port_80 --port 80

}

##Call all functions
CreateAppGateway

CreatePort

CreateCert

CreateBackendPools

CreateAppGatewaySettings

