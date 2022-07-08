# seges.github.identityserverautomation.client
```
# Secret contains special chars which expand easily in bash if you are not careful
# Which is why it is tunnelled, seemingly unnecessarily though env...
name: AgroId Client Registration
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        type: environment
        required: true 
jobs:
  client_registration:
    runs-on: ubuntu-22.04
    environment: ${{ inputs.environment }}
    steps:
      - name: Prod Variables
        env:
          SECRET: ${{ secrets.AGROIDENTITY_PRODUCTION_CLIENTSECRET }}
        if: ${{ startsWith(inputs.environment, 'prod') }}
        run: |
          echo "IdentityserverUrl=https://login.agroid.dk" >> $GITHUB_ENV
          echo "IdentityServerClientId=urn:prod-octopus-client" >> $GITHUB_ENV
          echo "IdentityServerClientSecret=${SECRET}" >> $GITHUB_ENV
          echo "ResourceName=https://${{inputs.environment}}-foling-api.seges.dk/" >> $GITHUB_ENV
      - name: PreProd Variables
        env:
          SECRET: ${{ secrets.AGROIDENTITY_PREPRODUCTION_CLIENTSECRET }}
        if: ${{ !startsWith(inputs.environment, 'prod') }}
        run: |
          echo "IdentityserverUrl=https://si-agroid-identityserver.segestest.dk" >> $GITHUB_ENV
          echo "IdentityServerClientId=urn:si-octopus-client" >> $GITHUB_ENV
          echo "IdentityServerClientSecret=${SECRET}" >> $GITHUB_ENV
          echo "ResourceName=https://${{inputs.environment}}-foling-api.segeswebsites.net/" >> $GITHUB_ENV
      - name: Propercase Env
        run: |
          echo "PropercaseEnv=${{inputs.environment}}" >>${GITHUB_ENV}
      - name: Lowercase Env
        run: |
          echo "LowercaseEnv=${PropercaseEnv,,}" >>${GITHUB_ENV}
      - name: ClientRegistration
        uses: segesdk/seges.github.identityserverautomation.client@master
        with:
          # Mandatory parameters
          IdentityServerClientId: ${{env.IdentityServerClientId}}
          IdentityServerClientSecret: "${{env.IdentityServerClientSecret}}"
          IdentityserverUrl: ${{env.IdentityserverUrl}}
          ResourceEnvironment: ${{env.LowercaseEnv}}
          ClientId: urn:${{env.LowercaseEnv}}-foling-client
          ClientName: ${{env.PropercaseEnv}} Foling Client
          AllowedScopes: openid role ${{env.LowercaseEnv}}.foling.default
          AllowedGrantTypes: authorization_code
          RedirectUris: https://localhost:8646
          PostLogoutRedirectUris: https://localhost:8646/signed-out
          # Optional parameters
          RequirePkce: 'true'
          AllowOfflineAccess: 'true'
          AllowedCorsOrigins: 'https://localhost:8646'
          RoleFilter: GTALCNotSet*
```
