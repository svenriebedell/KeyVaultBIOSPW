<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0
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

<#
.Synopsis
   This PowerShell add AzAccount Module to Powershell and Import KeyVault Certificate for authorization of KeyVault Requests

.DESCRIPTION
   This PowerShell Import PowerShell Module AzAccount and KeyVault Certificate
   
#>

######################################################################################################################
# Install PS-Module                                                                                                  #
######################################################################################################################
Install-Module -Name PowerShellGet -Force
Install-Module -Name Az -Force

######################################################################################################################
# Import Authentification Certificate                                                                                #
######################################################################################################################

Import-Certificate -FilePath .\MyKeyVault_Cert.cer -CertStoreLocation Cert:\LocalMachine\My\