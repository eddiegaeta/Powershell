##Ed Gaeta
###################################################
#This script pulls all Bitlocker information
###################################################


$DriveLetters = (Get-PSDrive).Name -match '^[a-z]$'

foreach($Drive in $DriveLetters)
{

    #(Get-BitLockerVolume -MountPoint $Drive) |Get-Member
   $computername = (Get-BitLockerVolume -MountPoint $Drive).Computername
   $MountPoint = (Get-BitLockerVolume -MountPoint $Drive).MountPoint
   $ProtectionStatus = (Get-BitLockerVolume -MountPoint $Drive).ProtectionStatus
   $VolumeStatus = (Get-BitLockerVolume -MountPoint $Drive).VolumeStatus
   $VolumeType = (Get-BitLockerVolume -MountPoint $Drive).VolumeType
   #$KeyProtector = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector
   $KeyProtectorId = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector | select KeyProtectorId 
   $AutoUnlockProtector = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector | select AutoUnlockProtector
   $RecoveryPassword = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector | select RecoveryPassword
   $KeyFileName = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector | select KeyFileName

       
    $obj = New-Object PSObject
        $obj | Add-Member ComputerName $ComputerName
        $obj | Add-Member MountPoint $MountPoint
        $obj | Add-Member ProtectionStatus $ProtectionStatus
        $obj | Add-Member VolumeStatus $VolumeStatus
        $obj | Add-Member VolumeType $VolumeType
        $obj | Add-Member KeyProtectorId $KeyProtectorId
        $obj | Add-Member AutoUnlockProtector $AutoUnlockProtector
        $obj | Add-Member RecoveryPassword $RecoveryPassword
        $obj | Add-Member KeyFileName $KeyFileName
        #$obj | Add-Member KeyProtector $KeyProtector
        
        $obj
    #$obj | Export-Csv -Path C:\!\bitlockeroutput.csv -Append -NoClobber -NoTypeInformation
}


