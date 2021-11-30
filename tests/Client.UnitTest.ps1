Set-StrictMode -Off
$ErrorActionPreference = "Ignore"
$projectName = "jmntest"
$projectRole = "frontend"
$environment = "dev"
$projectUrl= "someurl.somesites.net"

$global:PSDefaultParameterValues = @{
    'Invoke-RestMethod:Proxy'='http://127.0.0.1:8888'
    'Invoke-WebRequest:Proxy'='http://127.0.0.1:8888'
    '*:ProxyUseDefaultCredentials'=$true
}

Describe "Client" {
    It "writes configuration without errors" {
        # Arrange
        # Mandatory parameters
        $IdentityServerClientId = "urn:si-octopus-client"
        $IdentityServerClientSecret = $env:LocalOctopusClientSecret # You need to set $env:LocalOctopusClientSecret locally - use '' string if secret contains $
        $IdentityServerUrl = "https://si-agroid-identityserver.segestest.dk"
        $ResourceEnvironment = $environment
        $ClientId = "$environment-$projectName-$projectRole"
        $ClientName = "$($environment.ToUpper()) $projectName $projectRole"
        $AllowedScopes = "openid profile role offline_access dev.cattle_cattlewebapi.api"
        $AllowedGrantTypes = "authorization_code,password"
        $RedirectUris = "https://$projectUrl/"
        $PostLogoutRedirectUris = "https://$projectUrl/#/logged-out"
    
        # Optional parameters
        # $RequirePkce
        # $AllowOfflineAccess
        $AllowedCorsOrigins = "https://$projectUrl"
        $RoleFilter = "GTA*"
        
        # Act
        {
            & .\Client.ps1 -IdentityServerClientId $IdentityServerClientId -IdentityServerClientSecret $IdentityServerClientSecret -IdentityServerUrl $IdentityServerUrl -ResourceEnvironment $ResourceEnvironment -ClientId $ClientId -ClientName $ClientName -AllowedScopes $AllowedScopes -AllowedGrantTypes $AllowedGrantTypes -RedirectUris $RedirectUris -PostLogoutRedirectUris $PostLogoutRedirectUris -AllowedCorsOrigins $AllowedCorsOrigins -RoleFilter $RoleFilter  
        } | 
        
        # Asssert
        Should Not Throw
    }
}