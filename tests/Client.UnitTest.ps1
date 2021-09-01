Set-StrictMode -Off
$ErrorActionPreference = "Ignore"
$projectName = "jmntest"
$projectRole = "frontend"
$environment = "dev"
$projectUrl= "someurl.somesites.net"

Describe "Client" {
    It "writes configuration without errors" {
        # Arrange
        # Mandatory parameters
        $IdentityServerClientId = "urn:si-octopus-client"
        $IdentityServerClientSecret = $env:LocalOctopusClientSecret # You need to set $env:LocalOctopusClientSecret locally
        $IdentityServerUrl = "https://si-agroid-identityserver.segestest.dk"
        $ResourceEnvironment = $environment
        $ClientId = "$environment-$projectName-$projectRole"
        $ClientName = "$($environment.ToUpper()) $projectName $projectRole"
        $AllowedScopes = "openid profile role offline_access dev.cattle_cattlewebapi.api"
        $AllowedGrantTypes = "authorization_code,password"
        $RedirectUris = "https://$projectUrl/"
        $PostLogoutRedirectUri = "https://$projectUrl/#/logged-out"
    
        # Optional parameters
        # $RequirePkce
        # $AllowOfflineAccess
        $AllowedCorsOrigins = "https://$projectUrl"
        $RoleFilter = "GTA*"
        
        # Act
        {
            & .\Client.ps1 -IdentityServerClientId $IdentityServerClientId -IdentityServerClientSecret $IdentityServerClientSecret -IdentityServerUrl $IdentityServerUrl -ResourceEnvironment $ResourceEnvironment -ClientId $ClientId -ClientName $ClientName -AllowedScopes $AllowedScopes -AllowedGrantTypes $AllowedGrantTypes -RedirectUris $RedirectUris -PostLogoutRedirectUri $PostLogoutRedirectUri -AllowedCorsOrigins $AllowedCorsOrigins -RoleFilter $RoleFilter  
        } | 
        
        # Asssert
        Should Not Throw
    }
}