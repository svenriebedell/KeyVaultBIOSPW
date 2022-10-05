<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0.0
_Dev_Status_ = Test
Copyright Â© 2022 Dell Inc. or its subsidiaries. All Rights Reserved.

No implied support and test in test environment/device before using in any production environment.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#Version Changes

1.0.0    inital version

#>

<#
.Synopsis
   This PowerShell is for remediation by MS Endpoint Manager. This script will set a BIOS AdminPW on a Dell machine by using WMI.
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using WMI for setting AdminPW on the machine. The script checking if any PW is exist and can setup new and change PW. 
   This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for remediation only and need a seperate script for detection additional.
   
#>


#############################################################################
#############################################################################
# Variables section                                                         #
#############################################################################
#############################################################################

#############################################################################
# Connect informations for Azure Authentification                           #
#############################################################################

# Tenant, Application-ID and Secure-Value
$Tenant = '0d02d0b5-802d-427e-abc8-5166348b7f1f'
$ApplicationId = '9bd11b68-222e-4a0f-941a-a12345c3957d'
$Secret = 'GZJ8Q~Kz6lC2jCuMhcKi1gnhrRF4Viam7M2nnaYX'

#############################################################################
# device informations                                                       #
#############################################################################

$DeviceName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$serviceTag = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber


#############################################################################
# Environment Variables                                                     #
#############################################################################
$Date = Get-Date

#############################################################################
# Option Randmized PWD Function                                             #
#############################################################################

# Value true the password generator generate a randomize password
$PasswordGenerator = $False #$True/$False
$PWLength = 8 # lenght of your randomized Password

####################################################################################
# Variables for KeyVault PW PreShared Key works only if $PasswordGenerator = False #
####################################################################################

#Name of the Secret in KeyVault which incl. the Static Part of BIOS PWD
$KeyVaultPreShared = "0-PreSharedKey"

############################################################################
# required versions for PowerShell Modules                                 #
############################################################################

[Version]$PowerShellGetVersion = "2.2.5"
[Version]$AzKeyVaultVersion = "4.7.0"
[Version]$AzAccountsVersion = "2.10.1"


#############################################################################
#############################################################################
# Function section                                                          #
#############################################################################
#############################################################################

##################################################
#### Check install missing PowerShell Modules ####
##################################################

Function Check-Module
    {
    param
        (
        
        [string]$ModuleName,
        [Version]$ModuleVersion

        )
    

    ########################################
    #### Check if Module Name exist     ####
    ########################################
    
    $ModuleNameCheck = Get-InstalledModule -Name $ModuleName -ErrorAction Ignore

    If($Null -eq $ModuleNameCheck)
        {
        
        switch ($ModuleName)
            {
                Az.Accounts {'AZ'}
                Az.KeyVault {'AZ'}
                PowerShellGet {'PowerShellGet'}

            }

        Install-Module -Name $ModuleName -Force -AllowClobber

        $ModuleCheck = Get-InstalledModule -Name $ModuleName | Where-Object{$_.Version -ge "$ModuleVersion"} | Select-Object -ExpandProperty Name

        

        If($null-eq $ModuleCheck)
            {

            Write-EventLog -LogName "Dell BIOS" -EventId 11 -EntryType Error -Source "BIOS Password Manager" -Message "Powershell Module $ModuleName failed to install"

            }

        Else
            {

            Write-EventLog -LogName "Dell BIOS" -EventId 00 -EntryType SuccessAudit -Source "BIOS Password Manager" -Message "Powershell Module $ModuleName is successfull installed"

            }
        }

    
    Else
        {  
     
        $ModuleCheck = Get-InstalledModule -Name $ModuleName | Where-Object{$_.Version -ge "$ModuleVersion"} | Select-Object -ExpandProperty Name -ErrorAction Ignore

        switch ($ModuleName)
            {
                Az.Accounts {'AZ'}
                Az.KeyVault {'AZ'}
                PowerShellGet {'PowerShellGet'}

            }


        If($null-eq $ModuleCheck)
            {

            Install-Module -Name $ModuleName -Force -AllowClobber

            $ModuleCheck = Get-InstalledModule -Name $ModuleName | Where-Object{$_.Version -ge "$ModuleVersion"} | Select-Object -ExpandProperty Name

        

            If($null-eq $ModuleCheck)
                {

                Write-EventLog -LogName "Dell BIOS" -EventId 11 -EntryType Error -Source "BIOS Password Manager" -Message "Powershell Module $ModuleName failed to install"

                }

            Else
                {

                $AttributStringValue = "is installed"
                Write-EventLog -LogName "Dell BIOS" -EventId 00 -EntryType SuccessAudit -Source "BIOS Password Manager" -Message "Powershell Module $ModuleName is successfull installed"

                }

      
            }

        Else
            {

            Write-EventLog -LogName "Dell BIOS" -EventId 01 -EntryType Information -Source "BIOS Password Manager" -Message "Powershell Module $ModuleName is still existing"

            }
        }
   
    }



