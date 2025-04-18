trigger:
- main

pool:
  name: SelfHostedPool

stages:
- stage: Build
  displayName: 'Build Stage'
  jobs:
  - job: Build
    displayName: 'Build and Publish .NET 9 Application'
    steps:
    - checkout: self

    - task: UseDotNet@2
      displayName: 'Setup .NET 9'
      inputs:
        packageType: 'sdk'
        version: '9.0.x'
        installationPath: $(Agent.ToolsDirectory)/dotnet

    - script: |
        dotnet restore
        dotnet publish -c Release -o $(Build.ArtifactStagingDirectory)/PublishedApp
      displayName: 'Restore and Build'

    - task: PublishBuildArtifacts@1
      displayName: 'Upload Build Artifact'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/PublishedApp'
        artifactName: 'SalesApp'

- stage: Deploy
  displayName: 'Deploy Stage'
  dependsOn: Build
  jobs:
  - job: Deploy
    displayName: 'Deploy to IIS on Azure VM'
    steps:
    - task: DownloadBuildArtifacts@0
      displayName: 'Download Artifact'
      inputs:
        buildType: 'current'
        downloadType: 'single'
        artifactName: 'SalesApp'
        downloadPath: '$(Build.ArtifactStagingDirectory)/PublishedApp'

    - task: InstallSSHKey@0
      displayName: 'Install SSH Key'
      inputs:
        knownHostsEntry: $(KNOWN_HOSTS)
        sshKeySecureFile: 'SSH_PRIVATE_KEY'
        sshPassphrase: ''

    - script: |
        ssh-keyscan -H 20.81.164.12 >> ~/.ssh/known_hosts
        ssh -o BatchMode=yes -v vmadmin@20.81.164.12 "echo SSH connection verified!"
      displayName: 'Verify SSH Connection'

    - script: |
        ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command New-Item -ItemType Directory -Path 'C:\inetpub\wwwroot\SalesApp' -Force"
      displayName: 'Ensure Deployment Directory Exists'

    - task: PowerShell@2
      displayName: 'Copy Files to SalesApp'
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Stopping IIS to prevent file lock issues..."
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"Stop-Service -Name W3SVC -Force`""

          Write-Host "Removing old files inside SalesApp, but keeping the folder..."
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"Remove-Item -Path 'C:\inetpub\wwwroot\SalesApp\*' -Recurse -Force -ErrorAction SilentlyContinue`""

          Write-Host "Setting correct permissions (if needed)..."
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"icacls 'C:\inetpub\wwwroot\SalesApp' /grant vmadmin:F /inheritance:e /T`""

          Write-Host "Starting file transfer..."
          $sourcePath = "$(Build.ArtifactStagingDirectory)/PublishedApp"
          scp -v -r -o BatchMode=yes "$sourcePath/*" vmadmin@20.81.164.12:C:\\inetpub\\wwwroot\\

          Write-Host "Restarting IIS..."
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"Start-Service -Name W3SVC`""

          Write-Host "Deployment completed successfully!"


    - task: PowerShell@2
      displayName: 'Set IIS Permissions'
      inputs:
        targetType: 'inline'
        script: |
          Write-Host "Setting permissions for IIS..."
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"icacls 'C:\inetpub\wwwroot\SalesApp' /grant 'IIS_IUSRS:(OI)(CI)F' /T`""
          ssh -o BatchMode=yes vmadmin@20.81.164.12 "powershell -Command `"icacls 'C:\inetpub\wwwroot\SalesApp' /grant 'NT AUTHORITY\SYSTEM:(OI)(CI)F' /T`""
          Write-Host "Permissions set successfully"

    - script: |
        ssh -o BatchMode=yes vmadmin@20.81.164.12 "iisreset"
      displayName: 'Restart IIS'
