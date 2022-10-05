#Connect to the SecurityInterface WMI class
$SecurityInterface = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface
 
#Set the admin password when no password is currently set
$SecurityInterface.SetNewPassword(0,0,0,"Admin","","NewPassword")
 
#Set the system password when no password is currently set
$SecurityInterface.SetNewPassword(0,0,0,"System","","NewPassword")
 
#Change an existing admin password
$SecurityInterface.SetNewPassword(1,$Bytes.Length,$Bytes,"Admin","CurrentPassword","NewPassword")
 
#Clear an existing admin password
$SecurityInterface.SetNewPassword(1,$Bytes.Length,$Bytes,"Admin","CurrentPassword","")