##################################
#### Connect to KeyVault      ####
##################################

Function Connect-KeyVaultPWD
    {

    #############################################################################
    # Connect KeyVault                                                          #
    #############################################################################

    [SecureString]$pwd = ConvertTo-SecureString $Secret -AsPlainText -Force
    [PSCredential]$Credential = New-Object System.Management.Automation.PSCredential ($ApplicationId, $pwd)
    Connect-AzAccount -Credential $Credential -Tenant $Tenant -ServicePrincipal  

    }


##################################
#### Request KeyVault BIOSPWD ####
##################################

Function get-KeyVaultPWD
    {

    Param
        (

        [string]$KeyName

        )

    #############################################################################
    # Check BIOS PWD for Device or PreSharedKey                                 #
    #############################################################################

    $secret = (Get-AzKeyVaultSecret -vaultName "PWDBIOS" -name $KeyName) | select *
    $Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue) 
    $KeyPWD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret)  
       
    Return $KeyPWD   

    }


##################################
#### Request KeyVault BIOSPWD ####
##################################

Function write-KeyVaultPWD
    {

    Param
        (

        [string]$Password

        )

    $securevalue = ConvertTo-SecureString $Password -AsPlainText -Force
    $secret =  Set-AzureKeyVaultSecret -VaultName "pwdbios" -Name $serviceTag -SecretValue $securevalue

    }


############################
#### Password set check ####
############################

function AdminPWD-Check
    {

    # Check AdminPWD status 0 = no PWD is set / 1 = PWD is set
    $PWstatus = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | Select-Object -ExpandProperty IsPasswordSet

    Switch ($PWstatus)
        {

            0 {$AttributStringValue = 'disabled'}
            1 {$AttributStringValue = 'enabled'}

        }
    
    return $PWstatus,$AttributStringValue
    
    }


###################################
#### Password set new AdminPWD ####
###################################

function AdminPWD-setnew
    {

    param
        (

        [string]$Password

        )


    # Connect to the SecurityInterface WMI class
    $SecurityInterface = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface

    # Set AdminPW and get result
    $PWstatus = $SecurityInterface.SetNewPassword(0,0,0,"Admin","",$Password) | Select-Object -ExpandProperty Status

    Switch ($PWstatus)
        {

            0 {$result = "Success"}
            1 {$result = "Failed"}
            2 {$result = "Invalid Parameter"}
            3 {$result = 'Access Denied'}
            4 {$result = 'Not Supported'}
            5 {$result = 'Memory Error'}
            6 {$result = 'Protocol Error'}

        }
    
     return $PWstatus, $result

    }

###################################
#### Password change AdminPWD ####
###################################

function AdminPWD-change
    {

    param
        (

        [string]$Password,
        [string]$PasswordOld

        )


    # Connect to the SecurityInterface WMI class
    $SecurityInterface = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface

    # Change AdminPW and get result

    # Encoding BIOS Password Old
    $Encoder = New-Object System.Text.UTF8Encoding
    $Bytes = $Encoder.GetBytes($PasswordOld)

    $PWstatus = $SecurityInterface.SetNewPassword(1,$Bytes.Length,$Bytes,"Admin",$Password,$PasswordOld) | Select-Object -ExpandProperty Status
    
    Switch ($PWstatus)
        {

            0 {$result = "Success"}
            1 {$result = "Failed"}
            2 {$result = "Invalid Parameter"}
            3 {$result = 'Access Denied'}
            4 {$result = 'Not Supported'}
            5 {$result = 'Memory Error'}
            6 {$result = 'Protocol Error'}

        }
    
 
    return $PWstatus, $result

    }


