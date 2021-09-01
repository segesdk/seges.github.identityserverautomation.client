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
    $PostLogoutRedirectUri,
    [Parameter(Mandatory=$false)]
    [string]
    $RequirePkce=$true,
    [Parameter(Mandatory=$false)]
    [string]
    $AllowOfflineAccess=$false,
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

. $pwd\_IdentityServerCommon.ps1

Confirm-AbsoluteUrl ($IdentityServerUrl)
Confirm-LowerCase ($ClientId)

if ($RedirectUris)
{
    Confirm-LowerCase $RedirectUris
}

if ($PostLogoutRedirectUri)
{
  Confirm-LowerCase $PostLogoutRedirectUri
  Confirm-AbsoluteUrl $PostLogoutRedirectUri
}

$name = "$($ResourceEnvironment.ToUpper()) $ClientId";

Write-Host "Running Client.ps1:"
Write-Host "Name: $name"

$accesToken = GetAccesToken $identityServerUrl $IdentityServerClientId $IdentityServerClientSecret 

$oldClient = ClientExits $identityServerUrl $ClientId $accesToken

$client = @{ClientId = $clientId; ClientName = $ClientName; PostLogoutRedirectUri = $PostLogoutRedirectUri; RequirePkce = [System.Convert]::ToBoolean($RequirePkce);  AllowOfflineAccess = [System.Convert]::ToBoolean($AllowOfflineAccess); RoleFilter = $RoleFilter }

if ($AllowedScopes)
{
    $allowedScopesArray = SplitToArray $AllowedScopes ' '

    $client | add-member -Name "AllowedScopes" -value $allowedScopesArray -MemberType NoteProperty
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


