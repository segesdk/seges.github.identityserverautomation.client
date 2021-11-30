# https://confluence.seges.dk/pages/viewpage.action?pageId=166958870
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $IdentityServerClientId,
    [Parameter(Mandatory=$true)]
    [string]
    $IdentityServerClientSecret,
    [Parameter(Mandatory=$true)]
    [string]
    $IdentityServerUrl,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceEnvironment,
    [Parameter(Mandatory=$true)]
    [string]
    $ClientId,
    [Parameter(Mandatory=$true)]
    [string]
    $ClientName,
    [Parameter(Mandatory=$true)]
    [string]
    $AllowedScopes,
    [Parameter(Mandatory=$true)]
    [string]
    $AllowedGrantTypes,
    [Parameter(Mandatory=$true)]
    [string]
    $RedirectUris,
    [Parameter(Mandatory=$true)]
    [string]
    $PostLogoutRedirectUris,
    [Parameter(Mandatory=$false)]
    [string]
    $RequirePkce=$true,
    [Parameter(Mandatory=$false)]
    [string]
    $AllowOfflineAccess=$true,
    [Parameter(Mandatory=$false)]
    [string]
    $AllowedCorsOrigins,
    [Parameter(Mandatory=$false)]
    [string]
    $RoleFilter
)

#requires -PSEdition Core
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\_IdentityServerCommon.ps1

Confirm-AbsoluteUrl ($IdentityServerUrl)
Confirm-LowerCase ($ClientId)

if ($RedirectUris)
{
    Confirm-LowerCase $RedirectUris
}

$name = "$($ResourceEnvironment.ToUpper()) $ClientId";

Write-Host "Running Client.ps1:"
Write-Host "Name: $name"

$accesToken = GetAccesToken $identityServerUrl $IdentityServerClientId $IdentityServerClientSecret 

$oldClient = ClientExits $identityServerUrl $ClientId $accesToken

$client = @{ClientId = $clientId; ClientName = $ClientName; RequirePkce = [System.Convert]::ToBoolean($RequirePkce);  AllowOfflineAccess = [System.Convert]::ToBoolean($AllowOfflineAccess); RoleFilter = $RoleFilter }

if ($AllowedScopes)
{
    $allowedScopesArray = SplitToArray $AllowedScopes ' '

    $client | add-member -Name "AllowedScopes" -value $allowedScopesArray -MemberType NoteProperty
}

if ($PostLogoutRedirectUris)
{

    $postLogoutRedirectUrisArray = SplitToArray $PostLogoutRedirectUris ','
    for ($index = 0; $index -lt $postLogoutRedirectUrisArray.count; $index++)
    {
        Confirm-LowerCase $postLogoutRedirectUrisArray[$index] $("PostLogoutRedirectUris Index $index")
        Confirm-AbsoluteUrl $postLogoutRedirectUrisArray[$index] $("PostLogoutRedirectUris Index $index")
    }
    $client | add-member -Name "PostLogoutRedirectUris" -value $postLogoutRedirectUrisArray -MemberType NoteProperty
}
else {
    $client | add-member -Name "PostLogoutRedirectUris" -value @() -MemberType NoteProperty
}


if ($AllowedGrantTypes)
{ 
    $allowedGrantTypesArray = SplitToArray $AllowedGrantTypes ','

    $client | add-member -Name "AllowedGrantTypes" -value $allowedGrantTypesArray -MemberType NoteProperty
}

if ($RedirectUris)
{
    $redirectUrisArray = SplitToArray $RedirectUris ','

    for ($index = 0; $index -lt $redirectUrisArray.count; $index++)
    {
        Confirm-AbsoluteUrl $redirectUrisArray[$index] $("RedirectUris Index $index")
    }

    $client | add-member -Name "RedirectUris" -value $redirectUrisArray -MemberType NoteProperty
}

if ($AllowedCorsOrigins)
{
    $allowedCorsOriginsArray = SplitToArray $AllowedCorsOrigins ','

    for ($index = 0; $index -lt $allowedCorsOriginsArray.count; $index++)
    {
        Confirm-AbsoluteUrl $allowedCorsOriginsArray[$index] $("AllowedCors Index $index")
    }

    $client | add-member -Name "AllowedCorsOrigins" -value $allowedCorsOriginsArray -MemberType NoteProperty

}
else {
    $client | add-member -Name "AllowedCorsOrigins" -value @() -MemberType NoteProperty
}
$requestJson = $client | ConvertTo-Json -Compress

Write-Host $requestJson
if ($oldClient)
{
    Write-Host "Updating Client:"
    UpdateClient $identityServerUrl $requestJson $accesToken
}
else 
{
    Write-Host "Creating Client:"   
    CreateClient $identityServerUrl $requestJson $accesToken
}

Write-Host "Done"


