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
# Connect informations                                                      #
#############################################################################

# Tenant, Application-ID and Secure-Value
$Tenant = '0d02d0b5-802d-427e-abc8-5166348b7f1f'
$ApplicationId = '9bd11b68-222e-4a0f-941a-a12345c3957d'
$Secret = 'GZJ8Q~Kz6lC2jCuMhcKi1gnhrRF4Viam7M2nnaYX'

#############################################################################
# device informations                                                      #
#############################################################################

#Device Data
$DeviceName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$DateBIOSset = ""
$BIOSPWrenewal = "180" # Value of days before BIOS PWD need to be changed
#$PWset = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | Select-Object -ExpandProperty IsPasswordSet
$DateTransfer = (Get-Date).AddDays($PWTime)
$PWstatus = ""
$DeviceName = Get-CimInstance -ClassName win32_computersystem | select -ExpandProperty Name
$serviceTag = Get-CimInstance -ClassName win32_bios | Select-Object -ExpandProperty SerialNumber
$AdminPw = "$serviceTag$PWKey"
$Date = Get-Date
$PWKeyOld = ""
$serviceTagOld = ""
$AdminPwOld = ""
$PATH = "C:\Temp\"
$PWKey = "Dell2022008" #Sure-Key of AdminPW

#############################################################################
# enable or disable randomized password                                     #
#############################################################################

$PasswordGenerator = False # Value true the password generator generate a randomize password Value false password = ServiceTag +GenericValue


#############################################################################
# Prepraparations                                                           #
#############################################################################

Install-Module AZ -Force
Disable-AzContextAutosave

#############################################################################
# Connect KeyVault                                                          #
#############################################################################

[SecureString]$pwd = ConvertTo-SecureString $Secret -AsPlainText -Force
[PSCredential]$Credential = New-Object System.Management.Automation.PSCredential ($ApplicationId, $pwd)
Connect-AzAccount -Credential $Credential -Tenant $Tenant -ServicePrincipal

#############################################################################
# Check BIOS PWD for Device                                                 #
#############################################################################

$secret = (Get-AzKeyVaultSecret -vaultName "PWDBIOS" -name "SRLAB-1X752J3") | select *
$Get_My_Scret = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue) 
$Display_My_Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Get_My_Scret) 
$Display_My_Secret


#############################################################################
# Function section                                                          #
#############################################################################

############################
#### Password set check ####
############################

function AdminPWD-Check
    {

    # Connect to the SecurityInterface WMI class
    $SecurityInterface = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface

    # Check AdminPWD status 0 = no PWD is set / 1 = PWD is set
    $PWstatus = $SecurityInterface.SetNewPassword(0,0,0,"Admin","",$AdminPw) | Select-Object -ExpandProperty Status

    return $PWset

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
        [Int32]$Length = 10,

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


########################################
#### Test Registry Path/Value exist ####
########################################

# this function is from https://stackoverflow.com/questions/5648931/test-if-registry-value-exists

function Test-RegistryValue 
    {

    param 
        (

         [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]$Path,

        [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]$Value
        )

    try
        {

        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
        return $true

        }

    catch
        {

        return $false

        }

    }



#############################################################################
# Program section                                                           #
#############################################################################

########################################
#### Check if BIOS Admin PWD is set ####
########################################

AdminPWD-Check