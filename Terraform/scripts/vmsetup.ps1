# Enable RDP
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0

# Install IIS and features
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45
Install-WindowsFeature -Name Web-ISAPI-Ext
Install-WindowsFeature -Name Web-ISAPI-Filter
Install-WindowsFeature -Name Web-Mgmt-Console

# Configure IIS permissions
$websitePath = 'C:\inetpub\wwwroot'
$acl = Get-Acl $websitePath
$iisUserRule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS_IUSRS', 'ReadAndExecute', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$acl.SetAccessRule($iisUserRule)
$appPoolRule = New-Object System.Security.AccessControl.FileSystemAccessRule('IIS AppPool\DefaultAppPool', 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$acl.SetAccessRule($appPoolRule)
Set-Acl -Path $websitePath -AclObject $acl

# Create default page
Add-Content -Path "$websitePath\index.html" -Value '<html><body><h1>IIS Ready</h1><p>VM setup complete</p></body></html>'

# Restart IIS
iisreset /restart