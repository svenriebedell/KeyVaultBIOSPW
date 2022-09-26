#$azureAppId = '9bd11b68-222e-4a0f-941a-a12345c3957d'
 #$azureAppIdPassword = ConvertTo-SecureString 'CGZJ8Q~Kz6lC2jCuMhcKi1gnhrRF4Viam7M2nnaYX'
 #$azureAppCred = (New-Object System.Management.Automation.PSCredential ($azureAppId, $azureAppIdPassword))
 $subscriptionId = '124636a2-a349-4c59-b0b3-6769ed6dc6f9'
 $tenantId = '0d02d0b5-802d-427e-abc8-5166348b7f1f'
 Connect-AzAccount -ServicePrincipal -SubscriptionId $subscriptionId -TenantId $tenantId -Credential $azureAppCred

 $password = ConvertTo-SecureString 'CGZJ8Q~Kz6lC2jCuMhcKi1gnhrRF4Viam7M2nnaYX' -AsPlainText -Force
 $credential = New-Object System.Management.Automation.PSCredential ('9bd11b68-222e-4a0f-941a-a12345c3957d', $password)

 Connect-AzAccount -Credential $credential -ServicePrincipal

 Connect-AzAccount -ServicePrincipal -SubscriptionId $subscriptionId -TenantId $tenantId -Credential $credential