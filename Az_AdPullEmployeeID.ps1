##Ed Gaeta
#################################################################
#This script pulls nested AzureAd Users EmployeeId and ManagerId
#################################################################
#Connect-AzureAD
$Result = @()
$file1 = Import-Csv 'C:\Users\Ed.Gaeta\Downloads\userlist.csv' | ForEach-Object {
$managerObj = Get-AzureADUserManager -ObjectId $_."userPrincipalName"
$employeeobj = Get-AzureADUser -ObjectId $_."id" | Select -ExpandProperty ExtensionProperty (Get-AzureADUser -ObjectId $_."id").ExtensionProperty.employeeid
$Result += New-Object PSObject -property @{ 
UserName = $_."userPrincipalName"
ManagerName = if ($managerObj -ne $null) { $managerObj.DisplayName } else { $null }
ManagerMail = if ($managerObj -ne $null) { $managerObj.Mail } else { $null }
EmployeeID = if ($employeeobj.employeeId -ne $null) { $employeeobj.employeeId } else {$null}
}
}
$Result 