#############################
#### Password randomizer ####
#############################


# This function is from https://gist.github.com/indented-automation/2093bd088d59b362ec2a5b81a14ba84e
function New-Password {
  
    [CmdletBinding()]
    [OutputType([String])]
    param (
        # The length of the password which should be created.
        [Parameter(ValueFromPipeline)]        
        [ValidateRange(8, 255)]
        [Int32]$Length = $PWLength,

        # The character sets the password may contain. A password will contain at least one of each of the characters.
        [String[]]$CharacterSet = ('abcdefghijklmnopqrstuvwxyz',
                                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                   '0123456789',
                                   '!$%'),
<#
For Dell 7th Generation and newer client products, you should use the following guidelines:
BIOS passwords can include:
The following special characters (ASCII 0x21 – 0x2f):
! " # $ % & ' ( ) * + , - . /
A number (ASCII 0x30 – 0x39):
0 1 2 3 4 5 6 7 8 9
One of the following special characters (ASCII 0x3a – 0x40):
: ; < = > ? @
A capital English letter (ASCII 0x41 – 0x5a):
A - Z
One of the following special characters (ASCII 0x5b – 0x60):
[ \ ] ^ _ `
A lower case English letter (ASCII 0x61 – 0x7a):
a - z
One of the following special characters (ASCII 0x7b – 0x7e):
{ | } ~
#>
        # The number of characters to select from each character set.
        [Int32[]]$CharacterSetCount = (@(1) * $CharacterSet.Count)
    )

    begin {
        $bytes = [Byte[]]::new(4)
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)

        $seed = [System.BitConverter]::ToInt32($bytes, 0)
        $rnd = [Random]::new($seed)

        if ($CharacterSet.Count -ne $CharacterSetCount.Count) {
            throw "The number of items in -CharacterSet needs to match the number of items in -CharacterSetCount"
        }

        $allCharacterSets = [String]::Concat($CharacterSet)
    }

    process {
        try {
            $requiredCharLength = 0
            foreach ($i in $CharacterSetCount) {
                $requiredCharLength += $i
            }

            if ($requiredCharLength -gt $Length) {
                throw "The sum of characters specified by CharacterSetCount is higher than the desired password length"
            }

            $password = [Char[]]::new($Length)
            $index = 0
        
            for ($i = 0; $i -lt $CharacterSet.Count; $i++) {
                for ($j = 0; $j -lt $CharacterSetCount[$i]; $j++) {
                    $password[$index++] = $CharacterSet[$i][$rnd.Next($CharacterSet[$i].Length)]
                }
            }

            for ($i = $index; $i -lt $Length; $i++) {
                $password[$index++] = $allCharacterSets[$rnd.Next($allCharacterSets.Length)]
            }

            # Fisher-Yates shuffle
            for ($i = $Length; $i -gt 0; $i--) {
                $n = $i - 1
                $m = $rnd.Next($i)
                $j = $password[$m]
                $password[$m] = $password[$n]
                $password[$n] = $j
            }

            [String]::new($password)
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}



#############################################################################
# Program section                                                           #
#############################################################################

########################################
#### Start Logging                  ####
########################################

# setup LogID and Source for logging in MS Event Viewer
New-EventLog -LogName "Dell BIOS" -Source "BIOS Password Manager" -ErrorAction Ignore


########################################
#### prepare PowerShell Environment ####
########################################

# AZ PowerShell Module
$CheckPowerShellModule = Check-Module -ModuleName PowerShellGet -ModuleVersion $PowerShellGetVersion
# AZ PowerShell Module
$CheckPowerShellModule = Check-Module -ModuleName Az.Accounts -ModuleVersion $AzAccountsVersion
$CheckPowerShellModule = Check-Module -ModuleName Az.KeyVault -ModuleVersion $AzKeyVaultVersion


###############################################################
#### disable store Az.Account informations in User Profile ####
###############################################################

Disable-AzContextAutosave


########################################
#### Check if BIOS Admin PWD is set ####
########################################

$PWset = AdminPWD-Check


if ($PWset[0] -eq 0)
    {
    
    #Report missing BIOS AdminPWD
    Write-EventLog -LogName "Dell BIOS" -EventId 00 -Source "BIOS Password Manager" -EntryType Error -Message "Error: Device $DeviceName has no AdminPWD"

    ##############################################
    #### Setup BIOS AdminPWD                  ####
    ##############################################
    
    If($PasswordGenerator -eq $false)
        {

        # Connect to KeyVault
        Connect-KeyVaultPWD

        # Get PreShareKey for generate AdminPWD
        $AdminPreSharedKeyPWD = get-KeyVaultPWD -KeyName $KeyVaultPreShared

        $AdminPWDNew = $serviceTag+$AdminPreSharedKeyPWD

        }
    Else
        {


        $AdminPWDNew = New-Password


        }

    # Set AdminPWD to Device and return setup result
    $PWstatus = AdminPWD-setnew -Password $AdminPWDNew

        

        
    If($PWstatus -eq 0)
        {

        # report success to MS Event Viewer
        Write-EventLog -LogName "Dell BIOS" -EventId 00 -Source "BIOS Password Manager" -EntryType SuccessAudit -Message "Success: AdminPWD is set on Device $DeviceName"

        <#  0 {$result = "Success"}
            1 {$result = "Failed"}
            2 {$result = "Invalid Parameter"}
            3 {$result = 'Access Denied'}
            4 {$result = 'Not Supported'}
            5 {$result = 'Memory Error'}
            6 {$result = 'Protocol Error'} #>

        write-KeyVaultPWD -Password $AdminPWDNew

        }
    Else
        {

        # report Error Code to MS Event Viewer
        Write-EventLog -LogName "Dell BIOS" -EventId 11 -Source "BIOS Password Manager" -EntryType Error -Message "Error: AdminPWD is not set correctly on Device $DeviceName Error-Code: $PWstatus"

        }

    # disconnect KeyVault connection
    Disconnect-AzAccount
    
    }
Else
    {

    ###################################################################
    #### request Device BIOS PW from KeyVault or use PWD Generator ####
    ###################################################################

    If($PasswordGenerator -eq $false)
        {

        # Connect to KeyVault
        Connect-KeyVaultPWD
        $AdminKeyPWDCurrent = get-KeyVaultPWD -KeyName $DeviceName
        $AdminKeyPWDPreShared = get-KeyVaultPWD -KeyName $KeyVaultPreShared
        Disconnect-AzAccount

        $AdminPWDNew = $serviceTag+$AdminKeyPWDPreShared

        }
    Else
        {
        Connect-KeyVaultPWD
        $AdminKeyPWDCurrent = get-KeyVaultPWD -KeyName $DeviceName
        Disconnect-AzAccount

        $AdminPWDNew = New-Password


        }


    If($AdminKeyPWDCurrent -eq $AdminPWDNew)
        {
        
       
        Write-EventLog -LogName "Dell BIOS" -EventId 01 -EntryType Information -Source "BIOS Password Manager" -Message "The status of the BIOS AdminPWD has been checked and is unchanged."
        

        }

    Else
        {


        Write-Host "Passwort is not equal"
        $PWstatus = AdminPWD-change -Password $AdminPWDNew -PasswordOld $AdminKeyPWDCurrent


            If($PWstatus -eq 0)
                {

                # report success to MS Event Viewer
                Write-EventLog -LogName "Dell BIOS" -EventId 00 -Source "BIOS Password Manager" -EntryType SuccessAudit -Message "Success: AdminPWD is set on Device $DeviceName"

                <#  0 {$result = "Success"}
                    1 {$result = "Failed"}
                    2 {$result = "Invalid Parameter"}
                    3 {$result = 'Access Denied'}
                    4 {$result = 'Not Supported'}
                    5 {$result = 'Memory Error'}
                    6 {$result = 'Protocol Error'} #>

                write-KeyVaultPWD -Password $AdminPWDNew

                }
            Else
                {

                # report Error Code to MS Event Viewer
                Write-EventLog -LogName "Dell BIOS" -EventId 11 -Source "BIOS Password Manager" -EntryType Error -Message "Error: AdminPWD is not set correctly on Device $DeviceName Error-Code: $PWstatus"

                }

        }


    }