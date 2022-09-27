# Requires Module Az

Disable-AzContextAutosave

$Tenant = '0d02d0b5-802d-427e-abc8-5166348b7f1f'
$ApplicationId = '9bd11b68-222e-4a0f-941a-a12345c3957d'
$Secret = 'GZJ8Q~Kz6lC2jCuMhcKi1gnhrRF4Viam7M2nnaYX'
$VaultName = 'key-vault-name'

# Authenticate against Azure
[SecureString]$pwd = ConvertTo-SecureString $Secret -AsPlainText -Force
[PSCredential]$Credential = New-Object System.Management.Automation.PSCredential ($ApplicationId, $pwd)
Connect-AzAccount -Credential $Credential -Tenant $Tenant -ServicePrincipal

# Now we can get secrets. 
$secret = (Get-AzKeyVaultSecret -vaultName "PWDBIOS" -name "SRLAB-1X752J3") | select *
$Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue) 
$Display_My_Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret) 
$Display_My_Secret