$TenantID = "0d02d0b5-802d-427e-abc8-5166348b7f1f"
$App_ID = "9bd11b68-222e-4a0f-941a-a12345c3957d"
$ThumbPrint = "52FADBF9B36685E734DA84C6283D9EA7D4302E35"
Connect-AzAccount -tenantid $TenantID -ApplicationId $App_ID -CertificateThumbprint $ThumbPrint

$secret = (Get-AzKeyVaultSecret -vaultName "PWDBIOS" -name "SRLAB-1X752J3") | select *
$Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue) 
$Display_My_Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret) 
$Display_My_Secret