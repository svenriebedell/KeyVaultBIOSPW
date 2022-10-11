# Dell BIOS Password Manager with Microsoft Key Vault Service

### Changelog:
1.0.1  First public version

## Description 

This project shows how to set and change a Dell BIOS Admin password using Microsoft Key Vault. The passwords are stored securely in the Microsoft Key Vault service for later use in Dell Command | Update or other solutions.


**Legal disclaimer: THE INFORMATION IN THIS PUBLICATION IS PROVIDED 'AS-IS.' DELL MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND WITH RESPECT TO THE INFORMATION IN THIS PUBLICATION, AND SPECIFICALLY DISCLAIMS IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.** In no event shall Dell Technologies, its affiliates or suppliers, be liable for any damages whatsoever arising from or related to the information contained herein or actions that you decide to take based thereon, including any direct, indirect, incidental, consequential, loss of business profits or special damages, even if Dell Technologies, its affiliates or suppliers have been advised of the possibility of such damages.

## Instructions

### Requirements:
- Microsoft Azure Service
- Microsoft Key Vault Service
  Setup: https://learn.microsoft.com/en-us/azure/key-vault/general/quick-create-portal
- Azure Registered App Authentification 
- Dell Business Devices should not be older than 2018 (otherwise BIOS WMI is not supported on this machines)

### Configuration Options for PowerShell

There some fields you need **to edit before you start!!!**

- **$Tenant** is the Microsoft Azure Tenant-ID of your Environment
- **$Application** is your self created authentification Application-ID in Azure Service. Setup of Key Vault you will find below if needed.
- **$Secret** is your client secret value form authentification Application

#### *PowerShell:*

![image](https://user-images.githubusercontent.com/99394991/194841985-82b59f0b-ffba-42bc-b323-2fed473e7a08.png)


#### *$Tenant*

![image](https://user-images.githubusercontent.com/99394991/194842703-d7be07d5-ef69-4408-aa33-51fc21484c24.png)

#### *$Application*

![image](https://user-images.githubusercontent.com/99394991/194842507-ba792d34-c2a3-4b98-bdd2-051e487861c7.png)

#### *$Secret*

![image](https://user-images.githubusercontent.com/99394991/195053474-2c74bf77-ee63-4591-9e5c-dd7e94a2dc1e.png)




**************************************************************************************

### The PowerShell offers you **two** kinds of password options:
- PreSharedKey+ServiceTag (PreSharedKey cames from Microsoft Key Vault)
- full randomized password

#### PreSharedKey Option (default)

you need to edited the name of you PreshardKey. It should be the same like in Microsoft Key Vault service.


#### $KeyVaultPreShared

![image](https://user-images.githubusercontent.com/99394991/194842056-158f82c1-867d-48a7-b1e1-ea4aca42f3fe.png)

#### Key Vault Name
![image](https://user-images.githubusercontent.com/99394991/194842075-c8b58f95-3e11-44d7-b5c9-1ede5ecbeb54.png)





#### Randomized Option (option)

You need to enable this service first otherwise the password is used as PreSharedKey option

- **$PasswordGenerator** status is $false and could change to $true, if $true the script using a randomized password.
- **$PWLength** is lenght of the randomized passwort choose a value between 1 - 32 (max. 32 characters)

![image](https://user-images.githubusercontent.com/99394991/194842166-e140fca3-f459-4370-ad4f-ded975c0db8f.png)




****************************************
## Troubleshouting and logging

The PowerShell creating messages in Microsoft Event for Monitoring and troubleshouting

- Event ID 20 - 22 for WMI BIOS Settings (20 - Error / 21 - Infomation / 22 - Success)
- Event ID 30 - 32 for Key Vault Events (30 - Error / 31 - Infomation / 32 - Success)
- Event ID 40 - 22 for PowerShell Modules (40 - Error / 41 - Infomation / 42 - Success)

![image](https://user-images.githubusercontent.com/99394991/194856718-af44b342-1113-48ba-a214-63dba1bfa098.png)


****************************************

# Setup Key Vault Environment

If you have not in place yet we need a configured Key Vault Service and a registerd applications for authentification between client and Key Vault Service.
You can choose between different authentification types like Certificates, Client secrets and Federanted credentials. I choose the option client secrets for my scripts whichs allows me to run the script everywhere without to deploy any certificates on the client, for my example it makes the deployment and setup much easier.

![image](https://user-images.githubusercontent.com/99394991/194889752-e48ca9f7-4079-4fa3-95d5-3490ba2d6b31.png)


### Setup Microsoft Key Vault

**Prepare**
Login: **portal.azure.com**
Search for '**Key vaults**' and start service

![image](https://user-images.githubusercontent.com/99394991/195051856-8a704efa-0066-40d0-9903-7fa81462269d.png)



If you have no Key vaults Container you need setup one first.
Click 'Create'

![image](https://user-images.githubusercontent.com/99394991/195051916-ef1eb9c9-e892-4159-880d-3e7d5c114e2c.png)



Fill out mandetory fields:
- Resource group
- Key vault name e.g. PWDBIOS
- Region
- Pricing tier (Standard is fine)

Click 'Review + create

![image](https://user-images.githubusercontent.com/99394991/195052207-56f28dec-3d25-4b97-9a3d-069082be153b.png)



*Now* we have created the Key vault Container where we store the BIOS password later.

![image](https://user-images.githubusercontent.com/99394991/195052250-2cf3498c-d53d-4f75-882b-a7b3fe0b4338.png)


### Setup Azure App for Authentification

**Prepare**
Login: **portal.azure.com**
Search for '**App registrations**' and start service

![image](https://user-images.githubusercontent.com/99394991/195052304-3f12c2b8-9e92-45ab-af15-3a00d9d18016.png)


Click 'New registration'

![image](https://user-images.githubusercontent.com/99394991/195052348-173daf9d-855c-49cb-916c-3ed2f2e2d7fe.png)


Fill out mandetory fields:
- Name e.g. BIOS_PWD
Supported account types select based on your environment e.g. Single tenant

Click 'Register'

![image](https://user-images.githubusercontent.com/99394991/195052420-d6cddf6d-7247-42da-b256-db50b8662f9c.png)



### Generate a Client Secure for authentification

go to your Azure App for Authentication
Click 'Certificates & secrets'




Click 'Client secrets'
Click 'New client secret'


fill out mandetory fields:

- Description e.g. BIOSPWD
- Expires e.g. 6 month or longer depands on you IT-Security

Click 'Add'



Now you have a credential you can use with your version of the BIOS Password PowerShell script

**Important: The Value field is only viewable one time so please copy this information and save it on a secure place**




### Give Azure App for Authentification read/write rights in Key vaults container

go to your Key vaults container
Click 'Access policies'



Click 'Create'


Section '**Secret permissions**'
Select **ONLY** get, set
Click 'Next'




Search for your Azure App
Select this App
Click 'Next' twice



Click 'Create'



Ready.



Now please fill out the information in the PowerShell script (Informations you will find top of this Readme)


The script could be now use by Taskplaner or MEM Remediation, etc.















