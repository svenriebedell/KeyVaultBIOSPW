$securevalue = ConvertTo-SecureString "Dell9000!" -AsPlainText -Force
$secret =  Set-AzureKeyVaultSecret -VaultName "pwdbios" -Name "1X752J3" -SecretValue $securevalue


<#Install Az.Accounts
Install-Module -Name Az#>
Install-Module -Name Az.KeyVault -Force