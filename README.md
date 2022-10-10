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

![image](https://user-images.githubusercontent.com/99394991/194842244-09f06945-5077-4d78-ae40-29b52b36a751.png)



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


## Troubleshouting and logging

The PowerShell creating messages in Microsoft Event for Monitoring and troubleshouting

- Event ID 20 - 22 for WMI BIOS Settings (20 - Error / 21 - Infomation / 22 - Success)
- Event ID 30 - 32 for Key Vault Events (30 - Error / 31 - Infomation / 32 - Success)
- Event ID 40 - 22 for PowerShell Modules (40 - Error / 41 - Infomation / 42 - Success)

